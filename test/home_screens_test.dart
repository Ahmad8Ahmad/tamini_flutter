import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/theme/app_localizations.dart';
import 'package:tamini/features/orders/screens/orders_screen.dart';
import 'package:tamini/features/home/screens/home_screen.dart';

Widget wrap(Widget home) {
  final api = ApiClient();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api)),
      ChangeNotifierProvider(create: (_) => CartProvider(api)),
      ChangeNotifierProvider(create: (_) => OrderProvider(api)),
      ChangeNotifierProvider(create: (_) => RestaurantProvider(api)),
      ChangeNotifierProvider(create: (_) => DeliveryProvider(api)),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => SupportProvider(api)),
    ],
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

void main() {
  testWidgets('OrdersScreen mounts', (tester) async {
    await tester.pumpWidget(wrap(const OrdersScreen()));
    final error = tester.takeException();
    expect(error, isNull, reason: 'OrdersScreen threw: $error');
  });

  testWidgets('HomeScreen mounts', (tester) async {
    await tester.pumpWidget(wrap(const HomeScreen()));
    final error = tester.takeException();
    expect(error, isNull, reason: 'HomeScreen threw: $error');
  });
}
