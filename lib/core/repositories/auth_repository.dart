import '../api/api_client.dart';
import '../models/models.dart';

/// Everything a sign-in path produces: the token pair plus the raw profile
/// payload the backend returns alongside it.
class AuthSession {
  final String access;
  final String refresh;
  final Map<String, dynamic> user;

  const AuthSession({
    required this.access,
    required this.refresh,
    required this.user,
  });
}

/// Data access for authentication and the signed-in user's profile.
///
/// Providers depend on this abstraction instead of [ApiClient] directly so
/// unit tests can swap in an in-memory fake without HTTP, secure-storage or
/// Firebase plugins. The concrete [ApiAuthRepository] maps the auth endpoints
/// onto [AuthSession]/[User] and owns persisting tokens and the cached profile.
///
/// Firebase/Google SDK calls deliberately stay out of here: they are identity
/// providers, not backend data access, and the resulting ID token is handed to
/// [exchangeFirebaseToken].
abstract class AuthRepository {
  /// Fired when the session is permanently invalid (no refresh token, or the
  /// refresh itself is rejected). Listeners should log the user out.
  void Function()? get onAuthExpired;
  set onAuthExpired(void Function()? handler);

  /// The current access token, read from storage on first use.
  Future<String?> get accessToken;

  Future<bool> hasSession();

  /// Drops tokens and the cached profile (and any session-scoped cache the
  /// transport layer holds).
  Future<void> clearSession();

  /// Persists the profile payload so it survives an app restart.
  Future<void> saveUserData(Map<String, dynamic> user);

  Future<Map<String, dynamic>> fetchProfile();

  Future<AuthSession> verifyOtp(String email, String otp);

  /// Legacy password endpoint for accounts created before registration moved
  /// to Firebase.
  Future<AuthSession> loginWithPassword(String email, String password);

  Future<AuthSession> exchangeFirebaseToken(
    String idToken, {
    String? role,
    String? phone,
  });

  Future<void> sendVerificationEmail(String email);

  Future<void> registerFcmToken(String token, {String? platform});

  Future<List<User>> listStaff();

  Future<void> createStaff({
    required String email,
    required String firstName,
    required String password,
    String? phone,
  });

  /// Deletes the account, proving ownership with whichever credential the
  /// caller managed to obtain. Throws [ApiException] with the backend status
  /// on failure.
  Future<void> deleteAccount({
    String? idToken,
    String? email,
    String? password,
  });

  Future<User> updateProfile({
    required String username,
    String? phone,
    String? address,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class ApiAuthRepository implements AuthRepository {
  final ApiClient _api;

  ApiAuthRepository(this._api);

  @override
  void Function()? get onAuthExpired => _api.onAuthExpired;

  @override
  set onAuthExpired(void Function()? handler) => _api.onAuthExpired = handler;

  @override
  Future<String?> get accessToken => _api.accessToken;

  @override
  Future<bool> hasSession() => _api.hasTokens();

  @override
  Future<void> clearSession() => _api.clearTokens();

  @override
  Future<void> saveUserData(Map<String, dynamic> user) =>
      _api.saveUserData(user);

  @override
  Future<Map<String, dynamic>> fetchProfile() => _api.get('/auth/profile/');

  /// Decodes a sign-in response and persists the token pair + profile before
  /// handing the session back, so every sign-in path stores them identically.
  Future<AuthSession> _session(Map<String, dynamic> data) async {
    final session = AuthSession(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: data['user'] as Map<String, dynamic>,
    );
    await _api.saveTokens(session.access, session.refresh);
    await _api.saveUserData(session.user);
    return session;
  }

  @override
  Future<AuthSession> verifyOtp(String email, String otp) async {
    return _session(
      await _api.post(
        '/auth/verify-otp/',
        body: {'email': email, 'otp': otp},
      ),
    );
  }

  @override
  Future<AuthSession> loginWithPassword(String email, String password) async {
    return _session(
      await _api.post(
        '/auth/login/',
        body: {'email': email, 'password': password},
      ),
    );
  }

  @override
  Future<AuthSession> exchangeFirebaseToken(
    String idToken, {
    String? role,
    String? phone,
  }) async {
    final trimmedPhone = phone?.trim();
    return _session(
      await _api.post(
        '/auth/firebase/',
        body: {
          'id_token': idToken,
          if (role != null && role.isNotEmpty) 'role': role,
          if (trimmedPhone != null && trimmedPhone.isNotEmpty)
            'phone': trimmedPhone,
        },
      ),
    );
  }

  @override
  Future<void> sendVerificationEmail(String email) {
    return _api.post(
      '/auth/send-verification-email/',
      body: {'email': email},
    );
  }

  @override
  Future<void> registerFcmToken(String token, {String? platform}) {
    return _api.post(
      '/auth/fcm-token/',
      body: {'token': token, 'platform': ?platform},
    );
  }

  @override
  Future<List<User>> listStaff() async {
    final data = await _api.get('/auth/staff/');
    final list = data['results'] as List? ?? [];
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createStaff({
    required String email,
    required String firstName,
    required String password,
    String? phone,
  }) {
    return _api.post(
      '/auth/staff/',
      body: {
        'email': email,
        'first_name': firstName,
        'phone': ?phone,
        'password': password,
      },
    );
  }

  @override
  Future<void> deleteAccount({
    String? idToken,
    String? email,
    String? password,
  }) {
    return _api.post('/settings/delete-account/', body: {
      if (idToken != null && idToken.isNotEmpty) 'id_token': idToken,
      if (email != null && email.isNotEmpty) 'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    });
  }

  @override
  Future<User> updateProfile({
    required String username,
    String? phone,
    String? address,
  }) async {
    final data = await _api.patch('/auth/profile/', body: {
      'username': username,
      'phone': phone,
      'address': address,
    });
    await _api.saveUserData(data);
    return User.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _api.post('/auth/change-password/', body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}
