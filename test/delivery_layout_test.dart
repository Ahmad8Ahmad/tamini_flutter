import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/theme/app_localizations.dart';
import 'package:tamini/features/delivery/screens/delivery_dashboard_screen.dart';

class _EmptyApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    return {'results': <dynamic>[]};
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> patchMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    return <String, dynamic>{};
  }
}

Widget buildHarness() {
  final api = _EmptyApi();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api)),
      ChangeNotifierProvider(create: (_) => CartProvider(api)),
      ChangeNotifierProvider(create: (_) => OrderProvider(api)),
      ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
      ChangeNotifierProvider(create: (_) => OwnerProvider(api)),
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
      home: const DeliveryDashboardScreen(),
    ),
  );
}

void main() {
  testWidgets('header title is centered and action icons are evenly spaced', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final screenW = tester.getSize(find.byType(Scaffold).first).width;

    final titleRect = tester.getRect(find.text('لوحة التوصيل'));
    final titleCenter = titleRect.center;
    expect(
      (titleCenter.dx - screenW / 2).abs(),
      lessThan(1.0),
      reason: 'title must be horizontally centered (was ${titleCenter.dx})',
    );

    final lang = tester.getCenter(find.byIcon(Icons.language));
    final store = tester.getCenter(find.byIcon(Icons.storefront_outlined));
    final logout = tester.getCenter(find.byIcon(Icons.logout));
    final gap1 = (store.dx - lang.dx).abs();
    final gap2 = (logout.dx - store.dx).abs();
    expect(
      (gap1 - gap2).abs(),
      lessThan(2.0),
      reason: 'icon gaps must be even (gap1=$gap1 gap2=$gap2)',
    );
    expect(gap1, greaterThan(48.0), reason: 'icons need visible spacing');
  });

  testWidgets('empty state is centered horizontally and vertically', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'load must resolve to empty state',
    );
    expect(find.text('لا توجد طلبات متاحة حالياً'), findsOneWidget);

    final screen = tester.getSize(find.byType(Scaffold).first);
    final iconRect = tester.getRect(find.byIcon(Icons.delivery_dining));
    final buttonRect = tester.getRect(
      find.widgetWithText(ElevatedButton, 'تحديث'),
    );
    final bodyCenter = tester.getCenter(find.byType(TabBarView));

    final columnLeft = [
      iconRect.left,
      buttonRect.left,
    ].reduce((a, b) => a < b ? a : b);
    final columnRight = [
      iconRect.right,
      buttonRect.right,
    ].reduce((a, b) => a > b ? a : b);
    final columnTop = [
      iconRect.top,
      buttonRect.top,
    ].reduce((a, b) => a < b ? a : b);
    final columnBottom = [
      iconRect.bottom,
      buttonRect.bottom,
    ].reduce((a, b) => a > b ? a : b);

    final columnCenterX = (columnLeft + columnRight) / 2;
    final columnCenterY = (columnTop + columnBottom) / 2;
    expect(
      (columnCenterX - screen.width / 2).abs(),
      lessThan(1.0),
      reason: 'empty state must be horizontally centered',
    );
    expect(
      (columnCenterY - bodyCenter.dy).abs(),
      lessThan(1.0),
      reason: 'empty state must be vertically centered in the body',
    );
  });
}
