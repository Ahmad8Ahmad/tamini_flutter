import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_localizations.dart';
import 'features/auth/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaminiApp());
}

class TaminiApp extends StatefulWidget {
  const TaminiApp({super.key});

  @override
  State<TaminiApp> createState() => _TaminiAppState();
}

class _TaminiAppState extends State<TaminiApp> {
  final Locale _locale = const Locale('ar');

  @override
  Widget build(BuildContext context) {
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
        title: 'Tamini',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: _locale,
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
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
        home: const SplashScreen(),
      ),
    );
  }
}
