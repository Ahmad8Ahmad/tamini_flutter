import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/quantity_selector.dart';
import '../../../core/widgets/dashboard_button.dart';
import '../../../core/widgets/language_selector.dart';
import '../../orders/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myCart, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        actions: const [LanguageSelector(), DashboardButton()],
      ),
      body: cart.cart == null || cart.cart!.items.isEmpty
          ? TaminiEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: loc.cartEmpty,
              subtitle: loc.cartEmptyHint,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                    itemCount: cart.cart!.items.length,
                    itemBuilder: (ctx, i) => _buildCartItem(context, cart.cart!.items[i]),
                  ),
                ),
                _buildTotalBar(context, cart),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceXs),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Item image
          if (item.menuItem.image != null)
            ClipRRect(
              borderRadius: AppTheme.roundedMd,
              child: CachedNetworkImage(
                imageUrl: item.menuItem.image!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.orange50,
                  child: const Icon(Icons.fastfood, color: AppTheme.orange300, size: 20),
                ),
                errorWidget: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppTheme.orange50,
                  child: const Icon(Icons.fastfood, color: AppTheme.orange300, size: 20),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppTheme.orange50, borderRadius: AppTheme.roundedMd),
              child: const Icon(Icons.fastfood, color: AppTheme.orange300, size: 20),
            ),
          const SizedBox(width: 14),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)} SYP ${loc.each}',
                  style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.subtotal.toStringAsFixed(0)} SYP',
                  style: AppTheme.priceSmall,
                ),
              ],
            ),
          ),
          // Quantity
          QuantitySelector(
            quantity: item.quantity,
            onChanged: (qty) {
              if (qty == 0) {
                context.read<CartProvider>().removeItem(item.id);
              } else {
                context.read<CartProvider>().updateItem(item.id, qty);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBar(BuildContext context, CartProvider cart) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderLight)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.orange50,
                borderRadius: AppTheme.roundedXl,
                border: Border.all(color: AppTheme.orange100),
              ),
              child: Column(
                children: [
                  _summaryRow('${loc.total} (${cart.itemCount} ${loc.items})', '${cart.totalPrice.toStringAsFixed(0)} SYP', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TaminiButton(
              text: '${loc.checkout}  ${Directionality.of(context) == TextDirection.rtl ? '←' : '→'}',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isBold ? 18 : 14,
              fontWeight: FontWeight.w900,
              color: isBold ? AppTheme.orange600 : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
