import 'dart:ui' show Color;

import '../api/api_client.dart';

int _parseInt(dynamic v) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double _parseDouble(dynamic v) =>
    v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;

double? _parseDoubleNullable(dynamic v) =>
    v == null ? null : (v is double ? v : double.tryParse(v.toString()));

class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;
  final String? address;
  final bool isVerified;
  final bool isApproved;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    required this.role,
    this.phone,
    this.address,
    this.isVerified = false,
    this.isApproved = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: _parseInt(json['id']),
    email: json['email'] ?? '',
    username: json['username'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    role: json['role'] ?? 'customer',
    phone: json['phone'],
    address: json['address'],
    isVerified: json['is_verified'] ?? false,
    isApproved: json['is_approved'] ?? false,
  );
}

class Restaurant {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final bool isActive;
  final bool isApproved;
  final bool isTrendy;
  final double? averageRating;
  final DateTime? createdAt;
  final double? deliveryFee;
  final double? deliveryFeePerKm;
  final double? minOrderAmount;
  final double? deliveryRadiusKm;
  final bool? hasOwnDelivery;

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.logo,
    this.coverImage,
    this.phone,
    this.isActive = true,
    this.isApproved = false,
    this.isTrendy = false,
    this.averageRating,
    this.createdAt,
    this.deliveryFee,
    this.deliveryFeePerKm,
    this.minOrderAmount,
    this.deliveryRadiusKm,
    this.hasOwnDelivery,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: _parseInt(json['id']),
    name: json['name'] ?? '',
    description: json['description'],
    address: json['address'],
    latitude: _parseDoubleNullable(json['latitude']),
    longitude: _parseDoubleNullable(json['longitude']),
    logo: ApiClient.resolveImageUrl(json['logo']),
    coverImage: ApiClient.resolveImageUrl(json['cover_image']),
    phone: json['phone'],
    isActive: json['is_active'] ?? true,
    isApproved: json['is_approved'] ?? false,
    isTrendy: json['is_trendy'] ?? false,
    averageRating: _parseDoubleNullable(json['average_rating']),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    deliveryFee: _parseDoubleNullable(json['delivery_fee']),
    deliveryFeePerKm: _parseDoubleNullable(json['delivery_fee_per_km']),
    minOrderAmount: _parseDoubleNullable(json['min_order_amount']),
    deliveryRadiusKm: _parseDoubleNullable(json['delivery_radius_km']),
    hasOwnDelivery: json['has_own_delivery'] is bool
        ? json['has_own_delivery'] as bool
        : null,
  );

  Restaurant copyWith({
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? logo,
    String? coverImage,
    String? phone,
    bool? isActive,
    bool? isApproved,
    bool? isTrendy,
    double? averageRating,
    DateTime? createdAt,
    double? deliveryFee,
    double? deliveryFeePerKm,
    double? minOrderAmount,
    double? deliveryRadiusKm,
    bool? hasOwnDelivery,
  }) => Restaurant(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    logo: logo ?? this.logo,
    coverImage: coverImage ?? this.coverImage,
    phone: phone ?? this.phone,
    isActive: isActive ?? this.isActive,
    isApproved: isApproved ?? this.isApproved,
    isTrendy: isTrendy ?? this.isTrendy,
    averageRating: averageRating ?? this.averageRating,
    createdAt: createdAt ?? this.createdAt,
    deliveryFee: deliveryFee ?? this.deliveryFee,
    deliveryFeePerKm: deliveryFeePerKm ?? this.deliveryFeePerKm,
    minOrderAmount: minOrderAmount ?? this.minOrderAmount,
    deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
    hasOwnDelivery: hasOwnDelivery ?? this.hasOwnDelivery,
  );
}

class MenuItem {
  final int id;
  final int category;
  final String categoryName;
  final int restaurant;
  final String restaurantName;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? image;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.category,
    this.categoryName = '',
    required this.restaurant,
    this.restaurantName = '',
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    this.image,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: _parseInt(json['id']),
    category: _parseInt(json['category']),
    categoryName: json['category_name'] ?? '',
    restaurant: _parseInt(json['restaurant']),
    restaurantName: json['restaurant_name'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    price: _parseDouble(json['price']),
    discountPrice: _parseDoubleNullable(json['discount_price']),
    image: ApiClient.resolveImageUrl(json['image']),
    isAvailable: json['is_available'] ?? true,
  );

  double get effectivePrice => discountPrice ?? price;
}

class Category {
  final int id;
  final String name;
  final String? image;

  Category({required this.id, required this.name, this.image});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: _parseInt(json['id']),
    name: json['name'] ?? '',
    image: ApiClient.resolveImageUrl(json['image']),
  );
}

class HeroBanner {
  final int id;
  final String title;
  final String? subtitle;
  final String? image;
  final bool isVideo;
  final String? ctaText;
  final String? ctaUrl;

  HeroBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.image,
    this.isVideo = false,
    this.ctaText,
    this.ctaUrl,
  });

  factory HeroBanner.fromJson(Map<String, dynamic> json) => HeroBanner(
    id: _parseInt(json['id']),
    title: json['title'] ?? '',
    subtitle: json['subtitle'],
    image: ApiClient.resolveImageUrl(json['image']),
    isVideo: json['is_video'] ?? false,
    ctaText: json['cta_text'],
    ctaUrl: json['cta_url'],
  );
}

class SiteContent {
  final String welcomeTitle;
  final Color welcomeTitleColor;
  final double welcomeTitleSize;
  final String welcomeSubtitle;
  final Color welcomeSubtitleColor;
  final double welcomeSubtitleSize;

  SiteContent({
    this.welcomeTitle = 'أهلاً بك في طعميني',
    Color? welcomeTitleColor,
    this.welcomeTitleSize = 18,
    this.welcomeSubtitle = '',
    Color? welcomeSubtitleColor,
    this.welcomeSubtitleSize = 12,
  }) : welcomeTitleColor = welcomeTitleColor ?? _hexColor('#1F2937'),
       welcomeSubtitleColor = welcomeSubtitleColor ?? _hexColor('#6B7280');

  factory SiteContent.fromJson(Map<String, dynamic> json) => SiteContent(
    welcomeTitle: json['welcome_title'] ?? 'أهلاً بك في طعميني',
    welcomeTitleColor: _hexColor(
      json['welcome_title_color'],
      fallback: const Color(0xFF1F2937),
    ),
    welcomeTitleSize: _cssSize(json['welcome_title_size'], fallback: 18),
    welcomeSubtitle: json['welcome_subtitle'] ?? '',
    welcomeSubtitleColor: _hexColor(
      json['welcome_subtitle_color'],
      fallback: const Color(0xFF6B7280),
    ),
    welcomeSubtitleSize: _cssSize(json['welcome_subtitle_size'], fallback: 12),
  );
}

Color _hexColor(dynamic v, {Color fallback = const Color(0xFF111827)}) {
  var hex = v?.toString().trim() ?? '';
  if (hex.isEmpty) return fallback;
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return fallback;
  if (hex.length == 6) return Color(0xFF000000 | value);
  return Color(value);
}

double _cssSize(dynamic v, {required double fallback}) {
  final s = v?.toString().trim().toLowerCase() ?? '';
  if (s.isEmpty) return fallback;
  final n = double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), ''));
  if (n == null) return fallback;
  if (s.contains('rem')) return n * 16;
  return n;
}

class CartItem {
  final int id;
  final MenuItem menuItem;
  final int quantity;
  final double subtotal;
  final double unitPrice;

  CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.subtotal,
    required this.unitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: _parseInt(json['id']),
    menuItem: MenuItem.fromJson(json['menu_item']),
    quantity: _parseInt(json['quantity']),
    subtotal: _parseDouble(json['subtotal']),
    unitPrice: _parseDouble(json['unit_price']),
  );
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double totalPrice;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: _parseInt(json['id']),
    items:
        (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ??
        [],
    totalPrice: _parseDouble(json['total_price']),
    totalQuantity: _parseInt(json['total_quantity']),
  );
}

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
    createdAt: DateTime.parse(json['created_at']),
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
    createdAt: DateTime.parse(json['created_at']),
  );
}

class Delivery {
  final int id;
  final int orderId;
  final String driverEmail;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final String restaurantName;
  final String? restaurantAddress;
  final String? deliveryAddress;
  final String? customerName;
  final String? customerPhone;
  final double? distance;
  final int? calculatedFee;

  Delivery({
    required this.id,
    required this.orderId,
    required this.driverEmail,
    required this.status,
    this.currentLat,
    this.currentLng,
    required this.restaurantName,
    this.restaurantAddress,
    this.deliveryAddress,
    this.customerName,
    this.customerPhone,
    this.distance,
    this.calculatedFee,
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
    deliveryAddress: json['delivery_address'],
    customerName: json['customer_name'],
    customerPhone: json['customer_phone'],
    distance: _parseDoubleNullable(json['distance']),
    calculatedFee: json['calculated_fee'] is int
        ? json['calculated_fee']
        : int.tryParse(json['calculated_fee']?.toString() ?? ''),
  );
}

class SiteSettings {
  final String email;
  final String phone;
  final String whatsapp;
  final String instagram;
  final String facebook;
  final String x;
  final String snapchat;
  final String tiktok;

  SiteSettings({
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
    this.instagram = '',
    this.facebook = '',
    this.x = '',
    this.snapchat = '',
    this.tiktok = '',
  });

  factory SiteSettings.fromJson(Map<String, dynamic> json) => SiteSettings(
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    whatsapp: json['whatsapp'] ?? '',
    instagram: json['instagram'] ?? '',
    facebook: json['facebook'] ?? '',
    x: json['x'] ?? '',
    snapchat: json['snapchat'] ?? '',
    tiktok: json['tiktok'] ?? '',
  );
}

class SupportTicket {
  final int id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: _parseInt(json['id']),
    subject: json['subject'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    createdAt: DateTime.parse(json['created_at']),
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
