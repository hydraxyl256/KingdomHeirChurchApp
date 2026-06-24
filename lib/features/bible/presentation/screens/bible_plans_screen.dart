import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_reading_plans.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_engagement_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Reading plans catalogue. The "Continue Reading" hero at the top is
/// shown only when there's a plan in progress.
class BiblePlansScreen extends ConsumerWidget {
  const BiblePlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final palette = BibleReaderPalette.of(settings.theme);
    final progressList = ref.watch(planProgressProvider);

    // Find the active (not completed) plan with the highest index.
    BiblePlanProgress? activeProgress;
    for (final p in progressList) {
      if (p.completedAt != null) continue;
      if (activeProgress == null ||
          p.currentIndex > activeProgress.currentIndex) {
        activeProgress = p;
      }
    }
    final activePlan = activeProgress == null
        ? null
        : BibleReadingPlansCatalog.byId(activeProgress.planId);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                palette: palette,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            if (activePlan != null && activeProgress != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Builder(
                    builder: (context) {
                      final plan = activePlan;
                      final progress = activeProgress!;
                      final nextIndex = progress.currentIndex
                          .clamp(0, plan.chapters.length - 1);
                      return _ContinuePlanCard(
                        palette: palette,
                        plan: plan,
                        progress: progress,
                        onContinue: () => _openChapter(
                          context,
                          ref,
                          plan.chapters[nextIndex],
                        ),
                      ).animate().fadeIn(duration: AppMotion.emphasized).slideY(
                            begin: 0.1,
                            end: 0,
                            curve: AppMotion.decelerate,
                          );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'PLANS',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.accent,
                        letterSpacing: 2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: AppSpacing.sm,
                      height: 1,
                      color: palette.divider,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${BibleReadingPlansCatalog.all.length} available',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.foregroundMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: SliverList.separated(
                itemCount: BibleReadingPlansCatalog.all.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final plan = BibleReadingPlansCatalog.all[i];
                  final progress = ref
                      .watch(planProgressProvider)
                      .where((p) => p.planId == plan.id)
                      .firstOrNull;
                  return _PlanCard(
                    palette: palette,
                    plan: plan,
                    progress: progress,
                    onStart: () {
                      ref.read(planProgressProvider.notifier).start(plan.id);
                    },
                    onContinue: progress == null || progress.completedAt != null
                        ? null
                        : () => _openChapter(
                              context,
                              ref,
                              plan.chapters[progress.currentIndex.clamp(
                                0,
                                plan.chapters.length - 1,
                              )],
                            ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 80 * i),
                        duration: AppMotion.emphasized,
                      )
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        curve: AppMotion.decelerate,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChapter(BuildContext context, WidgetRef ref, String chapterId) {
    final parts = chapterId.split('.');
    if (parts.length != 2) return;
    final bookId = parts[0];
    final chapterNum = int.tryParse(parts[1]) ?? 1;
    ref.read(bibleNavigationProvider.notifier).update(
          (s) => BibleNavigationState(
            bookId: bookId,
            chapterId: '$bookId.$chapterNum',
          ),
        );
    context.go(RouteNames.bible);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.onBack});

  final BibleReaderPalette palette;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Material(
            color: palette.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: AppSpacing.iconLg + AppSpacing.sm,
                height: AppSpacing.iconLg + AppSpacing.sm,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: palette.foreground,
                  size: AppSpacing.iconSm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURATED',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.accent,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reading plans',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinuePlanCard extends StatelessWidget {
  const _ContinuePlanCard({
    required this.palette,
    required this.plan,
    required this.progress,
    required this.onContinue,
  });

  final BibleReaderPalette palette;
  final BibleReadingPlan plan;
  final BiblePlanProgress progress;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = _hex(plan.accentHex);
    final progressFraction =
        (progress.currentIndex / plan.chapters.length).clamp(0.0, 1.0);
    final currentChapter =
        plan.chapters[progress.currentIndex.clamp(0, plan.chapters.length - 1)];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onContinue,
        borderRadius: AppRadius.brXxl,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.brXxl,
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.2),
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.ink,
                        letterSpacing: 2,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    plan.coverEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                plan.title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Next: ${currentChapter.replaceAll('.', ' ').toUpperCase()}',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: AppRadius.brFull,
                child: LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 4,
                  backgroundColor: AppColors.ink.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Day ${progress.currentIndex + 1} of ${plan.chapters.length}',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.ink.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _hex(String s) {
    final clean = s.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.palette,
    required this.plan,
    required this.progress,
    required this.onStart,
    required this.onContinue,
  });

  final BibleReaderPalette palette;
  final BibleReadingPlan plan;
  final BiblePlanProgress? progress;
  final VoidCallback onStart;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = _hex(plan.accentHex);
    final started = progress != null;
    final completed = progress?.completedAt != null;
    final currentIndex = progress?.currentIndex ?? 0;
    final progressFraction =
        started ? (currentIndex / plan.chapters.length).clamp(0.0, 1.0) : 0.0;
    final ctaLabel = completed
        ? 'Completed'
        : started
            ? 'Continue'
            : 'Start plan';
    final onTap = completed
        ? null
        : started
            ? onContinue
            : onStart;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: started ? accent.withValues(alpha: 0.6) : palette.divider,
              width: started ? 1.5 : 1,
            ),
            boxShadow: AppElevation.shadowFor(AppElevation.level2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.avatarLg - 16,
                height: AppSpacing.avatarLg - 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: AppRadius.brMd,
                ),
                child: Text(
                  plan.coverEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.subtitle,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: palette.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      plan.description,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: palette.foregroundMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (started) ...[
                      ClipRRect(
                        borderRadius: AppRadius.brFull,
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 3,
                          backgroundColor: palette.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Day ${currentIndex + 1} of ${plan.chapters.length}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: palette.foregroundMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            '${plan.durationDays} days',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${plan.chapters.length} chapters',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: palette.foregroundMuted,
                          ),
                        ),
                        const Spacer(),
                        if (onTap != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: AppRadius.brFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ctaLabel,
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: AppColors.ink,
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.divider,
                              borderRadius: AppRadius.brFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: palette.foregroundMuted,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Completed',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: palette.foregroundMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
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
    );
  }

  static Color _hex(String s) {
    final clean = s.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
