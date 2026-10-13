import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../services/push_service.dart';
import '../services/order_cache_service.dart';

export 'catalog_provider.dart';
export 'owner_provider.dart';
export 'delivery_provider.dart';
export 'settings_provider.dart';
export '../repositories/order_repository.dart' show CheckoutResult;

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

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  User? _user;
  bool _loading = false;
  String? _error;
  String? _authErrorCode;

  AuthProvider(this._api) {
    _api.onAuthExpired = () {
      _user = null;
      notifyListeners();
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
  Future<String?> get accessToken => _api.accessToken;

  Future<bool> tryAutoLogin() async {
    if (!await _api.hasTokens()) return false;
    try {
      final data = await _api.get('/auth/profile/');
      _user = User.fromJson(data);
      await _api.saveUserData(data);
      notifyListeners();
      _syncPushToken();
      return true;
    } catch (e) {
      await _api.clearTokens();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post(
        '/auth/verify-otp/',
        body: {'email': email, 'otp': otp},
      );
      await _api.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      await _api.saveUserData(data['user']);
      _loading = false;
      notifyListeners();
      _syncPushToken();
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
      final data = await _api.post(
        '/auth/login/',
        body: {'email': email, 'password': password},
      );
      await _api.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      await _api.saveUserData(data['user']);
      _loading = false;
      notifyListeners();
      _syncPushToken();
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

  Future<bool> _exchangeFirebaseToken(String idToken, {String? role}) async {
    try {
      final data = await _api.post(
        '/auth/firebase/',
        body: {
          'id_token': idToken,
          if (role != null && role.isNotEmpty) 'role': role,
        },
      );
      await _api.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      await _api.saveUserData(data['user']);
      _loading = false;
      notifyListeners();
      _syncPushToken();
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
    String role,
  ) async {
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
      return await _exchangeFirebaseToken(fbToken, role: role);
    } catch (e) {
      _loading = false;
      _authErrorCode = e is FirebaseAuthException
          ? e.code
          : (e is ApiException ? null : null);
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
      await _api.post(
        '/auth/send-verification-email/',
        body: {'email': email},
      );
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
      final data = await _api.get('/auth/profile/');
      _user = User.fromJson(data);
      notifyListeners();
      return _user?.isVerified == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerFcmToken(String token, {String? platform}) async {
    try {
      await _api.post(
        '/auth/fcm-token/',
        body: {
          'token': token,
          'platform':
              platform ??
              (kIsWeb
                  ? 'web'
                  : defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android'),
        },
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
      final data = await _api.get('/auth/staff/');
      final list = data['results'] as List? ?? [];
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
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
      await _api.post(
        '/auth/staff/',
        body: {
          'email': email,
          'first_name': firstName,
          'phone': ?phone,
          'password': password,
        },
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
    await _api.clearTokens();
    _user = null;
    notifyListeners();
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
      await _api.post('/settings/delete-account/', body: {
        if (idToken != null && idToken.isNotEmpty) 'id_token': idToken,
        if (email != null && email.isNotEmpty) 'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      });
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
      final data = await _api.patch('/auth/profile/', body: {
        'username': username,
        'phone': phone,
        'address': address,
      });
      _user = User.fromJson(data);
      await _api.saveUserData(data);
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
      await _api.post('/auth/change-password/', body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
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

class CartProvider extends ChangeNotifier {
  final CartRepository _repo;
  Cart? _cart;
  bool _loading = false;

  CartProvider(this._repo);

  Cart? get cart => _cart;
  bool get loading => _loading;
  int get itemCount => _cart?.totalQuantity ?? 0;
  double get totalPrice => _cart?.totalPrice ?? 0;

  CartQuote? _quote;
  CartQuote? get quote => _quote;

  Future<void> loadCart() async {
    try {
      _cart = await _repo.fetchCart();
      _quote = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.loadCart: $e');
    }
  }

  Future<bool> addItem(int menuItemId, {int quantity = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      _cart = await _repo.addItem(menuItemId, quantity: quantity);
      _quote = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CartProvider.addItem: $e');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateItem(int itemId, int quantity) async {
    try {
      _cart = await _repo.updateItem(itemId, quantity);
      _quote = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.updateItem: $e');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      _cart = await _repo.removeItem(itemId);
      _quote = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.removeItem: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _repo.clear();
      _cart = null;
      _quote = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.clear: $e');
    }
  }

  /// Fetches the server-authoritative price breakdown (subtotal, delivery,
  /// service fee, total) for the current cart so checkout shows the exact
  /// amount that will be charged. Pass [lat]/[lng] when the delivery location
  /// is known so the distance-based delivery fee is included.
  Future<CartQuote?> fetchQuote({double? lat, double? lng}) async {
    try {
      _quote = await _repo.fetchQuote(lat: lat, lng: lng);
      notifyListeners();
      return _quote;
    } catch (e) {
      debugPrint('CartProvider.fetchQuote: $e');
      return null;
    }
  }
}

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;
  final OrderCacheService _cache = OrderCacheService();
  List<Order> _orders = [];
  List<Order> _restaurantOrders = [];
  bool _loading = false;
  bool _restaurantLoading = false;
  OrderTracking? _tracking;

  OrderProvider(this._repo);

  List<Order> get orders => _orders;
  List<Order> get restaurantOrders => _restaurantOrders;
  bool get loading => _loading;
  bool get restaurantLoading => _restaurantLoading;
  OrderTracking? get tracking => _tracking;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    try {
      _orders = await _repo.fetchOrders();
    } catch (e) {
      debugPrint('OrderProvider.loadOrders: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Loads the orders belonging to the restaurants owned by the logged-in
  /// user. The backend derives ownership from the JWT (GET /orders/).
  /// Falls back to cached orders when offline.
  Future<void> loadRestaurantOrders() async {
    _restaurantLoading = true;
    notifyListeners();
    try {
      _restaurantOrders = await _repo.fetchOrders();
      _cache.saveOrders(_restaurantOrders);
    } catch (e) {
      debugPrint('OrderProvider.loadRestaurantOrders: $e');
      if (_restaurantOrders.isEmpty) {
        _restaurantOrders = await _cache.loadOrders();
      }
    }
    _restaurantLoading = false;
    notifyListeners();
  }

  /// Pushes a status change through the dedicated `update-status` action
  /// rather than a plain PATCH on the order detail route.
  ///
  /// Both persist the status, but only the action fans out the customer-facing
  /// push (`OrderViewSet._notify_status_change`) and rejects an unknown status
  /// with a message listing the valid choices. `partial_update` notifies nobody,
  /// so the customer was never told their order had moved on.
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final updated = await _repo.updateStatus(orderId, status);
      final i = _restaurantOrders.indexWhere((o) => o.id == orderId);
      if (i != -1) {
        _restaurantOrders[i] = updated;
      } else {
        _restaurantOrders.insert(0, updated);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('OrderProvider.updateOrderStatus: $e');
      return false;
    }
  }

  Future<void> fetchTracking(int orderId) async {
    try {
      _tracking = await _repo.fetchTracking(orderId);
    } catch (e) {
      debugPrint('OrderProvider.fetchTracking: $e');
    }
    notifyListeners();
  }

  void clearTracking() {
    _tracking = null;
    notifyListeners();
  }

  Future<CheckoutResult?> checkout(Map<String, dynamic> body) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _repo.checkout(body);
      final order = result.order;
      if (order != null) _orders.insert(0, order);
      _loading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}

class SupportProvider extends ChangeNotifier {
  final ApiClient _api;
  bool _loading = false;
  String? _error;
  SiteSettings? _siteSettings;

  SupportProvider(this._api);

  bool get loading => _loading;
  String? get error => _error;
  SiteSettings? get siteSettings => _siteSettings;

  Future<bool> submitTicket({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String description,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post(
        '/support-tickets/',
        body: {
          'customer_name': name,
          'customer_email': email,
          if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
          'subject': subject,
          'description': description,
        },
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSiteSettings() async {
    try {
      final data = await _api.get(
        '/site-settings/',
        cacheTtl: const Duration(seconds: 60),
      );
      _siteSettings = SiteSettings.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('SupportProvider.fetchSiteSettings: $e');
    }
  }

  List<SupportTicket> _tickets = [];
  bool _ticketsLoading = false;
  String? _ticketsError;

  List<SupportTicket> get tickets => _tickets;
  bool get ticketsLoading => _ticketsLoading;
  String? get ticketsError => _ticketsError;

  /// The signed-in user's own tickets (the API scopes them by customer).
  Future<void> fetchTickets() async {
    _ticketsLoading = true;
    _ticketsError = null;
    notifyListeners();
    try {
      final data = await _api.get('/support-tickets/');
      final raw = data['results'] ?? data;
      _tickets = [
        for (final item in raw as List) SupportTicket.fromJson(item),
      ];
    } catch (e) {
      _ticketsError = e is ApiException ? e.message : e.toString();
      debugPrint('SupportProvider.fetchTickets: $e');
    }
    _ticketsLoading = false;
    notifyListeners();
  }
}
