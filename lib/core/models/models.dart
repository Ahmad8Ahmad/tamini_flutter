import 'dart:ui' show Color;

import '../api/api_client.dart';

part 'user.dart';
part 'restaurant.dart';
part 'cart.dart';
part 'order.dart';
part 'delivery.dart';
part 'content.dart';

int _parseInt(dynamic v) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double _parseDouble(dynamic v) =>
    v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;

double? _parseDoubleNullable(dynamic v) =>
    v == null ? null : (v is double ? v : double.tryParse(v.toString()));

/// Parses a required timestamp, falling back to the Unix epoch when the value
/// is missing or malformed so one bad row can't take down a whole list parse.
DateTime _parseDate(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

/// Parses an optional timestamp; null when missing or malformed.
DateTime? _parseDateNullable(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());
