import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class OwnerProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Restaurant> _myRestaurants = [];
  List<MenuItem> _ownerMenu = [];
  bool _myRestaurantsLoading = false;
  bool _ownerLoading = false;
  String? _myRestaurantsError;
  String? _myRestaurantsRawResponse;

  OwnerProvider(this._api);

  List<Restaurant> get myRestaurants => _myRestaurants;
  bool get myRestaurantsLoading => _myRestaurantsLoading;
  String? get myRestaurantsError => _myRestaurantsError;
  String? get myRestaurantsRawResponse => _myRestaurantsRawResponse;
  List<MenuItem> get ownerMenu => _ownerMenu;
  bool get ownerLoading => _ownerLoading;

  static const Duration _catalogTtl = Duration(seconds: 60);

  /// Drops cached catalog responses so the next public fetch reflects changes.
  void _invalidateCatalog() => _api.clearCatalogCache();

  Future<void> loadMyRestaurants({bool forceRefresh = false}) async {
    _myRestaurantsLoading = true;
    _myRestaurantsError = null;
    _myRestaurantsRawResponse = null;
    notifyListeners();
    try {
      final data = await _api.get(
        '/restaurants/my/',
        cacheTtl: _catalogTtl,
        forceRefresh: forceRefresh,
      );
      _myRestaurantsRawResponse = data.toString();
      _myRestaurants = _extractResults(data, Restaurant.fromJson);
      _myRestaurantsError = null;
      debugPrint(
        'OwnerProvider.loadMyRestaurants: ${_myRestaurants.length} owned',
      );
    } catch (e) {
      debugPrint('OwnerProvider.loadMyRestaurants: $e');
      _myRestaurants = [];
      _myRestaurantsError = e.toString();
    }
    _myRestaurantsLoading = false;
    notifyListeners();
  }

  Future<void> loadOwnerMenu(int restaurantId) async {
    _ownerLoading = true;
    notifyListeners();
    try {
      final data = await _api.get(
        '/menu-items/',
        queryParams: {'restaurant': restaurantId.toString()},
      );
      _ownerMenu = _extractResults(data, MenuItem.fromJson);
      debugPrint(
        'OwnerProvider.loadOwnerMenu: loaded ${_ownerMenu.length} items',
      );
    } catch (e) {
      debugPrint('OwnerProvider.loadOwnerMenu: $e');
    }
    _ownerLoading = false;
    notifyListeners();
  }

  Future<Restaurant?> updateRestaurant({
    required int id,
    required String name,
    String? description,
    String? address,
    String? phone,
    XFile? logo,
    XFile? coverImage,
  }) async {
    final fields = <String, String>{
      'name': name,
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      if (address != null && address.trim().isNotEmpty) 'address': address,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
    };
    try {
      final files = <http.MultipartFile>[];
      if (logo != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'logo',
            await logo.readAsBytes(),
            filename: logo.name,
          ),
        );
      }
      if (coverImage != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'cover_image',
            await coverImage.readAsBytes(),
            filename: coverImage.name,
          ),
        );
      }
      final data = files.isEmpty
          ? await _api.patch('/restaurants/$id/', body: fields)
          : await _api.patchMultipart(
              '/restaurants/$id/',
              fields: fields,
              files: files,
            );
      final updated = Restaurant.fromJson(data);
      _upsertMyRestaurants(updated);
      _invalidateCatalog();
      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint('OwnerProvider.updateRestaurant: $e');
      return null;
    }
  }

  Future<Restaurant?> setRestaurantActive({
    required int id,
    required bool isActive,
  }) async {
    try {
      final data = await _api.patch(
        '/restaurants/$id/',
        body: {'is_active': isActive},
      );
      final updated = Restaurant.fromJson(data);
      _upsertMyRestaurants(updated);
      _invalidateCatalog();
      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint('OwnerProvider.setRestaurantActive: $e');
      return null;
    }
  }

  Future<Restaurant?> updateDeliverySettings({
    required int id,
    double? deliveryFee,
    double? deliveryFeePerKm,
    double? minOrderAmount,
    double? deliveryRadiusKm,
    bool? hasOwnDelivery,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (deliveryFee != null) body['delivery_fee'] = deliveryFee;
      if (deliveryFeePerKm != null) {
        body['delivery_fee_per_km'] = deliveryFeePerKm;
      }
      if (minOrderAmount != null) body['min_order_amount'] = minOrderAmount;
      if (deliveryRadiusKm != null) {
        body['delivery_radius_km'] = deliveryRadiusKm;
      }
      if (hasOwnDelivery != null) body['has_own_delivery'] = hasOwnDelivery;
      final data = await _api.patch('/restaurants/$id/', body: body);
      final updated = Restaurant.fromJson(data);
      _upsertMyRestaurants(updated);
      _invalidateCatalog();
      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint('OwnerProvider.updateDeliverySettings: $e');
      return null;
    }
  }

  void _upsertMyRestaurants(Restaurant updated) {
    final i = _myRestaurants.indexWhere((r) => r.id == updated.id);
    if (i != -1) {
      _myRestaurants[i] = updated;
    } else {
      _myRestaurants.add(updated);
    }
  }

  Future<MenuItem?> createMenuItem({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  }) async {
    final fields = _menuItemFields(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      isAvailable: isAvailable,
    );
    try {
      final data = await _sendMenuItemRequest(
        path: '/menu-items/',
        fields: fields,
        image: image,
        isCreate: true,
      );
      final item = MenuItem.fromJson(data);
      _ownerMenu.insert(0, item);
      _invalidateCatalog();
      notifyListeners();
      return item;
    } catch (e) {
      debugPrint('OwnerProvider.createMenuItem: $e');
      return null;
    }
  }

  Future<MenuItem?> updateMenuItem({
    required int id,
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  }) async {
    final fields = _menuItemFields(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      isAvailable: isAvailable,
    );
    try {
      final data = await _sendMenuItemRequest(
        path: '/menu-items/$id/',
        fields: fields,
        image: image,
        isCreate: false,
      );
      final item = MenuItem.fromJson(data);
      final i = _ownerMenu.indexWhere((e) => e.id == id);
      if (i != -1) {
        _ownerMenu[i] = item;
      } else {
        _ownerMenu.insert(0, item);
      }
      _invalidateCatalog();
      notifyListeners();
      return item;
    } catch (e) {
      debugPrint('OwnerProvider.updateMenuItem: $e');
      return null;
    }
  }

  Future<bool> deleteMenuItem(int id) async {
    try {
      await _api.delete('/menu-items/$id/');
      _ownerMenu.removeWhere((e) => e.id == id);
      _invalidateCatalog();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('OwnerProvider.deleteMenuItem: $e');
      return false;
    }
  }

  Future<MenuItem?> setDiscount(int menuItemId, double discountPrice) async {
    try {
      final data = await _api.patch(
        '/menu-items/$menuItemId/',
        body: {'discount_price': _priceString(discountPrice)},
      );
      _invalidateCatalog();
      return _replaceInOwnerMenu(MenuItem.fromJson(data));
    } catch (e) {
      debugPrint('OwnerProvider.setDiscount: $e');
      return null;
    }
  }

  Future<bool> clearDiscount(int menuItemId) async {
    try {
      final data = await _api.patch(
        '/menu-items/$menuItemId/',
        body: {'discount_price': null},
      );
      _invalidateCatalog();
      _replaceInOwnerMenu(MenuItem.fromJson(data));
      return true;
    } catch (e) {
      debugPrint('OwnerProvider.clearDiscount: $e');
      return false;
    }
  }

  Future<bool> setMenuItemAvailability({
    required int id,
    required bool isAvailable,
  }) async {
    try {
      final data = await _api.patch(
        '/menu-items/$id/',
        body: {'is_available': isAvailable},
      );
      _replaceInOwnerMenu(MenuItem.fromJson(data));
      _invalidateCatalog();
      return true;
    } catch (e) {
      debugPrint('OwnerProvider.setMenuItemAvailability: $e');
      return false;
    }
  }

  MenuItem _replaceInOwnerMenu(MenuItem item) {
    final i = _ownerMenu.indexWhere((e) => e.id == item.id);
    if (i != -1) {
      _ownerMenu[i] = item;
    } else {
      _ownerMenu.insert(0, item);
    }
    notifyListeners();
    return item;
  }

  Map<String, String> _menuItemFields({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    required bool isAvailable,
  }) {
    return {
      'restaurant': restaurantId.toString(),
      'category': categoryId.toString(),
      'name': name,
      'price': _priceString(price),
      'is_available': isAvailable.toString(),
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      if (discountPrice != null && discountPrice > 0)
        'discount_price': _priceString(discountPrice),
    };
  }

  Future<Map<String, dynamic>> _sendMenuItemRequest({
    required String path,
    required Map<String, String> fields,
    XFile? image,
    required bool isCreate,
  }) async {
    if (image == null) {
      return isCreate
          ? _api.post(path, body: fields)
          : _api.patch(path, body: fields);
    }
    final bytes = await image.readAsBytes();
    final file = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
    );
    return isCreate
        ? _api.postMultipart(path, fields: fields, files: [file])
        : _api.patchMultipart(path, fields: fields, files: [file]);
  }

  String _priceString(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}

List<T> _extractResults<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data is List ? data : data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}
