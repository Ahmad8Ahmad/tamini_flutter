part of 'models.dart';

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
        ? DateTime.tryParse(json['created_at'].toString())
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
