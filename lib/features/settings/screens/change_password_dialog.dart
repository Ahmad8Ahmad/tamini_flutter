import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';

Future<void> showChangePasswordDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => const _ChangePasswordDialog(),
);

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final status = await context.read<AuthProvider>().changePassword(
      oldPassword: _oldCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final loc = AppLocalizations.of(context);
    if (status == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.passwordChanged)),
      );
      return;
    }
    // 400 from the API means the old password (or the strength validator)
    // was rejected; the form already enforces the strength rule.
    final message = status == 400 ? loc.oldPasswordIncorrect : loc.passwordChangeFailed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        loc.changePassword,
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TaminiInput(
                controller: _oldCtrl,
                labelText: loc.password,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? loc.requiredField : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _newCtrl,
                labelText: loc.newPasswordRule,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? loc.newPasswordRule : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TaminiInput(
                controller: _confirmCtrl,
                labelText: loc.confirmPassword,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v != _newCtrl.text ? loc.passwordsDontMatch : null,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(loc.cancel, style: const TextStyle(fontFamily: 'Cairo')),
        ),
        TaminiButton(
          text: loc.save,
          compact: true,
          width: 120,
          loading: _saving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
