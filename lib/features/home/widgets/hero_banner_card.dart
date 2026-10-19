import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import '../../../core/theme/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';

class HeroBannerCard extends StatelessWidget {
  const HeroBannerCard({super.key, required this.banner});

  final HeroBanner banner;

  Future<void> _handleCta(BuildContext context) async {
    final url = banner.ctaUrl?.trim().toLowerCase() ?? '';
    if (url.contains('register') ||
        url.contains('signup') ||
        url.contains('sign-up')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return;
    }
    if (url.contains('login') ||
        url.contains('signin') ||
        url.contains('sign-in')) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (banner.ctaUrl != null && banner.ctaUrl!.isNotEmpty) {
      final uri = Uri.parse(banner.ctaUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCta = banner.ctaUrl != null && banner.ctaUrl!.isNotEmpty;
    final loc = AppLocalizations.of(context);
    final bannerTitle = loc.backendText(banner.title);
    final bannerSubtitle = loc.backendText(banner.subtitle);
    final bannerCtaText = loc.backendText(banner.ctaText);

    final bannerWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(
          colors: [AppTheme.orange400, AppTheme.orange600],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.image != null)
              CachedNetworkImage(
                imageUrl: banner.image!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(),
                errorWidget: (_, _, _) => const SizedBox(),
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      bannerTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (bannerSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        bannerSubtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (bannerCtaText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white, // theme-guardrail: allow
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bannerCtaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.orange600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                              size: 14,
                              color: AppTheme.orange600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!hasCta) return bannerWidget;
    return GestureDetector(
      onTap: () => _handleCta(context),
      child: bannerWidget,
    );
  }
}
