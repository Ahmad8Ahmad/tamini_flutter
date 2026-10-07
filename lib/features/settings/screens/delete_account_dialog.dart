import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';

/// Shows the destructive-account confirmation and runs the two-step proof of
/// ownership the backend expects (`{id_token}` or `{email, password}`).
///
/// Returns true when the account was actually deleted.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final deleted = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return deleted ?? false;
}

bool _hasPasswordProvider(User user) =>
    user.providerData.any((info) => info.providerId == 'password');

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

  /// Whether the dialog must ask for a password: true when there is no
  /// Firebase session to reauthenticate, or when that session is backed by
  /// an email/password credential.
  bool get _needsPassword {
    final fbUser = FirebaseAuth.instance.currentUser;
    return fbUser == null || _hasPasswordProvider(fbUser);
  }

  Future<int?> _delete() async {
    final settings = context.read<SettingsProvider>();
    final authUser = context.read<AuthProvider>().user;
    final password = _passwordCtrl.text;
    final fb = FirebaseAuth.instance;
    var fbUser = fb.currentUser;

    // 1. Password-backed account: re-enter it locally, then prove it with a
    //    freshly minted ID token. Falls back to server-side verification when
    //    the local reauthentication is unavailable.
    if (fbUser != null && _hasPasswordProvider(fbUser)) {
      try {
        await fbUser.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: fbUser.email ?? authUser?.email ?? '',
            password: password,
          ),
        );
      } catch (e) {
        debugPrint('deleteAccount: local reauth failed, trying API: $e');
        return settings.deleteAccount(email: authUser?.email, password: password);
      }
      final token = await fbUser.getIdToken(true);
      if (token != null) return settings.deleteAccount(idToken: token);
    }

    // 2. Google-backed account (or no Firebase session yet): sign in again to
    //    prove presence, then send the resulting ID token.
    final googleUser = await GoogleSignIn(scopes: ['email']).signInSilently();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      try {
        fbUser ??= (await fb.signInWithCredential(credential)).user;
        if (fbUser != null) {
          await fbUser.reauthenticateWithCredential(credential);
          final token = await fbUser.getIdToken(true);
          if (token != null) {
            return await settings.deleteAccount(idToken: token);
          }
        }
      } catch (e) {
        debugPrint('deleteAccount: Google reauthentication failed: $e');
        return 0;
      }
    }

    // 3. Backend-only account: let the server verify the credentials against
    //    Firebase Identity Toolkit.
    if (password.isEmpty) return 0;
    return settings.deleteAccount(email: authUser?.email, password: password);
  }

  Future<void> _confirm() async {
    if (_needsPassword && _passwordCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    final status = await _delete();
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
          if (_needsPassword) ...[
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
