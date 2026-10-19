import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/providers/providers.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/cart_repository.dart';
import 'core/repositories/catalog_repository.dart';
import 'core/repositories/delivery_repository.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/owner_repository.dart';
import 'core/repositories/settings_repository.dart';
import 'core/repositories/support_repository.dart';
import 'core/services/push_service.dart';
import 'core/theme/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/role_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.init();
  runApp(await createTaminiApp());
}

/// Loads the locally persisted preferences and wires every session-scoped
/// object exactly once, returning the ready-to-mount app.
///
/// All construction happens here rather than in [TaminiApp.build], so a
/// rebuild of the app widget can never recreate providers and wipe live
/// session state. Exposed for the widget smoke test.
@visibleForTesting
Future<TaminiApp> createTaminiApp() async {
  final localeProvider = LocaleProvider();
  await localeProvider.load();
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  final api = ApiClient();
  final authProvider = AuthProvider(ApiAuthRepository(api));
  final cartProvider = CartProvider(ApiCartRepository(api));
  final orderProvider = OrderProvider(ApiOrderRepository(api));
  final catalogProvider = CatalogProvider(ApiCatalogRepository(api));
  final ownerProvider = OwnerProvider(ApiOwnerRepository(api));
  final deliveryProvider = DeliveryProvider(ApiDeliveryRepository(api));
  final supportProvider = SupportProvider(ApiSupportRepository(api));
  final settingsProvider = SettingsProvider(ApiSettingsRepository(api));
  // A session ends either through an explicit logout or when the backend
  // rejects the refresh token; both paths must drop the dead account's data
  // so it never leaks to the next user signing in on this device.
  authProvider.onSessionEnded = () {
    cartProvider.reset();
    orderProvider.reset();
    ownerProvider.reset();
    deliveryProvider.reset();
    supportProvider.reset();
  };

  return TaminiApp(
    localeProvider: localeProvider,
    themeProvider: themeProvider,
    authProvider: authProvider,
    cartProvider: cartProvider,
    orderProvider: orderProvider,
    catalogProvider: catalogProvider,
    ownerProvider: ownerProvider,
    deliveryProvider: deliveryProvider,
    supportProvider: supportProvider,
    settingsProvider: settingsProvider,
  );
}

class TaminiApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;
  final CartProvider cartProvider;
  final OrderProvider orderProvider;
  final CatalogProvider catalogProvider;
  final OwnerProvider ownerProvider;
  final DeliveryProvider deliveryProvider;
  final SupportProvider supportProvider;
  final SettingsProvider settingsProvider;

  const TaminiApp({
    super.key,
    required this.localeProvider,
    required this.themeProvider,
    required this.authProvider,
    required this.cartProvider,
    required this.orderProvider,
    required this.catalogProvider,
    required this.ownerProvider,
    required this.deliveryProvider,
    required this.supportProvider,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // `.value` throughout: ownership stays with [createTaminiApp], so
        // Provider never disposes an instance it did not create.
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider.value(value: catalogProvider),
        ChangeNotifierProvider.value(value: ownerProvider),
        ChangeNotifierProvider.value(value: deliveryProvider),
        ChangeNotifierProvider.value(value: supportProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) => MaterialApp(
          title: 'Tamini',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          locale: localeProvider.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('en');
          },
          home: const RoleRoot(),
        ),
      ),
    );
  }
}
