import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._api);

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  Future<bool> tryAutoLogin() async {
    if (!await _api.hasTokens()) return false;
    try {
      final data = await _api.get('/auth/profile/');
      _user = User.fromJson(data);
      await _api.saveUserData(data);
      notifyListeners();
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
      final data = await _api.post('/auth/verify-otp/', body: {'email': email, 'otp': otp});
      await _api.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      await _api.saveUserData(data['user']);
      _loading = false;
      notifyListeners();
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
      final data = await _api.post('/auth/login/', body: {'email': email, 'password': password});
      await _api.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      await _api.saveUserData(data['user']);
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

  Future<String?> register(String email, String username, String password, String passwordConfirm, String role, {String? phone}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.post('/auth/register/', body: {
        'email': email,
        'username': username,
        'password': password,
        'password_confirm': passwordConfirm,
        'role': role,
        if (phone != null) 'phone': phone,
      });
      _loading = false;
      notifyListeners();
      return data['otp_debug'];
    } catch (e) {
      _loading = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    _user = null;
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
    } catch (e) { debugPrint('CartProvider.loadCart: $e'); }
  }

  Future<bool> addItem(int menuItemId, {int quantity = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/cart/add/', body: {'menu_item_id': menuItemId, 'quantity': quantity});
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
      final data = await _api.put('/cart/item/$itemId/', body: {'quantity': quantity});
      _cart = Cart.fromJson(data);
      notifyListeners();
    } catch (e) { debugPrint('CartProvider.updateItem: $e'); }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final data = await _api.delete('/cart/item/$itemId/remove/');
      _cart = Cart.fromJson(data);
      notifyListeners();
    } catch (e) { debugPrint('CartProvider.removeItem: $e'); }
  }

  Future<void> clear() async {
    try {
      await _api.delete('/cart/clear/');
      _cart = null;
      notifyListeners();
    } catch (e) { debugPrint('CartProvider.clear: $e'); }
  }
}

class OrderProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Order> _orders = [];
  bool _loading = false;

  OrderProvider(this._api);

  List<Order> get orders => _orders;
  bool get loading => _loading;

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/orders/');
      _orders = _extractResults(data, Order.fromJson);
    } catch (e) { debugPrint('OrderProvider.loadOrders: $e'); }
    _loading = false;
    notifyListeners();
  }

  Future<Order?> checkout(Map<String, dynamic> body) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.post('/orders/checkout/', body: body);
      final order = Order.fromJson(data);
      _orders.insert(0, order);
      _loading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}

List<T> _extractResults<T>(Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) {
  final raw = data is List ? data : data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

class RestaurantProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = [];
  List<MenuItem> _featuredItems = [];
  List<HeroBanner> _banners = [];
  bool _loading = false;

  RestaurantProvider(this._api);

  List<Restaurant> get restaurants => _restaurants;
  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get featuredItems => _featuredItems;
  List<HeroBanner> get banners => _banners;
  bool get loading => _loading;

  Future<void> loadHome() async {
    _loading = true;
    notifyListeners();
    try {
      debugPrint('RestaurantProvider: fetching restaurants...');
      final rData = await _api.get('/restaurants/');
      _restaurants = _extractResults(rData, Restaurant.fromJson);
      debugPrint('RestaurantProvider: loaded ${_restaurants.length} restaurants');
      if (_restaurants.isEmpty) {
        debugPrint('RestaurantProvider: response keys = ${rData.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('RestaurantProvider: error loading restaurants — $e');
    }
    try {
      debugPrint('RestaurantProvider: fetching banners...');
      final bData = await _api.get('/banners/');
      _banners = _extractResults(bData, HeroBanner.fromJson);
      debugPrint('RestaurantProvider: loaded ${_banners.length} banners');
      if (_banners.isEmpty) {
        debugPrint('RestaurantProvider: banner response keys = ${bData.keys.join(", ")}');
      }
    } catch (e) {
      debugPrint('RestaurantProvider: error loading banners — $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadFeaturedItems({String? search}) async {
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final data = await _api.get('/menu-items/', queryParams: params);
      _featuredItems = _extractResults(data, MenuItem.fromJson);
      notifyListeners();
    } catch (e) { debugPrint('RestaurantProvider.loadFeaturedItems: $e'); }
  }

  Future<void> loadMenuItems({int? restaurantId, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (restaurantId != null) params['restaurant'] = restaurantId.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;
      final data = await _api.get('/menu-items/', queryParams: params);
      _menuItems = _extractResults(data, MenuItem.fromJson);
      debugPrint('RestaurantProvider.loadMenuItems: loaded ${_menuItems.length} items');
    } catch (e) { debugPrint('RestaurantProvider.loadMenuItems: $e'); }
    _loading = false;
    notifyListeners();
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
      await _api.post('/support-tickets/', body: {
        'customer_name': name,
        'customer_email': email,
        if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
        'subject': subject,
        'description': description,
      });
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
      final data = await _api.get('/site-settings/');
      _siteSettings = SiteSettings.fromJson(data);
      notifyListeners();
    } catch (e) { debugPrint('SupportProvider.fetchSiteSettings: $e'); }
  }
}
