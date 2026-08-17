import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class DeliveryProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Delivery> _available = [];
  List<Delivery> _myDeliveries = [];
  Order? _activeOrderDetail;
  bool _loadingAvailable = false;
  bool _loadingMyDeliveries = false;
  bool _loadingDetail = false;

  DeliveryProvider(this._api);

  List<Delivery> get available => _available;
  List<Delivery> get myDeliveries => _myDeliveries;
  Order? get activeOrderDetail => _activeOrderDetail;
  bool get loadingAvailable => _loadingAvailable;
  bool get loadingMyDeliveries => _loadingMyDeliveries;
  bool get loadingDetail => _loadingDetail;

  List<Delivery> get activeDeliveries =>
      _myDeliveries.where((d) => d.isActive).toList();

  List<Delivery> get completedDeliveries =>
      _myDeliveries.where((d) => d.status == 'delivered').toList();

  int get completedCount => completedDeliveries.length;

  int get totalEarnings => completedDeliveries.fold<int>(
        0,
        (sum, d) => sum + (d.calculatedFee ?? 0),
      );

  Future<void> loadAvailable() async {
    _loadingAvailable = true;
    notifyListeners();
    try {
      final data = await _api.get('/deliveries/available/');
      _available = _extractResults(data, Delivery.fromJson);
      debugPrint(
        'DeliveryProvider.loadAvailable: ${_available.length} available',
      );
    } catch (e) {
      debugPrint('DeliveryProvider.loadAvailable: $e');
    }
    _loadingAvailable = false;
    notifyListeners();
  }

  Future<void> loadMyDeliveries() async {
    _loadingMyDeliveries = true;
    notifyListeners();
    try {
      final data = await _api.get('/deliveries/');
      _myDeliveries = _extractResults(data, Delivery.fromJson);
      debugPrint(
        'DeliveryProvider.loadMyDeliveries: ${_myDeliveries.length} deliveries',
      );
    } catch (e) {
      debugPrint('DeliveryProvider.loadMyDeliveries: $e');
    }
    _loadingMyDeliveries = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([loadAvailable(), loadMyDeliveries()]);
  }

  Future<bool> acceptDelivery(int id) async {
    try {
      final data = await _api.post('/deliveries/$id/accept/');
      final accepted = Delivery.fromJson(data);
      _available.removeWhere((d) => d.id == id);
      _myDeliveries.removeWhere((d) => d.id == id);
      _myDeliveries.insert(0, accepted);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.acceptDelivery: $e');
      return false;
    }
  }

  Future<bool> rejectDelivery(int id) async {
    try {
      await _api.post('/deliveries/$id/reject/');
      _available.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.rejectDelivery: $e');
      return false;
    }
  }

  Future<bool> completeDelivery(int id) async {
    try {
      final data = await _api.post('/deliveries/$id/complete/');
      final done = Delivery.fromJson(data);
      final i = _myDeliveries.indexWhere((d) => d.id == id);
      if (i != -1) {
        _myDeliveries[i] = done;
      } else {
        _myDeliveries.insert(0, done);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.completeDelivery: $e');
      return false;
    }
  }

  Future<bool> updateLocation(int id, double lat, double lng) async {
    try {
      await _api.patch(
        '/deliveries/$id/update-location/',
        body: {'current_lat': lat.toString(), 'current_lng': lng.toString()},
      );
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.updateLocation: $e');
      return false;
    }
  }

  Future<void> fetchOrderDetail(int orderId) async {
    _loadingDetail = true;
    notifyListeners();
    try {
      final data = await _api.get('/orders/$orderId/');
      _activeOrderDetail = Order.fromJson(data);
    } catch (e) {
      debugPrint('DeliveryProvider.fetchOrderDetail: $e');
    }
    _loadingDetail = false;
    notifyListeners();
  }

  void clearOrderDetail() {
    _activeOrderDetail = null;
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
