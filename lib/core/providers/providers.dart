import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../api/api_client.dart';
import '../models/models.dart';

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
      final data = await _api.post(
        '/auth/verify-otp/',
        body: {'email': email, 'otp': otp},
      );
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
      final data = await _api.post(
        '/auth/login/',
        body: {'email': email, 'password': password},
      );
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

  Future<String?> register(
    String email,
    String username,
    String password,
    String passwordConfirm,
    String role, {
    String? phone,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.post(
        '/auth/register/',
        body: {
          'email': email,
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
          'role': role,
          if (phone != null) 'phone': phone,
        },
      );
      _loading = false;
      final otpDebug = data['otp_debug'];
      if (otpDebug != null) {
        debugPrint('REGISTER OTP for $email: $otpDebug');
      }
      notifyListeners();
      return otpDebug;
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
    } catch (e) {
      debugPrint('OrderProvider.loadOrders: $e');
    }
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

List<T> _extractResults<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data is List ? data : data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

class RestaurantProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Restaurant> _restaurants = [];
  List<Restaurant> _trendyRestaurants = [];
  List<MenuItem> _menuItems = [];
  List<MenuItem> _featuredItems = [];
  List<HeroBanner> _banners = [];
  List<Category> _categories = [];
  SiteContent? _siteContent;
  bool _loading = false;

  RestaurantProvider(this._api);

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get trendyRestaurants => _trendyRestaurants;
  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get featuredItems => _featuredItems;
  List<HeroBanner> get banners => _banners;
  List<Category> get categories => _categories;
  SiteContent? get siteContent => _siteContent;
  bool get loading => _loading;

  static const Duration _catalogTtl = Duration(seconds: 60);

  Future<void> loadHome() async {
    _loading = true;
    notifyListeners();
    await Future.wait([
      _loadHomeSection('site content', () async {
        final scData = await _api.get(
          '/site-content/current/',
          cacheTtl: _catalogTtl,
        );
        _siteContent = SiteContent.fromJson(scData);
      }),
      _loadHomeSection('categories', () async {
        final cData = await _api.get(
          '/categories/',
          queryParams: {'global': 'true'},
          cacheTtl: _catalogTtl,
        );
        _categories = _extractResults(cData, Category.fromJson);
      }),
      _loadHomeSection('trendy restaurants', () async {
        final tData = await _api.get(
          '/restaurants/',
          queryParams: {'trendy': 'true'},
          cacheTtl: _catalogTtl,
        );
        _trendyRestaurants = _extractResults(tData, Restaurant.fromJson);
      }),
      _loadHomeSection('restaurants', () async {
        final rData = await _api.get('/restaurants/', cacheTtl: _catalogTtl);
        _restaurants = _extractResults(rData, Restaurant.fromJson);
        if (_restaurants.isEmpty) {
          debugPrint(
            'RestaurantProvider: response keys = ${rData.keys.join(", ")}',
          );
        }
      }),
      _loadHomeSection('banners', () async {
        final bData = await _api.get('/banners/', cacheTtl: _catalogTtl);
        _banners = _extractResults(bData, HeroBanner.fromJson);
        if (_banners.isEmpty) {
          debugPrint(
            'RestaurantProvider: banner response keys = ${bData.keys.join(", ")}',
          );
        }
      }),
    ]);
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadHomeSection(
    String label,
    Future<void> Function() load,
  ) async {
    try {
      await load();
      debugPrint('RestaurantProvider: loaded $label');
    } catch (e) {
      debugPrint('RestaurantProvider: error loading $label — $e');
    }
  }

  Future<void> loadFeaturedItems({String? search, int? categoryId}) async {
    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null) params['category'] = categoryId.toString();
      final data = await _api.get(
        '/menu-items/',
        queryParams: params,
        cacheTtl: _catalogTtl,
      );
      _featuredItems = _extractResults(data, MenuItem.fromJson);
      notifyListeners();
    } catch (e) {
      debugPrint('RestaurantProvider.loadFeaturedItems: $e');
    }
  }

  Future<void> loadMenuItems({int? restaurantId, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (restaurantId != null) params['restaurant'] = restaurantId.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;
      final data = await _api.get(
        '/menu-items/',
        queryParams: params,
        cacheTtl: _catalogTtl,
      );
      _menuItems = _extractResults(data, MenuItem.fromJson);
      debugPrint(
        'RestaurantProvider.loadMenuItems: loaded ${_menuItems.length} items',
      );
    } catch (e) {
      debugPrint('RestaurantProvider.loadMenuItems: $e');
    }
    _loading = false;
    notifyListeners();
  }

  // ── Restaurant owner management ─────────────────────────────

  List<MenuItem> _ownerMenu = [];
  bool _ownerLoading = false;

  List<MenuItem> get ownerMenu => _ownerMenu;
  bool get ownerLoading => _ownerLoading;

  Future<void> loadOwnerMenu(int restaurantId) async {
    _ownerLoading = true;
    notifyListeners();
    try {
      final data = await _api.get(
        '/menu-items/',
        queryParams: {'restaurant': restaurantId.toString()},
      );
      _ownerMenu = _extractResults(data, MenuItem.fromJson);
      debugPrint(
        'RestaurantProvider.loadOwnerMenu: loaded ${_ownerMenu.length} items',
      );
    } catch (e) {
      debugPrint('RestaurantProvider.loadOwnerMenu: $e');
    }
    _ownerLoading = false;
    notifyListeners();
  }

  Future<MenuItem?> createMenuItem({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  }) async {
    final fields = _menuItemFields(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      isAvailable: isAvailable,
    );
    try {
      final data = await _sendMenuItemRequest(
        path: '/menu-items/',
        fields: fields,
        image: image,
        isCreate: true,
      );
      final item = MenuItem.fromJson(data);
      _ownerMenu.insert(0, item);
      notifyListeners();
      return item;
    } catch (e) {
      debugPrint('RestaurantProvider.createMenuItem: $e');
      return null;
    }
  }

  Future<MenuItem?> updateMenuItem({
    required int id,
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    bool isAvailable = true,
    XFile? image,
  }) async {
    final fields = _menuItemFields(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      isAvailable: isAvailable,
    );
    try {
      final data = await _sendMenuItemRequest(
        path: '/menu-items/$id/',
        fields: fields,
        image: image,
        isCreate: false,
      );
      final item = MenuItem.fromJson(data);
      final i = _ownerMenu.indexWhere((e) => e.id == id);
      if (i != -1) {
        _ownerMenu[i] = item;
      } else {
        _ownerMenu.insert(0, item);
      }
      notifyListeners();
      return item;
    } catch (e) {
      debugPrint('RestaurantProvider.updateMenuItem: $e');
      return null;
    }
  }

  Future<bool> deleteMenuItem(int id) async {
    try {
      await _api.delete('/menu-items/$id/');
      _ownerMenu.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('RestaurantProvider.deleteMenuItem: $e');
      return false;
    }
  }

  Future<MenuItem?> setDiscount(int menuItemId, double discountPrice) async {
    try {
      final data = await _api.patch(
        '/menu-items/$menuItemId/',
        body: {'discount_price': _priceString(discountPrice)},
      );
      return _replaceInOwnerMenu(MenuItem.fromJson(data));
    } catch (e) {
      debugPrint('RestaurantProvider.setDiscount: $e');
      return null;
    }
  }

  Future<bool> clearDiscount(int menuItemId) async {
    try {
      final data = await _api.patch(
        '/menu-items/$menuItemId/',
        body: {'discount_price': null},
      );
      _replaceInOwnerMenu(MenuItem.fromJson(data));
      return true;
    } catch (e) {
      debugPrint('RestaurantProvider.clearDiscount: $e');
      return false;
    }
  }

  MenuItem _replaceInOwnerMenu(MenuItem item) {
    final i = _ownerMenu.indexWhere((e) => e.id == item.id);
    if (i != -1) {
      _ownerMenu[i] = item;
    } else {
      _ownerMenu.insert(0, item);
    }
    notifyListeners();
    return item;
  }

  Map<String, String> _menuItemFields({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    required bool isAvailable,
  }) {
    return {
      'restaurant': restaurantId.toString(),
      'category': categoryId.toString(),
      'name': name,
      'price': _priceString(price),
      'is_available': isAvailable.toString(),
      if (description != null && description.trim().isNotEmpty)
        'description': description,
      if (discountPrice != null && discountPrice > 0)
        'discount_price': _priceString(discountPrice),
    };
  }

  Future<Map<String, dynamic>> _sendMenuItemRequest({
    required String path,
    required Map<String, String> fields,
    XFile? image,
    required bool isCreate,
  }) async {
    if (image == null) {
      return isCreate
          ? _api.post(path, body: fields)
          : _api.patch(path, body: fields);
    }
    final bytes = await image.readAsBytes();
    final file = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
    );
    return isCreate
        ? _api.postMultipart(path, fields: fields, files: [file])
        : _api.patchMultipart(path, fields: fields, files: [file]);
  }

  String _priceString(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}

class DeliveryProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Delivery> _available = [];
  List<Delivery> _myDeliveries = [];
  bool _loading = false;

  DeliveryProvider(this._api);

  List<Delivery> get available => _available;
  List<Delivery> get myDeliveries => _myDeliveries;
  bool get loading => _loading;

  Future<void> loadAvailable() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/deliveries/available/');
      _available = _extractResults(data, Delivery.fromJson);
      debugPrint(
        'DeliveryProvider.loadAvailable: ${_available.length} available',
      );
    } catch (e) {
      debugPrint('DeliveryProvider.loadAvailable: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMyDeliveries() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.get('/deliveries/');
      _myDeliveries = _extractResults(data, Delivery.fromJson);
      debugPrint(
        'DeliveryProvider.loadMyDeliveries: ${_myDeliveries.length} deliveries',
      );
    } catch (e) {
      debugPrint('DeliveryProvider.loadMyDeliveries: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> acceptDelivery(int id) async {
    try {
      final data = await _api.post('/deliveries/$id/accept/');
      final accepted = Delivery.fromJson(data);
      _available.removeWhere((d) => d.id == id);
      _myDeliveries.removeWhere((d) => d.id == id);
      _myDeliveries.insert(0, accepted);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.acceptDelivery: $e');
      return false;
    }
  }

  Future<bool> completeDelivery(int id) async {
    try {
      final data = await _api.post('/deliveries/$id/complete/');
      final done = Delivery.fromJson(data);
      final i = _myDeliveries.indexWhere((d) => d.id == id);
      if (i != -1) {
        _myDeliveries[i] = done;
      } else {
        _myDeliveries.insert(0, done);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.completeDelivery: $e');
      return false;
    }
  }

  Future<bool> updateLocation(int id, double lat, double lng) async {
    try {
      await _api.patch(
        '/deliveries/$id/update-location/',
        body: {'current_lat': lat.toString(), 'current_lng': lng.toString()},
      );
      return true;
    } catch (e) {
      debugPrint('DeliveryProvider.updateLocation: $e');
      return false;
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
}
