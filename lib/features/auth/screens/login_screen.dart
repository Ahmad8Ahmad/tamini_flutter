import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../dashboard/screens/restaurant_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
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
                    child: const Icon(Icons.restaurant, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(loc.appName, style: AppTheme.displayMedium.copyWith(color: AppTheme.orange600)),
                  const SizedBox(height: 8),
                  Text(loc.welcomeBack, style: AppTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text(loc.signInToContinue, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                  SizedBox(height: size.height * 0.06),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
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
                          validator: (v) => v != null && v.contains('@') ? null : loc.enterValidEmail,
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        TaminiInput(
                          controller: _passwordController,
                          labelText: loc.password,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.gray400, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) => v != null && v.length >= 6 ? null : loc.passwordMin6,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        TaminiButton(
                          text: loc.login,
                          loading: auth.loading,
                          onPressed: _login,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(loc.dontHaveAccount, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const RegisterScreen(),
                          transitionsBuilder: (_, anim, __, child) => SlideTransition(
                            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        )),
                        child: Text(loc.register, style: AppTheme.bodyMedium.copyWith(color: AppTheme.orange600, fontWeight: FontWeight.w800)),
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
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.read<CartProvider>().loadCart();
      final role = context.read<AuthProvider>().user?.role ?? 'customer';
      final destination = role == 'restaurant' ? const RestaurantDashboardScreen() : const HomeScreen();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => destination), (_) => false);
    } else {
      final msg = context.read<AuthProvider>().error ?? AppLocalizations.of(context).loginFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
