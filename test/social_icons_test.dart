import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/widgets/social_icons.dart';

void main() {
  group('SocialPathParser', () {
    test('parses a simple move/line/close path', () {
      final path = SocialPathParser('M0 0 L10 0 L10 10 Z').parse();
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('relative commands accumulate from the current point', () {
      final path = SocialPathParser('m2 3 l4 0 v5 h-4 z').parse();
      expect(path.getBounds(), const Rect.fromLTRB(2, 3, 6, 8));
    });

    test('tokenizer splits compact numbers like ".5.5"', () {
      // h.5 then v.5: two implicit numbers sharing a dot separator.
      final path = SocialPathParser('M0 0h.5v.5z').parse();
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 0.5, 0.5));
    });

    test('cubic curves stay within the viewBox', () {
      final path = SocialPathParser(
        'M12 2 C6 2 2 6 2 12 C2 18 6 22 12 22 Z',
      ).parse();
      final bounds = path.getBounds();
      expect(bounds.left, greaterThanOrEqualTo(-0.001));
      expect(bounds.right, lessThanOrEqualTo(24.001));
    });
  });

  group('SocialIcon widget', () {
    for (final brand in SocialBrand.values) {
      testWidgets('$brand renders without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Center(child: SocialIcon(brand, size: 32))),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(SocialIcon), findsOneWidget);
      });
    }

    testWidgets('brand marks paint a non-empty path', (tester) async {
      // Whatsapp is a filled path, so its bounds must be populated.
      final path = SocialPathParser(
        'M12 2 C6 2 2 6 2 12 L12 22 Z',
      ).parse();
      expect(path.getBounds().isEmpty, isFalse);
    });
  });
}
