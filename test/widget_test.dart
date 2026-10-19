import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamini/core/widgets/role_root.dart';
import 'package:tamini/features/auth/screens/splash_screen.dart';
import 'package:tamini/main.dart';

const _secureStorage = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Session restore reads the stored tokens on boot; answer "no session" so
  // the app routes to the guest destination without touching the network.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, null);
  });

  testWidgets('TaminiApp boots through RoleRoot to the guest home',
      (tester) async {
    await tester.pumpWidget(await createTaminiApp());
    expect(find.byType(MaterialApp), findsOneWidget);

    // The initial route is built on the following frame.
    await tester.pump();
    expect(find.byType(RoleRoot), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget,
        reason: 'the boot sequence should start on the splash screen');

    // Let session restore finish and RoleRoot route the guest user.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RoleRoot), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing,
        reason: 'boot should leave the splash screen');

    final error = tester.takeException();
    expect(error, isNull, reason: 'app startup threw: $error');
  });
}
