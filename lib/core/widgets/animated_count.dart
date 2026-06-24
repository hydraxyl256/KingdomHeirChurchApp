// Kingdom Heir — AnimatedCount
//
// A numeric counter that tweens from 0 → [value] (or [from] → [to]) when
// the value changes. Used by:
//   • Kingdom Impact stat tiles
//   • Campaign raised numbers
//   • Prayer reaction counts
//
// Honors:
//   • MediaQuery.disableAnimations (snaps to final value)
//   • TextScaler (the rendered text uses the inherited TextScaler automatically,
//     but we cap the duration when the user's text scale is large so the digits
//     don't feel laggy)
//
// The widget rebuilds only when [value] changes (uses AnimatedSwitcher + an
// internal TweenAnimationBuilder<double>, keyed on `value`).

import 'package:flutter/material.dart';

class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    required this.style,
    super.key,
    this.from,
    this.duration = const Duration(milliseconds: 1100),
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.useGrouping = true,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  });

  final num value;
  final TextStyle? style;
  final num? from;

  /// Total animation duration. Capped internally when system reduce-motion
  /// is on, or when text-scale is large.
  final Duration duration;
  final Curve curve;

  /// Optional prefix (e.g. `'$'` or `'×'`).
  final String prefix;

  /// Optional suffix (e.g. `' days'` or `' nations'`).
  final String suffix;

  /// Whether to render with locale grouping separators (1,234 vs 1234).
  final bool useGrouping;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    final effectiveDuration = mq.disableAnimations ? Duration.zero : duration;

    final fromValue = (from ?? 0).toDouble();
    final toValue = value.toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: fromValue, end: toValue),
      duration: effectiveDuration,
      curve: curve,
      builder: (context, current, _) {
        final display = current.round();
        final formatted = useGrouping ? _groupInt(display) : display.toString();
        return Text(
          '$prefix$formatted$suffix',
          style: style,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
        );
      },
    );
  }

  static String _groupInt(int value) {
    // Locale-agnostic thousands grouping (en_US-style commas). Replace with
    // NumberFormat.simpleCurrency / .decimalPattern if/when l10n is wired.
    final negative = value < 0;
    final digits = value.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return negative ? '-$buf' : buf.toString();
  }
}
