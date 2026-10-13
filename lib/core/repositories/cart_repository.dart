import '../api/api_client.dart';
import '../models/models.dart';

/// Data access for the shopping cart.
///
/// Providers depend on this abstraction instead of [ApiClient] directly so
/// unit tests can swap in an in-memory fake without any HTTP or secure-storage
/// plugin. The concrete [ApiCartRepository] is a thin wrapper that maps the
/// cart endpoints onto parsed [Cart]/[CartQuote] models.
abstract class CartRepository {
  Future<Cart> fetchCart();

  Future<Cart> addItem(int menuItemId, {int quantity = 1});

  Future<Cart> updateItem(int itemId, int quantity);

  Future<Cart> removeItem(int itemId);

  Future<void> clear();

  /// Server-authoritative price breakdown for the current cart. Pass
  /// [lat]/[lng] when the delivery location is known so the distance-based
  /// delivery fee is included.
  Future<CartQuote> fetchQuote({double? lat, double? lng});
}

class ApiCartRepository implements CartRepository {
  final ApiClient _api;

  ApiCartRepository(this._api);

  @override
  Future<Cart> fetchCart() async {
    return Cart.fromJson(await _api.get('/cart/'));
  }

  @override
  Future<Cart> addItem(int menuItemId, {int quantity = 1}) async {
    final data = await _api.post(
      '/cart/add/',
      body: {'menu_item_id': menuItemId, 'quantity': quantity},
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> updateItem(int itemId, int quantity) async {
    final data = await _api.put(
      '/cart/item/$itemId/',
      body: {'quantity': quantity},
    );
    return Cart.fromJson(data);
  }

  @override
  Future<Cart> removeItem(int itemId) async {
    return Cart.fromJson(await _api.delete('/cart/item/$itemId/remove/'));
  }

  @override
  Future<void> clear() async {
    await _api.delete('/cart/clear/');
  }

  @override
  Future<CartQuote> fetchQuote({double? lat, double? lng}) async {
    final query = <String, String>{};
    if (lat != null) query['delivery_lat'] = lat.toString();
    if (lng != null) query['delivery_lng'] = lng.toString();
    final data = await _api.get(
      '/cart/quote/',
      queryParams: query.isEmpty ? null : query,
    );
    return CartQuote.fromJson(data);
  }
}
