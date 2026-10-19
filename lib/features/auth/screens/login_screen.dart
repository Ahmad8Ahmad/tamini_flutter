import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String? _generalError;

  late final AnimationController _errorAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _errorFade = CurvedAnimation(
    parent: _errorAnimController,
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.colors.tint, context.colors.background],
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
                      // Brand Header
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.appName,
                        style: AppTheme.displayMedium.copyWith(
                          color: AppTheme.orange600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(loc.welcomeBack, style: AppTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        loc.signInToContinue,
                        style: AppTheme.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: size.height * 0.06),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spaceLg),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXxl,
                          ),
                          boxShadow: AppTheme.shadowLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TaminiInput(
                              controller: _emailController,
                              labelText: loc.email,
                              hintText: 'name@example.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : loc.enterValidEmail,
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            TaminiInput(
                              controller: _passwordController,
                              labelText: loc.password,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.gray400,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => v != null && v.length >= 6
                                  ? null
                                  : loc.passwordMin6,
                              onFieldSubmitted: (_) => _login(),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: Text(
                                  loc.forgotPassword,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.orange600,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            TaminiButton(
                              text: loc.login,
                              loading: auth.loading,
                              onPressed: _login,
                            ),
                            _errorBanner(_generalError),
                            const SizedBox(height: AppTheme.spaceMd),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: context.colors.border),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    loc.orContinueWith,
                                    style: AppTheme.bodySmall,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: context.colors.border),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            TaminiButton(
                              text: loc.googleSignIn,
                              icon: Icons.g_mobiledata,
                              loading: auth.loading,
                              style: TaminiButtonStyle.secondary,
                              onPressed: _googleSignIn,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loc.dontHaveAccount,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, _, _) =>
                                    const RegisterScreen(),
                                transitionsBuilder: (_, anim, _, child) =>
                                    SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(1, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: anim,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                              ),
                            ),
                            child: Text(
                              loc.register,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.orange600,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: const LanguageSelector(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _generalError = null);
    final success = await context.read<AuthProvider>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      unawaited(context.read<CartProvider>().loadCart());
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _mapLoginError(context.read<AuthProvider>());
    }
  }

  /// Turns a failed login into one friendly, localized message. Firebase
  /// reports a code for bad credentials; anything else keeps the backend's own
  /// (already localized) detail, e.g. a pending-approval notice or network
  /// error, rather than the raw "No active account found" text.
  void _mapLoginError(AuthProvider auth) {
    final loc = AppLocalizations.of(context);
    String message;
    switch (auth.authErrorCode) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-not-found':
        message = loc.invalidCredentials;
        break;
      case 'network-request-failed':
      case 'too-many-requests':
        message = loc.networkRequestFailed;
        break;
      default:
        message = auth.error ?? loc.loginFailed;
    }
    setState(() => _generalError = message);
    _showErrorBanner();
  }

  Future<void> _googleSignIn() async {
    setState(() => _generalError = null);
    final success = await context.read<AuthProvider>().googleSignIn();
    if (!mounted) return;
    if (success) {
      unawaited(context.read<CartProvider>().loadCart());
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(
        () => _generalError =
            context.read<AuthProvider>().error ??
            AppLocalizations.of(context).googleSignInFailed,
      );
      _showErrorBanner();
    }
  }

  /// Restarts the entrance animation whenever the error banner appears.
  void _showErrorBanner() {
    _errorAnimController.forward(from: 0);
  }

  /// A modern animated inline error banner, matching the registration screen.
  Widget _errorBanner(String? message) {
    if (message == null) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _errorFade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.15),
          end: Offset.zero,
        ).animate(_errorFade),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.dangerBg,
              borderRadius: AppTheme.roundedMd,
              border: Border.all(
                color: AppTheme.danger.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.danger,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.danger,
                      height: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _generalError = null),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.close,
                      color: AppTheme.danger,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _errorAnimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
