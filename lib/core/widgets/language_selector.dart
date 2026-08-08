import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_localizations.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    return PopupMenuButton<String>(
      tooltip: AppLocalizations.of(context).language,
      icon: const Icon(Icons.language, color: AppTheme.orange500),
      onSelected: (code) => localeProvider.setLocale(Locale(code)),
      itemBuilder: (_) {
        final current = localeProvider.locale.languageCode;
        const languages = [
          (code: 'ar', label: 'العربية'),
          (code: 'en', label: 'English'),
          (code: 'sv', label: 'Svenska'),
        ];
        return languages
            .map((l) => PopupMenuItem(
                  value: l.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.label,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (l.code == current) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check, size: 16, color: AppTheme.orange600),
                      ],
                    ],
                  ),
                ))
            .toList();
      },
    );
  }
}
