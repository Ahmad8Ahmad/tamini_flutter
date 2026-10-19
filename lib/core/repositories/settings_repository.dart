import '../api/api_client.dart';
import '../models/models.dart';

/// Data access for the server-backed half of settings: notification/theme
/// preferences and the legal pages.
///
/// Kept behind an interface so providers can be exercised in tests with an
/// in-memory fake rather than a live HTTP client.
abstract class SettingsRepository {
  Future<UserPreference> fetchPreferences();

  Future<UserPreference> savePreferences(UserPreference pref);

  Future<LegalContent> fetchLegal(String slug, {String? lang});
}

class ApiSettingsRepository implements SettingsRepository {
  final ApiClient _api;

  ApiSettingsRepository(this._api);

  @override
  Future<UserPreference> fetchPreferences() async {
    return UserPreference.fromJson(await _api.get('/settings/preferences/'));
  }

  @override
  Future<UserPreference> savePreferences(UserPreference pref) async {
    final data = await _api.put(
      '/settings/preferences/',
      body: pref.toJson(),
    );
    return UserPreference.fromJson(data);
  }

  @override
  Future<LegalContent> fetchLegal(String slug, {String? lang}) async {
    final data = await _api.get(
      '/legal/$slug/',
      queryParams: lang == null ? null : {'lang': lang},
      cacheTtl: const Duration(minutes: 30),
    );
    return LegalContent.fromJson(data);
  }
}
