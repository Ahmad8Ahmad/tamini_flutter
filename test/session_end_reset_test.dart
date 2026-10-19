import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/repositories/auth_repository.dart';
import 'package:tamini/core/repositories/cart_repository.dart';

/// Minimal in-memory cart repo so the cart provider can be exercised without
/// HTTP or the secure-storage plugin.
class _FakeCartRepository implements CartRepository {
  _FakeCartRepository(this.cart);

  Cart? cart;

  @override
  Future<Cart> fetchCart() async => cart!;

  @override
  Future<Cart> addItem(int menuItemId, {int quantity = 1}) async => cart!;

  @override
  Future<Cart> updateItem(int itemId, int quantity) async => cart!;

  @override
  Future<Cart> removeItem(int itemId) async => cart!;

  @override
  Future<void> clear() async {
    cart = null;
  }

  @override
  Future<CartQuote> fetchQuote({double? lat, double? lng}) async =>
      CartQuote(subtotal: 0, deliveryFee: 0, serviceFee: 0, total: 0, itemCount: 0);
}

const _secureStorage = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

User _user() =>
    User(id: 1, email: 'a@test.com', username: 'a', role: 'customer');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // logout() touches Firebase/Google plugins (caught internally) and calls
  // clearTokens(), which reads/writes secure storage; answer it with null so
  // nothing throws.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, null);
  });

  test('reset() drops the cart state without touching the server', () async {
    final provider = CartProvider(
      _FakeCartRepository(
        Cart(id: 0, items: const [], totalPrice: 0, totalQuantity: 3),
      ),
    );
    await provider.loadCart();
    await provider.fetchQuote();
    expect(provider.cart, isNotNull);
    expect(provider.quote, isNotNull);

    provider.reset();

    expect(provider.cart, isNull);
    expect(provider.quote, isNull);
  });

  test('logout ends the session and fires onSessionEnded', () async {
    final api = ApiClient();
    final auth = AuthProvider(ApiAuthRepository(api));
    final cart = CartProvider(
      _FakeCartRepository(
        Cart(id: 0, items: const [], totalPrice: 0, totalQuantity: 1),
      ),
    );
    await cart.loadCart();
    expect(cart.cart, isNotNull);

    var sessionEnded = false;
    auth.onSessionEnded = () {
      sessionEnded = true;
      cart.reset();
    };
    auth.debugSetUser(_user());
    expect(auth.isLoggedIn, isTrue);

    await auth.logout();

    expect(auth.user, isNull);
    expect(sessionEnded, isTrue, reason: 'wiring must run on logout');
    expect(
      cart.cart,
      isNull,
      reason: "the previous account's cart must not survive logout",
    );
  });

  test('a rejected refresh ends the session and fires onSessionEnded', () async {
    final api = ApiClient();
    final auth = AuthProvider(ApiAuthRepository(api));
    var sessionEnded = false;
    auth.onSessionEnded = () => sessionEnded = true;
    auth.debugSetUser(_user());

    // The API client invokes this when the refresh token is permanently gone.
    api.onAuthExpired!.call();

    expect(auth.user, isNull);
    expect(sessionEnded, isTrue);
  });
}
