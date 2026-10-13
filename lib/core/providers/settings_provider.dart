import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../models/models.dart';

/// Theme choice (light / dark / system), persisted locally so it applies on
/// launch before any network call, and mirrored to the backend by
/// [SettingsProvider] so the website shows the same choice.
class ThemeProvider extends ChangeNotifier {
  static const _storageKey = 'app_theme';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  String get preference {
    switch (_mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> load() async {
    try {
      final value = await _storage.read(key: _storageKey);
      final mode = _fromPreference(value);
      if (mode != _mode) {
        _mode = mode;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ThemeProvider.load: $e');
    }
  }

  /// Applies a 'light' | 'dark' | 'system' string coming from the backend.
  Future<void> applyPreference(String? theme) => setMode(_fromPreference(theme));

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await _storage.write(key: _storageKey, value: preference);
    } catch (e) {
      debugPrint('ThemeProvider.setMode: $e');
    }
  }

  static ThemeMode _fromPreference(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}

/// Server-backed half of the settings screen: theme + notification
/// preferences, legal copy, and account deletion.
class SettingsProvider extends ChangeNotifier {
  final ApiClient _api;

  SettingsProvider(this._api);

  UserPreference _pref = UserPreference();
  bool _loading = false;
  String? _error;

  UserPreference get pref => _pref;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/settings/preferences/');
      _pref = UserPreference.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      debugPrint('SettingsProvider.load: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> setTheme(String theme) => _save(_pref.copyWith(theme: theme));

  Future<bool> setOrderUpdates(bool value) =>
      _save(_pref.copyWith(notifyOrderUpdates: value));

  Future<bool> setPromotions(bool value) =>
      _save(_pref.copyWith(notifyPromotions: value));

  Future<bool> setEmailNotifications(bool value) =>
      _save(_pref.copyWith(notifyEmail: value));

  Future<bool> _save(UserPreference next) async {
    final previous = _pref;
    _pref = next;
    notifyListeners();
    try {
      final data = await _api.put('/settings/preferences/', body: next.toJson());
      _pref = UserPreference.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _pref = previous;
      _error = e is ApiException ? e.message : e.toString();
      debugPrint('SettingsProvider._save: $e');
      notifyListeners();
      return false;
    }
  }

  /// Terms / privacy copy. Returns null when the request fails so the caller
  /// can show an empty state.
  Future<LegalContent?> fetchLegal(String slug, {String? lang}) async {
    try {
      final data = await _api.get(
        '/legal/$slug/',
        queryParams: lang == null ? null : {'lang': lang},
        cacheTtl: const Duration(minutes: 30),
      );
      return LegalContent.fromJson(data);
    } catch (e) {
      debugPrint('SettingsProvider.fetchLegal: $e');
      return null;
    }
  }
}
