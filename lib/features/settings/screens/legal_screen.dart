import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_localizations.dart';

/// Renders the Terms / Privacy copy from `GET /api/legal/<slug>/`.
///
/// The backend returns HTML; the app has no HTML renderer dependency, so the
/// markup is flattened to readable paragraphs instead.
class LegalScreen extends StatefulWidget {
  final String slug;
  final String title;

  const LegalScreen({super.key, required this.slug, required this.title});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  LegalContent? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = AppLocalizations.of(context);
    final content = await context.read<SettingsProvider>().fetchLegal(
      widget.slug,
      lang: loc.isArabic ? 'ar' : 'en',
    );
    if (!mounted) return;
    setState(() {
      _content = content;
      _loading = false;
    });
  }

  static String _plainText(String html) {
    final withBreaks = html
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*(p|div|li|h[1-6])\s*>', caseSensitive: false), '\n\n');
    final stripped = withBreaks.replaceAll(RegExp(r'<[^>]*>'), '');
    return stripped
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_content == null || _content!.content.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      loc.legalUnavailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    _plainText(_content!.content),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.8),
                  ),
                ),
    );
  }
}
