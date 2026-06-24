import 'package:flutter/widgets.dart';
import 'package:kingdom_heir/core/responsive/app_metrics.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart' show Insets;

/// Kingdom Heir — Band-aware corner radius scale.
///
/// Slightly tighter radii on phone (Apple HIG) and slightly larger on
/// tablet/desktop so large surfaces feel cohesive.
@immutable
class Radii {
  const Radii._({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  /// Band-aware lookup. Same contract as [Insets.of].
  static Radii of(BuildContext context) {
    final m = AppMetrics.maybeOf(context);
    return m == null ? fixed(LayoutBand.md) : fixed(m.band);
  }

  /// Static lookup for use in `ThemeData` / data builders.
  static Radii fixed(LayoutBand band) => _table[band] ?? fixed(LayoutBand.md);

  static final Map<LayoutBand, Radii> _table = {
    LayoutBand.xs: const Radii._(
      xs: 4,
      sm: 6,
      md: 10,
      lg: 12,
      xl: 18,
      full: 26,
    ),
    LayoutBand.sm: const Radii._(
      xs: 4,
      sm: 6,
      md: 10,
      lg: 14,
      xl: 20,
      full: 28,
    ),
    LayoutBand.md: const Radii._(
      xs: 4,
      sm: 6,
      md: 10,
      lg: 14,
      xl: 20,
      full: 28,
    ),
    LayoutBand.lg: const Radii._(
      xs: 4,
      sm: 6,
      md: 12,
      lg: 16,
      xl: 24,
      full: 32,
    ),
    LayoutBand.xl: const Radii._(
      xs: 6,
      sm: 8,
      md: 12,
      lg: 18,
      xl: 28,
      full: 36,
    ),
    LayoutBand.xxl: const Radii._(
      xs: 6,
      sm: 8,
      md: 14,
      lg: 20,
      xl: 32,
      full: 40,
    ),
  };
}
