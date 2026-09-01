import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../services/push_service.dart';
import '../services/order_cache_service.dart';

export 'catalog_provider.dart';
export 'owner_provider.dart';
export 'delivery_provider.dart';

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
        notifyListeners();
      }
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
    notifyListeners();
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

  Future<bool> _exchangeFirebaseToken(String idToken) async {
    try {
      final data = await _api.post(
        '/auth/firebase/',
        body: {'id_token': idToken},
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
      if (fbCredential.user?.emailVerified == false) {
        await fbCredential.user?.sendEmailVerification();
      }
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
      final token = PushService.token;
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
    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }

  @visibleForTesting
  void debugSetUser(User? user) {
    _user = user;
    notifyListeners();
  }
}

class CartProvider extends ChangeNotifier {
  final ApiClient _api;
  Cart? _cart;
  bool _loading = false;

  CartProvider(this._api);

  Cart? get cart => _cart;
  bool get loading => _loading;
  int get itemCount => _cart?.totalQuantity ?? 0;
  double get totalPrice => _cart?.totalPrice ?? 0;

  Future<void> loadCart() async {
    try {
      final data = await _api.get('/cart/');
      _cart = Cart.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.loadCart: $e');
    }
  }

  Future<bool> addItem(int menuItemId, {int quantity = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post(
        '/cart/add/',
        body: {'menu_item_id': menuItemId, 'quantity': quantity},
      );
      _cart = Cart.fromJson(data);
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
      final data = await _api.put(
        '/cart/item/$itemId/',
        body: {'quantity': quantity},
      );
      _cart = Cart.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.updateItem: $e');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final data = await _api.delete('/cart/item/$itemId/remove/');
      _cart = Cart.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.removeItem: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _api.delete('/cart/clear/');
      _cart = null;
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider.clear: $e');
    }
  }
}

class CheckoutResult {
  final Order? order;
  final String? paymentUrl;
  CheckoutResult({this.order, this.paymentUrl});
}

class OrderProvider extends ChangeNotifier {
  final ApiClient _api;
  final OrderCacheService _cache = OrderCacheService();
  List<Order> _orders = [];
  List<Order> _restaurantOrders = [];
  bool _loading = false;
  bool _restaurantLoading = false;
  OrderTracking? _tracking;

  OrderProvider(this._api);

  List<Order> get orders => _orders;
  List<Order> get restaurantOrders => _restaurantOrders;
  bool get loading => _loading;
  bool get restaurantLoading => _restaurantLoading;
  OrderTracking? get tracking => _tracking;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/orders/');
      _orders = _extractResults(data, Order.fromJson);
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
      final data = await _api.get('/orders/');
      _restaurantOrders = _extractResults(data, Order.fromJson);
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

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final data = await _api.patch(
        '/orders/$orderId/',
        body: {'status': status},
      );
      final updated = Order.fromJson(data);
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
      final data = await _api.get('/orders/$orderId/tracking/');
      _tracking = OrderTracking.fromJson(data);
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
      final data = await _api.post('/orders/checkout/', body: body);
      final order = Order.fromJson(data);
      _orders.insert(0, order);
      _loading = false;
      notifyListeners();
      final paymentUrl = data['payment_url'] is String
          ? data['payment_url'] as String
          : null;
      return CheckoutResult(order: order, paymentUrl: paymentUrl);
    } catch (e) {
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}

List<T> _extractResults<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data is List ? data : data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
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
}
