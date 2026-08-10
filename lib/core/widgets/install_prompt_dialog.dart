import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/session_store.dart';
import '../theme/app_localizations.dart';
import '../theme/app_theme.dart';

/// Centered install prompt shown once per web session.
///
/// Dismissing it (X, "continue in browser", or tapping the CTA) stores a
/// [SessionStore] flag so it stays hidden while navigating the site; reopening
/// the browser/tab later shows it again.
Future<void> showInstallPromptDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);

  void close() {
    SessionStore.dismissInstallPrompt();
    Navigator.of(context).pop();
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => Dialog(
      elevation: 24,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.roundedXl),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: AppTheme.roundedMd,
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Text(
                    l10n.installPromptTitle,
                    style: AppTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: close,
                  tooltip: l10n.cancel,
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l10n.installPromptBody,
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spaceXl),
            ElevatedButton.icon(
              onPressed: () {
                close();
                launchUrl(
                  Uri.parse(AppConfig.downloadPageUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(Icons.download, size: 20),
              label: Text(l10n.downloadAppNow),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextButton(
              onPressed: close,
              child: Text(l10n.continueInBrowser),
            ),
          ],
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        ),
        child: child,
      ),
    ),
  );
}
