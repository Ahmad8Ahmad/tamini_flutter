part of 'models.dart';

class Delivery {
  final int id;
  final int orderId;
  final String driverEmail;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final String restaurantName;
  final String? restaurantAddress;
  final double? restaurantLat;
  final double? restaurantLng;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? customerName;
  final String? customerPhone;
  final double? distance;
  final int? calculatedFee;
  final DateTime? deliveredAt;

  Delivery({
    required this.id,
    required this.orderId,
    required this.driverEmail,
    required this.status,
    this.currentLat,
    this.currentLng,
    required this.restaurantName,
    this.restaurantAddress,
    this.restaurantLat,
    this.restaurantLng,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.customerName,
    this.customerPhone,
    this.distance,
    this.calculatedFee,
    this.deliveredAt,
  });

  bool get isActive => status == 'on_way' || status == 'picked_up';

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    id: _parseInt(json['id']),
    orderId: json['order_id_display'] != null
        ? _parseInt(json['order_id_display'])
        : _parseInt(json['order']),
    driverEmail: json['driver_email'] ?? '',
    status: json['status'] ?? 'searching',
    currentLat: _parseDoubleNullable(json['current_lat']),
    currentLng: _parseDoubleNullable(json['current_lng']),
    restaurantName: json['restaurant_name'] ?? '',
    restaurantAddress: json['restaurant_address'],
    restaurantLat: _parseDoubleNullable(json['restaurant_lat']),
    restaurantLng: _parseDoubleNullable(json['restaurant_lng']),
    deliveryAddress: json['delivery_address'],
    deliveryLat: _parseDoubleNullable(json['delivery_lat']),
    deliveryLng: _parseDoubleNullable(json['delivery_lng']),
    customerName: json['customer_name'],
    customerPhone: json['customer_phone'],
    distance: _parseDoubleNullable(json['distance']),
    calculatedFee: json['calculated_fee'] is int
        ? json['calculated_fee']
        : int.tryParse(json['calculated_fee']?.toString() ?? ''),
    deliveredAt: json['delivered_at'] != null
        ? DateTime.tryParse(json['delivered_at'])
        : null,
  );
}
