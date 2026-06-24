import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/responsive/radii.dart';
import 'package:kingdom_heir/core/responsive/sizing.dart';

/// Kingdom Heir — Ambient layout metrics, broadcast from the root.
///
/// A single [InheritedWidget] that every screen in the app reads via
/// [AppMetrics.of]. Updates only when the active [LayoutBand] changes,
/// so the keyboard opening or a text-scale change does NOT trigger a
/// rebuild of every consumer (the [MediaQuery] subtree itself handles
/// text-scale and padding updates).
///
/// You should never need to construct an [AppMetrics] yourself. The
/// root bootstrap wraps `runApp`'s output in one.
@immutable
class AppMetrics extends InheritedWidget {
  const AppMetrics({
    required this.band,
    required this.safePadding,
    required this.viewInsets,
    required this.textScaler,
    required this.contentMaxWidth,
    required this.devicePixelRatio,
    required super.child,
    super.key,
  });

  /// Convenience factory that reads from the ambient [MediaQuery] and
  /// resolves the band from a known [LayoutBand] (e.g. forced in tests).
  factory AppMetrics.fromMediaQuery({
    required LayoutBand band,
    required MediaQueryData mq,
    required Widget child,
    Key? key,
  }) {
    return AppMetrics(
      key: key,
      band: band,
      safePadding: mq.padding,
      viewInsets: mq.viewInsets,
      textScaler: mq.textScaler,
      contentMaxWidth: _contentMaxWidthFor(band),
      devicePixelRatio: mq.devicePixelRatio,
      child: child,
    );
  }

  /// Resolve the [LayoutBand] directly from `MediaQuery.size.width`.
  factory AppMetrics.fromContext({
    required BuildContext context,
    required Widget child,
    Key? key,
  }) {
    final mq = MediaQuery.of(context);
    return AppMetrics.fromMediaQuery(
      key: key,
      band: layoutBandFromWidth(mq.size.width),
      mq: mq,
      child: child,
    );
  }

  /// The active layout band.
  final LayoutBand band;

  /// Resolved `MediaQuery.padding` — system safe-area insets.
  final EdgeInsets safePadding;

  /// Resolved `MediaQuery.viewInsets` — current keyboard / system UI inset.
  final EdgeInsets viewInsets;

  /// Resolved `MediaQuery.textScaler`.
  final TextScaler textScaler;

  /// Maximum content width (clamped to a comfortable reading width on
  /// larger screens; the `ResponsiveScaffold` constrains `body` to this).
  final double contentMaxWidth;

  /// `MediaQuery.devicePixelRatio` for golden-test setups.
  final double devicePixelRatio;

  /// Look up the ambient [AppMetrics]. Returns `null` outside the
  /// root wrapper — callers should fall back to [LayoutBand.md] in
  /// that case.
  static AppMetrics? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppMetrics>();
  }

  /// Like [maybeOf] but throws in debug if absent. Use inside `build`
  /// of any widget wrapped by `ResponsiveScaffold` or the root
  /// [AppMetrics]; the root widget always installs the inherited
  /// widget before any feature screen builds.
  static AppMetrics of(BuildContext context) {
    final m = maybeOf(context);
    assert(
      m != null,
      'AppMetrics not found. Wrap your app in AppMetrics.fromContext, '
      'or use LayoutBand.fromWidth(constraints.maxWidth) inside a '
      'LayoutBuilder.',
    );
    return m ?? _fallback;
  }

  /// Convenience: band-aware [Insets] lookup.
  Insets get insets => Insets.fixed(band);

  /// Convenience: band-aware [Sizing] lookup.
  Sizing get sizing => Sizing.fixed(band);

  /// Convenience: band-aware [Radii] lookup.
  Radii get radii => Radii.fixed(band);

  @override
  bool updateShouldNotify(AppMetrics oldWidget) => band != oldWidget.band;

  // ─────────────────────────────────────────────────────────────────
  // Internals
  // ─────────────────────────────────────────────────────────────────

  static double _contentMaxWidthFor(LayoutBand band) => switch (band) {
        LayoutBand.xs => 720,
        LayoutBand.sm => 720,
        LayoutBand.md => 720,
        LayoutBand.lg => 960,
        LayoutBand.xl => 1200,
        LayoutBand.xxl => 1320,
      };

  static const AppMetrics _fallback = AppMetrics(
    band: LayoutBand.md,
    safePadding: EdgeInsets.zero,
    viewInsets: EdgeInsets.zero,
    textScaler: TextScaler.noScaling,
    contentMaxWidth: 720,
    devicePixelRatio: 1,
    child: SizedBox.shrink(),
  );
}
