import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/language_selector.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});
  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _pollTimer;
  bool _sending = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _sending = true);
    await context.read<AuthProvider>().sendVerificationEmail(widget.email);
    if (!mounted) return;
    setState(() => _sending = false);
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final verified =
          await context.read<AuthProvider>().checkEmailVerified(widget.email);
      if (verified && mounted) {
        _pollTimer?.cancel();
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.emailVerifiedSuccess),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final verified =
        await context.read<AuthProvider>().checkEmailVerified(widget.email);
    if (!mounted) return;
    setState(() => _checking = false);
    final loc = AppLocalizations.of(context);
    if (verified) {
      _pollTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.emailVerifiedSuccess),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.emailNotVerified),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.verifyEmail),
        actions: const [LanguageSelector()],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.orange50, AppTheme.gray50],
            stops: [0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceLg,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  loc.verificationEmailSent,
                  style: AppTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  loc.checkInboxVerify,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBg,
                    borderRadius: AppTheme.roundedLg,
                    border: Border.all(
                      color: AppTheme.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppTheme.info,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                TaminiButton(
                  text: loc.checkStatus,
                  loading: _checking,
                  onPressed: _checkNow,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TaminiButton(
                  text: loc.resendVerification,
                  style: TaminiButtonStyle.ghost,
                  loading: _sending,
                  onPressed: _sending ? null : _sendVerificationEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
