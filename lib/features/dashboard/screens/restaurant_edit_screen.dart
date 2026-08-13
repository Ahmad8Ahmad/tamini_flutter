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
import '../../../core/widgets/language_selector.dart';

class RestaurantEditScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantEditScreen({super.key, required this.restaurant});

  @override
  State<RestaurantEditScreen> createState() => _RestaurantEditScreenState();
}

class _RestaurantEditScreenState extends State<RestaurantEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  XFile? _newLogo;
  XFile? _newCover;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _nameController = TextEditingController(text: r.name);
    _descriptionController = TextEditingController(text: r.description ?? '');
    _addressController = TextEditingController(text: r.address ?? '');
    _phoneController = TextEditingController(text: r.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<XFile?> _pickImage() async {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
  }

  Future<void> _pickLogo() async {
    final picked = await _pickImage();
    if (picked != null) setState(() => _newLogo = picked);
  }

  Future<void> _pickCover() async {
    final picked = await _pickImage();
    if (picked != null) setState(() => _newCover = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context);
    setState(() => _saving = true);
    final provider = context.read<RestaurantProvider>();
    final result = await provider.updateRestaurant(
      id: widget.restaurant.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      logo: _newLogo,
      coverImage: _newCover,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null ? loc.savedSuccessfully : loc.errorOccurred),
        backgroundColor: result != null ? AppTheme.success : AppTheme.danger,
      ),
    );
    if (result != null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.editRestaurant),
        actions: const [LanguageSelector()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCoverPicker(loc),
              const SizedBox(height: AppTheme.spaceLg),
              _buildLogoPicker(loc),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiInput(
                controller: _nameController,
                labelText: loc.restaurantName,
                prefixIcon: Icons.storefront_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? loc.requiredField : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _descriptionController,
                labelText: loc.restaurantDescription,
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _addressController,
                labelText: loc.address,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _phoneController,
                labelText: loc.restaurantPhone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiButton(
                text: loc.save,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPicker(AppLocalizations loc) {
    return _imagePicker(
      title: loc.chooseCoverImage,
      changeLabel: loc.changeCoverImage,
      currentUrl: widget.restaurant.coverImage,
      newFile: _newCover,
      onPick: _pickCover,
      height: 160,
      placeholderIcon: Icons.photo_outlined,
    );
  }

  Widget _buildLogoPicker(AppLocalizations loc) {
    return _imagePicker(
      title: loc.chooseLogo,
      changeLabel: loc.changeLogo,
      currentUrl: widget.restaurant.logo,
      newFile: _newLogo,
      onPick: _pickLogo,
      height: 160,
      placeholderIcon: Icons.storefront_outlined,
    );
  }

  Widget _imagePicker({
    required String title,
    required String changeLabel,
    required String? currentUrl,
    required XFile? newFile,
    required Future<void> Function() onPick,
    required double height,
    required IconData placeholderIcon,
  }) {
    final Widget preview;
    if (newFile != null) {
      preview = Image.file(
        File(newFile.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
      );
    } else if (currentUrl != null) {
      preview = CachedNetworkImage(
        imageUrl: currentUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        placeholder: (_, _) => const Center(
          child: CircularProgressIndicator(color: AppTheme.orange500),
        ),
        errorWidget: (_, _, _) => _imagePlaceholder(placeholderIcon),
      );
    } else {
      preview = _imagePlaceholder(placeholderIcon);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppTheme.roundedXl,
          child: SizedBox(height: height, child: preview),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        TextButton.icon(
          onPressed: onPick,
          icon: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppTheme.orange600,
            size: 20,
          ),
          label: Text(
            newFile != null || currentUrl != null ? changeLabel : title,
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

  Widget _imagePlaceholder(IconData icon) => Container(
    color: AppTheme.orange50,
    child: Center(
      child: Icon(icon, size: 48, color: AppTheme.orange300),
    ),
  );
}
