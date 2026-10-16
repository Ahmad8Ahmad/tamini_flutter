part of 'models.dart';

class SiteSettings {
  final String email;
  final String phone;
  final String whatsapp;
  final String instagram;
  final String facebook;
  final String x;
  final String snapchat;
  final String tiktok;
  final int commissionRate;
  final double deliveryBaseFee;
  final double deliveryPerKmFee;

  SiteSettings({
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
    this.instagram = '',
    this.facebook = '',
    this.x = '',
    this.snapchat = '',
    this.tiktok = '',
    this.commissionRate = 0,
    this.deliveryBaseFee = 0,
    this.deliveryPerKmFee = 0,
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
    commissionRate: _parseInt(json['commission_rate']),
    deliveryBaseFee: _parseDoubleNullable(json['delivery_base_fee']) ?? 0,
    deliveryPerKmFee: _parseDoubleNullable(json['delivery_per_km_fee']) ?? 0,
  );
}

class LegalContent {
  final String slug;
  final String title;
  final String content;

  LegalContent({required this.slug, required this.title, required this.content});

  factory LegalContent.fromJson(Map<String, dynamic> json) => LegalContent(
    slug: json['slug'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
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
    createdAt: _parseDate(json['created_at']),
  );
}
