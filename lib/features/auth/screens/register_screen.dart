import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../../core/widgets/tamini_input.dart';
import '../../../core/widgets/language_selector.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'customer';
  bool _obscure = true;
  String? _emailError;
  String? _passwordError;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createAccount),
        actions: const [LanguageSelector()],
      ),
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
                TaminiButton(
                  text: loc.googleSignIn,
                  icon: Icons.g_mobiledata,
                  loading: auth.loading,
                  style: TaminiButtonStyle.secondary,
                  onPressed: _googleSignIn,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(loc.orContinueWith, style: AppTheme.bodySmall),
                    ),
                    const Expanded(child: Divider(color: AppTheme.border)),
                  ],
                ),
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
                        onChanged: (_) {
                          if (_emailError != null) setState(() => _emailError = null);
                        },
                        validator: (v) => v != null && v.contains('@') ? null : loc.enterValidEmail,
                      ),
                      _fieldError(_emailError, onDismiss: () => setState(() => _emailError = null)),
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
                        onChanged: (_) {
                          if (_passwordError != null) setState(() => _passwordError = null);
                        },
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.gray400, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) => v != null && v.length >= 6 ? null : loc.passwordMin6,
                      ),
                      _fieldError(_passwordError, onDismiss: () => setState(() => _passwordError = null)),
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
                _fieldError(_generalError, onDismiss: () => setState(() => _generalError = null)),
                if (_generalError != null) const SizedBox(height: AppTheme.spaceMd),
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

  Future<void> _googleSignIn() async {
    final success = await context.read<AuthProvider>().googleSignIn();
    if (!mounted) return;
    if (success) {
      context.read<CartProvider>().loadCart();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final msg =
          context.read<AuthProvider>().error ??
          AppLocalizations.of(context).googleSignInFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
      );
    }
  }

  Future<void> _register() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.registerByFirebase(
      _emailController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
      _role,
    );
    if (!mounted) return;
    if (success) {
      context.read<CartProvider>().loadCart();
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    _mapAuthError(auth.authErrorCode);
  }

  /// Maps a Firebase auth error code to the relevant field and a localized,
  /// inline (non-blocking) error message shown beneath the input.
  void _mapAuthError(String? code) {
    final loc = AppLocalizations.of(context);
    String? message;
    switch (code) {
      case 'email-already-in-use':
        message = loc.emailAlreadyInUse;
        break;
      case 'weak-password':
        message = loc.weakPassword;
        break;
      case 'invalid-email':
        message = loc.invalidEmail;
        break;
      case 'operation-not-allowed':
        message = loc.operationNotAllowed;
        break;
      case 'network-request-failed':
      case 'too-many-requests':
        message = loc.networkRequestFailed;
        break;
      default:
        message = code == null ? null : loc.genericAuthError;
    }
    setState(() {
      if (message == null) {
        _generalError = loc.registrationFailed;
        return;
      }
      if (code == 'email-already-in-use' || code == 'invalid-email') {
        _emailError = message;
      } else if (code == 'weak-password') {
        _passwordError = message;
      } else {
        _generalError = message;
      }
    });
  }

  /// Triggers the entrance animation whenever a field-level error appears.
  void _showErrorBanner() {
    if (_errorAnimController.isAnimating || _errorAnimController.status == AnimationStatus.forward) return;
    _errorAnimController.forward(from: 0);
  }

  /// A modern animated inline error banner rendered beneath an input.
  Widget _fieldError(String? message, {VoidCallback? onDismiss}) {
    if (message == null) return const SizedBox.shrink();
    _showErrorBanner();
    return FadeTransition(
      opacity: _errorFade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.15),
          end: Offset.zero,
        ).animate(_errorFade),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.dangerBg,
              borderRadius: AppTheme.roundedMd,
              border: Border.all(color: AppTheme.danger.withValues(alpha: 0.35), width: 1),
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
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
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
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
