/// Kingdom Heir — Elevation System
///
/// Five tiers of elevation. Each tier maps to a Material 3 `ElevationShadow`
/// specification (Material 3 raised shadows use multiple shadow layers at
/// specific opacities). The [AppElevation] tokens are drop-in dp values for
/// `BoxShadow` and Material widgets.
library kingdom_heir.theme.elevation;

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';

abstract final class AppElevation {
  // ─────────────────────────────────────────────────────────────────────────
  // Elevation Levels (dp)
  // ─────────────────────────────────────────────────────────────────────────

  /// 0 — flush with surface.
  static const double level0 = 0;

  /// 1 — subtle lift; cards on neutral surfaces.
  static const double level1 = 1;

  /// 2 — standard card elevation.
  static const double level2 = 2;

  /// 3 — raised cards, selected items, FAB.
  static const double level3 = 4;

  /// 4 — modal, dialog.
  static const double level4 = 8;

  /// 5 — bottom sheet, drawer.
  static const double level5 = 12;

  /// 6 — hero / elevated feature card.
  static const double level6 = 16;

  // ─────────────────────────────────────────────────────────────────────────
  // Preset Shadow Tokens (M3-style multi-layer)
  // ─────────────────────────────────────────────────────────────────────────

  /// No shadow.
  static const List<BoxShadow> shadowNone = <BoxShadow>[];

  /// Subtle shadow — resting cards.
  static List<BoxShadow> get shadow1 => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 3,
          spreadRadius: -1,
        ),
      ];

  /// Card shadow — typical raised card.
  static List<BoxShadow> get shadow2 => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 5,
          spreadRadius: -1,
        ),
      ];

  /// Hover / selected shadow — lifted card.
  static List<BoxShadow> get shadow3 => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.10),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ];

  /// Dialog shadow — modal surfaces.
  static List<BoxShadow> get shadow4 => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.12),
          offset: const Offset(0, 8),
          blurRadius: 16,
        ),
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 6,
          spreadRadius: -2,
        ),
      ];

  /// Bottom-sheet / drawer shadow.
  static List<BoxShadow> get shadow5 => [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.16),
          offset: const Offset(0, 12),
          blurRadius: 24,
        ),
        BoxShadow(
          color: AppColors.navy.withValues(alpha: 0.10),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: -2,
        ),
      ];

  /// Hero / primary CTA shadow — gold tinted for the royal feel.
  static List<BoxShadow> get shadowGold => [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.35),
          offset: const Offset(0, 6),
          blurRadius: 16,
        ),
        BoxShadow(
          color: AppColors.goldDark.withValues(alpha: 0.20),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // Resolve a shadow list for a tier.
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the canonical shadow list for [level].
  static List<BoxShadow> shadowFor(double level) {
    if (level <= 0) return shadowNone;
    if (level <= 1) return shadow1;
    if (level <= 2) return shadow2;
    if (level <= 4) return shadow3;
    if (level <= 8) return shadow4;
    return shadow5;
  }
}
