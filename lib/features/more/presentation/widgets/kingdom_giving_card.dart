// Kingdom Heir — Kingdom Giving Card (SECTION 5)
//
// Premium stewardship card summarizing:
//   • This month's giving (amount / goal) with animated progress
//   • Active campaign progress (raised / goal) with a different color
//   • A small sparkline of the last 6 months
//   • A primary "Give now" CTA and a secondary "History" link
//
// Visual:
//   • Glassy navy/gold gradient surface
//   • Gold progress bars with animated fills
//   • Sparkline drawn with a `CustomPainter` — no extra dependency
//
// Animation:
//   • Card fades in via a self-contained `TweenAnimationBuilder` (no
//     `flutter_animate` chain — its internal Builder crashed
//     inside SliverToBoxAdapter).
//   • Both progress bars animate via `TweenAnimationBuilder` (1.2s ease-out).
//
// Theming:
//   • All brand navy/gold/warmWhite/ink surfaces come from
//     `MoreSectionTheme.of(context)` so the card stays on-brand in both
//     light and dark themes.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/more_section_theme.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';

class KingdomGivingCard extends StatelessWidget {
  const KingdomGivingCard({required this.summary, super.key});

  final MoreGivingSummary summary;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final section = MoreSectionTheme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, insets.lg),
      // Wrap the card in a self-contained fade-in to avoid the
      // flutter_animate internal Builder that crashed RenderBox.size
      // inside SliverToBoxAdapter.
      child: _KingdomCardFadeIn(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                section.heroBackgroundTop,
                section.heroBackgroundBottom,
                section.heroAccentOnSurface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: section.brandBorder),
            boxShadow: [
              BoxShadow(
                color: section.brandShadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: section.brandContainerSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: section.heroAccent,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Text(
                      'KINGDOM GIVING',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: section.heroAccent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  Text(
                    summary.monthLabel,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: section.heroMutedOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: insets.md),

              // ── Month progress ────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _currency(summary.amountGiven),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: section.heroAccentOnSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: insets.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'of ${_currency(summary.goalAmount)}',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: section.heroMutedOnSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: insets.xs),
              _AnimatedGoldBar(
                value: summary.monthProgress,
                height: 8,
                section: section,
              ),
              SizedBox(height: insets.xs),
              Text(
                '${(summary.monthProgress * 100).toStringAsFixed(0)}% of monthly goal',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: section.heroAccentOnSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: insets.md),

              // ── Sparkline (last 6 months) ────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: insets.md,
                  vertical: insets.sm,
                ),
                decoration: BoxDecoration(
                  color: section.heroAccentOnSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: section.heroAccentOnSurface.withValues(alpha: 0.08),
                    width: 0.6,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LAST 6 MONTHS',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color:
                            section.heroAccentOnSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: insets.xs),
                    SizedBox(
                      height: 36,
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          values: summary.recentMonths,
                          strokeColor: section.heroAccent,
                          fillColor: section.heroAccent.withValues(alpha: 0.16),
                          lastPointColor: section.heroAccentOnSurface,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: insets.md),

              // ── Campaign progress ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: section.brandChipBackground,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'CAMPAIGN',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: section.heroBackgroundTop,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Text(
                      summary.campaignTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: section.heroAccentOnSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: insets.xs),
              _AnimatedGoldBar(
                value: summary.campaignProgress,
                section: section,
              ),
              SizedBox(height: insets.xxs),
              Text(
                '${_currency(summary.campaignRaised)} raised · ${_currency(summary.campaignGoal)} goal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: section.heroAccentOnSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: insets.md),

              // ── CTAs ─────────────────────────────────────────────────────
              // The primary CTA opens the hosted donation page in the
              // device's external browser (see `donation_launcher.dart`).
              // The secondary "History" button stays in-app so the user
              // can still review past giving records.
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Donate Securely',
                      icon: Icons.open_in_new_rounded,
                      onPressed: () => openDonationPage(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

/// Self-contained opacity + Y-translate fade-in used for the Kingdom
/// Giving card. Replaces `flutter_animate`'s chain so SliverToBoxAdapter
/// measurement never sees an internal Builder.
class _KingdomCardFadeIn extends StatelessWidget {
  const _KingdomCardFadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

class _AnimatedGoldBar extends StatelessWidget {
  const _AnimatedGoldBar({
    required this.value,
    required this.section,
    this.height = 6,
  });

  final double value;
  final double height;
  final MoreSectionTheme section;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: height,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: section.heroAccentOnSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                Container(
                  height: height,
                  width: constraints.maxWidth * v,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        section.brandChipBackground,
                        section.heroAccent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: section.heroAccent.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.strokeColor,
    required this.fillColor,
    required this.lastPointColor,
  });

  final List<double> values;
  final Color strokeColor;
  final Color fillColor;
  final Color lastPointColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final span = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);

    final dx = size.width / (values.length - 1);

    final line = Path();
    final fill = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height -
          ((values[i] - minV) / span) * (size.height - 4) -
          2; // small inset
      if (i == 0) {
        line.moveTo(x, y);
        fill
          ..moveTo(x, size.height)
          ..lineTo(x, y);
      } else {
        line.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(fill, fillPaint);

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(line, strokePaint);

    // Final point dot
    final lastX = (values.length - 1) * dx;
    final lastY =
        size.height - ((values.last - minV) / span) * (size.height - 4) - 2;
    canvas
      ..drawCircle(
        Offset(lastX, lastY),
        3.5,
        Paint()..color = strokeColor,
      )
      ..drawCircle(
        Offset(lastX, lastY),
        1.6,
        Paint()..color = lastPointColor,
      );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}
