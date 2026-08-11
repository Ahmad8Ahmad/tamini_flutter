import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/theme/app_localizations.dart';

void main() {
  group('backendText localization', () {
    const backendArabic = {
      'title': 'أهلاً بك في طعميني',
      'subtitle':
          'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ',
      'bannerTitle': 'سجل الأن',
      'bannerSubtitle': 'سجل الأن و إحصل على 20% خصم على اول طلب',
      'cta': 'سجل هنا',
    };

    String en(String? s) => AppLocalizations(const Locale('en')).backendText(s);
    String ar(String? s) => AppLocalizations(const Locale('ar')).backendText(s);
    String sv(String? s) => AppLocalizations(const Locale('sv')).backendText(s);

    test('English locale shows English for all backend Arabic strings', () {
      expect(en(backendArabic['title']), 'Welcome to Tamini');
      expect(en(backendArabic['bannerTitle']), 'Register now');
      expect(
        en(backendArabic['bannerSubtitle']),
        'Register now and get 20% off your first order',
      );
      expect(en(backendArabic['cta']), 'Register here');
      expect(
        en(backendArabic['subtitle']),
        startsWith('O you who believe! Eat of the lawful things'),
      );
    });

    test('Arabic locale keeps the backend Arabic strings', () {
      expect(ar(backendArabic['title']), backendArabic['title']);
      expect(ar(backendArabic['bannerTitle']), backendArabic['bannerTitle']);
      expect(ar(backendArabic['cta']), backendArabic['cta']);
      expect(ar(backendArabic['subtitle']), backendArabic['subtitle']);
    });

    test('Swedish locale shows Swedish for known backend strings', () {
      expect(sv(backendArabic['title']), 'Välkommen till Tamini');
      expect(sv(backendArabic['bannerTitle']), 'Registrera dig nu');
      expect(sv(backendArabic['cta']), 'Registrera dig här');
    });

    test('matches despite differing diacritics', () {
      final withShadda =
          'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ';
      expect(en(withShadda), startsWith('O you who believe!'));
    });

    test(
      'English backend text still translates to Arabic when Arabic locale',
      () {
        expect(
          ar('register now and get 20% off your first order'),
          'سجّل الآن واحصل على خصم 20% على طلبك الأول',
        );
      },
    );

    test('unknown strings pass through unchanged', () {
      expect(en('Something totally new'), 'Something totally new');
      expect(en('مرحباً'), 'مرحباً');
    });
  });
}
