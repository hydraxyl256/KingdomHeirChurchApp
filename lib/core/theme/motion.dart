/// Kingdom Heir — Motion System
///
/// Motion conveys *reverence, excellence, and modernity*. Curves lean toward
/// Apple's spring-driven feel (overshoot allowed on entrance, calm on exit)
/// with M3 emphasized/standard durations for utility motion.
///
/// Reference:
///   • Material 3 motion specs (emphasized, standard, expressive durations).
///   • Apple HIG: spring animations for tactile feedback; gentle ease-out for
///     state changes; respect Reduce Motion.
library kingdom_heir.theme.motion;

import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  // ─────────────────────────────────────────────────────────────────────────
  // Duration Tokens (ms)
  // ─────────────────────────────────────────────────────────────────────────

  /// Instant feedback (button press highlight). 80ms.
  static const Duration instant = Duration(milliseconds: 80);

  /// Quick state change (toggle, ripple). 150ms.
  static const Duration quick = Duration(milliseconds: 150);

  /// Standard transition (fade, slide). 250ms.
  static const Duration standard = Duration(milliseconds: 250);

  /// Emphasized transition (shared element, hero). 400ms.
  static const Duration emphasized = Duration(milliseconds: 400);

  /// Expressive / choreographed entrance. 600ms.
  static const Duration expressive = Duration(milliseconds: 600);

  /// Slow, reverent entrance (splash, brand mark). 900ms.
  static const Duration reverent = Duration(milliseconds: 900);

  // ─────────────────────────────────────────────────────────────────────────
  // Curves — Material 3 + Apple HIG
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard easing — in-out cubic, M3 default.
  static const Curve standardCurve = Curves.easeInOutCubic;

  /// Decelerate — entering motion (M3 emphasized decelerate).
  static const Curve decelerate = Curves.easeOutCubic;

  /// Accelerate — exiting motion (M3 emphasized accelerate).
  static const Curve accelerate = Curves.easeInCubic;

  /// Linear — for spinners / progress indicators.
  static const Curve linear = Curves.linear;

  /// Overshoot — Apple-style tactile spring (slight).
  static const Curve overshoot = Curves.easeOutBack;

  /// Strong overshoot — for hero / brand entrances.
  static const Curve overshootStrong = Curves.elasticOut;

  // ─────────────────────────────────────────────────────────────────────────
  // Spring Specifications (Apple HIG aligned)
  // ─────────────────────────────────────────────────────────────────────────

  /// Responsive default spring — used for snappy UI controls.
  static const SpringDescription springSnappy = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 18,
  );

  /// Bouncy spring — used for delightful interactions (FAB press, badge pop).
  static const SpringDescription springBouncy = SpringDescription(
    mass: 1,
    stiffness: 240,
    damping: 14,
  );

  /// Smooth spring — used for subtle motion (page transition, drawer).
  static const SpringDescription springSmooth = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 22,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Pre-built [AnimationController] durations
  // ─────────────────────────────────────────────────────────────────────────

  /// Recommended [Duration] for fade-in.
  static const Duration fadeIn = standard;

  /// Recommended [Duration] for fade-out.
  static const Duration fadeOut = Duration(milliseconds: 200);

  /// Recommended [Duration] for slide-up entrance.
  static const Duration slideUp = emphasized;

  /// Recommended [Duration] for slide-down exit.
  static const Duration slideDown = Duration(milliseconds: 300);

  /// Recommended [Duration] for scale-in (cards, modals).
  static const Duration scaleIn = Duration(milliseconds: 350);

  /// Recommended [Duration] for shimmer loop cycle.
  static const Duration shimmerCycle = Duration(milliseconds: 1500);

  /// Recommended [Duration] for ripple.
  static const Duration ripple = Duration(milliseconds: 300);

  // ─────────────────────────────────────────────────────────────────────────
  // Page transition (Apple HIG + M3 hybrid)
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard page transition — fade + subtle slide-up.
  static const Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) pageTransitionBuilder = _pageTransition;

  static Widget _pageTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: decelerate,
      reverseCurve: accelerate,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reduce-motion guard (Apple HIG accessibility)
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a disabled [Duration] (~0) when [MediaQuery.disableAnimationsOf]
  /// is on. Pass the [BuildContext] of a widget that may respect reduce-motion.
  static Duration reduce(BuildContext context, Duration original) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : original;
  }
}
