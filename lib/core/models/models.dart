import '../api/api_client.dart';

int _parseInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double _parseDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;

double? _parseDoubleNullable(dynamic v) => v == null ? null : (v is double ? v : double.tryParse(v.toString()));

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
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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

  Cart({required this.id, required this.items, required this.totalPrice, required this.totalQuantity});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: _parseInt(json['id']),
    items: (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ?? [],
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
    customerOrderNumber: json['customer_order_number'] is int ? json['customer_order_number'] : int.tryParse(json['customer_order_number']?.toString() ?? ''),
    items: (json['items'] as List? ?? []).map((e) => OrderItem.fromJson(e)).toList(),
    createdAt: DateTime.parse(json['created_at']),
  );
}

class OrderItem {
  final int id;
  final int menuItem;
  final String menuItemName;
  final int quantity;
  final double price;

  OrderItem({required this.id, required this.menuItem, required this.menuItemName, required this.quantity, required this.price});

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

  Review({required this.id, required this.restaurant, required this.restaurantName, required this.user, required this.userEmail, required this.rating, this.comment, required this.createdAt});

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
  final double? distance;
  final int? calculatedFee;

  Delivery({required this.id, required this.orderId, required this.driverEmail, required this.status, this.currentLat, this.currentLng, required this.restaurantName, this.distance, this.calculatedFee});

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    id: _parseInt(json['id']),
    orderId: json['order_id_display'] != null ? _parseInt(json['order_id_display']) : _parseInt(json['order']),
    driverEmail: json['driver_email'] ?? '',
    status: json['status'] ?? 'searching',
    currentLat: _parseDoubleNullable(json['current_lat']),
    currentLng: _parseDoubleNullable(json['current_lng']),
    restaurantName: json['restaurant_name'] ?? '',
    distance: _parseDoubleNullable(json['distance']),
    calculatedFee: json['calculated_fee'] is int ? json['calculated_fee'] : int.tryParse(json['calculated_fee']?.toString() ?? ''),
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

  SupportTicket({required this.id, required this.subject, required this.description, required this.status, required this.priority, required this.createdAt});

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: _parseInt(json['id']),
    subject: json['subject'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    createdAt: DateTime.parse(json['created_at']),
  );
}
