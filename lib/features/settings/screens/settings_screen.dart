import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/social_icons.dart';
import '../../../core/widgets/tamini_button.dart';
import '../../support/screens/contact_us_screen.dart';
import '../../support/screens/my_tickets_screen.dart';
import 'change_password_dialog.dart';
import 'delete_account_dialog.dart';
import 'edit_profile_screen.dart';
import 'legal_screen.dart';

/// The consolidated settings area: Account, Preferences, Notifications,
/// Help & Support, Legal, About, and Delete Account.
///
/// Preferences and notification toggles are persisted through
/// `PUT /api/settings/preferences/`; legal copy through `GET /api/legal/<slug>/`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().load();
    context.read<SupportProvider>().fetchSiteSettings();
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        ),
        backgroundColor: error ? AppTheme.danger : null,
      ),
    );
  }

  Future<void> _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('SettingsScreen._launch($url): $e');
    }
  }

  Future<void> _setTheme(String theme) async {
    final settings = context.read<SettingsProvider>();
    final themeProvider = context.read<ThemeProvider>();
    await themeProvider.applyPreference(theme);
    final ok = await settings.setTheme(theme);
    if (!ok) _snack(loc.preferencesSaveFailed, error: true);
  }

  Future<void> _setToggle(String name, bool value) async {
    final settings = context.read<SettingsProvider>();
    bool ok;
    if (name == 'order') {
      ok = await settings.setOrderUpdates(value);
    } else if (name == 'promo') {
      ok = await settings.setPromotions(value);
    } else {
      ok = await settings.setEmailNotifications(value);
    }
    if (!ok) _snack(loc.preferencesSaveFailed, error: true);
  }

  AppLocalizations get loc => AppLocalizations.of(context);

  Color get _border =>
      Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkBorder
          : context.colors.borderLight;

  @override
  Widget build(BuildContext context) {
    final loc = this.loc;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final support = context.watch<SupportProvider>();
    final loggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.settings,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
      ),
      body: settings.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (loggedIn)
                  _section(
                    icon: Icons.person_outline,
                    title: loc.account,
                    child: _accountBody(loc, auth),
                  ),
                _section(
                  icon: Icons.palette_outlined,
                  title: loc.preferences,
                  child: _preferencesBody(loc, settings, loggedIn: loggedIn),
                ),
                if (!loggedIn)
                  _prompt(loc.signInSettings)
                else ...[
                  _section(
                    icon: Icons.notifications_outlined,
                    title: loc.notifications,
                    child: _notificationsBody(loc, settings),
                  ),
                  _section(
                    icon: Icons.support_agent_outlined,
                    title: loc.helpAndSupport,
                    child: _helpBody(loc, support),
                  ),
                  _section(
                    icon: Icons.description_outlined,
                    title: loc.legal,
                    child: _legalBody(loc),
                  ),
                  _section(
                    icon: Icons.info_outline,
                    title: loc.about,
                    child: _aboutBody(loc, support),
                  ),
                  _section(
                    icon: Icons.delete_outline,
                    title: loc.deleteAccount,
                    danger: true,
                    child: _dangerBody(loc),
                  ),
                ],
              ],
            ),
    );
  }

  // ── Section chrome ────────────────────────────────────────────────────

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
    bool danger = false,
  }) {
    final accent = danger ? AppTheme.danger : AppTheme.orange500;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(
          color: danger ? AppTheme.danger.withValues(alpha: 0.35) : _border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          initiallyExpanded: false,
          iconColor: accent,
          collapsedIconColor: accent,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: danger ? AppTheme.danger : null,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }

  Widget _prompt(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppTheme.roundedLg,
        border: Border.all(color: _border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tint = color ?? AppTheme.orange500;
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.roundedLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tint),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(
              loc.isArabic ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
              size: 12,
              color: AppTheme.gray400,
            ),
          ],
        ),
      ),
    );
  }

  // ── Account ───────────────────────────────────────────────────────────

  Widget _accountBody(AppLocalizations loc, AuthProvider auth) {
    final user = auth.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(loc.username, user.username),
        _row(loc.email, user.email),
        _row(loc.phone, user.phone?.isNotEmpty == true ? user.phone! : '—'),
        if (user.address != null && user.address!.isNotEmpty) _row(loc.address, user.address!),
        const SizedBox(height: 6),
        _action(
          icon: Icons.edit_outlined,
          label: loc.editProfile,
          onTap: () => _open(const EditProfileScreen()),
        ),
        _action(
          icon: Icons.lock_reset_outlined,
          label: loc.changePassword,
          onTap: () => showChangePasswordDialog(context),
        ),
      ],
    );
  }

  // ── Preferences ───────────────────────────────────────────────────────

  Widget _preferencesBody(
    AppLocalizations loc,
    SettingsProvider settings, {
    required bool loggedIn,
  }) {
    final pref = settings.pref;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.language,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        _option(
          'العربية',
          locale == 'ar',
          () => context.read<LocaleProvider>().setLocale(const Locale('ar')),
        ),
        _option(
          'English',
          locale == 'en',
          () => context.read<LocaleProvider>().setLocale(const Locale('en')),
        ),
        if (loggedIn) ...[
          const SizedBox(height: 10),
          Text(
            loc.theme,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          _option(loc.lightTheme, pref.theme == 'light', () => _setTheme('light')),
          _option(loc.systemTheme, pref.theme == 'system', () => _setTheme('system')),
          _option(loc.darkTheme, pref.theme == 'dark', () => _setTheme('dark')),
        ],
      ],
    );
  }

  Widget _option(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.roundedLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppTheme.orange500 : null,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? AppTheme.orange500 : context.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ── Notifications ─────────────────────────────────────────────────────

  Widget _notificationsBody(AppLocalizations loc, SettingsProvider settings) {
    final pref = settings.pref;
    return Column(
      children: [
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: pref.notifyOrderUpdates,
          onChanged: (v) => _setToggle('order', v),
          title: Text(loc.orderUpdates, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: pref.notifyPromotions,
          onChanged: (v) => _setToggle('promo', v),
          title: Text(loc.promotions, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: pref.notifyEmail,
          onChanged: (v) => _setToggle('email', v),
          title: Text(loc.emailNotifications, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── Help & Support ────────────────────────────────────────────────────

  Widget _helpBody(AppLocalizations loc, SupportProvider support) {
    final email = support.siteSettings?.email;
    return Column(
      children: [
        _action(
          icon: Icons.add_comment_outlined,
          label: loc.newTicket,
          onTap: () => _open(const ContactUsScreen()),
        ),
        _action(
          icon: Icons.confirmation_number_outlined,
          label: loc.myTickets,
          onTap: () => _open(const MyTicketsScreen()),
        ),
        _action(
          icon: Icons.mail_outline,
          label: loc.emailUs,
          onTap: () => _launch('mailto:${email ?? 'taminyfood@gmail.com'}'),
        ),
      ],
    );
  }

  // ── Legal ─────────────────────────────────────────────────────────────

  Widget _legalBody(AppLocalizations loc) {
    return Column(
      children: [
        _action(
          icon: Icons.article_outlined,
          label: loc.termsOfService,
          onTap: () => _open(LegalScreen(slug: 'terms', title: loc.termsOfService)),
        ),
        _action(
          icon: Icons.privacy_tip_outlined,
          label: loc.privacyPolicy,
          onTap: () => _open(LegalScreen(slug: 'privacy', title: loc.privacyPolicy)),
        ),
      ],
    );
  }

  // ── About ─────────────────────────────────────────────────────────────

  Widget _aboutBody(AppLocalizations loc, SupportProvider support) {
    final settings = support.siteSettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(loc.appVersion, AppConfig.appVersion),
        if (settings != null && settings.email.isNotEmpty)
          _row(loc.email, settings.email),
        const SizedBox(height: 4),
        Text(
          loc.followUs,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        _socialRow(settings),
      ],
    );
  }

  Widget _socialRow(SiteSettings? s) {
    if (s == null) return const SizedBox.shrink();
    final items = <(SocialBrand, String)>[
      if (s.facebook.isNotEmpty) (SocialBrand.facebook, s.facebook),
      if (s.instagram.isNotEmpty) (SocialBrand.instagram, s.instagram),
      if (s.x.isNotEmpty) (SocialBrand.x, s.x),
      if (s.snapchat.isNotEmpty) (SocialBrand.snapchat, s.snapchat),
      if (s.tiktok.isNotEmpty) (SocialBrand.tiktok, s.tiktok),
      if (s.whatsapp.isNotEmpty) (SocialBrand.whatsapp, 'https://wa.me/${s.whatsapp}'),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: items
          .map(
            (e) => IconButton(
              visualDensity: VisualDensity.compact,
              icon: SocialIcon(e.$1, size: 24),
              onPressed: () => _launch(e.$2),
            ),
          )
          .toList(),
    );
  }

  // ── Delete account ────────────────────────────────────────────────────

  Widget _dangerBody(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.deleteAccountWarning,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        TaminiButton(
          text: loc.deleteAccount,
          style: TaminiButtonStyle.danger,
          compact: true,
          icon: Icons.delete_outline,
          onPressed: () async {
            final deleted = await showDeleteAccountDialog(context);
            if (!deleted || !mounted) return;
            _snack(loc.accountDeleted);
            await context.read<AuthProvider>().logout();
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
