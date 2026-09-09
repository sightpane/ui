import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData dark({TargetPlatform? platform}) => ThemeData(
    platform: platform,
    colorScheme: ColorSchemes.darkZinc.copyWith(
      background: () => Tokens.bg,
      foreground: () => Tokens.text,
      card: () => Tokens.panel,
      cardForeground: () => Tokens.text,
      popover: () => Tokens.raised,
      popoverForeground: () => Tokens.text,
      primary: () => Tokens.accent,
      primaryForeground: () => Tokens.accentInk,
      secondary: () => Tokens.raised,
      secondaryForeground: () => Tokens.textStrong,
      muted: () => Tokens.chip,
      mutedForeground: () => Tokens.textMuted,
      accent: () => Tokens.raised,
      accentForeground: () => Tokens.textStrong,
      destructive: () => Tokens.danger,
      border: () => Tokens.border,
      input: () => Tokens.border,
      ring: () => Tokens.accent,
    ),
    radius: Tokens.radius / 16,
  );

  /// Fixed-width style for tabular figures.
  static TextStyle mono({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = Tokens.text,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['JetBrains Mono', 'Menlo', 'Consolas'],
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
