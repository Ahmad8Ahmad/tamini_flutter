import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import '../../support/screens/contact_us_screen.dart';
import 'change_password_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _username = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().updateProfile(
      username: _username.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? loc.profileUpdated : loc.profileUpdateFailed),
        backgroundColor: ok ? null : AppTheme.danger,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.editProfile,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaminiInput(
                controller: _username,
                labelText: loc.username,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? loc.requiredField : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _email,
                labelText: loc.email,
                prefixIcon: Icons.email_outlined,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _phone,
                labelText: loc.phone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _address,
                labelText: loc.addressOptional,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              TaminiButton(
                text: loc.save,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              TaminiButton(
                text: loc.changePassword,
                style: TaminiButtonStyle.secondary,
                icon: Icons.lock_outline,
                onPressed: () => showChangePasswordDialog(context),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                ),
                icon: const Icon(Icons.support_agent_outlined, size: 18),
                label: Text(
                  loc.helpAndSupport,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
