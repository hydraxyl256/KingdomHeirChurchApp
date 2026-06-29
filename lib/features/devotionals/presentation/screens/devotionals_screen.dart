// Kingdom Heir — Devotional Journey: Screen 1 — Home
//
// Premium daily spiritual companion home screen.
// Shows: greeting, streak banner, today's hero card, stats, previous list.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';

class DevotionalsScreen extends ConsumerWidget {
  const DevotionalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyDevotionalProvider);
    final streak = ref.watch(devotionalStreakProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator.adaptive(
        color: AppColors.goldDark,
        onRefresh: () async => ref.invalidate(dailyDevotionalProvider),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            _DevotionalAppBar(streak: streak),

            // ── Date + Greeting ──────────────────────────────────────────
            const SliverToBoxAdapter(child: _DateGreeting()),

            // ── Streak Banner ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StreakBanner(streak: streak),
            ),

            // ── Today's Hero Card ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: dailyAsync.when(
                  loading: () => const _TodayCardSkeleton(),
                  error: (_, __) => const _TodayCardError(),
                  data: (devotional) {
                    if (devotional == null) return const _NoDevotionalCard();
                    final progress = ref
                        .watch(journeyProgressProvider(devotional.id));
                    return _TodayHeroCard(
                      devotional: devotional,
                      progress: progress,
                    );
                  },
                ),
              ),
            ),

            // ── Stats Row ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StatsRow(streak: streak),
            ),

            // ── Previous Devotionals Header ───────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Previous Devotionals',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ),
            ),

            // ── Previous List ─────────────────────────────────────────────
            ref.watch(previousDevotionalsProvider).when(
                  loading: () => const SliverToBoxAdapter(
                    child: _PreviousListSkeleton(),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: _PreviousListError(),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: _EmptyPreviousList(),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) => _PreviousDevotionalTile(
                          devotional: list[i],
                          index: i,
                          progress: ref.watch(
                            journeyProgressProvider(list[i].id),
                          ),
                        ),
                      ),
                    );
                  },
                ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.massive),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _DevotionalAppBar extends StatelessWidget {
  const _DevotionalAppBar({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.navy.withValues(alpha: 0.08),
      titleSpacing: AppSpacing.lg,
      title: Text(
        'Devotional Journey',
        style: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        // Streak flame in app bar
        if (streak.currentStreak > 0)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 3),
                  Text(
                    '${streak.currentStreak}',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: AppColors.navy),
          tooltip: 'My Journal',
          onPressed: () => context.push('/home/devotionals/journal'),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

// ─── Date + Greeting ──────────────────────────────────────────────────────────

class _DateGreeting extends StatelessWidget {
  const _DateGreeting();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: AppTypography.scriptureRef.copyWith(
              color: AppColors.goldDark,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$greeting 🙏',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your daily devotional is ready.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.emphasized).slideY(
          begin: -0.05,
          end: 0,
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        );
  }
}

// ─── Streak Banner ────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${streak.currentStreak}-day streak',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      streak.currentStreak == 0
                          ? 'Start your streak today!'
                          : "Keep going — you're doing great!",
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${streak.totalCompletedDays}',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'total days',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Weekly dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final done = i < streak.weeklyCompletion.length &&
                    streak.weeklyCompletion[i];
                final isToday = DateTime.now().weekday - 1 == i;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.standard,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.goldDark
                            : isToday
                                ? AppColors.goldContainer
                                : AppColors.dividerLight,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: AppColors.goldDark, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14,)
                            : Text(
                                labels[i],
                                style: TextStyle(
                                  color: isToday
                                      ? AppColors.goldDark
                                      : AppColors.textDisabled,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms, duration: AppMotion.emphasized).slideY(
          begin: 0.05,
          end: 0,
          delay: 150.ms,
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        );
  }
}

// ─── Today's Hero Card ────────────────────────────────────────────────────────

class _TodayHeroCard extends StatelessWidget {
  const _TodayHeroCard({
    required this.devotional,
    required this.progress,
  });

  final Devotional devotional;
  final DevotionalProgress? progress;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? false;
    final fraction = progress?.progressFraction ?? 0.0;
    final estimatedMin = 8 + (devotional.body.length ~/ 800);

    return GestureDetector(
      onTap: () => _openJourney(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative orb
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: completed
                              ? AppColors.success
                              : AppColors.goldDark,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          completed ? '✓ COMPLETED' : "TODAY'S DEVOTIONAL",
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$estimatedMin min',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    devotional.title,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Scripture ref
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: AppRadius.brCircle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        devotional.scriptureRef,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Progress bar
                  if (!completed) ...[
                    Row(
                      children: [
                        Text(
                          'Progress',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(fraction * 5).round()}/5 steps',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // CTA Button
                  GestureDetector(
                    onTap: () => _openJourney(context),
                    child: Container(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldDark, AppColors.gold],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            completed
                                ? 'Review Journey'
                                : fraction > 0
                                    ? 'Continue Journey'
                                    : 'Begin Journey',
                            style:
                                AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            completed
                                ? Icons.replay_rounded
                                : Icons.arrow_forward_rounded,
                            color: AppColors.ink,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: AppMotion.emphasized)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          delay: 250.ms,
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        );
  }

  void _openJourney(BuildContext context) {
    context.push('/home/devotionals/${devotional.id}/scripture');
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Longest Streak',
            value: '${streak.longestStreak}d',
            icon: '🏆',
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatChip(
            label: 'This Week',
            value: '${streak.thisWeekCount}/7',
            icon: '📅',
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatChip(
            label: 'All Time',
            value: '${streak.totalCompletedDays}',
            icon: '⭐',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: AppMotion.standard);
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textDisabled,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Previous Devotional Tile ─────────────────────────────────────────────────

class _PreviousDevotionalTile extends StatelessWidget {
  const _PreviousDevotionalTile({
    required this.devotional,
    required this.index,
    required this.progress,
  });
  final Devotional devotional;
  final int index;
  final DevotionalProgress? progress;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? false;
    final fraction = progress?.progressFraction ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => context.push(
            '/home/devotionals/${devotional.id}/scripture',
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.dividerLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon / completion badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.successContainer
                        : AppColors.goldContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.auto_stories_rounded,
                      color: completed
                          ? AppColors.success
                          : AppColors.goldDark,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        devotional.title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        devotional.scriptureRef,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!completed && fraction > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 3,
                            backgroundColor:
                                AppColors.dividerLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 550 + index * 50),
          duration: AppMotion.standard,
        );
  }
}

// ─── Skeletons & Empty States ─────────────────────────────────────────────────

class _TodayCardSkeleton extends StatelessWidget {
  const _TodayCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.dividerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
          duration: const Duration(milliseconds: 800),
        );
  }
}

class _TodayCardError extends StatelessWidget {
  const _TodayCardError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.error, size: 32,),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Could not load today's devotional.",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDevotionalCard extends StatelessWidget {
  const _NoDevotionalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.goldContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📖', style: TextStyle(fontSize: 36)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No devotional scheduled for today.',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check back tomorrow or explore previous devotionals below.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PreviousListSkeleton extends StatelessWidget {
  const _PreviousListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviousListError extends ConsumerWidget {
  const _PreviousListError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.error, size: 32,),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Could not load previous devotionals.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => ref.invalidate(previousDevotionalsProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreviousList extends StatelessWidget {
  const _EmptyPreviousList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Text(
          'No previous devotionals yet.\nStart today and build your journey!',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textDisabled,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
