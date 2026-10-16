import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/providers.dart';
import 'core/repositories/cart_repository.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/catalog_repository.dart';
import 'core/repositories/owner_repository.dart';
import 'core/services/push_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_localizations.dart';
import 'core/widgets/role_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.init();
  final localeProvider = LocaleProvider();
  await localeProvider.load();
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  runApp(TaminiApp(localeProvider: localeProvider, themeProvider: themeProvider));
}

class TaminiApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  const TaminiApp({
    super.key,
    required this.localeProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    final cartRepository = ApiCartRepository(api);
    final orderRepository = ApiOrderRepository(api);
    final catalogRepository = ApiCatalogRepository(api);
    final ownerRepository = ApiOwnerRepository(api);

    // Built up-front so the session-end hook can reset every provider that
    // holds account-scoped data. Providers are still owned/disposed by the
    // ChangeNotifierProviders below.
    final authProvider = AuthProvider(api);
    final cartProvider = CartProvider(cartRepository);
    final orderProvider = OrderProvider(orderRepository);
    final ownerProvider = OwnerProvider(ownerRepository);
    final deliveryProvider = DeliveryProvider(api);
    final supportProvider = SupportProvider(api);
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => cartProvider),
        ChangeNotifierProvider(create: (_) => orderProvider),
        ChangeNotifierProvider(create: (_) => CatalogProvider(catalogRepository)),
        ChangeNotifierProvider(create: (_) => ownerProvider),
        ChangeNotifierProvider(create: (_) => deliveryProvider),
        ChangeNotifierProvider(create: (_) => supportProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider(api)),
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
