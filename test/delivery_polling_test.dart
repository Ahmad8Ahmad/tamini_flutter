import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/theme/app_localizations.dart';
import 'package:tamini/features/delivery/screens/delivery_home_screen.dart';

/// Counts refresh attempts so the poll cadence is observable. Every call still
/// runs the real fetch, which the test HTTP override answers with an empty
/// body, so nothing leaves the process.
class _CountingDeliveryProvider extends DeliveryProvider {
  _CountingDeliveryProvider(super.api);

  int availableCalls = 0;

  @override
  Future<void> loadAvailable() async {
    availableCalls++;
    await super.loadAvailable();
  }
}

const _secureStorage = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

Widget _buildApp(_CountingDeliveryProvider delivery) {
  final api = ApiClient();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api)),
      ChangeNotifierProvider(create: (_) => CartProvider(api)),
      ChangeNotifierProvider(create: (_) => OrderProvider(api)),
      ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
      ChangeNotifierProvider(create: (_) => OwnerProvider(api)),
      ChangeNotifierProvider<DeliveryProvider>.value(value: delivery),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => SupportProvider(api)),
    ],
    child: const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DeliveryHomeScreen(),
    ),
  );
}

void main() {
  // The socket reads the access token on mount, so the secure storage channel
  // has to answer or the handler throws MissingPluginException. Returning null
  // leaves the socket idle, which is what we want here anyway.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, null);
  });

  testWidgets('board refreshes on its own while foregrounded', (tester) async {
    final delivery = _CountingDeliveryProvider(ApiClient());
    await tester.pumpWidget(_buildApp(delivery));
    await tester.pump();
    await tester.pump();
    expect(delivery.availableCalls, 1, reason: 'mount should load once');

    // The available board is derived server-side from orders that reached an
    // out-for-delivery status, and nothing announces that transition to the
    // app, so a driver would otherwise only see a new job by pulling to
    // refresh. This is the assertion that keeps that fixed.
    await tester.pump(const Duration(seconds: 21));
    expect(
      delivery.availableCalls,
      2,
      reason: 'the board should refresh with no user action',
    );
  });

  testWidgets('polling pauses in the background and resumes on return',
      (tester) async {
    final delivery = _CountingDeliveryProvider(ApiClient());
    await tester.pumpWidget(_buildApp(delivery));
    await tester.pump();
    await tester.pump();
    final atMount = delivery.availableCalls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 45));
    expect(
      delivery.availableCalls,
      atMount,
      reason: 'a pocketed phone should not keep the free tier awake',
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 21));
    expect(
      delivery.availableCalls,
      greaterThan(atMount),
      reason: 'polling should pick back up when the driver returns',
    );
  });
}
