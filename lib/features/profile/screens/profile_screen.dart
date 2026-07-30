import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../support/screens/contact_us_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800))),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(color: AppTheme.orange50, shape: BoxShape.circle),
                      child: const Icon(Icons.person_outline, size: 48, color: AppTheme.orange300),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Text(loc.notLoggedIn, style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(height: AppTheme.spaceLg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orange500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: Text(loc.isArabic ? 'تسجيل الدخول' : 'Log In', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.orange500,
                          side: const BorderSide(color: AppTheme.orange300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: Text(loc.isArabic ? 'إنشاء حساب' : 'Create Account', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
              children: [
                const SizedBox(height: AppTheme.spaceLg),
                // Avatar
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.avatarGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user!.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                // Name + Role
                Text(
                  user!.username.isNotEmpty ? user!.username : user!.email,
                  textAlign: TextAlign.center,
                  style: AppTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      user!.role.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.orange600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),

                // Info Cards
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: loc.username,
                  value: user!.username,
                ),
                if (user!.phone != null && user!.phone!.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.phone_outlined,
                    label: loc.phone,
                    value: user!.phone!,
                  ),
                if (user!.address != null && user!.address!.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    label: loc.address,
                    value: user!.address!,
                  ),
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: loc.email,
                  value: user!.email,
                ),

                const SizedBox(height: AppTheme.spaceLg),

                // Contact Us
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.roundedLg,
                    border: Border.all(color: AppTheme.orange100),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.orange50, shape: BoxShape.circle),
                      child: const Icon(Icons.headset_mic_outlined, color: AppTheme.orange500, size: 18),
                    ),
                    title: Text(
                      loc.contactUs,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.gray300),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Logout Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.roundedLg,
                    border: Border.all(color: AppTheme.dangerBg),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.dangerBg, shape: BoxShape.circle),
                      child: const Icon(Icons.logout, color: AppTheme.danger, size: 18),
                    ),
                    title: Text(
                      loc.logout,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppTheme.danger),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedLg),
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.orange50, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.orange400, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
