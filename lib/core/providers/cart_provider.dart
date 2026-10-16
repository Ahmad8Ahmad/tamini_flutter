import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../models/models.dart';
import '../repositories/cart_repository.dart';

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

  /// Drops every trace of the current cart on session end. Without this the
  /// next signed-in account would see the previous user's items until its own
  /// cart finishes loading.
  void reset() {
    _cart = null;
    _quote = null;
    _loading = false;
    notifyListeners();
  }
}
