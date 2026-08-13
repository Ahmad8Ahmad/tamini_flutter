import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UpdateInfo {
  final String version;
  final String apkUrl;
  final String? notes;
  final String? minVersion;
  final bool required;

  const UpdateInfo({
    required this.version,
    required this.apkUrl,
    this.notes,
    this.minVersion,
    this.required = false,
  });

  /// True when the update must be installed (blocking dialog with no
  /// "Later" action): either the release is explicitly marked required, or
  /// the installed version is below the declared minimum.
  bool get isRequired =>
      required ||
      (minVersion != null && UpdateService.isNewerVersion(minVersion!, AppConfig.appVersion));
}

class UpdateService {
  UpdateService._();

  /// Checks the release feed for a newer version. Returns null when there is
  /// no update or the check fails (offline, timeout, bad payload).
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.updateCheckUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        debugPrint('[UpdateCheck] HTTP ${response.statusCode} '
            'from ${AppConfig.updateCheckUrl}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[UpdateCheck] unexpected payload: ${response.body}');
        return null;
      }
      final version = decoded['version']?.toString();
      if (version == null || version.isEmpty) {
        debugPrint('[UpdateCheck] no version field in payload: $decoded');
        return null;
      }
      if (!isNewerVersion(version, AppConfig.appVersion)) {
        debugPrint('[UpdateCheck] installed ${AppConfig.appVersion} is current '
            '(feed $version)');
        return null;
      }
      final apkUrl = decoded['apkUrl']?.toString() ??
          AppConfig.fallbackApkUrl(version);
      return UpdateInfo(
        version: version,
        apkUrl: apkUrl,
        notes: decoded['notes']?.toString(),
        minVersion: decoded['minVersion']?.toString(),
        required: decoded['required'] == true,
      );
    } catch (e) {
      debugPrint('[UpdateCheck] check failed: $e');
      return null;
    }
  }

  /// True when [candidate] is a higher version than [current] using semantic
  /// version comparison (e.g. 1.2.0 > 1.1.9).
  static bool isNewerVersion(String candidate, String current) {
    final c = _parse(candidate);
    final k = _parse(current);
    for (var i = 0; i < 3; i++) {
      if (c[i] != k[i]) return c[i] > k[i];
    }
    return false;
  }

  static List<int> _parse(String version) {
    final parts = version.trim().split(RegExp(r'[._\-]'));
    return [
      for (var i = 0; i < 3; i++)
        i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0,
    ];
  }
}
