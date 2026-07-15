// Kingdom Heir — Devotional Series Detail Screen
//
// Shows header (cover, title, author, progress) + day list.
// Each day row: locked 🔒 / completed ✅ / available ▶
// Tapping an available/completed day navigates to DevotionalDayReaderScreen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_series_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionalSeriesDetailScreen extends ConsumerWidget {
  const DevotionalSeriesDetailScreen({required this.seriesId, super.key});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(devotionalSeriesByIdProvider(seriesId));
    final progressAsync = ref.watch(devotionalProgressProvider(seriesId));
    final entriesAsync = ref.watch(unlockedEntriesProvider(seriesId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: seriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
        data: (series) {
          final progress = progressAsync.valueOrNull;
          final entries = entriesAsync.valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              // ── App bar with cover ────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.navy,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    series.title,
                    style: const TextStyle(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  background: _SeriesHeader(series: series),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Author / description ──────────────────────
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (series.authorName != null)
                            Text(
                              'by ${series.authorName}',
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (series.description != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              series.description!,
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(height: 1.65),
                            ),
                          ],

                          // ── Progress overview ───────────────────
                          if (progress != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _ProgressOverview(
                              progress: progress,
                              totalDays: series.totalDays,
                            ),
                          ],

                          // ── Join CTA (not yet started) ──────────
                          if (progress == null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await ref
                                      .read(devotionalProgressProvider(
                                        seriesId,
                                      ).notifier,)
                                      .joinChallenge();
                                  result.fold(
                                    (err) =>
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(err)),
                                        ),
                                    (_) => ref.invalidate(
                                      unlockedEntriesProvider(seriesId),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.rocket_launch_rounded,
                                  size: 18,
                                ),
                                label: const Text('Start this Journey'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.navy,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],

                          // ── Amazon CTA ──────────────────────────
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => _launchAmazon(
                              context,
                              series.amazonPurchaseUrl,
                            ),
                            icon: const Icon(Icons.shopping_cart_outlined,
                                size: 16,),
                            label: const Text('Buy Physical Copy on Amazon'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 44),
                              foregroundColor:
                                  theme.colorScheme.onSurface,
                              side: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Section header ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        'YOUR JOURNEY',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Day list ──────────────────────────────────────────
              _DayList(
                seriesId: seriesId,
                totalDays: series.totalDays,
                entries: entries,
                progress: progressAsync.valueOrNull,
              ),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _launchAmazon(BuildContext context, String? url) async {
    const fallback =
        'https://www.amazon.com/s?k=james+maddalone&crid=33XGMCSH8QWPF&sprefix=james+maddalone+%2Caps%2C194&ref=nb_sb_noss';
    final uri = Uri.parse(url ?? fallback);
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Amazon.')),
      );
    }
  }
}

// ─── Series header ────────────────────────────────────────────────────────────

class _SeriesHeader extends StatelessWidget {
  const _SeriesHeader({required this.series});
  final DevotionalSeries series;

  @override
  Widget build(BuildContext context) {
    if (series.coverImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: series.coverImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => const ColoredBox(
          color: AppColors.navyMid,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
        errorWidget: (_, __, ___) => _GradientPlaceholder(series: series),
      );
    }
    return _GradientPlaceholder(series: series);
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.series});
  final DevotionalSeries series;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 52),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${series.totalDays} Days',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress overview ────────────────────────────────────────────────────────

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({
    required this.progress,
    required this.totalDays,
  });
  final DevotionalSeriesProgress progress;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
            label: '${progress.completedDays.length}',
            sub: 'Completed',
            color: AppColors.success,
          ),
          _StatChip(
            label: '$totalDays',
            sub: 'Total Days',
            color: AppColors.gold,
          ),
          _StatChip(
            label: '${progress.currentStreak}',
            sub: 'Streak 🔥',
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.sub,
    required this.color,
  });
  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          sub,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Day list ─────────────────────────────────────────────────────────────────

class _DayList extends StatelessWidget {
  const _DayList({
    required this.seriesId,
    required this.totalDays,
    required this.entries,
    required this.progress,
  });

  final String seriesId;
  final int totalDays;
  final List<DevotionalEntry> entries;
  final DevotionalSeriesProgress? progress;

  @override
  Widget build(BuildContext context) {
    // Build a lookup map for entries we have content for
    final entryByDay = <int, DevotionalEntry>{
      for (final e in entries) e.dayNumber: e,
    };

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final day = index + 1;
            final entry = entryByDay[day];
            final isCompleted = progress?.isDayCompleted(day) ?? false;
            final isUnlocked = progress?.isDayUnlocked(day) ?? false;
            final isAvailable = isUnlocked && !isCompleted;

            return _DayRow(
              day: day,
              title: entry?.title,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isAvailable: isAvailable,
              onTap: (isUnlocked || isCompleted)
                  ? () => context.push(
                        RouteNames.devotionalDayReader
                            .replaceFirst(':seriesId', seriesId)
                            .replaceFirst(':dayNumber', '$day'),
                      )
                  : null,
            );
          },
          childCount: totalDays,
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isAvailable,
    this.title,
    this.onTap,
  });

  final int day;
  final String? title;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color iconColor;
    IconData iconData;
    Color rowColor;

    if (isCompleted) {
      iconData  = Icons.check_circle_rounded;
      iconColor = AppColors.success;
      rowColor  = AppColors.success.withValues(alpha: 0.08);
    } else if (isAvailable) {
      iconData  = Icons.play_circle_rounded;
      iconColor = AppColors.gold;
      rowColor  = AppColors.gold.withValues(alpha: 0.08);
    } else {
      iconData  = Icons.lock_rounded;
      iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      rowColor  = Colors.transparent;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : isAvailable
                    ? AppColors.gold.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: Icon(iconData, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $day',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isUnlocked || isCompleted
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                    ),
                  ),
                  if (title != null)
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: isUnlocked ? 0.7 : 0.35),
                      ),
                    ),
                ],
              ),
            ),
            if (isAvailable)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.gold, size: 20,),
          ],
        ),
      ),
    );
  }
}
