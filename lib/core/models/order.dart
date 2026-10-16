part of 'models.dart';

class Order {
  final int id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final int restaurant;
  final String restaurantName;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLng;
  final double deliveryFee;
  final double totalPrice;
  final String status;
  final String? paymentMethod;
  final int? customerOrderNumber;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.restaurant,
    required this.restaurantName,
    required this.deliveryAddress,
    this.deliveryLat = 0,
    this.deliveryLng = 0,
    this.deliveryFee = 0,
    required this.totalPrice,
    required this.status,
    this.paymentMethod,
    this.customerOrderNumber,
    this.items = const [],
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: _parseInt(json['id']),
    customerName: json['customer_name'] ?? '',
    customerPhone: json['customer_phone'] ?? '',
    customerEmail: json['customer_email'] ?? '',
    restaurant: _parseInt(json['restaurant']),
    restaurantName: json['restaurant_name'] ?? '',
    deliveryAddress: json['delivery_address'] ?? '',
    deliveryLat: _parseDoubleNullable(json['delivery_lat']) ?? 0,
    deliveryLng: _parseDoubleNullable(json['delivery_lng']) ?? 0,
    deliveryFee: _parseDoubleNullable(json['delivery_fee']) ?? 0,
    totalPrice: _parseDouble(json['total_price']),
    status: json['status'] ?? 'Pending',
    paymentMethod: json['payment_method'],
    customerOrderNumber: json['customer_order_number'] is int
        ? json['customer_order_number']
        : int.tryParse(json['customer_order_number']?.toString() ?? ''),
    items: (json['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(e))
        .toList(),
    createdAt: _parseDate(json['created_at']),
  );
}

class OrderItem {
  final int id;
  final int menuItem;
  final String menuItemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.menuItem,
    required this.menuItemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: _parseInt(json['id']),
    menuItem: _parseInt(json['menu_item']),
    menuItemName: json['menu_item_name'] ?? '',
    quantity: _parseInt(json['quantity']),
    price: _parseDouble(json['price']),
  );
}

class Review {
  final int id;
  final int restaurant;
  final String restaurantName;
  final int user;
  final String userEmail;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.restaurant,
    required this.restaurantName,
    required this.user,
    required this.userEmail,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: _parseInt(json['id']),
    restaurant: _parseInt(json['restaurant']),
    restaurantName: json['restaurant_name'] ?? '',
    user: _parseInt(json['user']),
    userEmail: json['user_email'] ?? '',
    rating: _parseInt(json['rating']),
    comment: json['comment'],
    createdAt: _parseDate(json['created_at']),
  );
}

class OrderTracking {
  final int orderId;
  final String status;
  final String? driverName;
  final String? driverPhone;
  final double? driverLat;
  final double? driverLng;
  final double? restaurantLat;
  final double? restaurantLng;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? deliveryAddress;

  OrderTracking({
    required this.orderId,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.driverLat,
    this.driverLng,
    this.restaurantLat,
    this.restaurantLng,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryAddress,
  });

  bool get hasDriverLocation =>
      driverLat != null &&
      driverLng != null &&
      driverLat != 0 &&
      driverLng != 0;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final restLat = _parseDoubleNullable(
      json['restaurant_lat'] ?? json['restaurant_latitude'],
    );
    final restLng = _parseDoubleNullable(
      json['restaurant_lng'] ?? json['restaurant_longitude'],
    );
    final delLat = _parseDoubleNullable(
      json['delivery_lat'] ?? json['delivery_latitude'],
    );
    final delLng = _parseDoubleNullable(
      json['delivery_lng'] ?? json['delivery_longitude'],
    );
    return OrderTracking(
      orderId: _parseInt(json['id'] ?? json['order_id']),
      status: json['status'] ?? 'Pending',
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      driverLat: _parseDoubleNullable(
        json['current_lat'] ?? json['driver_lat'],
      ),
      driverLng: _parseDoubleNullable(
        json['current_lng'] ?? json['driver_lng'],
      ),
      restaurantLat: restLat != null && restLat != 0 ? restLat : null,
      restaurantLng: restLng != null && restLng != 0 ? restLng : null,
      deliveryLat: delLat != null && delLat != 0 ? delLat : null,
      deliveryLng: delLng != null && delLng != 0 ? delLng : null,
      deliveryAddress: json['delivery_address'],
    );
  }
}
