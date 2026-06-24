// Kingdom Heir — Sermon Series Screen
//
// Series detail page. Sliver app bar cover, progress bar, description,
// related resources, and the episode list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/series/series_cover.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/series/series_episode_tile.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/series/series_progress_bar.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/series/series_related_resources.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermons_empty_state.dart';

class SermonSeriesScreen extends ConsumerWidget {
  const SermonSeriesScreen({
    required this.sermonId,
    required this.seriesId,
    super.key,
  });

  final String sermonId;
  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(sermonSeriesListProvider(seriesId));
    final episodesAsync = ref.watch(sermonSeriesEpisodesProvider(seriesId));
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: seriesAsync.when(
        data: (seriesList) {
          if (seriesList.isEmpty) {
            return const _MissingSeries();
          }
          final series = seriesList.first;
          return episodesAsync.when(
            data: (episodes) {
              return CustomScrollView(
                slivers: [
                  SeriesCover(series: series),
                  SliverToBoxAdapter(child: SeriesProgressBar(series: series)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Text(
                        series.description,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (series.upcomingDate != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Next message: ${DateFormat.yMMMMd().format(series.upcomingDate!)}',
                                  style: AppTypography.textTheme.titleSmall
                                      ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SeriesRelatedResources(
                    resources: [],
                  ),
                  if (episodes.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: SermonsEmptyState(
                        icon: Icons.collections_bookmark_outlined,
                        title: 'No episodes yet',
                        description:
                            'New messages in this series are on the way.',
                        isCompact: true,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = episodes[i];
                          return SeriesEpisodeTile(
                            episodeNumber: i + 1,
                            sermon: s,
                            isWatched: i < series.completedCount,
                          );
                        },
                        childCount: episodes.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(sermonSeriesEpisodesProvider(seriesId)),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(sermonSeriesListProvider(seriesId)),
        ),
      ),
    );
  }
}

class _MissingSeries extends StatelessWidget {
  const _MissingSeries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
      ),
      body: const SermonsEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Series not found',
        description:
            'This series may have been removed or is no longer available.',
      ),
    );
  }
}
