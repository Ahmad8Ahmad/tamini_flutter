import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Dark-mode theme guardrail.
///
/// Scans lib/ for light-only color patterns that break dark mode:
/// - hardcoded white surfaces (Scaffold/AppBar/Container/...)
/// - the static light-only AppTheme color tokens (card, textPrimary, ...)
///
/// The theme source of truth (lib/core/theme/) is exempt: it is where the
/// light and dark values are defined. Dormant/never-routed screens are also
/// exempt (they are not reachable in the app).
///
/// To intentionally keep a white foreground/overlay (e.g. white on a
/// gradient), add `// theme-guardrail: allow` on the offending line or the
/// line above it.
const _allowComment = 'theme-guardrail: allow';

const _exemptFiles = {
  'lib/core/theme/app_theme.dart',
  'lib/core/theme/app_palette.dart',
  'lib/features/delivery/screens/delivery_dashboard_screen.dart',
  'lib/features/owner/screens/restaurant_dashboard_screen.dart',
  'lib/features/auth/screens/otp_screen.dart',
  'lib/features/auth/screens/email_verification_screen.dart',
};

const _rules = <String, String>{
  'Scaffold/AppBar/bottom-bar white background':
      r'backgroundColor:\s*Colors\.white\s*[,)]',
  'white input fill': r'fillColor:\s*Colors\.white\s*[,)]',
  'white BoxDecoration/Container/Material/Card surface':
      r'(?:BoxDecoration|Material|Card)\(\s*color:\s*Colors\.white\s*[,)]',
  'static light-only AppTheme color token':
      r'AppTheme\.(?:card|background|textPrimary|textSecondary|textMuted|borderLight|primaryLight)\b|AppTheme\.border\b',
};

List<File> _dartFilesIn(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  final libDir = Directory('lib');
  final files = _dartFilesIn(libDir).where((f) {
    final path = f.path.replaceAll('\\', '/');
    return !_exemptFiles.contains(path);
  }).toList();

  test('guardrail scans the codebase (found enough files)', () {
    expect(files.length, greaterThanOrEqualTo(50),
        reason: 'lib/ scan looks broken — only ${files.length} files found.');
  });

  for (final entry in _rules.entries) {
    test('no ${entry.key} outside the theme', () {
      final violations = <String>[];
      final pattern = RegExp(entry.value, multiLine: true);
      final allowPattern = RegExp(_allowComment);

      for (final file in files) {
        final content = file.readAsStringSync();
        if (!pattern.hasMatch(content)) continue;

        final lines = content.split('\n');
        for (final m in pattern.allMatches(content)) {
          final startIdx = content.substring(0, m.start).split('\n').length - 1;
          final endIdx = startIdx + m.group(0)!.split('\n').length - 1;
          var allowed = false;
          for (var i = startIdx > 0 ? startIdx - 1 : 0; i <= endIdx; i++) {
            if (allowPattern.hasMatch(lines[i])) {
              allowed = true;
              break;
            }
          }
          if (allowed) continue;
          final path = file.path.replaceAll('\\', '/');
          violations.add('$path:${startIdx + 1}: ${m.group(0)!.replaceAll('\n', ' ')}');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Hardcoded light-only colors found:\n'
            '${violations.join('\n')}\n'
            'Use context.colors.* (or Theme.of(context)) instead, or add a '
            '"// $_allowComment" comment if white-on-color is intentional.',
      );
    });
  }
}
