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
    id: json['id'],
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
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'],
    address: json['address'],
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    logo: json['logo'],
    coverImage: json['cover_image'],
    phone: json['phone'],
    isActive: json['is_active'] ?? true,
    isApproved: json['is_approved'] ?? false,
    isTrendy: json['is_trendy'] ?? false,
    averageRating: (json['average_rating'] as num?)?.toDouble(),
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
    id: json['id'],
    category: json['category'] ?? 0,
    categoryName: json['category_name'] ?? '',
    restaurant: json['restaurant'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    discountPrice: (json['discount_price'] as num?)?.toDouble(),
    image: json['image'],
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
    id: json['id'],
    name: json['name'] ?? '',
    image: json['image'],
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
    id: json['id'],
    title: json['title'] ?? '',
    subtitle: json['subtitle'],
    image: json['image'],
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
    id: json['id'],
    menuItem: MenuItem.fromJson(json['menu_item']),
    quantity: json['quantity'] ?? 1,
    subtotal: (json['subtotal'] as num).toDouble(),
    unitPrice: (json['unit_price'] as num).toDouble(),
  );
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double totalPrice;
  final int totalQuantity;

  Cart({required this.id, required this.items, required this.totalPrice, required this.totalQuantity});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json['id'],
    items: (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
    totalPrice: (json['total_price'] as num).toDouble(),
    totalQuantity: json['total_quantity'] ?? 0,
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
    id: json['id'],
    customerName: json['customer_name'] ?? '',
    customerPhone: json['customer_phone'] ?? '',
    customerEmail: json['customer_email'] ?? '',
    restaurant: json['restaurant'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    deliveryAddress: json['delivery_address'] ?? '',
    deliveryLat: (json['delivery_lat'] as num?)?.toDouble() ?? 0,
    deliveryLng: (json['delivery_lng'] as num?)?.toDouble() ?? 0,
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
    totalPrice: (json['total_price'] as num).toDouble(),
    status: json['status'] ?? 'Pending',
    customerOrderNumber: json['customer_order_number'],
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
    id: json['id'],
    menuItem: json['menu_item'] ?? 0,
    menuItemName: json['menu_item_name'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] as num).toDouble(),
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
    id: json['id'],
    restaurant: json['restaurant'] ?? 0,
    restaurantName: json['restaurant_name'] ?? '',
    user: json['user'] ?? 0,
    userEmail: json['user_email'] ?? '',
    rating: json['rating'] ?? 0,
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
    id: json['id'],
    orderId: json['order_id_display'] ?? json['order'] ?? 0,
    driverEmail: json['driver_email'] ?? '',
    status: json['status'] ?? 'searching',
    currentLat: (json['current_lat'] as num?)?.toDouble(),
    currentLng: (json['current_lng'] as num?)?.toDouble(),
    restaurantName: json['restaurant_name'] ?? '',
    distance: (json['distance'] as num?)?.toDouble(),
    calculatedFee: json['calculated_fee'],
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
    id: json['id'],
    subject: json['subject'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    createdAt: DateTime.parse(json['created_at']),
  );
}
