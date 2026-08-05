import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/theme/app_localizations.dart';
import 'package:tamini/core/widgets/dashboard_button.dart';
import 'package:tamini/features/cart/screens/cart_screen.dart';

Widget buildApp({required User user}) {
  final api = ApiClient();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api)..debugSetUser(user)),
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
      home: const _TestScaffold(),
    ),
  );
}

class _TestScaffold extends StatelessWidget {
  const _TestScaffold();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('role:${auth.user?.role ?? 'null'}'),
            const DashboardButton(),
          ],
        ),
      ),
    );
  }
}

User delivery() => User(
      id: 1,
      email: 'driver@test.com',
      username: 'driver',
      role: 'delivery',
      isApproved: true,
    );

User customer() => User(
      id: 2,
      email: 'customer@test.com',
      username: 'customer',
      role: 'customer',
    );

void main() {
  testWidgets('DashboardButton shows for delivery user', (tester) async {
    await tester.pumpWidget(buildApp(user: delivery()));
    await tester.pump();
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
  });

  testWidgets('DashboardButton hidden for customer user', (tester) async {
    await tester.pumpWidget(buildApp(user: customer()));
    await tester.pump();
    expect(find.byIcon(Icons.dashboard_outlined), findsNothing);
  });

  testWidgets('DashboardButton hidden for guest', (tester) async {
    final api = ApiClient();
    await tester.pumpWidget(MultiProvider(
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
        home: const _TestScaffold(),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.dashboard_outlined), findsNothing);
  });

  testWidgets('DashboardButton shows on CartScreen for delivery user', (tester) async {
    final api = ApiClient();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)..debugSetUser(delivery())),
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
        home: const CartScreen(),
      ),
    ));
    await tester.pump();
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
  });
}
