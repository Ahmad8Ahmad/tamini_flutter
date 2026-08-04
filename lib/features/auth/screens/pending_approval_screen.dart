import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../home/screens/home_screen.dart';
import '../../dashboard/screens/restaurant_dashboard_screen.dart';
import '../../delivery/screens/delivery_dashboard_screen.dart';

Widget buildRoleDestination(User? user) {
  if (user == null) return const HomeScreen();
  if (user.role == 'restaurant') {
    return user.isApproved ? const RestaurantDashboardScreen() : const PendingApprovalScreen();
  }
  if (user.role == 'delivery') {
    return user.isApproved ? const DeliveryDashboardScreen() : const PendingApprovalScreen();
  }
  return const HomeScreen();
}

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});
  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    context.read<SupportProvider>().fetchSiteSettings();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _checkStatus() async {
    final loc = AppLocalizations.of(context);
    setState(() => _checking = true);
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    setState(() => _checking = false);
    if (auth.user?.isApproved == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => buildRoleDestination(auth.user)),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.driverPendingApprovalHint),
        backgroundColor: AppTheme.warning,
      ));
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SupportProvider>().siteSettings;
    final isRestaurant = user?.role == 'restaurant';
    final whatsapp = settings?.whatsapp.isNotEmpty == true ? settings!.whatsapp : '963900000000';
    final email = settings?.email.isNotEmpty == true ? settings!.email : 'taminyfood@gmail.com';

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppTheme.gray50,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
                boxShadow: AppTheme.shadowLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.orange50),
                    child: RotationTransition(
                      turns: _spin,
                      child: const Center(child: Icon(Icons.hourglass_empty, size: 48, color: AppTheme.orange400)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRestaurant ? loc.restaurantNotApproved : loc.accountUnderReview,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    loc.underReviewBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: 28),
                  _contactButton(
                    label: loc.contactWhatsapp,
                    color: const Color(0xFF25D366),
                    icon: Icons.chat,
                    onTap: () => _launch('https://wa.me/$whatsapp'),
                  ),
                  const SizedBox(height: 12),
                  _contactButton(
                    label: loc.contactEmail,
                    color: const Color(0xFF3B82F6),
                    icon: Icons.email_outlined,
                    onTap: () => _launch('mailto:$email'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
                      ),
                      child: Text(loc.backToHome),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _checking ? null : _checkStatus,
                    icon: _checking
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.orange500))
                        : const Icon(Icons.refresh, size: 18),
                    label: Text(loc.checkStatus),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _logout,
                    child: Text(loc.logout, style: const TextStyle(color: AppTheme.textMuted)),
                  ),
                  const SizedBox(height: 8),
                  Text(loc.joinThanks, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactButton({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
        ),
      ),
    );
  }
}
