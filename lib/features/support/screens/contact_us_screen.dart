import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_localizations.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null) {
      _nameCtrl.text = user.username;
      _emailCtrl.text = user.email;
      if (user.phone != null) _phoneCtrl.text = user.phone!;
    }
    context.read<SupportProvider>().fetchSiteSettings();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SupportProvider>();
    final ok = await provider.submitTicket(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.ticketFailed), backgroundColor: AppTheme.danger),
      );
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SupportProvider>().siteSettings;

    return Scaffold(
      appBar: AppBar(title: Text(loc.contactUs, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800))),
      body: _sent ? _buildSuccess(loc) : _buildForm(loc, settings),
    );
  }

  Widget _buildSuccess(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(color: AppTheme.successBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, size: 48, color: AppTheme.success),
            ),
            const SizedBox(height: 24),
            Text(loc.ticketSent, style: AppTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _sent = false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.orange500,
                  side: const BorderSide(color: AppTheme.orange300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
                ),
                child: Text(loc.send, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations loc, SiteSettings? settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.contactSubtitle, style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spaceLg),
          _contactCards(loc, settings),
          const SizedBox(height: AppTheme.spaceLg),
          if (settings != null) _socialRow(loc, settings),
          if (settings != null) const SizedBox(height: AppTheme.spaceLg),
          _buildFormFields(loc),
        ],
      ),
    );
  }

  Widget _contactCards(AppLocalizations loc, SiteSettings? settings) {
    return Row(
      children: [
        Expanded(child: _contactCard(Icons.email_outlined, loc.emailUs, settings?.email ?? 'taminyfood@gmail.com', () => _launch('mailto:${settings?.email ?? 'taminyfood@gmail.com'}'))),
        const SizedBox(width: 10),
        Expanded(child: _contactCard(Icons.phone_outlined, loc.callUs, settings?.phone ?? '+963 900 000 000', () => _launch('tel:${settings?.phone ?? '+963900000000'}'))),
        const SizedBox(width: 10),
        Expanded(child: _contactCard(Icons.chat_outlined, loc.whatsapp, settings?.whatsapp ?? '963900000000', () => _launch('https://wa.me/${settings?.whatsapp ?? '963900000000'}'))),
      ],
    );
  }

  Widget _contactCard(IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _copy(value, label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.roundedXl,
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppTheme.orange50, shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.orange500, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value.replaceAll(RegExp(r'[^0-9]'), ''), style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _socialRow(AppLocalizations loc, SiteSettings s) {
    final items = [
      if (s.facebook.isNotEmpty) ('Facebook', Icons.people_outline, s.facebook),
      if (s.instagram.isNotEmpty) ('Instagram', Icons.camera_alt_outlined, s.instagram),
      if (s.x.isNotEmpty) ('X', Icons.alternate_email, s.x),
      if (s.snapchat.isNotEmpty) ('Snapchat', Icons.photo_camera_outlined, s.snapchat),
      if (s.tiktok.isNotEmpty) ('TikTok', Icons.music_note_outlined, s.tiktok),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.followUs, style: AppTheme.headlineSmall),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: IconButton(
              icon: Icon(e.$2, color: AppTheme.orange500),
              onPressed: () => _launch(e.$3),
              tooltip: e.$1,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFormFields(AppLocalizations loc) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.contactInfo, style: AppTheme.headlineSmall),
          const SizedBox(height: 12),
          _field(loc.yourNameField, _nameCtrl, validator: (v) => v != null && v.trim().isEmpty ? loc.requiredField : null),
          const SizedBox(height: 12),
          _field(loc.email, _emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) {
            if (v == null || v.trim().isEmpty) return loc.requiredField;
            if (!v.contains('@')) return loc.enterValidEmail;
            return null;
          }),
          const SizedBox(height: 12),
          _field(loc.phoneOptional, _phoneCtrl, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _field(loc.subject, _subjectCtrl, hint: loc.subjectHint, validator: (v) => v != null && v.trim().isEmpty ? loc.requiredField : null),
          const SizedBox(height: 12),
          _field(loc.description, _descCtrl, hint: loc.descriptionHint, maxLines: 5, validator: (v) => v != null && v.trim().isEmpty ? loc.requiredField : null),
          const SizedBox(height: AppTheme.spaceLg),
          Consumer<SupportProvider>(
            builder: (ctx, p, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: p.loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.orange300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
                  elevation: 0,
                ),
                child: p.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(loc.send, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, TextInputType? keyboardType, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppTheme.textMuted, fontSize: 13),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppTheme.gray400, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: AppTheme.roundedLg,
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.roundedLg,
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.roundedLg,
          borderSide: const BorderSide(color: AppTheme.orange400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.roundedLg,
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
