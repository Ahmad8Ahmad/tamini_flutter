import '../../../core/providers/providers.dart';

/// Outcome of an "add to cart" tap from the home feed.
enum AddToCartResult { added, failed, needsAuth }

/// Actions for the home feed.
///
/// Keeps the auth-gate + add-to-cart orchestration out of the widget, which
/// only renders the returned outcome.
class HomeController {
  HomeController(this._cart, this._auth);

  final CartProvider _cart;
  final AuthProvider _auth;

  Future<AddToCartResult> addToCart(int menuItemId) async {
    if (!_auth.isLoggedIn) return AddToCartResult.needsAuth;
    final ok = await _cart.addItem(menuItemId);
    return ok ? AddToCartResult.added : AddToCartResult.failed;
  }
}
