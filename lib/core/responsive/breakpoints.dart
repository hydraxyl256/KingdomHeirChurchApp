/// Kingdom Heir — Responsive Breakpoint Taxonomy
///
/// The app targets six logical bands. Resolve a [LayoutBand] from any
/// `BoxConstraints` or raw width, then ask token accessors for a value.
///
/// Bands are intentionally coarser than Material 3's `WindowSizeClass`:
/// we want a single source of truth for the 320 → 1240+ range we ship on,
/// and we don't want Material's 4-class bucketing to push a 360 dp phone
/// into the same bucket as a 1024 dp tablet.
library;

import 'package:flutter/rendering.dart';

/// Logical width bands, ordered narrowest → widest.

/// Logical width bands, ordered narrowest → widest.
///
/// Use [LayoutBandResolution.fromConstraints] to resolve a band from a width.
enum LayoutBand {
  /// < 360 dp — 320 dp phones, Galaxy Fold cover.
  xs,

  /// 360 – < 390 dp — Pixel 4a, most compact modern phones.
  sm,

  /// 390 – < 600 dp — iPhone 12/13/14, Pixel 6, "normal" phones.
  md,

  /// 600 – < 840 dp — small tablets, large phones landscape.
  lg,

  /// 840 – < 1240 dp — iPad mini, iPad landscape.
  xl,

  /// >= 1240 dp — iPad Pro 12.9, desktop, foldable open.
  xxl,
}

extension LayoutBandX on LayoutBand {
  /// True when this band is at least as wide as [other].
  bool isAtLeast(LayoutBand other) => index >= other.index;

  /// True when this band is at most as wide as [other].
  bool isAtMost(LayoutBand other) => index <= other.index;

  /// Human-readable label for diagnostics.
  String get label => switch (this) {
        LayoutBand.xs => 'xs (<360)',
        LayoutBand.sm => 'sm (360-<390)',
        LayoutBand.md => 'md (390-<600)',
        LayoutBand.lg => 'lg (600-<840)',
        LayoutBand.xl => 'xl (840-<1240)',
        LayoutBand.xxl => 'xxl (>=1240)',
      };
}

/// Resolve a [LayoutBand] from a raw `maxWidth` (logical pixels).
LayoutBand layoutBandFromWidth(double maxWidth) {
  if (maxWidth < 360) return LayoutBand.xs;
  if (maxWidth < 390) return LayoutBand.sm;
  if (maxWidth < 600) return LayoutBand.md;
  if (maxWidth < 840) return LayoutBand.lg;
  if (maxWidth < 1240) return LayoutBand.xl;
  return LayoutBand.xxl;
}

extension LayoutBandResolution on LayoutBand {
  /// Resolve a [LayoutBand] from any [BoxConstraints].
  ///
  /// Uses [BoxConstraints.maxWidth] (the larger of the two axes
  /// collapses correctly for portrait phones).
  static LayoutBand fromConstraints(BoxConstraints constraints) =>
      layoutBandFromWidth(constraints.maxWidth);

  /// Named constructor; reads `constraints.maxWidth`.
  static LayoutBand callConstraints(BoxConstraints constraints) =>
      fromConstraints(constraints);
}
