import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/providers.dart';
import 'core/repositories/cart_repository.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/catalog_repository.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => CartProvider(cartRepository)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderRepository)),
        ChangeNotifierProvider(create: (_) => CatalogProvider(catalogRepository)),
        ChangeNotifierProvider(create: (_) => OwnerProvider(api)),
        ChangeNotifierProvider(create: (_) => DeliveryProvider(api)),
        ChangeNotifierProvider(create: (_) => SupportProvider(api)),
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
