// Kingdom Heir — Financial Stewardship (SECTION 7)
//
// THE other overflow fix. Three cards compose this section:
//   1. Giving summary  — month label, animated amount, goal, weekly sparkline
//   2. Campaign progress — title, animated raised amount, animated progress bar
//   3. Quick give      — preset amount pills + "Custom" CTA
//
// Layout:
//   • < 600 dp: cards stack vertically (Wrap with `runSpacing`)
//   • ≥ 600 dp: cards render in a 2-column Wrap; the giving summary and quick
//     give share the first row (50/50), the campaign spans the second row
//
// An empty [GivingSummary] (amountGiven = 0) is treated as "no history" and
// still renders the section, but with a friendlier empty state for "Quick give".

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/animated_count.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class FinancialStewardshipSection extends StatelessWidget {
  const FinancialStewardshipSection({
    required this.summary,
    super.key,
    this.onSeeAll,
    this.onGive,
    this.onPresetTap,
  });

  final GivingSummary summary;
  final VoidCallback? onSeeAll;
  final VoidCallback? onGive;
  final void Function(double)? onPresetTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Financial stewardship',
          subtitle: 'Faithful giving, faithful living',
          actionLabel: 'History',
          onAction: onSeeAll,
          icon: Icons.favorite_rounded,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            insets.lg,
            insets.xs,
            insets.lg,
            insets.xl,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.maxWidth);
              final isWide = band.isAtLeast(LayoutBand.lg);

              final summaryCard = _GivingSummaryCard(
                summary: summary,
                onSeeAll: onSeeAll,
              );
              final campaignCard = _CampaignProgressCard(summary: summary);
              final quickGiveCard = _QuickGiveCard(
                summary: summary,
                onGive: onGive,
                onPresetTap: onPresetTap,
              );

              if (isWide) {
                return Wrap(
                  spacing: insets.md,
                  runSpacing: insets.md,
                  children: [
                    SizedBox(
                      width: (constraints.maxWidth - insets.md) / 2,
                      child: summaryCard,
                    ),
                    SizedBox(
                      width: (constraints.maxWidth - insets.md) / 2,
                      child: quickGiveCard,
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: campaignCard,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  summaryCard,
                  SizedBox(height: insets.md),
                  campaignCard,
                  SizedBox(height: insets.md),
                  quickGiveCard,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GivingSummaryCard extends StatelessWidget {
  const _GivingSummaryCard({required this.summary, this.onSeeAll});
  final GivingSummary summary;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.monthLabel.toUpperCase(),
                  style: AppTypography.scriptureRef.copyWith(
                    color: AppColors.goldDark,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.goldDark,
                    minimumSize: const Size(0, 32),
                    padding: EdgeInsets.symmetric(horizontal: insets.xs),
                  ),
                  child: const Text('History'),
                ),
            ],
          ),
          SizedBox(height: insets.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                r'$',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AnimatedCount(
                value: summary.amountGiven.round(),
                style: AppTypography.statNumber.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: insets.xs),
          Text(
            'of \$${summary.goalAmount.round()} goal',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: insets.md),
          _AnimatedProgressBar(progress: summary.progress),
          SizedBox(height: insets.md),
          _WeeklySparkline(values: summary.history),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.standard, curve: AppMotion.decelerate)
        .slideY(begin: 0.1, end: 0);
  }
}

class _CampaignProgressCard extends StatelessWidget {
  const _CampaignProgressCard({required this.summary});
  final GivingSummary summary;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Container(
      padding: EdgeInsets.all(insets.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CAMPAIGN',
            style: AppTypography.scriptureRef.copyWith(
              color: AppColors.goldLight,
            ),
          ),
          SizedBox(height: insets.xs),
          Text(
            summary.campaignTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: insets.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                r'$',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.goldLight,
                ),
              ),
              AnimatedCount(
                value: summary.campaignRaised.round(),
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.warmWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: insets.xs),
              Flexible(
                child: Text(
                  'of \$${(summary.campaignGoal / 1000).toStringAsFixed(0)}K',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: insets.md),
          _AnimatedProgressBar(
            progress: summary.campaignProgress,
            backgroundColor: AppColors.warmWhite.withValues(alpha: 0.18),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: AppMotion.standard,
          delay: const Duration(milliseconds: 80),
          curve: AppMotion.decelerate,
        )
        .slideY(begin: 0.1, end: 0);
  }
}

class _QuickGiveCard extends StatelessWidget {
  const _QuickGiveCard({
    required this.summary,
    this.onGive,
    this.onPresetTap,
  });
  final GivingSummary summary;
  final VoidCallback? onGive;
  final void Function(double)? onPresetTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(insets.xs),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.goldDark,
                  size: 16,
                ),
              ),
              SizedBox(width: insets.xs),
              Expanded(
                child: Text(
                  'Quick give',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: insets.md),
          // Wrap so preset pills never overflow on 320 dp screens.
          Wrap(
            spacing: insets.xs,
            runSpacing: insets.xs,
            children: [
              for (final amount in summary.presets)
                _PresetPill(
                  label: '\$$amount',
                  onTap: () => onPresetTap?.call(amount),
                ),
            ],
          ),
          SizedBox(height: insets.md),
          AppButton(
            label: 'Custom amount',
            icon: Icons.edit_rounded,
            onPressed: onGive,
            height: 44,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: AppMotion.standard,
          delay: const Duration(milliseconds: 160),
          curve: AppMotion.decelerate,
        )
        .slideY(begin: 0.1, end: 0);
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: insets.md,
            vertical: insets.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.progress,
    // ignore: unused_element_parameter
    this.foregroundColor,
    this.backgroundColor,
  });
  final double progress;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: AppMotion.decelerate,
              builder: (context, value, _) {
                return Container(
                  height: 8,
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _WeeklySparkline extends StatelessWidget {
  const _WeeklySparkline({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values) ...[
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: maxValue <= 0 ? 0 : v / maxValue),
                duration: const Duration(milliseconds: 900),
                curve: AppMotion.decelerate,
                builder: (context, ratio, _) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: insets.xxxs),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    height: 40 * ratio,
                  );
                },
              ),
            ),
          ],
          SizedBox(width: insets.sm),
          Text(
            'Last 4 wks',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
