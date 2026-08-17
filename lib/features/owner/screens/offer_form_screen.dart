import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import '../../../core/widgets/language_selector.dart';

class OfferFormScreen extends StatefulWidget {
  final int restaurantId;
  final MenuItem? item;

  const OfferFormScreen({super.key, required this.restaurantId, this.item});

  @override
  State<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends State<OfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _discountController;
  int? _itemId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _itemId = widget.item?.id;
    _discountController = TextEditingController(
      text: widget.item?.discountPrice != null
          ? _priceText(widget.item!.discountPrice!)
          : '',
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  String _priceText(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);
    final provider = context.read<OwnerProvider>();
    final item = provider.ownerMenu.firstWhere((e) => e.id == _itemId);
    final price = double.parse(_discountController.text.trim());
    if (price >= item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.offerPriceLessThanOriginal),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final result = await provider.setDiscount(item.id, price);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null ? loc.offerSaved : loc.errorOccurred),
        backgroundColor: result != null ? AppTheme.success : AppTheme.danger,
      ),
    );
    if (result != null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<OwnerProvider>();
    final items = provider.ownerMenu;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? loc.editOffer : loc.addOffer),
        actions: const [LanguageSelector()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.item == null) ...[
                DropdownButtonFormField<int>(
                  initialValue: _itemId,
                  isExpanded: true,
                  hint: Text(
                    loc.chooseMeal,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            e.name,
                            style: const TextStyle(fontFamily: 'Cairo'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _itemId = v),
                  decoration: _dropdownDecoration(loc.chooseMeal),
                  validator: (v) => v == null ? loc.requiredField : null,
                ),
                const SizedBox(height: AppTheme.spaceMd),
              ],
              if (_itemId != null)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.orange50,
                    borderRadius: AppTheme.roundedLg,
                  ),
                  child: Text(
                    _selectedItem(items)?.name ?? '',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              if (_itemId != null) const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _discountController,
                labelText: loc.offerPrice,
                hintText: loc.offerPriceHint,
                prefixIcon: Icons.local_fire_department_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final d = double.tryParse((v ?? '').trim());
                  if (d == null || d <= 0) return loc.requiredField;
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiButton(text: loc.save, loading: _saving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  MenuItem? _selectedItem(List<MenuItem> items) {
    for (final e in items) {
      if (e.id == _itemId) return e;
    }
    return null;
  }

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppTheme.gray50,
    prefixIcon: const Icon(
      Icons.restaurant_menu,
      color: AppTheme.orange400,
      size: 20,
    ),
    border: OutlineInputBorder(
      borderRadius: AppTheme.roundedLg,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppTheme.roundedLg,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppTheme.roundedLg,
      borderSide: const BorderSide(color: AppTheme.orange500, width: 2),
    ),
  );
}
