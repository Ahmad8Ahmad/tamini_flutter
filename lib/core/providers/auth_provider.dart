import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart'
    show
        ChangeNotifier,
        TargetPlatform,
        debugPrint,
        defaultTargetPlatform,
        kIsWeb,
        visibleForTesting;
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_client.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../services/push_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  User? _user;
  bool _loading = false;
  String? _error;
  String? _authErrorCode;

  /// Invoked whenever a session ends — explicitly through [logout] or when the
  /// backend permanently rejects the refresh token. The app wires this to drop
  /// every provider's copy of the dead account's data so it cannot leak to the
  /// next user who signs in on the same device.
  void Function()? onSessionEnded;

  AuthProvider(this._repo) {
    _repo.onAuthExpired = () {
      _user = null;
      notifyListeners();
      onSessionEnded?.call();
    };
    // FCM rotates the device token periodically; re-register so the backend
    // keeps pushing to the live token instead of a stale one.
    PushService.onTokenRefresh = (token) async {
      if (_user != null) await registerFcmToken(token);
    };
  }

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String? get authErrorCode => _authErrorCode;
  Future<String?> get accessToken => _repo.accessToken;

  Future<bool> tryAutoLogin() async {
    if (!await _repo.hasSession()) return false;
    try {
      final data = await _repo.fetchProfile();
      _user = User.fromJson(data);
      await _repo.saveUserData(data);
      notifyListeners();
      unawaited(_syncPushToken());
      return true;
    } catch (e) {
      await _repo.clearSession();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _loading = true;
    notifyListeners();
    try {
      final session = await _repo.verifyOtp(email, otp);
      _user = User.fromJson(session.user);
      _loading = false;
      notifyListeners();
      unawaited(_syncPushToken());
      return true;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    _authErrorCode = null;
    notifyListeners();

    // Every account registered in the app stores its password in Firebase, so
    // authenticate there first and exchange the resulting ID token for our own
    // JWT — the same path registration and Google Sign-In use. This makes
    // customer, restaurant and delivery accounts all able to sign in.
    String? firebaseCode;
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final idToken = await credential.user?.getIdToken();
      if (idToken != null) {
        return await _exchangeFirebaseToken(idToken);
      }
    } on FirebaseAuthException catch (e) {
      firebaseCode = e.code;
      debugPrint('AuthProvider.login: Firebase auth ${e.code}, trying legacy API');
    } catch (e) {
      debugPrint('AuthProvider.login: Firebase unavailable ($e), trying legacy API');
    }

    // Legacy fallback for accounts created before registration moved to
    // Firebase; those still authenticate against the Django password endpoint.
    try {
      final session = await _repo.loginWithPassword(email, password);
      _user = User.fromJson(session.user);
      _loading = false;
      notifyListeners();
      unawaited(_syncPushToken());
      return true;
    } catch (e) {
      _loading = false;
      // Let the UI turn a bad-credentials code into one friendly, localized
      // message instead of the backend's raw "No active account found with the
      // given credentials". Null keeps the backend detail (e.g. pending
      // approval or a network error).
      _authErrorCode = firebaseCode;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        _loading = false;
        _error = 'Failed to get Google credentials';
        notifyListeners();
        return false;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );
      final fbCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final fbToken = await fbCredential.user?.getIdToken();
      if (fbToken == null) {
        _loading = false;
        _error = 'Failed to get Firebase credentials';
        notifyListeners();
        return false;
      }
      return await _exchangeFirebaseToken(fbToken);
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> _exchangeFirebaseToken(
    String idToken, {
    String? role,
    String? phone,
  }) async {
    try {
      final session = await _repo.exchangeFirebaseToken(
        idToken,
        role: role,
        phone: phone,
      );
      _user = User.fromJson(session.user);
      _loading = false;
      notifyListeners();
      unawaited(_syncPushToken());
      return true;
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerByFirebase(
    String email,
    String username,
    String password,
    String role, {
    String? phone,
  }) async {
    _loading = true;
    _error = null;
    _authErrorCode = null;
    notifyListeners();
    try {
      final fbCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (fbCredential.user != null) {
        await fbCredential.user!.updateDisplayName(username);
      }
      final fbToken = await fbCredential.user?.getIdToken();
      if (fbToken == null) {
        _loading = false;
        _error = 'Failed to get Firebase credentials';
        notifyListeners();
        return false;
      }
      return await _exchangeFirebaseToken(fbToken, role: role, phone: phone);
    } catch (e) {
      _loading = false;
      _authErrorCode = e is FirebaseAuthException ? e.code : null;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException {
      _loading = false;
      _error = null;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendVerificationEmail(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.sendVerificationEmail(email);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkEmailVerified(String email) async {
    try {
      final data = await _repo.fetchProfile();
      _user = User.fromJson(data);
      notifyListeners();
      return _user?.isVerified == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerFcmToken(String token, {String? platform}) async {
    try {
      await _repo.registerFcmToken(
        token,
        platform:
            platform ??
            (kIsWeb
                ? 'web'
                : defaultTargetPlatform == TargetPlatform.iOS
                ? 'ios'
                : 'android'),
      );
      return true;
    } catch (e) {
      debugPrint('AuthProvider.registerFcmToken: $e');
      return false;
    }
  }

  Future<void> _syncPushToken() async {
    try {
      // The token may not have been available at startup (iOS especially);
      // fetch it now rather than silently skipping registration.
      final token = PushService.token ?? await PushService.refreshToken();
      if (token == null || token.isEmpty) return;
      await registerFcmToken(token);
    } catch (e) {
      debugPrint('AuthProvider._syncPushToken: $e');
    }
  }

  Future<List<User>> listStaff() async {
    try {
      return await _repo.listStaff();
    } catch (e) {
      debugPrint('AuthProvider.listStaff: $e');
      return [];
    }
  }

  Future<bool> createStaff({
    required String email,
    required String firstName,
    required String password,
    String? phone,
  }) async {
    try {
      await _repo.createStaff(
        email: email,
        firstName: firstName,
        password: password,
        phone: phone,
      );
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      debugPrint('AuthProvider.createStaff: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Clear the provider-side sessions too; otherwise the previously signed-in
    // Firebase/Google account lingers and can shadow the next login.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('AuthProvider.logout: Firebase sign-out failed: $e');
    }
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('AuthProvider.logout: Google sign-out failed: $e');
    }
    await _repo.clearSession();
    _user = null;
    notifyListeners();
    onSessionEnded?.call();
  }

  /// Whether deleting the account must be confirmed with a password. True when
  /// there is no Firebase session to reauthenticate, or that session is backed
  /// by an email/password credential.
  bool get deleteAccountRequiresPassword {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || _hasPasswordProvider(user.providerData);
  }

  /// Deletes the signed-in account, proving ownership before the backend
  /// removes it.
  ///
  /// All Firebase/Google reauthentication lives here so widgets stay free of
  /// auth SDKs. A password is used when there is no provider session or the
  /// session is password-backed; Google sessions are re-proven silently and
  /// the backend verifies email + password as a last resort.
  ///
  /// Returns null on success, otherwise the HTTP status (0 off-network) so the
  /// caller can map it to a localized message.
  Future<int?> deleteAccount({String password = ''}) async {
    final email = _user?.email;
    final fbUser = FirebaseAuth.instance.currentUser;

    // 1. Password-backed session: reauthenticate locally, then prove it with a
    //    freshly minted ID token. Fall back to server-side verification when
    //    the local reauthentication is unavailable.
    if (fbUser != null && _hasPasswordProvider(fbUser.providerData)) {
      try {
        await fbUser.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: fbUser.email ?? email ?? '',
            password: password,
          ),
        );
      } catch (e) {
        debugPrint('AuthProvider.deleteAccount: local reauth failed: $e');
        return await _submitDeleteAccount(email: email, password: password);
      }
      final token = await fbUser.getIdToken(true);
      if (token != null) return _submitDeleteAccount(idToken: token);
    }

    // 2. Google-backed (or no Firebase session yet): sign in silently to prove
    //    presence, then send the resulting ID token.
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signInSilently();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final user =
            fbUser ??
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        if (user != null) {
          await user.reauthenticateWithCredential(credential);
          final token = await user.getIdToken(true);
          if (token != null) return await _submitDeleteAccount(idToken: token);
        }
      }
    } catch (e) {
      debugPrint('AuthProvider.deleteAccount: Google reauth failed: $e');
      return 0;
    }

    // 3. No provider session: let the backend verify email + password.
    if (password.isEmpty) return 0;
    return _submitDeleteAccount(email: email, password: password);
  }

  Future<int?> _submitDeleteAccount({
    String? idToken,
    String? email,
    String? password,
  }) async {
    try {
      await _repo.deleteAccount(idToken: idToken, email: email, password: password);
      return null;
    } on ApiException catch (e) {
      debugPrint('AuthProvider.deleteAccount: ${e.statusCode} ${e.message}');
      return e.statusCode;
    } catch (e) {
      debugPrint('AuthProvider.deleteAccount: $e');
      return 0;
    }
  }

  bool _hasPasswordProvider(List<UserInfo> providerData) =>
      providerData.any((info) => info.providerId == 'password');

  /// Saves the editable profile fields and refreshes the cached copy.
  ///
  /// PATCH (not PUT) because the profile serializer marks several fields
  /// required that the app does not collect here (email, role).
  Future<bool> updateProfile({
    required String username,
    String? phone,
    String? address,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.updateProfile(
        username: username,
        phone: phone,
        address: address,
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      debugPrint('AuthProvider.updateProfile: $e');
      notifyListeners();
      return false;
    }
  }

  /// Changes the signed-in user's password. Returns null on success, or the
  /// HTTP status (0 off-network) so the caller can localize the error.
  Future<int?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _repo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      debugPrint('AuthProvider.changePassword: ${e.statusCode} ${e.message}');
      return e.statusCode;
    } catch (e) {
      debugPrint('AuthProvider.changePassword: $e');
      return 0;
    }
  }

  @visibleForTesting
  void debugSetUser(User? user) {
    _user = user;
    notifyListeners();
  }
}
