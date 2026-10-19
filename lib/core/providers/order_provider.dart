import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../models/models.dart';
import '../repositories/order_repository.dart';
import '../services/order_cache_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;
  final OrderCacheService _cache = OrderCacheService();
  List<Order> _orders = [];
  List<Order> _restaurantOrders = [];
  bool _loading = false;
  bool _restaurantLoading = false;
  OrderTracking? _tracking;

  OrderProvider(this._repo);

  List<Order> get orders => _orders;
  List<Order> get restaurantOrders => _restaurantOrders;
  bool get loading => _loading;
  bool get restaurantLoading => _restaurantLoading;
  OrderTracking? get tracking => _tracking;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    try {
      _orders = await _repo.fetchOrders();
    } catch (e) {
      debugPrint('OrderProvider.loadOrders: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Loads the orders belonging to the restaurants owned by the logged-in
  /// user. The backend derives ownership from the JWT (GET /orders/).
  /// Falls back to cached orders when offline.
  Future<void> loadRestaurantOrders() async {
    _restaurantLoading = true;
    notifyListeners();
    try {
      _restaurantOrders = await _repo.fetchOrders();
      unawaited(_cache.saveOrders(_restaurantOrders));
    } catch (e) {
      debugPrint('OrderProvider.loadRestaurantOrders: $e');
      if (_restaurantOrders.isEmpty) {
        _restaurantOrders = await _cache.loadOrders();
      }
    }
    _restaurantLoading = false;
    notifyListeners();
  }

  /// Pushes a status change through the dedicated `update-status` action
  /// rather than a plain PATCH on the order detail route.
  ///
  /// Both persist the status, but only the action fans out the customer-facing
  /// push (`OrderViewSet._notify_status_change`) and rejects an unknown status
  /// with a message listing the valid choices. `partial_update` notifies nobody,
  /// so the customer was never told their order had moved on.
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final updated = await _repo.updateStatus(orderId, status);
      final i = _restaurantOrders.indexWhere((o) => o.id == orderId);
      if (i != -1) {
        _restaurantOrders[i] = updated;
      } else {
        _restaurantOrders.insert(0, updated);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('OrderProvider.updateOrderStatus: $e');
      return false;
    }
  }

  Future<void> fetchTracking(int orderId) async {
    try {
      _tracking = await _repo.fetchTracking(orderId);
    } catch (e) {
      debugPrint('OrderProvider.fetchTracking: $e');
    }
    notifyListeners();
  }

  void clearTracking() {
    _tracking = null;
    notifyListeners();
  }

  Future<CheckoutResult?> checkout(Map<String, dynamic> body) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _repo.checkout(body);
      final order = result.order;
      if (order != null) _orders.insert(0, order);
      _loading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('OrderProvider.checkout: $e');
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Builds the checkout payload from typed inputs and places the order. The
  /// wire shape of the request is an order-domain concern, so it lives here
  /// rather than in the checkout widget.
  Future<CheckoutResult?> placeOrder({
    required int restaurantId,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String paymentMethod,
    required List<CartItem> items,
  }) {
    return checkout({
      'restaurant_id': restaurantId,
      'delivery_address': deliveryAddress,
      'delivery_lat': ?deliveryLat,
      'delivery_lng': ?deliveryLng,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'payment_method': paymentMethod,
      'items': items
          .map(
            (item) => {
              'menu_item_id': item.menuItem.id,
              'quantity': item.quantity,
            },
          )
          .toList(),
    });
  }

  /// Clears the order lists, live tracking and the offline order cache on
  /// session end, so nothing from the previous account survives a logout.
  void reset() {
    _orders = [];
    _restaurantOrders = [];
    _tracking = null;
    _loading = false;
    _restaurantLoading = false;
    _cache.clear();
    notifyListeners();
  }
}
