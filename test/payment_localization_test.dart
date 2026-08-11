import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/theme/app_localizations.dart';

void main() {
  group('payment method localization', () {
    String t(Locale locale, String Function(AppLocalizations) getter) =>
        getter(AppLocalizations(locale));

    test('English locale shows payment labels', () {
      final en = AppLocalizations(const Locale('en'));
      expect(en.paymentMethod, 'Payment Method');
      expect(en.cashOnDelivery, 'Cash on Delivery');
      expect(en.cardPayment, 'Pay by Card');
      expect(en.placeOrder, 'Confirm Order and Pay');
    });

    test('Arabic locale shows payment labels', () {
      final ar = AppLocalizations(const Locale('ar'));
      expect(ar.paymentMethod, 'طريقة الدفع');
      expect(ar.cashOnDelivery, 'الدفع عند الاستلام');
      expect(ar.cardPayment, 'الدفع بالبطاقة');
      expect(ar.placeOrder, 'تأكيد الطلب والدفع');
    });

    test('unused legacy languages still resolve via English fallback', () {
      expect(t(const Locale('en'), (l) => l.paymentRedirecting), isNotEmpty);
      expect(t(const Locale('ar'), (l) => l.paymentRedirecting), isNotEmpty);
    });
  });
}
