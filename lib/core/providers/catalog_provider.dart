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

  Future<void> loadHome({bool forceRefresh = false}) async {
    _loading = true;
    notifyListeners();
    await Future.wait([
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
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadHomeSection(
    String label,
    Future<void> Function() load,
  ) async {
    try {
      await load();
      debugPrint('CatalogProvider: loaded $label');
    } catch (e) {
      debugPrint('CatalogProvider: error loading $label — $e');
    }
  }

  Future<void> loadFeaturedItems({
    String? search,
    int? categoryId,
    bool forceRefresh = false,
  }) async {
    try {
      final params = <String, String>{'available': 'true'};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null) params['category'] = categoryId.toString();
      final data = await _api.get(
        '/menu-items/',
        queryParams: params,
        cacheTtl: catalogTtl,
        forceRefresh: forceRefresh,
      );
      _featuredItems = _extractResults(data, MenuItem.fromJson);
      notifyListeners();
    } catch (e) {
      debugPrint('CatalogProvider.loadFeaturedItems: $e');
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
      final data = await _api.get(
        '/menu-items/',
        queryParams: params,
        cacheTtl: catalogTtl,
        forceRefresh: forceRefresh,
      );
      _menuItems = _extractResults(data, MenuItem.fromJson);
      debugPrint(
        'CatalogProvider.loadMenuItems: loaded ${_menuItems.length} items',
      );
    } catch (e) {
      debugPrint('CatalogProvider.loadMenuItems: $e');
    }
    _loading = false;
    notifyListeners();
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
