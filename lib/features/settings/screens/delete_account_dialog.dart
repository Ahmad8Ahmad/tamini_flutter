import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';

/// Shows the destructive-account confirmation and runs the two-step proof of
/// ownership the backend expects, delegated to [AuthProvider].
///
/// Returns true when the account was actually deleted.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final deleted = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return deleted ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final auth = context.read<AuthProvider>();
    if (auth.deleteAccountRequiresPassword && _passwordCtrl.text.isEmpty) {
      return;
    }
    setState(() => _saving = true);
    final status = await auth.deleteAccount(password: _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _saving = false);

    if (status == null) {
      Navigator.of(context).pop(true);
      return;
    }

    final loc = AppLocalizations.of(context);
    final message = switch (status) {
      401 => loc.deleteWrongPassword,
      403 => loc.deleteNotYours,
      419 || 429 => loc.deleteTooManyAttempts,
      0 => loc.deleteAccountFailed,
      _ => status >= 500 ? loc.deleteAccountFailed : loc.deleteVerifyFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final requiresPassword =
        context.read<AuthProvider>().deleteAccountRequiresPassword;

    return AlertDialog(
      title: Text(
        loc.deleteAccountTitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppTheme.danger,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.deleteAccountWarning,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.6),
          ),
          if (requiresPassword) ...[
            const SizedBox(height: AppTheme.spaceMd),
            TaminiInput(
              controller: _passwordCtrl,
              labelText: loc.passwordToConfirm,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(loc.cancel, style: const TextStyle(fontFamily: 'Cairo')),
        ),
        TaminiButton(
          text: loc.deleteAccountConfirm,
          compact: true,
          width: 160,
          loading: _saving,
          style: TaminiButtonStyle.danger,
          onPressed: _confirm,
        ),
      ],
    );
  }
}
