import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class CatalogProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Restaurant> _restaurants = [];
  List<Restaurant> _trendyRestaurants = [];
  List<MenuItem> _menuItems = [];
  List<MenuItem> _featuredItems = [];
  List<HeroBanner> _banners = [];
  List<Category> _categories = [];
  SiteContent? _siteContent;
  bool _loading = false;

  CatalogProvider(this._api);

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get trendyRestaurants => _trendyRestaurants;
  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get featuredItems => _featuredItems;
  List<HeroBanner> get banners => _banners;
  List<Category> get categories => _categories;
  SiteContent? get siteContent => _siteContent;
  bool get loading => _loading;

  static const Duration catalogTtl = Duration(seconds: 60);

  /// Menu lists are fetched in pages instead of downloading the whole catalog
  /// in one request. Capped so a backend with a huge catalog can never stall
  /// the app or rebuild the UI with an unbounded payload.
  static const int _menuPageSize = 50;
  static const int _maxMenuPages = 5;

  bool _homeLoading = false;
  bool _featuredLoading = false;
  DateTime? _homeLoadedAt;
  DateTime? _featuredLoadedAt;
  Map<String, String>? _featuredParams;

  bool get _homeFresh =>
      _homeLoadedAt != null &&
      DateTime.now().difference(_homeLoadedAt!) < catalogTtl;

  bool get _featuredFresh =>
      _featuredLoadedAt != null &&
      DateTime.now().difference(_featuredLoadedAt!) < catalogTtl;

  Future<void> loadHome({bool forceRefresh = false}) async {
    if (forceRefresh) _homeLoadedAt = null;
    if (!forceRefresh && _homeLoading) return;
    if (!forceRefresh && _homeFresh) {
      debugPrint('CatalogProvider.loadHome: skipped (fresh cache)');
      return;
    }
    _homeLoading = true;
    _loading = true;
    notifyListeners();
    final successes = await Future.wait([
      _loadHomeSection('site content', () async {
        final scData = await _api.get(
          '/site-content/current/',
          cacheTtl: catalogTtl,
          forceRefresh: forceRefresh,
        );
        _siteContent = SiteContent.fromJson(scData);
      }),
      _loadHomeSection('categories', () async {
        final cData = await _api.get(
          '/categories/',
          queryParams: {'global': 'true'},
          cacheTtl: catalogTtl,
          forceRefresh: forceRefresh,
        );
        _categories = _extractResults(cData, Category.fromJson);
      }),
      _loadHomeSection('trendy restaurants', () async {
        final tData = await _api.get(
          '/restaurants/',
          queryParams: {'trendy': 'true'},
          cacheTtl: catalogTtl,
          forceRefresh: forceRefresh,
        );
        _trendyRestaurants = _extractResults(tData, Restaurant.fromJson);
      }),
      _loadHomeSection('restaurants', () async {
        final rData = await _api.get(
          '/restaurants/',
          cacheTtl: catalogTtl,
          forceRefresh: forceRefresh,
        );
        _restaurants = _extractResults(rData, Restaurant.fromJson);
        if (_restaurants.isEmpty) {
          debugPrint(
            'CatalogProvider: response keys = ${rData.keys.join(", ")}',
          );
        }
      }),
      _loadHomeSection('banners', () async {
        final bData = await _api.get(
          '/banners/',
          cacheTtl: catalogTtl,
          forceRefresh: forceRefresh,
        );
        _banners = _extractResults(bData, HeroBanner.fromJson);
        if (_banners.isEmpty) {
          debugPrint(
            'CatalogProvider: banner response keys = ${bData.keys.join(", ")}',
          );
        }
      }),
    ]);
    _homeLoading = false;
    _loading = false;
    // Only treat the catalog as fresh (and skip re-fetches) when some section
    // actually loaded; a totally failed cold start should be retried on next
    // resume instead of showing an empty home for the whole TTL.
    if (successes.contains(true)) _homeLoadedAt = DateTime.now();
    notifyListeners();
  }

  Future<bool> _loadHomeSection(
    String label,
    Future<void> Function() load,
  ) async {
    try {
      await load();
      debugPrint('CatalogProvider: loaded $label');
      return true;
    } catch (e) {
      debugPrint('CatalogProvider: error loading $label — $e');
      return false;
    }
  }

  Future<void> loadFeaturedItems({
    String? search,
    int? categoryId,
    bool forceRefresh = false,
  }) async {
    final params = <String, String>{'available': 'true'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['category'] = categoryId.toString();
    if (forceRefresh) {
      _featuredLoadedAt = null;
    } else if (_featuredLoading ||
        (_featuredFresh &&
            mapEquals(_featuredParams, params) &&
            search == null &&
            categoryId == null)) {
      return;
    }
    _featuredLoading = true;
    try {
      _featuredItems = await _fetchAllMenuItems(params, forceRefresh);
      _featuredParams = params;
      _featuredLoadedAt = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('CatalogProvider.loadFeaturedItems: $e');
    } finally {
      _featuredLoading = false;
    }
  }

  Future<void> loadMenuItems({
    int? restaurantId,
    String? search,
    bool forceRefresh = false,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (restaurantId != null) params['restaurant'] = restaurantId.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;
      _menuItems = await _fetchAllMenuItems(params, forceRefresh);
      debugPrint(
        'CatalogProvider.loadMenuItems: loaded ${_menuItems.length} items',
      );
    } catch (e) {
      debugPrint('CatalogProvider.loadMenuItems: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Fetches [MenuItems] page by page so a cold/slow server only ever has to
  /// return bounded chunks. Follows `next`/`count` from the DRF pagination
  /// metadata and stops at [_maxMenuPages] as a hard safety cap.
  Future<List<MenuItem>> _fetchAllMenuItems(
    Map<String, String> params,
    bool forceRefresh,
  ) async {
    final items = <MenuItem>[];
    for (var page = 1; page <= _maxMenuPages; page++) {
      final data = await _api.get(
        '/menu-items/',
        queryParams: {
          ...params,
          'page': '$page',
          'page_size': '$_menuPageSize',
        },
        cacheTtl: catalogTtl,
        forceRefresh: forceRefresh,
      );
      final batch = _extractResults(data, MenuItem.fromJson);
      if (batch.isEmpty) break;
      items.addAll(batch);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final count = data['count'];
      if (count is int && items.length >= count) break;
    }
    return items;
  }

  /// Called by OwnerProvider after mutations to refresh public catalog data.
  void invalidateCatalog() => _api.clearCatalogCache();

  /// Updates a restaurant in all public lists (called after owner edits).
  void upsertRestaurant(Restaurant updated) {
    void upsert(List<Restaurant> list) {
      final i = list.indexWhere((r) => r.id == updated.id);
      if (i != -1) {
        list[i] = updated;
      } else {
        list.add(updated);
      }
    }

    upsert(_restaurants);
    upsert(_trendyRestaurants);
    notifyListeners();
  }
}

List<T> _extractResults<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data is List ? data : data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}
