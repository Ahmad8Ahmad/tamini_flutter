import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/json.dart';

/// Data access for the driver app: the shared board, the driver's own
/// deliveries, and the order detail shown alongside an active run.
///
/// Kept behind an interface so providers can be exercised in tests with an
/// in-memory fake rather than a live HTTP client.
abstract class DeliveryRepository {
  Future<List<Delivery>> fetchAvailable();

  Future<List<Delivery>> fetchMine();

  Future<Delivery> accept(int id);

  Future<void> reject(int id);

  Future<Delivery> complete(int id);

  Future<void> updateLocation(int id, double lat, double lng);

  Future<Order> fetchOrderDetail(int orderId);
}

class ApiDeliveryRepository implements DeliveryRepository {
  final ApiClient _api;

  ApiDeliveryRepository(this._api);

  @override
  Future<List<Delivery>> fetchAvailable() async {
    return extractResults(
      await _api.get('/deliveries/available/'),
      Delivery.fromJson,
    );
  }

  @override
  Future<List<Delivery>> fetchMine() async {
    return extractResults(await _api.get('/deliveries/'), Delivery.fromJson);
  }

  @override
  Future<Delivery> accept(int id) async {
    return Delivery.fromJson(await _api.post('/deliveries/$id/accept/'));
  }

  @override
  Future<void> reject(int id) => _api.post('/deliveries/$id/reject/');

  @override
  Future<Delivery> complete(int id) async {
    return Delivery.fromJson(await _api.post('/deliveries/$id/complete/'));
  }

  @override
  Future<void> updateLocation(int id, double lat, double lng) {
    return _api.patch(
      '/deliveries/$id/update-location/',
      body: {'current_lat': lat.toString(), 'current_lng': lng.toString()},
    );
  }

  @override
  Future<Order> fetchOrderDetail(int orderId) async {
    return Order.fromJson(await _api.get('/orders/$orderId/'));
  }
}
