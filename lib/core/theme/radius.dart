/// Kingdom Heir — Radius System
///
/// Border-radius scale tuned for a luxury, reverent feel. Smaller radii
/// convey refinement; the largest radii (full / pill) are reserved for
/// primary actions and badges to keep visual emphasis on what matters.
library kingdom_heir.theme.radius;

import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  // ─────────────────────────────────────────────────────────────────────────
  // Radius Scale
  // ─────────────────────────────────────────────────────────────────────────

  /// 0 — flush edges (tables, dividers).
  static const double none = 0;

  /// 4px — pill on small chips / icons.
  static const double xs = 4;

  /// 6px — small components (badges, tags).
  static const double sm = 6;

  /// 10px — standard buttons, text fields, list items.
  static const double md = 10;

  /// 14px — cards, dialogs.
  static const double lg = 14;

  /// 20px — bottom sheets, large cards, image thumbnails.
  static const double xl = 20;

  /// 28px — extra-large surface (hero cards, feature tiles).
  static const double xxl = 28;

  /// Full-pill — primary buttons, FABs, segmented pills.
  static const double full = 28;

  /// 9999px — true circle (avatars, dot indicators).
  static const double circle = 9999;

  // ─────────────────────────────────────────────────────────────────────────
  // BorderRadius helpers
  // ─────────────────────────────────────────────────────────────────────────

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));

  /// Top-rounded bottom-sheet corner.
  static const BorderRadius brSheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// Top-rounded modal sheet (Apple HIG style).
  static const BorderRadius brModalTop = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Circle border-radius for square aspect-ratio containers.
  static const BorderRadius brCircle =
      BorderRadius.all(Radius.circular(circle));
}
