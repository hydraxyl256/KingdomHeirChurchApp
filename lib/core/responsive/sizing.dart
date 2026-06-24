import 'package:flutter/widgets.dart';
import 'package:kingdom_heir/core/responsive/app_metrics.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart' show Insets;

/// Kingdom Heir — Band-aware component dimensions.
///
/// Replaces the static constants in the legacy `AppSpacing`:
/// `buttonHeight`, `fieldHeight`, `navBarHeight`, `appBarHeight`,
/// `avatarMd/Lg/Xl`, `iconMd`, plus a few new ones (miniPlayerHeight,
/// extendedRailWidth, appBarExpandedHeight).
///
/// Same lookup contract as [Insets]: `Sizing.of(context)` inside
/// `build`, `Sizing.fixed(band)` in theme/data builders.
@immutable
class Sizing {
  const Sizing._({
    required this.buttonHeight,
    required this.buttonHeightSm,
    required this.fieldHeight,
    required this.navBarHeight,
    required this.appBarHeight,
    required this.appBarExpandedHeight,
    required this.miniPlayerHeight,
    required this.avatarXs,
    required this.avatarSm,
    required this.avatarMd,
    required this.avatarLg,
    required this.avatarXl,
    required this.iconXs,
    required this.iconSm,
    required this.iconMd,
    required this.iconLg,
    required this.iconXl,
    required this.railWidth,
    required this.railExtendedWidth,
    required this.sheetHandleWidth,
    required this.sheetHandleHeight,
  });

  /// Standard button height.
  final double buttonHeight;

  /// Compact / small button height.
  final double buttonHeightSm;

  /// Text field resting height.
  final double fieldHeight;

  /// Bottom navigation bar height.
  final double navBarHeight;

  /// Top app bar resting height.
  final double appBarHeight;

  /// Sliver app bar expanded height (e.g. for `FlexibleSpaceBar`).
  final double appBarExpandedHeight;

  /// Persistent sermon mini-player height (above the nav bar).
  final double miniPlayerHeight;

  /// Avatar sizes, diameter.
  final double avatarXs;
  final double avatarSm;
  final double avatarMd;
  final double avatarLg;
  final double avatarXl;

  /// Icon sizes.
  final double iconXs;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double iconXl;

  /// Navigation rail (compact) width.
  final double railWidth;

  /// Navigation rail (extended / tablet) width.
  final double railExtendedWidth;

  /// Bottom-sheet grab handle dimensions.
  final double sheetHandleWidth;
  final double sheetHandleHeight;

  /// Band-aware lookup. Same contract as [Insets.of].
  static Sizing of(BuildContext context) {
    final m = AppMetrics.maybeOf(context);
    return m == null ? fixed(LayoutBand.md) : fixed(m.band);
  }

  /// Static lookup for use in `ThemeData` / data builders.
  static Sizing fixed(LayoutBand band) => _table[band] ?? fixed(LayoutBand.md);

  // ─────────────────────────────────────────────────────────────────
  // Table
  // ─────────────────────────────────────────────────────────────────

  static final Map<LayoutBand, Sizing> _table = {
    LayoutBand.xs: const Sizing._(
      buttonHeight: 48,
      buttonHeightSm: 36,
      fieldHeight: 52,
      navBarHeight: 60,
      appBarHeight: 52,
      appBarExpandedHeight: 96,
      miniPlayerHeight: 60,
      avatarXs: 24,
      avatarSm: 32,
      avatarMd: 44,
      avatarLg: 56,
      avatarXl: 72,
      iconXs: 12,
      iconSm: 16,
      iconMd: 22,
      iconLg: 28,
      iconXl: 44,
      railWidth: 64,
      railExtendedWidth: 200,
      sheetHandleWidth: 36,
      sheetHandleHeight: 4,
    ),
    LayoutBand.sm: const Sizing._(
      buttonHeight: 50,
      buttonHeightSm: 38,
      fieldHeight: 54,
      navBarHeight: 62,
      appBarHeight: 56,
      appBarExpandedHeight: 104,
      miniPlayerHeight: 62,
      avatarXs: 26,
      avatarSm: 34,
      avatarMd: 46,
      avatarLg: 60,
      avatarXl: 80,
      iconXs: 13,
      iconSm: 17,
      iconMd: 23,
      iconLg: 30,
      iconXl: 46,
      railWidth: 68,
      railExtendedWidth: 208,
      sheetHandleWidth: 38,
      sheetHandleHeight: 4,
    ),
    LayoutBand.md: const Sizing._(
      buttonHeight: 52,
      buttonHeightSm: 40,
      fieldHeight: 56,
      navBarHeight: 64,
      appBarHeight: 64,
      appBarExpandedHeight: 120,
      miniPlayerHeight: 64,
      avatarXs: 28,
      avatarSm: 36,
      avatarMd: 48,
      avatarLg: 64,
      avatarXl: 80,
      iconXs: 14,
      iconSm: 18,
      iconMd: 24,
      iconLg: 32,
      iconXl: 48,
      railWidth: 72,
      railExtendedWidth: 216,
      sheetHandleWidth: 40,
      sheetHandleHeight: 4,
    ),
    LayoutBand.lg: const Sizing._(
      buttonHeight: 56,
      buttonHeightSm: 44,
      fieldHeight: 60,
      navBarHeight: 68,
      appBarHeight: 68,
      appBarExpandedHeight: 144,
      miniPlayerHeight: 68,
      avatarXs: 30,
      avatarSm: 40,
      avatarMd: 52,
      avatarLg: 72,
      avatarXl: 96,
      iconXs: 14,
      iconSm: 18,
      iconMd: 26,
      iconLg: 36,
      iconXl: 56,
      railWidth: 80,
      railExtendedWidth: 240,
      sheetHandleWidth: 44,
      sheetHandleHeight: 5,
    ),
    LayoutBand.xl: const Sizing._(
      buttonHeight: 60,
      buttonHeightSm: 48,
      fieldHeight: 64,
      navBarHeight: 72,
      appBarHeight: 72,
      appBarExpandedHeight: 168,
      miniPlayerHeight: 72,
      avatarXs: 32,
      avatarSm: 44,
      avatarMd: 56,
      avatarLg: 80,
      avatarXl: 104,
      iconXs: 16,
      iconSm: 20,
      iconMd: 28,
      iconLg: 40,
      iconXl: 64,
      railWidth: 88,
      railExtendedWidth: 264,
      sheetHandleWidth: 48,
      sheetHandleHeight: 5,
    ),
    LayoutBand.xxl: const Sizing._(
      buttonHeight: 64,
      buttonHeightSm: 52,
      fieldHeight: 68,
      navBarHeight: 76,
      appBarHeight: 76,
      appBarExpandedHeight: 192,
      miniPlayerHeight: 76,
      avatarXs: 36,
      avatarSm: 48,
      avatarMd: 60,
      avatarLg: 88,
      avatarXl: 120,
      iconXs: 16,
      iconSm: 22,
      iconMd: 32,
      iconLg: 44,
      iconXl: 72,
      railWidth: 96,
      railExtendedWidth: 288,
      sheetHandleWidth: 52,
      sheetHandleHeight: 6,
    ),
  };
}
