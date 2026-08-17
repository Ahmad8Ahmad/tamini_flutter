import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

class OrderCacheService {
  static const _key = 'cached_restaurant_orders';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveOrders(List<Order> orders) async {
    try {
      final jsonList = orders.map((o) => _orderToJson(o)).toList();
      await _storage.write(key: _key, value: jsonEncode(jsonList));
    } catch (e) {
      debugPrint('OrderCacheService.saveOrders: $e');
    }
  }

  Future<List<Order>> loadOrders() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('OrderCacheService.loadOrders: $e');
      return [];
    }
  }

  Map<String, dynamic> _orderToJson(Order o) => {
        'id': o.id,
        'customer_name': o.customerName,
        'customer_phone': o.customerPhone,
        'customer_email': o.customerEmail,
        'restaurant': o.restaurant,
        'restaurant_name': o.restaurantName,
        'delivery_address': o.deliveryAddress,
        'delivery_lat': o.deliveryLat,
        'delivery_lng': o.deliveryLng,
        'delivery_fee': o.deliveryFee,
        'total_price': o.totalPrice,
        'status': o.status,
        'payment_method': o.paymentMethod,
        'customer_order_number': o.customerOrderNumber,
        'items': o.items
            .map((it) => {
                  'id': it.id,
                  'menu_item': it.menuItem,
                  'menu_item_name': it.menuItemName,
                  'quantity': it.quantity,
                  'price': it.price,
                })
            .toList(),
        'created_at': o.createdAt.toIso8601String(),
      };
}
