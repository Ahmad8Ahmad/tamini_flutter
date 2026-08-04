import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import 'otp_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'customer';
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.createAccount)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.orange50, AppTheme.gray50],
            stops: [0, 0.2],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spaceMd),
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
                        controller: _usernameController,
                        labelText: loc.username,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v != null && v.isNotEmpty ? null : loc.requiredField,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      TaminiInput(
                        controller: _phoneController,
                        labelText: loc.phoneOptional,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      // Role selector as segmented buttons
                      Text(loc.registerAs, style: AppTheme.labelLarge.copyWith(color: AppTheme.gray600)),
                      const SizedBox(height: AppTheme.spaceSm),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gray50,
                          borderRadius: AppTheme.roundedLg,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _roleChip(loc.customer, 'customer'),
                            _roleChip(loc.restaurantOwner, 'restaurant'),
                            _roleChip(loc.deliveryDriver, 'delivery'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      TaminiInput(
                        controller: _passwordController,
                        labelText: loc.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.gray400, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) => v != null && v.length >= 6 ? null : loc.passwordMin6,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      TaminiInput(
                        controller: _confirmController,
                        labelText: loc.confirmPassword,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) => v == _passwordController.text ? null : loc.passwordsDontMatch,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                TaminiButton(
                  text: loc.register,
                  loading: auth.loading,
                  onPressed: _register,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.alreadyHaveAccount, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text(loc.login, style: AppTheme.bodyMedium.copyWith(color: AppTheme.orange600, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String label, String value) {
    final isSelected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.orange500 : Colors.transparent,
            borderRadius: AppTheme.roundedMd,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final otpDebug = await context.read<AuthProvider>().register(
      _emailController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
      _confirmController.text,
      _role,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
    );
    if (!mounted) return;
    if (otpDebug != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(email: _emailController.text.trim(), debugOtp: otpDebug)),
      );
    } else {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.registerFailed),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
