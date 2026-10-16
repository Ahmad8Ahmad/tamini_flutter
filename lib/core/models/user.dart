part of 'models.dart';

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

class UserPreference {
  final String theme; // 'light' | 'dark' | 'system'
  final bool notifyOrderUpdates;
  final bool notifyPromotions;
  final bool notifyEmail;

  UserPreference({
    this.theme = 'light',
    this.notifyOrderUpdates = true,
    this.notifyPromotions = true,
    this.notifyEmail = true,
  });

  static const themes = ['light', 'dark', 'system'];

  factory UserPreference.fromJson(Map<String, dynamic> json) => UserPreference(
    theme: UserPreference.themes.contains(json['theme'])
        ? json['theme'] as String
        : 'light',
    notifyOrderUpdates: json['notify_order_updates'] ?? true,
    notifyPromotions: json['notify_promotions'] ?? true,
    notifyEmail: json['notify_email'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'theme': theme,
    'notify_order_updates': notifyOrderUpdates,
    'notify_promotions': notifyPromotions,
    'notify_email': notifyEmail,
  };

  UserPreference copyWith({
    String? theme,
    bool? notifyOrderUpdates,
    bool? notifyPromotions,
    bool? notifyEmail,
  }) => UserPreference(
    theme: theme ?? this.theme,
    notifyOrderUpdates: notifyOrderUpdates ?? this.notifyOrderUpdates,
    notifyPromotions: notifyPromotions ?? this.notifyPromotions,
    notifyEmail: notifyEmail ?? this.notifyEmail,
  );
}
