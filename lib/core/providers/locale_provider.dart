import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const _storageKey = 'app_locale';
  static const _supported = {'ar', 'en'};
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> load() async {
    try {
      final code = await _storage.read(key: _storageKey);
      if (code != null && _supported.contains(code)) {
        _locale = Locale(code);
      } else {
        final deviceLang = PlatformDispatcher.instance.locale.languageCode;
        _locale = _supported.contains(deviceLang)
            ? Locale(deviceLang)
            : const Locale('en');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('LocaleProvider.load: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_supported.contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    try {
      await _storage.write(key: _storageKey, value: locale.languageCode);
    } catch (e) {
      debugPrint('LocaleProvider.setLocale: $e');
    }
  }
}
