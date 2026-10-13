import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/repositories/cart_repository.dart';

/// In-memory [CartRepository] so provider logic can be exercised without any
/// HTTP or secure-storage plugin — the whole point of the repository layer.
class FakeCartRepository implements CartRepository {
  FakeCartRepository({this.cart, this.quote});

  Cart? cart;
  final CartQuote? quote;

  int quoteCalls = 0;
  double? lastLat;
  double? lastLng;
  bool cleared = false;

  @override
  Future<Cart> fetchCart() async => cart ?? _emptyCart;

  @override
  Future<Cart> addItem(int menuItemId, {int quantity = 1}) async =>
      cart ?? _emptyCart;

  @override
  Future<Cart> updateItem(int itemId, int quantity) async =>
      cart ?? _emptyCart;

  @override
  Future<Cart> removeItem(int itemId) async => cart ?? _emptyCart;

  @override
  Future<void> clear() async {
    cleared = true;
    cart = null;
  }

  @override
  Future<CartQuote> fetchQuote({double? lat, double? lng}) async {
    quoteCalls++;
    lastLat = lat;
    lastLng = lng;
    return quote ?? _zeroQuote;
  }
}

final _emptyCart = Cart(id: 0, items: [], totalPrice: 0, totalQuantity: 0);
final _zeroQuote = CartQuote(
  subtotal: 0,
  deliveryFee: 0,
  serviceFee: 0,
  total: 0,
  itemCount: 0,
);

void main() {
  test('fetchQuote stores the server quote and forwards the location', () async {
    final repo = FakeCartRepository(
      quote: CartQuote(
        subtotal: 2000,
        deliveryFee: 3500,
        serviceFee: 100,
        total: 5600,
        itemCount: 2,
      ),
    );
    final provider = CartProvider(repo);

    final quote = await provider.fetchQuote(lat: 33.5, lng: 36.3);

    expect(repo.quoteCalls, 1);
    expect(repo.lastLat, 33.5);
    expect(repo.lastLng, 36.3);
    expect(quote?.total, 5600);
    expect(provider.quote?.serviceFee, 100);
  });

  test('mutating the cart drops the stale quote', () async {
    final repo = FakeCartRepository(
      cart: _emptyCart,
      quote: CartQuote(
        subtotal: 2000,
        deliveryFee: 3500,
        serviceFee: 100,
        total: 5600,
        itemCount: 2,
      ),
    );
    final provider = CartProvider(repo);

    await provider.fetchQuote();
    expect(provider.quote, isNotNull);

    await provider.updateItem(1, 3);
    expect(provider.quote, isNull);
  });

  test('clear() empties the cart state', () async {
    final repo = FakeCartRepository(cart: _emptyCart);
    final provider = CartProvider(repo);
    await provider.loadCart();

    await provider.clear();

    expect(repo.cleared, isTrue);
    expect(provider.cart, isNull);
  });
}
