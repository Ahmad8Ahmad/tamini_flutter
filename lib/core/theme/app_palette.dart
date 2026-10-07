import 'package:flutter/material.dart';

/// Brightness-aware semantic color tokens.
///
/// [AppTheme.light] registers [light] and [AppTheme.dark] registers [dark]
/// as a [ThemeExtension], so widgets resolve colors through
/// `context.colors.<token>` instead of hardcoding light-mode values
/// (which looked broken on dark surfaces).
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderLight,
    required this.inputFill,
    required this.subtleFill,
    required this.tint,
    required this.tintText,
    required this.successBg,
    required this.infoBg,
    required this.warningBg,
    required this.dangerBg,
  });

  /// Whether this palette was built for a dark theme.
  final Brightness brightness;

  /// Scaffold background behind cards.
  final Color background;

  /// Surface color for cards, bars, dialogs and menus.
  final Color card;

  /// Primary body/heading text.
  final Color textPrimary;

  /// Secondary/caption text.
  final Color textSecondary;

  /// Hints, disabled icons, placeholder glyphs.
  final Color textMuted;

  /// Stronger border (inputs, chips, focused outlines).
  final Color border;

  /// Subtle card/list border.
  final Color borderLight;

  /// Text field fill.
  final Color inputFill;

  /// Neutral fill for disabled controls and quiet chips.
  final Color subtleFill;

  /// Soft brand-tinted container (selected pills, quantity selector).
  final Color tint;

  /// Foreground (text/icon) that sits on [tint].
  final Color tintText;

  /// Status chip backgrounds (badges, alerts).
  final Color successBg;
  final Color infoBg;
  final Color warningBg;
  final Color dangerBg;

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF9FAFB),
    card: Colors.white,
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    border: Color(0xFFE5E7EB),
    borderLight: Color(0xFFF3F4F6),
    inputFill: Color(0xFFF9FAFB),
    subtleFill: Color(0xFFE5E7EB),
    tint: Color(0xFFFFF7ED),
    tintText: Color(0xFFEA580C),
    successBg: Color(0xFFDCFCE7),
    infoBg: Color(0xFFDBEAFE),
    warningBg: Color(0xFFFEF3C7),
    dangerBg: Color(0xFFFEE2E2),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF111827),
    card: Color(0xFF1F2937),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF9CA3AF),
    border: Color(0xFF4B5563),
    borderLight: Color(0xFF374151),
    inputFill: Color(0xFF374151),
    subtleFill: Color(0xFF374151),
    tint: Color(0x33F97316),
    tintText: Color(0xFFFB923C),
    successBg: Color(0x3322C55E),
    infoBg: Color(0x333B82F6),
    warningBg: Color(0x33F59E0B),
    dangerBg: Color(0x33EF4444),
  );

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderLight,
    Color? inputFill,
    Color? subtleFill,
    Color? tint,
    Color? tintText,
    Color? successBg,
    Color? infoBg,
    Color? warningBg,
    Color? dangerBg,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      inputFill: inputFill ?? this.inputFill,
      subtleFill: subtleFill ?? this.subtleFill,
      tint: tint ?? this.tint,
      tintText: tintText ?? this.tintText,
      successBg: successBg ?? this.successBg,
      infoBg: infoBg ?? this.infoBg,
      warningBg: warningBg ?? this.warningBg,
      dangerBg: dangerBg ?? this.dangerBg,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      subtleFill: Color.lerp(subtleFill, other.subtleFill, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      tintText: Color.lerp(tintText, other.tintText, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Semantic colors of the current theme.
  ///
  /// Falls back to a palette derived from the theme brightness when none is
  /// registered, so custom/legacy [ThemeData] (e.g. in tests) stays safe.
  AppPalette get colors {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}
