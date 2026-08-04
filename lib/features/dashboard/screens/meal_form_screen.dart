import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';

class MealFormScreen extends StatefulWidget {
  final int restaurantId;
  final MenuItem? item;

  const MealFormScreen({super.key, required this.restaurantId, this.item});

  @override
  State<MealFormScreen> createState() => _MealFormScreenState();
}

class _MealFormScreenState extends State<MealFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _descriptionController;
  int? _categoryId;
  bool _isAvailable = true;
  XFile? _newImage;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null ? _priceText(item.price) : '',
    );
    _discountController = TextEditingController(
      text: item?.discountPrice != null ? _priceText(item!.discountPrice!) : '',
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _categoryId = item?.category;
    _isAvailable = item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _priceText(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _newImage = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);
    final price = double.parse(_priceController.text.trim());
    final discount = double.tryParse(_discountController.text.trim());
    if (discount != null && discount >= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.isArabic
                ? 'سعر العرض يجب أن يكون أقل من السعر الأصلي'
                : 'Offer price must be less than the original price',
          ),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<RestaurantProvider>();
    MenuItem? result;
    if (_isEdit) {
      result = await provider.updateMenuItem(
        id: widget.item!.id,
        restaurantId: widget.restaurantId,
        categoryId: _categoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountPrice: discount,
        isAvailable: _isAvailable,
        image: _newImage,
      );
    } else {
      result = await provider.createMenuItem(
        restaurantId: widget.restaurantId,
        categoryId: _categoryId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        discountPrice: discount,
        isAvailable: _isAvailable,
        image: _newImage,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.savedSuccessfully),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.errorOccurred),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final loc = AppLocalizations.of(context);
    final provider = context.read<RestaurantProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          loc.deleteConfirmTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          loc.deleteMealConfirm,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              loc.cancel,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              loc.confirm,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    final ok = await provider.deleteMenuItem(widget.item!.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.deleted : loc.errorOccurred),
        backgroundColor: ok ? AppTheme.danger : AppTheme.danger,
      ),
    );
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<RestaurantProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? loc.editMeal : loc.addMeal)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(loc),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiInput(
                controller: _nameController,
                labelText: loc.mealName,
                prefixIcon: Icons.restaurant_menu,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.requiredField : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                isExpanded: true,
                hint: Text(
                  loc.chooseCategory,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                decoration: _dropdownDecoration(loc.chooseCategory),
                validator: (v) => v == null ? loc.requiredField : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: TaminiInput(
                      controller: _priceController,
                      labelText: loc.mealPrice,
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final d = double.tryParse((v ?? '').trim());
                        if (d == null || d <= 0) return loc.requiredField;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: TaminiInput(
                      controller: _discountController,
                      labelText: loc.offerPrice,
                      hintText: loc.offerPriceHint,
                      prefixIcon: Icons.local_fire_department_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _descriptionController,
                labelText: loc.mealDescription,
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SwitchListTile(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                title: Text(
                  loc.availableForOrder,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                activeTrackColor: AppTheme.orange400,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiButton(text: loc.save, loading: _saving, onPressed: _save),
              if (_isEdit) ...[
                const SizedBox(height: AppTheme.spaceSm),
                TaminiButton(
                  text: loc.deleteMeal,
                  style: TaminiButtonStyle.danger,
                  loading: _deleting,
                  onPressed: _delete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations loc) {
    final Widget preview;
    if (_newImage != null) {
      preview = Image.file(
        File(_newImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
      );
    } else if (widget.item?.image != null) {
      preview = CachedNetworkImage(
        imageUrl: widget.item!.image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        placeholder: (_, _) => const Center(
          child: CircularProgressIndicator(color: AppTheme.orange500),
        ),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    } else {
      preview = _imagePlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppTheme.roundedXl,
          child: SizedBox(height: 180, child: preview),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppTheme.orange600,
            size: 20,
          ),
          label: Text(
            _newImage != null || widget.item?.image != null
                ? loc.changeImage
                : loc.chooseMealImage,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              color: AppTheme.orange600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
    color: AppTheme.orange50,
    child: const Center(
      child: Icon(Icons.restaurant_menu, size: 48, color: AppTheme.orange300),
    ),
  );

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppTheme.gray50,
    prefixIcon: const Icon(
      Icons.category_outlined,
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
