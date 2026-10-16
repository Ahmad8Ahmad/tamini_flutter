import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/providers/catalog_provider.dart';
import 'package:tamini/core/repositories/catalog_repository.dart';

/// In-memory [CatalogRepository] that records the search term it was asked for.
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({this.results = const [], this.failSearch = false});

  final List<Restaurant> results;
  final bool failSearch;

  int searchCalls = 0;
  String? lastSearch;
  bool? lastForceRefresh;

  @override
  Future<List<Restaurant>> fetchRestaurants({
    bool forceRefresh = false,
    String? search,
  }) async {
    searchCalls++;
    lastSearch = search;
    lastForceRefresh = forceRefresh;
    if (failSearch) throw Exception('boom');
    return results;
  }

  @override
  Future<SiteContent> fetchSiteContent({bool forceRefresh = false}) async =>
      SiteContent();

  @override
  Future<List<Category>> fetchCategories({bool forceRefresh = false}) async =>
      const [];

  @override
  Future<List<Restaurant>> fetchTrendyRestaurants({
    bool forceRefresh = false,
  }) async => const [];

  @override
  Future<List<HeroBanner>> fetchBanners({bool forceRefresh = false}) async =>
      const [];

  @override
  Future<MenuItemsPage> fetchMenuItemsPage({
    Map<String, String> params = const {},
    required int page,
    bool forceRefresh = false,
  }) async => const MenuItemsPage(items: <MenuItem>[], hasMore: false);

  @override
  void invalidateCache() {}
}

void main() {
  test('searchRestaurants queries the server and exposes the results', () async {
    final repo = FakeCatalogRepository(
      results: [Restaurant(id: 1, name: 'Pizza Place')],
    );
    final provider = CatalogProvider(repo);

    expect(provider.isSearching, isFalse);

    final future = provider.searchRestaurants('  pizza  ');
    expect(provider.searchLoading, isTrue);
    await future;

    expect(repo.searchCalls, 1);
    expect(repo.lastSearch, 'pizza');
    expect(repo.lastForceRefresh, isTrue);
    expect(provider.isSearching, isTrue);
    expect(provider.searchQuery, 'pizza');
    expect(provider.searchLoading, isFalse);
    expect(provider.searchResults.map((r) => r.id), [1]);
  });

  test('an empty query clears the search without hitting the server', () async {
    final repo = FakeCatalogRepository(
      results: [Restaurant(id: 1, name: 'Pizza Place')],
    );
    final provider = CatalogProvider(repo);
    await provider.searchRestaurants('pizza');
    expect(provider.isSearching, isTrue);

    await provider.searchRestaurants('   ');

    expect(repo.searchCalls, 1, reason: 'blank query must not call the server');
    expect(provider.isSearching, isFalse);
    expect(provider.searchResults, isEmpty);
  });

  test('a failed search clears the results and stops loading', () async {
    final repo = FakeCatalogRepository(failSearch: true);
    final provider = CatalogProvider(repo);

    await provider.searchRestaurants('pizza');

    expect(provider.searchLoading, isFalse);
    expect(provider.searchResults, isEmpty);
    expect(provider.isSearching, isTrue);
  });
}
