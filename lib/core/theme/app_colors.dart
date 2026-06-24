import 'package:flutter/material.dart';

/// Kingdom Heir — Complete Color Token System
///
/// Structure:
///   • Brand primitives (raw hex values)
///   • Semantic tokens (what a color means)
///   • Material 3 ColorScheme factories (light / dark)
abstract final class AppColors {
  // ─────────────────────────────────────────────────────────────────────────
  // Brand Primitives
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary brand gold — #D4AF37
  static const Color gold = Color(0xFFD4AF37);

  /// Lighter gold tint — #F5DD7E
  static const Color goldLight = Color(0xFFF5DD7E);

  /// Deeper gold shade — #A88B1D
  static const Color goldDark = Color(0xFFA88B1D);

  /// Richest gold container — #FDF3C0
  static const Color goldContainer = Color(0xFFFDF3C0);

  /// Deep navy — #0F172A
  static const Color navy = Color(0xFF0F172A);

  /// Mid navy — #1E293B
  static const Color navyMid = Color(0xFF1E293B);

  /// Light navy surface — #334155
  static const Color navyLight = Color(0xFF334155);

  /// Navy tint for containers — #1E3A8A
  static const Color navyAccent = Color(0xFF1E3A8A);

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Near-white warm background — #FFFBF2
  static const Color warmWhite = Color(0xFFFFFBF2);

  /// Ink — very dark near-black — #0C0A00
  static const Color ink = Color(0xFF0C0A00);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic — Status Colors
  // ─────────────────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFFE4E4);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic — Text
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary text on light backgrounds
  static const Color textPrimary = Color(0xFF0F172A);

  /// Secondary / muted text
  static const Color textSecondary = Color(0xFF475569);

  /// Disabled / placeholder text
  static const Color textDisabled = Color(0xFF94A3B8);

  /// Text on dark backgrounds (e.g. gold buttons)
  static const Color textOnDark = Color(0xFF0C0A00);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic — Surfaces (Light Mode)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF8F4E8);
  static const Color surfaceContainerLight = Color(0xFFF1EDD8);
  static const Color surfaceContainerHighLight = Color(0xFFEDE8D2);
  static const Color backgroundLight = Color(0xFFFFFBF2);
  static const Color dividerLight = Color(0xFFE5DFC8);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic — Surfaces (Dark Mode)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF243347);
  static const Color surfaceContainerDark = Color(0xFF162033);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color dividerDark = Color(0xFF334155);
  static const Color cardDark = Color(0xFF1E293B);

  // Legacy surface aliases (kept for backward compat)
  static const Color surface = surfaceLight;

  // ─────────────────────────────────────────────────────────────────────────
  // Backward-compat aliases (purple era → gold era mapping)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color primary = gold;
  static const Color primaryLight = goldLight;
  static const Color primaryDark = goldDark;
  static const Color secondary = navyAccent;
  static const Color secondaryLight = navyLight;
  static const Color secondaryDark = navy;
  static const Color onSecondary = white;
  static const Color tertiary = Color(0xFF0EA5E9); // sky blue accent
  static const Color onPrimary = ink;

  // ─────────────────────────────────────────────────────────────────────────
  // Material 3 ColorScheme factories
  // ─────────────────────────────────────────────────────────────────────────

  /// Full light [ColorScheme] for Kingdom Heir.
  static ColorScheme get lightScheme => const ColorScheme(
        brightness: Brightness.light,

        // Primary — Gold
        primary: Color(0xFFD4AF37),
        onPrimary: Color(0xFF0C0A00),
        primaryContainer: Color(0xFFFDF3C0),
        onPrimaryContainer: Color(0xFF211B00),

        // Secondary — Navy blue
        secondary: Color(0xFF1E40AF),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFDBEAFE),
        onSecondaryContainer: Color(0xFF1E3A8A),

        // Tertiary — Sky accent
        tertiary: Color(0xFF0EA5E9),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFE0F2FE),
        onTertiaryContainer: Color(0xFF0369A1),

        // Error
        error: Color(0xFFDC2626),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFE4E4),
        onErrorContainer: Color(0xFF7F1D1D),

        // Surface & background
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A),
        onSurfaceVariant: Color(0xFF475569),
        surfaceContainerHighest: Color(0xFFEDE8D2),
        surfaceContainerHigh: Color(0xFFF1EDD8),
        surfaceContainer: Color(0xFFF5F0DF),
        surfaceContainerLow: Color(0xFFF8F4E8),
        surfaceContainerLowest: Color(0xFFFFFBF2),

        // Misc
        outline: Color(0xFFCBB86A),
        outlineVariant: Color(0xFFE5DFC8),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF1E293B),
        onInverseSurface: Color(0xFFF1EDD8),
        inversePrimary: Color(0xFFF5DD7E),
      );

  /// Full dark [ColorScheme] for Kingdom Heir.
  static ColorScheme get darkScheme => const ColorScheme(
        brightness: Brightness.dark,

        // Primary — Gold (stays vibrant in dark)
        primary: Color(0xFFD4AF37),
        onPrimary: Color(0xFF0C0A00),
        primaryContainer: Color(0xFF3D3100),
        onPrimaryContainer: Color(0xFFF5DD7E),

        // Secondary — lighter navy/blue for dark mode readability
        secondary: Color(0xFF93C5FD),
        onSecondary: Color(0xFF1E3A8A),
        secondaryContainer: Color(0xFF1E40AF),
        onSecondaryContainer: Color(0xFFDBEAFE),

        // Tertiary
        tertiary: Color(0xFF38BDF8),
        onTertiary: Color(0xFF0C4A6E),
        tertiaryContainer: Color(0xFF0369A1),
        onTertiaryContainer: Color(0xFFE0F2FE),

        // Error
        error: Color(0xFFFF6B6B),
        onError: Color(0xFF7F1D1D),
        errorContainer: Color(0xFF7F1D1D),
        onErrorContainer: Color(0xFFFFE4E4),

        // Surface & background — deep navy family
        surface: Color(0xFF1E293B),
        onSurface: Color(0xFFF1EDD8),
        onSurfaceVariant: Color(0xFFCBB86A),
        surfaceContainerHighest: Color(0xFF2D3F57),
        surfaceContainerHigh: Color(0xFF243347),
        surfaceContainer: Color(0xFF1A2743),
        surfaceContainerLow: Color(0xFF162033),
        surfaceContainerLowest: Color(0xFF0F172A),

        // Misc
        outline: Color(0xFFA88B1D),
        outlineVariant: Color(0xFF334155),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFF1EDD8),
        onInverseSurface: Color(0xFF1E293B),
        inversePrimary: Color(0xFFA88B1D),
      );
}
