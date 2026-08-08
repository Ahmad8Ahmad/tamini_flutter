import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_localizations.dart';
import 'core/widgets/role_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.load();
  runApp(TaminiApp(localeProvider: localeProvider));
}

class TaminiApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  const TaminiApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => CartProvider(api)),
        ChangeNotifierProvider(create: (_) => OrderProvider(api)),
        ChangeNotifierProvider(create: (_) => RestaurantProvider(api)),
        ChangeNotifierProvider(create: (_) => DeliveryProvider(api)),
        ChangeNotifierProvider(create: (_) => SupportProvider(api)),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'Tamini',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('sv'),
          ],
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
            return const Locale('ar');
          },
          home: const RoleRoot(),
        ),
      ),
    );
  }
}
