import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import '../theme/app_localizations.dart';
import '../theme/app_theme.dart';

/// Returns `true` when the user clicked "Later" (or dismissed) and the
/// prompt should be remembered, or `false` when the user chose "Update Now".
Future<bool> showUpdateDialog(BuildContext context, UpdateInfo update) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !update.isRequired,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.system_update_alt, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.updateAvailable)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.updateMessage),
          if (update.notes != null && update.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(update.notes!, style: AppTheme.bodyMedium),
          ],
        ],
      ),
      actions: [
        if (!update.isRequired)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.later),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(dialogContext).pop(false);
            launchUrl(
              Uri.parse(update.apkUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          icon: const Icon(Icons.download, size: 18),
          label: Text(l10n.updateNow),
        ),
      ],
    ),
  );
  return result ?? true;
}
