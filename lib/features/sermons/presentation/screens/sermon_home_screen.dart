// Kingdom Heir — Sermon Home Screen
//
// The Sermon Home tab. CustomScrollView of slivers that compose the
// sections defined in the Sermon Platform redesign plan: featured
// hero, live banner, continue watching, latest, popular, series
// collections, recommended, downloads shortcut.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_downloads_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/continue_watching_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/downloads_shortcut.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/featured_hero.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/latest_sermons_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/live_service_banner.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/popular_sermons_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/quick_filter_chips.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/recommended_for_you_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/home/series_collections_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermons_empty_state.dart';

class SermonHomeScreen extends ConsumerWidget {
  const SermonHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(sermonHomeDataProvider);
    final downloads = ref.watch(downloadsShortcutProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sermonHomeDataProvider);
        },
        color: AppColors.gold,
        child: homeDataAsync.when(
          data: (data) => _SermonHomeBody(
            data: data,
            downloads: downloads,
          ),
          loading: () => const _SermonHomeSkeleton(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(sermonHomeDataProvider),
          ),
        ),
      ),
    );
  }
}

class _SermonHomeBody extends StatelessWidget {
  const _SermonHomeBody({required this.data, required this.downloads});
  final SermonHomeData data;
  final List<SermonDownload> downloads;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            'Media',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
          ],
        ),
        const SliverToBoxAdapter(child: QuickFilterChips()),
        if (data.liveStream != null) ...[
          SliverToBoxAdapter(
            child: LiveServiceBanner(
              sermon: data.liveStream!,
              onWatch: () => context.push(
                '/home/sermons/${data.liveStream!.id}/player',
              ),
            ),
          ),
        ],
        if (data.featured != null)
          SliverToBoxAdapter(
            child: FeaturedHero(
              sermon: data.featured!,
              height: 280,
              onWatch: () => context.push(
                '/home/sermons/${data.featured!.id}/player',
              ),
            ),
          ),
        if (data.continueWatching.isNotEmpty)
          SliverToBoxAdapter(
            child: ContinueWatchingRow(items: data.continueWatching),
          ),
        if (data.latest.isNotEmpty)
          SliverToBoxAdapter(
            child: LatestSermonsRow(sermons: data.latest),
          ),
        if (data.series.isNotEmpty)
          SliverToBoxAdapter(
            child: SeriesCollectionsRow(series: data.series),
          ),
        if (data.popular.isNotEmpty)
          SliverToBoxAdapter(
            child: PopularSermonsRow(sermons: data.popular),
          ),
        if (data.recommended.isNotEmpty)
          SliverToBoxAdapter(
            child: RecommendedForYouRow(sermons: data.recommended),
          ),
        if (downloads.isNotEmpty)
          SliverToBoxAdapter(
            child: DownloadsShortcut(downloads: downloads),
          ),
        if (data.featured == null &&
            data.continueWatching.isEmpty &&
            data.latest.isEmpty &&
            data.series.isEmpty &&
            data.popular.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SermonsEmptyState(
              title: 'No sermons yet',
              description:
                  'Check back soon — new messages are added every week.',
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SermonHomeSkeleton extends StatelessWidget {
  const _SermonHomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _skeletonBox(height: 280),
          const SizedBox(height: AppSpacing.lg),
          _skeletonBox(height: 200, margin: AppSpacing.lg),
          const SizedBox(height: AppSpacing.md),
          _skeletonBox(height: 280, margin: AppSpacing.lg),
          const SizedBox(height: AppSpacing.md),
          _skeletonBox(height: 180, margin: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height, double margin = 0}) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
    );
  }
}
