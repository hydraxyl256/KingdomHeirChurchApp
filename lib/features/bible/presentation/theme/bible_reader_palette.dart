import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';

/// Visual tokens for the Bible reader, derived from the active
/// [ReaderTheme]. Centralised so every screen (reader, settings, bookmarks,
/// plans) reads from the same palette and the dark mode never looks like
/// an afterthought.
class BibleReaderPalette {
  const BibleReaderPalette._({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.foreground,
    required this.foregroundMuted,
    required this.accent,
    required this.accentSoft,
    required this.divider,
    required this.glow,
    required this.brightness,
    required this.appBarStyle,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color foreground;
  final Color foregroundMuted;
  final Color accent;
  final Color accentSoft;
  final Color divider;
  final Color glow;
  final Brightness brightness;

  /// Iconography used in the app bar (`light` for dark themes, `dark` for
  /// light themes).
  final Brightness appBarStyle;

  // ignore: prefer_constructors_over_static_methods
  static BibleReaderPalette of(ReaderTheme theme) {
    switch (theme) {
      case ReaderTheme.royalDark:
        return const BibleReaderPalette._(
          background: AppColors.navy,
          surface: Color(0xFF142033),
          surfaceMuted: Color(0xFF1E2C44),
          foreground: AppColors.warmWhite,
          foregroundMuted: Color(0xFFCBB86A),
          accent: AppColors.gold,
          accentSoft: Color(0x33D4AF37),
          divider: Color(0x14FFFFFF),
          glow: Color(0x33D4AF37),
          brightness: Brightness.dark,
          appBarStyle: Brightness.dark,
        );
      case ReaderTheme.royalLight:
        return const BibleReaderPalette._(
          background: AppColors.warmWhite,
          surface: Color(0xFFFFFFFF),
          surfaceMuted: Color(0xFFF1EDD8),
          foreground: AppColors.navy,
          foregroundMuted: Color(0xFF475569),
          accent: AppColors.goldDark,
          accentSoft: Color(0x22A88B1D),
          divider: Color(0x1A0F172A),
          glow: Color(0x1AA88B1D),
          brightness: Brightness.light,
          appBarStyle: Brightness.light,
        );
      case ReaderTheme.sepia:
        return const BibleReaderPalette._(
          background: Color(0xFFFBF3DD),
          surface: Color(0xFFF5E9C8),
          surfaceMuted: Color(0xFFEDDDB5),
          foreground: Color(0xFF3B2A12),
          foregroundMuted: Color(0xFF7A5A2E),
          accent: Color(0xFFA88B1D),
          accentSoft: Color(0x33A88B1D),
          divider: Color(0x1A3B2A12),
          glow: Color(0x22A88B1D),
          brightness: Brightness.light,
          appBarStyle: Brightness.light,
        );
      case ReaderTheme.midnight:
        return const BibleReaderPalette._(
          background: Color(0xFF000000),
          surface: Color(0xFF0A0A0A),
          surfaceMuted: Color(0xFF141414),
          foreground: Color(0xFFEDEAE0),
          foregroundMuted: Color(0xFF8A8A8A),
          accent: AppColors.gold,
          accentSoft: Color(0x22D4AF37),
          divider: Color(0x14FFFFFF),
          glow: Color(0x33D4AF37),
          brightness: Brightness.dark,
          appBarStyle: Brightness.dark,
        );
    }
  }
}
