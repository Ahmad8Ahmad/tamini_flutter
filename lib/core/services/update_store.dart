import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers which app version the update prompt was last shown for, so the
/// user is asked only once per new release instead of on every check.
class UpdateStore {
  UpdateStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'last_prompted_version';

  static Future<String?> get lastPromptedVersion async =>
      _storage.read(key: _key);

  static Future<void> setLastPromptedVersion(String version) async =>
      _storage.write(key: _key, value: version);
}
