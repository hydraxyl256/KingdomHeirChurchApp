// Kingdom Heir — Engagement Chart
//
// Custom-painted bar chart showing weekly active members over the last
// 8 weeks. No external chart dependency — uses `CustomPainter` and a
// `TweenAnimationBuilder` for the entry animation.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class EngagementChart extends StatelessWidget {
  const EngagementChart({
    required this.weeklyActive,
    super.key,
    this.label = 'Weekly active members',
  });

  /// Values per week, oldest first → most recent last. Provide up to 8.
  final List<int> weeklyActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final data = weeklyActive.length >= 8
        ? weeklyActive.sublist(weeklyActive.length - 8)
        : weeklyActive;
    final maxV = (data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b))
        .clamp(1, 1000000)
        .toDouble();

    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: insets.sm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, t, __) => SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _BarPainter(
                  values: data,
                  maxValue: maxV,
                  progress: t,
                  barColor: AppColors.gold,
                  axisColor: theme.colorScheme.outlineVariant,
                  textColor: theme.colorScheme.onSurfaceVariant,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.values,
    required this.maxValue,
    required this.progress,
    required this.barColor,
    required this.axisColor,
    required this.textColor,
  });

  final List<int> values;
  final double maxValue;
  final double progress;
  final Color barColor;
  final Color axisColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const labelHeight = 18.0;
    final chartHeight = size.height - labelHeight;
    const gap = 6.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    // Baseline.
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      axisPaint,
    );

    for (var i = 0; i < values.length; i++) {
      final v = values[i].toDouble();
      final ratio = v / maxValue;
      final barHeight = chartHeight * ratio * progress;
      final left = i * (barWidth + gap);
      final top = chartHeight - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [barColor, barColor.withValues(alpha: 0.55)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);

      // Week label (last week index → today).
      final isLast = i == values.length - 1;
      final tp = TextPainter(
        text: TextSpan(
          text: isLast ? 'Now' : 'W${values.length - i}',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barWidth + gap);
      tp.paint(
        canvas,
        Offset(left + (barWidth - tp.width) / 2, chartHeight + 2),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.maxValue != maxValue;
}
