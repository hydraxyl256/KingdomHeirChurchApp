// Kingdom Heir — Devotional Progress Card Widget
//
// A compact, reusable card that shows:
//   - Day X of N progress bar
//   - Current streak badge
//   - State-based CTA (join / continue / completed today / all done)
//
// Used in both the Challenge Hub and the Devotionals screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_series_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class DevotionalProgressCard extends ConsumerWidget {
  const DevotionalProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardStateAsync = ref.watch(primaryChallengeCardStateProvider);
    final theme = Theme.of(context);

    return cardStateAsync.when(
      loading: () => _CardShell(child: _LoadingSkeleton(theme: theme)),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        if (state == null) return const SizedBox.shrink();
        return _CardShell(child: _CardContent(state: state));
      },
    );
  }
}

// ─── Card outer shell ─────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SkeletonLine(width: 120, height: 14),
        SizedBox(height: AppSpacing.sm),
        _SkeletonLine(width: double.infinity, height: 8),
        SizedBox(height: AppSpacing.md),
        _SkeletonLine(width: 200, height: 40, radius: 12),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine(
      {required this.width, required this.height, this.radius = 4,});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Card content ─────────────────────────────────────────────────────────────

class _CardContent extends ConsumerWidget {
  const _CardContent({required this.state});
  final DashboardDevotionalState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header row ────────────────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppColors.gold, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '90-DAY CHALLENGE',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            if (state.currentStreak != null && state.currentStreak! > 0)
              _StreakBadge(streak: state.currentStreak!),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Progress bar (only when joined) ───────────────────────────
        if (state.status != DashboardDevotionalStatus.notJoined &&
            state.currentDay != null &&
            state.totalDays != null) ...[
          Row(
            children: [
              Text(
                'Day ${state.currentDay} of ${state.totalDays}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.warmWhite.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${((state.currentDay! / state.totalDays!) * 100).toStringAsFixed(0)}%',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _ProgressBar(
            value: state.currentDay! / state.totalDays!,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else
          const SizedBox(height: AppSpacing.xs),

        // ── CTA ───────────────────────────────────────────────────────
        _CtaButton(state: state, ref: ref),
      ],
    );
  }
}

// ─── Streak badge ─────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => LayoutBuilder(
        builder: (_, constraints) => Stack(
          children: [
            Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.warmWhite.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            Container(
              height: 6,
              width: constraints.maxWidth * v,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.gold],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CTA button ───────────────────────────────────────────────────────────────

class _CtaButton extends ConsumerWidget {
  const _CtaButton({required this.state, required this.ref});
  final DashboardDevotionalState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case DashboardDevotionalStatus.notJoined:
        return _GoldButton(
          label: 'Start the 90-Day Challenge',
          icon: Icons.rocket_launch_rounded,
          onTap: () async {
            final result = await ref
                .read(devotionalProgressProvider(state.seriesId).notifier)
                .joinChallenge();
            result.fold(
              (err) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err)),
              ),
              (_) => context.push(
                RouteNames.devotionalDayReader
                    .replaceFirst(':seriesId', state.seriesId)
                    .replaceFirst(':dayNumber', '1'),
              ),
            );
          },
        );

      case DashboardDevotionalStatus.continueDay:
        return _GoldButton(
          label: 'Continue Day ${state.currentDay}',
          icon: Icons.play_arrow_rounded,
          onTap: () => context.push(
            RouteNames.devotionalDayReader
                .replaceFirst(':seriesId', state.seriesId)
                .replaceFirst(':dayNumber', '${state.currentDay}'),
          ),
        );

      case DashboardDevotionalStatus.completedToday:
        return _InfoRow(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          message:
              'Day ${state.currentDay! - 1} Complete — return tomorrow for Day ${state.currentDay}',
        );

      case DashboardDevotionalStatus.allComplete:
        return _InfoRow(
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.gold,
          message: '${AppLocalizations.of(context)!.allDaysComplete} 🎉',
        );
    }
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.message,
  });
  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
