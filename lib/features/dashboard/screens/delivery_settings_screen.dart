import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';

class DeliverySettingsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const DeliverySettingsScreen({super.key, required this.restaurant});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _feeController;
  late final TextEditingController _feePerKmController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _radiusController;
  late bool _hasOwnDelivery;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _feeController = TextEditingController(text: _fmt(r.deliveryFee));
    _feePerKmController = TextEditingController(text: _fmt(r.deliveryFeePerKm));
    _minOrderController = TextEditingController(text: _fmt(r.minOrderAmount));
    _radiusController = TextEditingController(text: _fmt(r.deliveryRadiusKm));
    _hasOwnDelivery = r.hasOwnDelivery ?? true;
  }

  @override
  void dispose() {
    _feeController.dispose();
    _feePerKmController.dispose();
    _minOrderController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  String _fmt(double? v) => v == null || v == 0 ? '' : _trim(v);

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  double? _parse(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);
    setState(() => _saving = true);
    final result = await context
        .read<RestaurantProvider>()
        .updateDeliverySettings(
          id: widget.restaurant.id,
          deliveryFee: _parse(_feeController),
          deliveryFeePerKm: _parse(_feePerKmController),
          minOrderAmount: _parse(_minOrderController),
          deliveryRadiusKm: _parse(_radiusController),
          hasOwnDelivery: _hasOwnDelivery,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? loc.savedSuccessfully
              : '${loc.errorOccurred} · ${loc.deliverySettingsHint}',
        ),
        backgroundColor: result != null ? AppTheme.success : AppTheme.danger,
      ),
    );
    if (result != null) Navigator.pop(context, true);
  }

  String? _positiveValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = double.tryParse(value.trim());
    if (v == null || v < 0) return AppLocalizations.of(context).requiredField;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.deliverySettings),
        actions: const [LanguageSelector()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: AppTheme.roundedLg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.orange600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.deliverySettingsHint,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiInput(
                controller: _feeController,
                labelText: loc.flatDeliveryFee,
                prefixIcon: Icons.ev_station_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveValidator,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _feePerKmController,
                labelText: loc.deliveryFeePerKm,
                prefixIcon: Icons.route_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveValidator,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _minOrderController,
                labelText: loc.minOrderAmount,
                prefixIcon: Icons.shopping_cart_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveValidator,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _radiusController,
                labelText: loc.deliveryRadius,
                prefixIcon: Icons.radar_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _positiveValidator,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.roundedLg,
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: AppTheme.orange600,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.hasOwnDelivery,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.hasOwnDeliveryHint,
                            style: AppTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hasOwnDelivery,
                      onChanged: (v) => setState(() => _hasOwnDelivery = v),
                      activeThumbColor: AppTheme.orange500,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiButton(text: loc.save, loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
