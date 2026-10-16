part of 'models.dart';

class CartItem {
  final int id;
  final MenuItem menuItem;
  final int quantity;
  final double subtotal;
  final double unitPrice;

  CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.subtotal,
    required this.unitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: _parseInt(json['id']),
    menuItem: MenuItem.fromJson(json['menu_item']),
    quantity: _parseInt(json['quantity']),
    subtotal: _parseDouble(json['subtotal']),
    unitPrice: _parseDouble(json['unit_price']),
  );
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double totalPrice;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: _parseInt(json['id']),
    items:
        (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ??
        [],
    totalPrice: _parseDouble(json['total_price']),
    totalQuantity: _parseInt(json['total_quantity']),
  );
}

class CartQuote {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final int itemCount;

  CartQuote({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.itemCount,
  });

  factory CartQuote.fromJson(Map<String, dynamic> json) => CartQuote(
    subtotal: _parseDouble(json['subtotal']),
    deliveryFee: _parseDouble(json['delivery_fee']),
    serviceFee: _parseDouble(json['service_fee']),
    total: _parseDouble(json['total']),
    itemCount: _parseInt(json['item_count']),
  );
}
