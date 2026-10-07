import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart';

class AppTheme {
  AppTheme._();

  // ── Orange Brand Palette ──────────────────────────────────────
  static const Color orange50  = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);

  // ── Neutral Gray Palette ──────────────────────────────────────
  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ── Semantic Status Colors ────────────────────────────────────
  static const Color success   = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color info      = Color(0xFF3B82F6);
  static const Color infoBg    = Color(0xFFDBEAFE);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color danger    = Color(0xFFEF4444);
  static const Color dangerBg  = Color(0xFFFEE2E2);

  // ── Brand Shortcuts (matching web app usage) ──────────────────
  static const Color primary       = orange500;
  static const Color primaryDark   = orange600;
  static const Color primaryLight  = orange50;
  static const Color background    = gray50;
  static const Color card          = Colors.white;
  static const Color textPrimary   = gray800;
  static const Color textSecondary = gray500;
  static const Color textMuted     = gray400;
  static const Color border        = gray200;
  static const Color borderLight   = gray100;

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange400, orange600],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Colors.black54, Colors.transparent],
  );

  static const LinearGradient avatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange400, danger],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), success],
  );

  // ── Border Radius Tokens ──────────────────────────────────────
  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusXl   = 24;
  static const double radiusXxl  = 32;
  static const double radiusFull = 999;

  static BorderRadius get roundedSm  => BorderRadius.circular(radiusSm);
  static BorderRadius get roundedMd  => BorderRadius.circular(radiusMd);
  static BorderRadius get roundedLg  => BorderRadius.circular(radiusLg);
  static BorderRadius get roundedXl  => BorderRadius.circular(radiusXl);
  static BorderRadius get roundedXxl => BorderRadius.circular(radiusXxl);

  // ── Spacing Tokens ────────────────────────────────────────────
  static const double spaceXs  = 4;
  static const double spaceSm  = 8;
  static const double spaceMd  = 16;
  static const double spaceLg  = 24;
  static const double spaceXl  = 32;
  static const double spaceXxl = 48;

  // ── Shadow Tokens ─────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowMd => [
    const BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowLg => [
    const BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get shadowXl => [
    const BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // ── Typography (Cairo + Lalezar) ──────────────────────────────
  static const String _cairo   = 'Cairo';
  static const String _lalezar = 'Lalezar';

  // Display / Hero headings (Lalezar).
  //
  // Text styles intentionally carry no `color:` — they inherit from the
  // ambient `Theme.textTheme`, which is already brightness-aware. Pass
  // `color: context.colors.*` (or an explicit color) when a style sits on a
  // non-themed background such as a gradient.
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: _lalezar, fontSize: 32, height: 1.2,
      );
  static TextStyle get displayMedium => const TextStyle(
        fontFamily: _lalezar, fontSize: 28, height: 1.2,
      );
  static TextStyle get displaySmall => const TextStyle(
        fontFamily: _lalezar, fontSize: 24, height: 1.3,
      );

  // Headings (Cairo bold/black)
  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: _cairo,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );
  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: _cairo,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );
  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: _cairo,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  // Title (Cairo bold)
  static TextStyle get titleLarge => const TextStyle(
        fontFamily: _cairo, fontSize: 18, fontWeight: FontWeight.w700,
      );
  static TextStyle get titleMedium => const TextStyle(
        fontFamily: _cairo, fontSize: 16, fontWeight: FontWeight.w700,
      );
  static TextStyle get titleSmall => const TextStyle(
        fontFamily: _cairo, fontSize: 14, fontWeight: FontWeight.w700,
      );

  // Body (Cairo regular/medium)
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _cairo, fontSize: 16, fontWeight: FontWeight.w500,
      );
  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: _cairo, fontSize: 14, fontWeight: FontWeight.w500,
      );
  static TextStyle get bodySmall => const TextStyle(
        fontFamily: _cairo, fontSize: 12, fontWeight: FontWeight.w500,
      );

  // Label
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _cairo, fontSize: 14, fontWeight: FontWeight.w700,
      );
  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _cairo, fontSize: 12, fontWeight: FontWeight.w700,
      );
  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _cairo, fontSize: 10, fontWeight: FontWeight.w700,
      );

  // Price text
  static TextStyle get priceLarge => const TextStyle(
    fontFamily: _cairo, fontSize: 18, fontWeight: FontWeight.w900, color: primary,
  );
  static TextStyle get priceMedium => const TextStyle(
    fontFamily: _cairo, fontSize: 16, fontWeight: FontWeight.w900, color: primary,
  );
  static TextStyle get priceSmall => const TextStyle(
    fontFamily: _cairo, fontSize: 14, fontWeight: FontWeight.w800, color: primary,
  );

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _cairo,
    scaffoldBackgroundColor: background,
    extensions: const [AppPalette.light],
    colorScheme: const ColorScheme.light(
      primary: orange500,
      onPrimary: Colors.white,
      secondary: orange600,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: gray800,
      error: danger,
      onError: Colors.white,
      onSurfaceVariant: gray600,
      outline: gray500,
      outlineVariant: gray200,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: gray100,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: orange600,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: orange600,
      ),
      iconTheme: IconThemeData(color: orange600),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: roundedLg,
        side: const BorderSide(color: borderLight),
      ),
      margin: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange500,
        foregroundColor: Colors.white,
        disabledBackgroundColor: gray300,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: roundedLg),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange600,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: roundedLg),
        side: const BorderSide(color: orange300, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: orange600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: orange600,
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray50,
      hintStyle: const TextStyle(fontFamily: _cairo, color: gray400, fontSize: 14, fontWeight: FontWeight.w500),
      labelStyle: const TextStyle(fontFamily: _cairo, color: gray600, fontSize: 14, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: orange500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: orange600,
      unselectedItemColor: gray400,
      selectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: orange600,
      unselectedLabelColor: gray500,
      indicatorColor: orange500,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: orange500, width: 3),
      ),
      labelStyle: TextStyle(
        fontFamily: _cairo,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: roundedXl),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: gray500,
      textColor: gray800,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: gray900,
      contentTextStyle: const TextStyle(fontFamily: _cairo, color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: roundedLg),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark counterparts of the tokens above. Widgets should prefer
  // `context.colors.*` (AppPalette) over these static constants so surfaces
  // follow the active theme.
  static const Color darkBackground = gray900;
  static const Color darkCard = gray800;
  static const Color darkBorder = gray700;
  static const Color darkTextPrimary = gray100;
  static const Color darkTextSecondary = gray400;

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _cairo,
    scaffoldBackgroundColor: darkBackground,
    extensions: const [AppPalette.dark],
    colorScheme: const ColorScheme.dark(
      primary: orange500,
      onPrimary: Colors.white,
      secondary: orange600,
      onSecondary: Colors.white,
      surface: gray800,
      onSurface: gray100,
      error: danger,
      onError: Colors.white,
      onSurfaceVariant: gray400,
      outline: gray500,
      outlineVariant: gray600,
      surfaceContainerLowest: gray900,
      surfaceContainerLow: gray800,
      surfaceContainer: gray800,
      surfaceContainerHigh: gray800,
      surfaceContainerHighest: gray700,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCard,
      foregroundColor: orange400,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: orange400,
      ),
      iconTheme: IconThemeData(color: orange400),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: roundedLg,
        side: const BorderSide(color: darkBorder),
      ),
      margin: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange500,
        foregroundColor: Colors.white,
        disabledBackgroundColor: gray700,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: roundedLg),
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange400,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: roundedLg),
        side: const BorderSide(color: orange700, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: orange400,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: orange400,
        textStyle: const TextStyle(
          fontFamily: _cairo,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray700,
      hintStyle: const TextStyle(fontFamily: _cairo, color: gray400, fontSize: 14, fontWeight: FontWeight.w500),
      labelStyle: const TextStyle(fontFamily: _cairo, color: gray300, fontSize: 14, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: orange500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: roundedLg,
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: gray800,
      selectedItemColor: orange400,
      unselectedItemColor: gray400,
      selectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: orange400,
      unselectedLabelColor: gray400,
      indicatorColor: orange400,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: orange400, width: 3),
      ),
      labelStyle: TextStyle(
        fontFamily: _cairo,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: _cairo,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: gray800,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: roundedXl),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: gray800,
      surfaceTintColor: Colors.transparent,
    ),
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(gray800),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: gray400,
      textColor: gray100,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: gray700,
      contentTextStyle: const TextStyle(fontFamily: _cairo, color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: roundedLg),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
