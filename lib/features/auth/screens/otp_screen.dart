import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/widgets/tamini_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String? debugOtp;
  const OtpScreen({super.key, required this.email, this.debugOtp});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.verifyEmail)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.orange50, AppTheme.gray50],
            stops: [0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spaceXl),
                // Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(loc.enterVerificationCode, style: AppTheme.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: AppTheme.spaceSm),
                if (widget.debugOtp != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBg,
                      borderRadius: AppTheme.roundedLg,
                      border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.science_outlined, size: 18, color: AppTheme.info),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${loc.isArabic ? 'رمز التحقق (تجريبي):' : 'Debug code:'} ${widget.debugOtp}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.info,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                ],
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${loc.otpSentTo}\n',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.orange600, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),

                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) => _buildOtpBox(i)),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                TaminiButton(
                  text: loc.verify,
                  loading: auth.loading,
                  onPressed: _verify,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TaminiButton(
                  text: loc.retry,
                  style: TaminiButtonStyle.ghost,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: AppTheme.roundedLg,
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTheme.roundedLg,
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.roundedLg,
            borderSide: const BorderSide(color: AppTheme.orange500, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            _verify();
          }
        },
      ),
    );
  }

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) return;
    final success = await context.read<AuthProvider>().verifyOtp(widget.email, otp);
    if (!mounted) return;
    if (success) {
      context.read<CartProvider>().loadCart();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.invalidOtp),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final n in _focusNodes) { n.dispose(); }
    super.dispose();
  }
}
