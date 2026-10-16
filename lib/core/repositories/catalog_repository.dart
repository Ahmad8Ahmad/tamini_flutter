import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/json.dart';

/// How long catalog reads are cached in memory (both by the API client and by
/// providers deciding whether a refresh is worthwhile).
const Duration catalogTtl = Duration(seconds: 60);

/// Number of menu items requested per page. The catalog is paged instead of
/// downloaded in one shot so a slow server only ever returns bounded chunks.
const int menuPageSize = 50;

/// One page of the paged menu-items endpoint.
class MenuItemsPage {
  final List<MenuItem> items;

  /// Whether the server advertised a further page (`next` was non-empty).
  final bool hasMore;

  /// Total item count reported by the server, when present, so the caller can
  /// stop early instead of walking every page.
  final int? count;

  const MenuItemsPage({required this.items, required this.hasMore, this.count});
}

/// Read access to the public catalog (restaurants, menu, categories, banners).
///
/// Providers depend on this interface, not [ApiClient], so tests can serve
/// canned catalog data without touching the network.
abstract class CatalogRepository {
  Future<SiteContent> fetchSiteContent({bool forceRefresh = false});

  Future<List<Category>> fetchCategories({bool forceRefresh = false});

  Future<List<Restaurant>> fetchTrendyRestaurants({bool forceRefresh = false});

  Future<List<Restaurant>> fetchRestaurants({
    bool forceRefresh = false,
    String? search,
  });

  Future<List<HeroBanner>> fetchBanners({bool forceRefresh = false});

  Future<MenuItemsPage> fetchMenuItemsPage({
    Map<String, String> params,
    required int page,
    bool forceRefresh = false,
  });

  /// Drops the in-memory GET cache so the next read hits the network.
  void invalidateCache();
}

class ApiCatalogRepository implements CatalogRepository {
  final ApiClient _api;

  ApiCatalogRepository(this._api);

  @override
  Future<SiteContent> fetchSiteContent({bool forceRefresh = false}) async {
    final data = await _api.get(
      '/site-content/current/',
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return SiteContent.fromJson(data);
  }

  @override
  Future<List<Category>> fetchCategories({bool forceRefresh = false}) async {
    final data = await _api.get(
      '/categories/',
      queryParams: {'global': 'true'},
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return extractResults(data, Category.fromJson);
  }

  @override
  Future<List<Restaurant>> fetchTrendyRestaurants({
    bool forceRefresh = false,
  }) async {
    final data = await _api.get(
      '/restaurants/',
      queryParams: {'trendy': 'true'},
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return extractResults(data, Restaurant.fromJson);
  }

  @override
  Future<List<Restaurant>> fetchRestaurants({
    bool forceRefresh = false,
    String? search,
  }) async {
    final query = search?.trim();
    final data = await _api.get(
      '/restaurants/',
      queryParams: (query != null && query.isNotEmpty)
          ? {'search': query}
          : null,
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return extractResults(data, Restaurant.fromJson);
  }

  @override
  Future<List<HeroBanner>> fetchBanners({bool forceRefresh = false}) async {
    final data = await _api.get(
      '/banners/',
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return extractResults(data, HeroBanner.fromJson);
  }

  @override
  Future<MenuItemsPage> fetchMenuItemsPage({
    Map<String, String> params = const {},
    required int page,
    bool forceRefresh = false,
  }) async {
    final data = await _api.get(
      '/menu-items/',
      queryParams: {
        ...params,
        'page': '$page',
        'page_size': '$menuPageSize',
      },
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    final items = extractResults(data, MenuItem.fromJson);
    final next = data['next'];
    final count = data['count'];
    return MenuItemsPage(
      items: items,
      hasMore: next is String && next.isNotEmpty,
      count: count is int ? count : null,
    );
  }

  @override
  void invalidateCache() => _api.clearCatalogCache();
}
