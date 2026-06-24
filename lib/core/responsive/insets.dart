import 'package:flutter/widgets.dart';
import 'package:kingdom_heir/core/responsive/app_metrics.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart' show AppSpacing;
import 'package:kingdom_heir/core/theme/spacing.dart' show AppSpacing;
import 'package:kingdom_heir/core/theme/theme.dart' show AppSpacing;

/// Kingdom Heir — Band-aware spatial tokens (the new [AppSpacing]).
///
/// Replace `AppSpacing.lg` with `Insets.of(context).lg` inside any
/// `build` method. The value returned depends on the active
/// [LayoutBand] resolved from the nearest [AppMetrics] inherited
/// widget (which is installed at the root of every screen via
/// `ResponsiveScaffold` / `bootstrap`).
///
/// Every value is on the 8-point grid (or a 2-pt sub-grid for hairline
/// gaps). The scale tightens on [LayoutBand.xs] and [LayoutBand.sm] so
/// 320 dp phones don't feel cramped, and widens on `lg+` so tablets
/// feel native.
@immutable
class Insets {
  const Insets._({
    required this.xxxs,
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.huge,
    required this.massive,
  });

  /// 2 dp — micro gap (badge padding).
  final double xxxs;

  /// 4 dp — extra extra small.
  final double xxs;

  /// 6–8 dp — extra small (chip horizontal padding).
  final double xs;

  /// 8–12 dp — small (1 grid unit).
  final double sm;

  /// 12–16 dp — medium-small (default tile padding).
  final double md;

  /// 14–20 dp — medium (default page horizontal padding).
  final double lg;

  /// 16–28 dp — medium-large (section padding).
  final double xl;

  /// 20–32 dp — large (card padding).
  final double xxl;

  /// 24–48 dp — extra large (page vertical rhythm).
  final double xxxl;

  /// 32–72 dp — section spacing.
  final double huge;

  /// 40–96 dp — hero / app-bar spacing.
  final double massive;

  /// Look up band-aware insets from the ambient [AppMetrics] widget.
  ///
  /// Falls back to [LayoutBand.md] if no [AppMetrics] is present
  /// (e.g. inside `ThemeData` builders that run before the root
  /// inherited widget is installed — use [Insets.fixed] in that case).
  static Insets of(BuildContext context) {
    final m = AppMetrics.maybeOf(context);
    return m == null ? fixed(LayoutBand.md) : fixed(m.band);
  }

  /// Look up insets for a known [LayoutBand] (no widget required).
  ///
  /// Use this from `ThemeData` builders, `TextStyle` factories, and
  /// any context that runs *before* the first layout pass.
  static Insets fixed(LayoutBand band) => _table[band] ?? fixed(LayoutBand.md);

  // ─────────────────────────────────────────────────────────────────
  // Table
  // ─────────────────────────────────────────────────────────────────

  static final Map<LayoutBand, Insets> _table = {
    LayoutBand.xs: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 6,
      sm: 8,
      md: 10,
      lg: 14,
      xl: 16,
      xxl: 18,
      xxxl: 22,
      huge: 28,
      massive: 36,
    ),
    LayoutBand.sm: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 6,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 18,
      xxl: 22,
      xxxl: 28,
      huge: 36,
      massive: 48,
    ),
    LayoutBand.md: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 6,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
      xxl: 24,
      xxxl: 32,
      huge: 40,
      massive: 56,
    ),
    LayoutBand.lg: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 6,
      sm: 10,
      md: 14,
      lg: 20,
      xl: 24,
      xxl: 32,
      xxxl: 40,
      huge: 56,
      massive: 72,
    ),
    LayoutBand.xl: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 8,
      sm: 12,
      md: 16,
      lg: 24,
      xl: 28,
      xxl: 40,
      xxxl: 48,
      huge: 64,
      massive: 80,
    ),
    LayoutBand.xxl: const Insets._(
      xxxs: 2,
      xxs: 4,
      xs: 8,
      sm: 12,
      md: 16,
      lg: 28,
      xl: 32,
      xxl: 48,
      xxxl: 56,
      huge: 72,
      massive: 96,
    ),
  };
}
