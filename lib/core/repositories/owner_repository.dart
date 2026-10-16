import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/formatters.dart';
import '../utils/json.dart';
import 'catalog_repository.dart';

/// Result of loading the owner's restaurants: the parsed list plus the raw
/// response body, which the owner UI shows as a debugging aid when the server
/// returns an empty list.
class OwnerRestaurants {
  final List<Restaurant> restaurants;
  final String raw;

  const OwnerRestaurants({required this.restaurants, required this.raw});
}

/// Write access to a restaurant owner's own restaurants and menu.
///
/// Providers depend on this interface, not [ApiClient], so tests can exercise
/// owner state management with an in-memory fake. It also keeps multipart
/// construction (and the `http` package) out of the provider layer.
abstract class OwnerRepository {
  Future<OwnerRestaurants> fetchMyRestaurants({bool forceRefresh = false});

  Future<List<MenuItem>> fetchMenuItems(int restaurantId);

  Future<Restaurant> updateRestaurant({
    required int id,
    required String name,
    String? description,
    String? address,
    String? phone,
    XFile? logo,
    XFile? coverImage,
  });

  Future<Restaurant> setRestaurantActive({
    required int id,
    required bool isActive,
  });

  Future<Restaurant> updateDeliverySettings({
    required int id,
    double? deliveryFee,
    double? deliveryFeePerKm,
    double? minOrderAmount,
    double? deliveryRadiusKm,
    bool? hasOwnDelivery,
  });

  Future<MenuItem> createMenuItem({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  });

  Future<MenuItem> updateMenuItem({
    required int id,
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  });

  Future<void> deleteMenuItem(int id);

  Future<MenuItem> setDiscount(int menuItemId, double discountPrice);

  Future<MenuItem> clearDiscount(int menuItemId);

  Future<MenuItem> setMenuItemAvailability({
    required int id,
    required bool isAvailable,
  });

  /// Drops the cached public catalog responses so the next public fetch
  /// reflects owner-side changes.
  void invalidateCatalog();
}

class ApiOwnerRepository implements OwnerRepository {
  final ApiClient _api;

  ApiOwnerRepository(this._api);

  @override
  Future<OwnerRestaurants> fetchMyRestaurants({
    bool forceRefresh = false,
  }) async {
    final data = await _api.get(
      '/restaurants/my/',
      cacheTtl: catalogTtl,
      forceRefresh: forceRefresh,
    );
    return OwnerRestaurants(
      restaurants: extractResults(data, Restaurant.fromJson),
      raw: data.toString(),
    );
  }

  @override
  Future<List<MenuItem>> fetchMenuItems(int restaurantId) async {
    final data = await _api.get(
      '/menu-items/',
      queryParams: {'restaurant': restaurantId.toString()},
    );
    return extractResults(data, MenuItem.fromJson);
  }

  @override
  Future<Restaurant> updateRestaurant({
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
    return Restaurant.fromJson(data);
  }

  @override
  Future<Restaurant> setRestaurantActive({
    required int id,
    required bool isActive,
  }) async {
    final data = await _api.patch(
      '/restaurants/$id/',
      body: {'is_active': isActive},
    );
    return Restaurant.fromJson(data);
  }

  @override
  Future<Restaurant> updateDeliverySettings({
    required int id,
    double? deliveryFee,
    double? deliveryFeePerKm,
    double? minOrderAmount,
    double? deliveryRadiusKm,
    bool? hasOwnDelivery,
  }) async {
    final body = <String, dynamic>{};
    if (deliveryFee != null) body['delivery_fee'] = deliveryFee;
    if (deliveryFeePerKm != null) body['delivery_fee_per_km'] = deliveryFeePerKm;
    if (minOrderAmount != null) body['min_order_amount'] = minOrderAmount;
    if (deliveryRadiusKm != null) body['delivery_radius_km'] = deliveryRadiusKm;
    if (hasOwnDelivery != null) body['has_own_delivery'] = hasOwnDelivery;
    final data = await _api.patch('/restaurants/$id/', body: body);
    return Restaurant.fromJson(data);
  }

  @override
  Future<MenuItem> createMenuItem({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  }) async {
    final data = await _sendMenuItemRequest(
      path: '/menu-items/',
      fields: _menuItemFields(
        restaurantId: restaurantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        isAvailable: isAvailable,
      ),
      image: image,
      isCreate: true,
    );
    return MenuItem.fromJson(data);
  }

  @override
  Future<MenuItem> updateMenuItem({
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
    final data = await _sendMenuItemRequest(
      path: '/menu-items/$id/',
      fields: _menuItemFields(
        restaurantId: restaurantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        isAvailable: isAvailable,
      ),
      image: image,
      isCreate: false,
    );
    return MenuItem.fromJson(data);
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await _api.delete('/menu-items/$id/');
  }

  @override
  Future<MenuItem> setDiscount(int menuItemId, double discountPrice) async {
    final data = await _api.patch(
      '/menu-items/$menuItemId/',
      body: {'discount_price': formatAmount(discountPrice)},
    );
    return MenuItem.fromJson(data);
  }

  @override
  Future<MenuItem> clearDiscount(int menuItemId) async {
    final data = await _api.patch(
      '/menu-items/$menuItemId/',
      body: {'discount_price': null},
    );
    return MenuItem.fromJson(data);
  }

  @override
  Future<MenuItem> setMenuItemAvailability({
    required int id,
    required bool isAvailable,
  }) async {
    final data = await _api.patch(
      '/menu-items/$id/',
      body: {'is_available': isAvailable},
    );
    return MenuItem.fromJson(data);
  }

  @override
  void invalidateCatalog() => _api.clearCatalogCache();

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
      'price': formatAmount(price),
      'is_available': isAvailable.toString(),
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      if (discountPrice != null && discountPrice > 0)
        'discount_price': formatAmount(discountPrice),
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
}
