import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import '../../../core/widgets/tamini_empty_state.dart';
import '../../../core/widgets/language_selector.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrderProvider>();
    final loc = AppLocalizations.of(context);
    final cartData = cart.cart;

    if (cartData == null || cartData.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.checkout),
          actions: const [LanguageSelector()],
        ),
        body: TaminiEmptyState(
          icon: Icons.shopping_cart_outlined,
          title: loc.cartEmptyLogin,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.checkout,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [LanguageSelector()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Delivery Details Card ────────────────────────
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.roundedXl,
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.orange50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.orange500,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(loc.deliveryDetails, style: AppTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    TaminiInput(
                      controller: _nameController,
                      labelText: loc.yourName,
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : loc.requiredField,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    TaminiInput(
                      controller: _phoneController,
                      labelText: loc.phone,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : loc.requiredField,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    TaminiInput(
                      controller: _addressController,
                      labelText: loc.deliveryAddress,
                      prefixIcon: Icons.home_outlined,
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : loc.requiredField,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // ── Payment Method Card ───────────────────────────
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.roundedXl,
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.orange50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            color: AppTheme.orange500,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(loc.paymentMethod, style: AppTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    _paymentOption(
                      value: 'Cash',
                      title: loc.cashOnDelivery,
                      subtitle: loc.cashOnDeliveryHint,
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    _paymentOption(
                      value: 'Card',
                      title: loc.cardPayment,
                      subtitle: loc.cardPaymentHint,
                      icon: Icons.credit_card_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // ── Order Summary Card ───────────────────────────
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: AppTheme.roundedXl,
                  border: Border.all(color: AppTheme.orange100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppTheme.orange500,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(loc.orderSummary, style: AppTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    ...cartData.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.orange400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.quantity}× ${item.menuItem.name}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${item.subtotal.toStringAsFixed(0)} SYP',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: AppTheme.orange200, height: 20),
                    _summaryRow(loc.deliveryFee, '5,000 SYP'),
                    const SizedBox(height: 4),
                    _summaryRow(
                      loc.total,
                      '${(cart.totalPrice + 5000).toStringAsFixed(0)} SYP',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // ── Place Order Button ───────────────────────────
              TaminiButton(
                text: loc.placeOrder,
                loading: orders.loading,
                onPressed: _placeOrder,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _paymentMethod == value;
    return Material(
      color: selected ? AppTheme.orange50 : Colors.transparent,
      borderRadius: AppTheme.roundedLg,
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        borderRadius: AppTheme.roundedLg,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: AppTheme.roundedLg,
            border: Border.all(
              color: selected ? AppTheme.orange500 : AppTheme.borderLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppTheme.orange600 : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppTheme.orange600 : AppTheme.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isBold ? 16 : 14,
              fontWeight: FontWeight.w800,
              color: isBold ? AppTheme.orange600 : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final cartData = cart.cart;
    if (cartData == null || cartData.items.isEmpty) return;

    final restaurantId = cartData.items.first.menuItem.restaurant;
    final loc = AppLocalizations.of(context);
    final customerEmail = context.read<AuthProvider>().user?.email ?? '';
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await context.read<OrderProvider>().checkout({
      'restaurant_id': restaurantId,
      'delivery_address': _addressController.text.trim(),
      'customer_name': _nameController.text.trim(),
      'customer_phone': _phoneController.text.trim(),
      'customer_email': customerEmail,
      'payment_method': _paymentMethod,
      'items': cartData.items
          .map(
            (item) => {
              'menu_item_id': item.menuItem.id,
              'quantity': item.quantity,
            },
          )
          .toList(),
    });

    if (!context.mounted) return;
    if (result?.order == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.orderFailed),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
        ),
      );
      return;
    }

    await cart.clear();
    if (!context.mounted) return;

    final paymentUrl = result!.paymentUrl;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.paymentRedirecting),
          backgroundColor: AppTheme.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
        ),
      );
      final uri = Uri.tryParse(paymentUrl);
      if (uri != null && uri.hasScheme) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(loc.orderPlaced),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
        ),
      );
    }
    if (context.mounted) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
