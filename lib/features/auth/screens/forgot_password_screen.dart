import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import '../../../core/widgets/language_selector.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.forgotPassword),
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
            child: Form(
              key: _formKey,
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
                      Icons.lock_reset_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(
                    _sent ? loc.emailSent : loc.forgotPassword,
                    style: AppTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    _sent ? loc.checkYourEmail : loc.forgotPasswordSubtitle,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_sent) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successBg,
                        borderRadius: AppTheme.roundedLg,
                        border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _emailController.text.trim(),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: size.height * 0.04),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spaceLg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusXxl,
                        ),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: TaminiInput(
                        controller: _emailController,
                        labelText: loc.email,
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : loc.enterValidEmail,
                        onFieldSubmitted: (_) => _resetPassword(),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spaceXl),
                  if (_sent)
                    TaminiButton(
                      text: loc.back,
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    TaminiButton(
                      text: loc.resetPassword,
                      loading: auth.loading,
                      onPressed: _resetPassword,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().forgotPassword(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      final loc = AppLocalizations.of(context);
      final msg =
          context.read<AuthProvider>().error ?? loc.resetPasswordFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
