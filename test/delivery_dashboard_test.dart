import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/theme/app_localizations.dart';
import 'package:tamini/features/delivery/screens/delivery_dashboard_screen.dart';

Widget buildApp() {
  final api = ApiClient();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api)),
      ChangeNotifierProvider(create: (_) => CartProvider(api)),
      ChangeNotifierProvider(create: (_) => OrderProvider(api)),
      ChangeNotifierProvider(create: (_) => RestaurantProvider(api)),
      ChangeNotifierProvider(create: (_) => DeliveryProvider(api)),
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
      home: const DeliveryDashboardScreen(),
    ),
  );
}

void main() {
  testWidgets('Delivery dashboard builds without exceptions', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    final error = tester.takeException();
    expect(error, isNull, reason: 'Dashboard threw: $error');
    expect(find.text('لوحة التوصيل'), findsOneWidget);
  });
}
