/// Kingdom Heir — Spacing, Border Radius & Elevation System
///
/// Built on an 8-point grid. All sizes are multiples of 4 or 8.
abstract final class AppSpacing {
  // ─────────────────────────────────────────────────────────────────────────
  // Spacing Scale (8-point grid)
  // ─────────────────────────────────────────────────────────────────────────

  /// 2px — micro gap
  static const double xxxs = 2;

  /// 4px — extra extra small
  static const double xxs = 4;

  /// 6px — extra small (non-standard convenience)
  static const double xs = 6;

  /// 8px — small (1 grid unit)
  static const double sm = 8;

  /// 12px — medium-small
  static const double md = 12;

  /// 16px — medium (2 grid units) — default padding
  static const double lg = 16;

  /// 20px — medium-large
  static const double xl = 20;

  /// 24px — extra large (3 grid units)
  static const double xxl = 24;

  /// 32px — 2× large
  static const double xxxl = 32;

  /// 40px — section spacing
  static const double huge = 40;

  /// 56px — hero / app-bar spacing
  static const double massive = 56;

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius Scale
  // ─────────────────────────────────────────────────────────────────────────

  /// 4px — pill on small chips
  static const double radiusXs = 4;

  /// 6px — small components (chips, badges)
  static const double radiusSm = 6;

  /// 10px — standard buttons, text fields
  static const double radiusMd = 10;

  /// 14px — cards, dialogs
  static const double radiusLg = 14;

  /// 20px — bottom sheets, large cards
  static const double radiusXl = 20;

  /// 28px — full-pill buttons / FABs
  static const double radiusFull = 28;

  /// 9999px — circle (use with BorderRadius.circular)
  static const double radiusCircle = 9999;

  // ─────────────────────────────────────────────────────────────────────────
  // Elevation Scale (dp)
  // ─────────────────────────────────────────────────────────────────────────

  /// Flat — no shadow (cards on coloured backgrounds)
  static const double elevation0 = 0;

  /// Subtle lift — cards on white
  static const double elevation1 = 1;

  /// Standard card elevation
  static const double elevation2 = 2;

  /// Raised card / selected item
  static const double elevation3 = 4;

  /// Modal / dialog
  static const double elevation4 = 8;

  /// Navigation drawer / bottom sheet
  static const double elevation5 = 12;

  // ─────────────────────────────────────────────────────────────────────────
  // Avatar Sizes
  // ─────────────────────────────────────────────────────────────────────────

  /// 28px diameter — micro avatar (chat bubbles)
  static const double avatarXs = 28;

  /// 36px diameter — small avatar (list tiles)
  static const double avatarSm = 36;

  /// 48px diameter — medium avatar (cards)
  static const double avatarMd = 48;

  /// 64px diameter — large avatar (profile headers)
  static const double avatarLg = 64;

  /// 80px diameter — extra large (profile screen)
  static const double avatarXl = 80;

  // ─────────────────────────────────────────────────────────────────────────
  // Icon Sizes
  // ─────────────────────────────────────────────────────────────────────────

  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // ─────────────────────────────────────────────────────────────────────────
  // Component Sizes
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard button height
  static const double buttonHeight = 52;

  /// Small / compact button height
  static const double buttonHeightSm = 40;

  /// Text field height
  static const double fieldHeight = 56;

  /// Minimum touch target (48dp — WCAG / Material accessibility baseline)
  static const double minTouchTarget = 48;

  /// Navigation bar height
  static const double navBarHeight = 64;

  /// App bar height
  static const double appBarHeight = 64;

  /// Bottom sheet handle width
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;
}
