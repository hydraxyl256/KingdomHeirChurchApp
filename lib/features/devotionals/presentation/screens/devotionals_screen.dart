import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class DevotionalsScreen extends ConsumerWidget {
  const DevotionalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyDevotionalProvider);
    final streak = ref.watch(devotionalStreakProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator.adaptive(
        color: AppColors.goldDark,
        onRefresh: () async => ref.invalidate(dailyDevotionalProvider),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
          slivers: [
            _DevotionalAppBar(streak: streak),
            const SliverToBoxAdapter(child: _DateGreeting()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: dailyAsync.when(
                  loading: () => const _TodayCardSkeleton(),
                  error: (_, __) => const _TodayCardError(),
                  data: (devotional) {
                    if (devotional == null) return const _NoDevotionalCard();
                    final progress =
                        ref.watch(journeyProgressProvider(devotional.id));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TodayHeroCard(
                          devotional: devotional,
                          progress: progress,
                          streak: streak,
                        ),
                        if (progress?.completed ?? false) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const _ReflectionCard(),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
            SliverToBoxAdapter(
              child: _JourneyProgressTimeline(streak: streak),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: _StreakStatsCard(streak: streak),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.xl + AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Previous Devotionals',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.filter_list_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ),
            ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      titleSpacing: AppSpacing.lg,
      title: Text(
        'Devotional Journey',
        style: AppTypography.textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        if (streak.currentStreak > 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
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
                  const Icon(
                    Icons.local_fire_department_outlined,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
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
          icon: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.onSurface),
          tooltip: AppLocalizations.of(context)!.myJournal,
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
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr.toUpperCase(),
            style: AppTypography.scriptureRef.copyWith(
              color: AppColors.goldDark,
              letterSpacing: 1.5,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                greeting,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.wb_sunny_outlined,
                color: AppColors.goldDark,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your daily devotional is ready. Take a deep breath and begin.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
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

// ─── Today's Hero Card ────────────────────────────────────────────────────────

class _TodayHeroCard extends StatelessWidget {
  const _TodayHeroCard({
    required this.devotional,
    required this.progress,
    required this.streak,
  });

  final Devotional devotional;
  final DevotionalProgress? progress;
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? false;
    final fraction = progress?.progressFraction ?? 0.0;
    final estimatedMin = 8 + (devotional.body.length ~/ 800);
    // User requested "Day X of 90" calculated based on total completed days.
    // If today is NOT completed, the current day they are on is totalCompleted + 1.
    final currentDay =
        completed ? streak.totalCompletedDays : streak.totalCompletedDays + 1;

    return Semantics(
      button: true,
      label: "Today's Devotional",
      child: GestureDetector(
        onTap: () => _openJourney(context),
        child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Soft subtle gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Decorative subtle shape
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: completed
                              ? AppColors.success.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          completed ? 'COMPLETED' : 'DAY $currentDay OF 90',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: completed
                                ? AppColors.successContainer
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$estimatedMin min',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    devotional.title,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        devotional.scriptureRef,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl + AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openJourney(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(48, 48),
              backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                          child: Text(
                            completed
                                ? 'Review Journey'
                                : fraction > 0
                                    ? 'Continue Reading'
                                    : 'Begin Journey',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      if (!completed)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: fraction,
                                strokeWidth: 3.5,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(fraction * 100).toInt()}%',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (completed)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: AppMotion.emphasized).scale(
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

// ─── Reflection Card ──────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a moment to reflect',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Capture your thoughts for today.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push('/home/devotionals/journal'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: const BorderSide(color: AppColors.dividerDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            child: const Text('Write'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.standard).slideY(
          begin: 0.1,
          end: 0,
          curve: AppMotion.decelerate,
        );
  }
}

// ─── Journey Progress Timeline ────────────────────────────────────────────────

class _JourneyProgressTimeline extends StatelessWidget {
  const _JourneyProgressTimeline({required this.streak});

  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    // Generate a beautiful timeline of days
    final totalDays = streak.totalCompletedDays;
    final currentDayIndex = totalDays; // 0-indexed day they are on next

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Your Journey',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '90 Days',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: 90,
            itemBuilder: (context, index) {
              final isCompleted = index < currentDayIndex;
              final isCurrent = index == currentDayIndex;

              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.successContainer
                              : isCurrent
                                  ? AppColors.goldContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: isCurrent
                              ? Border.all(color: AppColors.gold, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.success,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTypography.textTheme.labelMedium
                                      ?.copyWith(
                                    color: isCurrent
                                        ? AppColors.goldDark
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Day ${index + 1}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: isCurrent || isCompleted
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (index < 89)
                    Container(
                      width: 24,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20), // align with circle
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms, duration: AppMotion.standard);
  }
}

// ─── Streak & Stats Card ──────────────────────────────────────────────────────

class _StreakStatsCard extends StatelessWidget {
  const _StreakStatsCard({required this.streak});

  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                label: 'Current Streak',
                value: '${streak.currentStreak}',
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFFD97706),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _StatItem(
                label: 'Longest Streak',
                value: '${streak.longestStreak}',
                icon: Icons.emoji_events_outlined,
                iconColor: AppColors.goldDark,
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _StatItem(
                label: 'Total Days',
                value: '${streak.totalCompletedDays}',
                icon: Icons.star_outline_rounded,
                iconColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${streak.thisWeekCount}/7 Completed',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final done = i < streak.weeklyCompletion.length &&
                  streak.weeklyCompletion[i];
              final isToday = DateTime.now().weekday - 1 == i;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.goldDark
                          : isToday
                              ? AppColors.goldContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isToday && !done
                          ? Border.all(color: AppColors.goldDark, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              labels[i],
                              style: TextStyle(
                                color: isToday
                                    ? AppColors.goldDark
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                                fontSize: 11,
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
    ).animate().fadeIn(delay: 450.ms, duration: AppMotion.standard);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        child: Semantics(
          button: true,
          label: devotional.title,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => context.push(
            '/home/devotionals/${devotional.id}/scripture',
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.successContainer
                        : AppColors.goldContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      completed
                          ? Icons.check_rounded
                          : Icons.auto_stories_outlined,
                      color: completed ? AppColors.success : AppColors.goldDark,
                      size: 20,
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
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        devotional.scriptureRef,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
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
                Icon(Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ],
            ),
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
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 8),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Couldn't Load Devotional",
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please check your connection and try again.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text('Support'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  side: const BorderSide(color: AppColors.dividerDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 40,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'All Caught Up',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'There is no new devotional scheduled for today. Explore previous devotionals below.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: AppColors.goldDark,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            child: const Text('Browse Library'),
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Could not load previous devotionals.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(previousDevotionalsProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.tryAgain_1),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: const BorderSide(color: AppColors.dividerDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
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
        child: Column(
          children: [
            Icon(Icons.auto_awesome_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No previous devotionals yet.\nStart today and build your journey!',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
