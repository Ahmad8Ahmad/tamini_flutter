import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/json.dart';

/// Result of placing an order: the created order plus the redirect URL when a
/// card payment flow was initiated.
class CheckoutResult {
  final Order? order;
  final String? paymentUrl;

  CheckoutResult({this.order, this.paymentUrl});
}

/// Data access for orders and their live tracking.
///
/// Kept behind an interface so providers can be exercised in tests with an
/// in-memory fake rather than a live HTTP client.
abstract class OrderRepository {
  Future<List<Order>> fetchOrders();

  Future<Order> updateStatus(int orderId, String status);

  Future<OrderTracking> fetchTracking(int orderId);

  Future<CheckoutResult> checkout(Map<String, dynamic> body);
}

class ApiOrderRepository implements OrderRepository {
  final ApiClient _api;

  ApiOrderRepository(this._api);

  @override
  Future<List<Order>> fetchOrders() async {
    final data = await _api.get('/orders/');
    return extractResults(data, Order.fromJson);
  }

  @override
  Future<Order> updateStatus(int orderId, String status) async {
    final data = await _api.patch(
      '/orders/$orderId/update-status/',
      body: {'status': status},
    );
    return Order.fromJson(data);
  }

  @override
  Future<OrderTracking> fetchTracking(int orderId) async {
    return OrderTracking.fromJson(await _api.get('/orders/$orderId/tracking/'));
  }

  @override
  Future<CheckoutResult> checkout(Map<String, dynamic> body) async {
    final data = await _api.post('/orders/checkout/', body: body);
    return CheckoutResult(
      order: Order.fromJson(data),
      paymentUrl: data['payment_url'] is String ? data['payment_url'] as String : null,
    );
  }
}
