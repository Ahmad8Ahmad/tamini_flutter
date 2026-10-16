import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../repositories/owner_repository.dart';

class OwnerProvider extends ChangeNotifier {
  final OwnerRepository _repo;
  List<Restaurant> _myRestaurants = [];
  List<MenuItem> _ownerMenu = [];
  bool _myRestaurantsLoading = false;
  bool _ownerLoading = false;
  String? _myRestaurantsError;
  String? _myRestaurantsRawResponse;

  OwnerProvider(this._repo);

  List<Restaurant> get myRestaurants => _myRestaurants;
  bool get myRestaurantsLoading => _myRestaurantsLoading;
  String? get myRestaurantsError => _myRestaurantsError;
  String? get myRestaurantsRawResponse => _myRestaurantsRawResponse;
  List<MenuItem> get ownerMenu => _ownerMenu;
  bool get ownerLoading => _ownerLoading;

  /// Drops cached catalog responses so the next public fetch reflects changes.
  void _invalidateCatalog() => _repo.invalidateCatalog();

  /// Clears the owner's restaurants and menu on session end, so swapping
  /// accounts on one device never shows the previous owner's data.
  void reset() {
    _myRestaurants = [];
    _ownerMenu = [];
    _myRestaurantsLoading = false;
    _ownerLoading = false;
    _myRestaurantsError = null;
    _myRestaurantsRawResponse = null;
    notifyListeners();
  }

  Future<void> loadMyRestaurants({bool forceRefresh = false}) async {
    _myRestaurantsLoading = true;
    _myRestaurantsError = null;
    _myRestaurantsRawResponse = null;
    notifyListeners();
    try {
      final result = await _repo.fetchMyRestaurants(forceRefresh: forceRefresh);
      _myRestaurantsRawResponse = result.raw;
      _myRestaurants = result.restaurants;
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
      _ownerMenu = await _repo.fetchMenuItems(restaurantId);
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
    try {
      final updated = await _repo.updateRestaurant(
        id: id,
        name: name,
        description: description,
        address: address,
        phone: phone,
        logo: logo,
        coverImage: coverImage,
      );
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
      final updated = await _repo.setRestaurantActive(id: id, isActive: isActive);
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
      final updated = await _repo.updateDeliverySettings(
        id: id,
        deliveryFee: deliveryFee,
        deliveryFeePerKm: deliveryFeePerKm,
        minOrderAmount: minOrderAmount,
        deliveryRadiusKm: deliveryRadiusKm,
        hasOwnDelivery: hasOwnDelivery,
      );
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
    try {
      final item = await _repo.createMenuItem(
        restaurantId: restaurantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        isAvailable: isAvailable,
        image: image,
      );
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
    try {
      final item = await _repo.updateMenuItem(
        id: id,
        restaurantId: restaurantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        isAvailable: isAvailable,
        image: image,
      );
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
      await _repo.deleteMenuItem(id);
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
      final item = await _repo.setDiscount(menuItemId, discountPrice);
      _invalidateCatalog();
      return _replaceInOwnerMenu(item);
    } catch (e) {
      debugPrint('OwnerProvider.setDiscount: $e');
      return null;
    }
  }

  Future<bool> clearDiscount(int menuItemId) async {
    try {
      final item = await _repo.clearDiscount(menuItemId);
      _invalidateCatalog();
      _replaceInOwnerMenu(item);
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
      final item = await _repo.setMenuItemAvailability(
        id: id,
        isAvailable: isAvailable,
      );
      _replaceInOwnerMenu(item);
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
}
