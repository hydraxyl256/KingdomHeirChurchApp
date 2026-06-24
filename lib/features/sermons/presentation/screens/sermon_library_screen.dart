// Kingdom Heir — Sermon Library Screen
//
// CustomScrollView of slivers composing the topic chips bar, sort tabs,
// filter FAB, and the responsive library grid. Empty + error states
// are surfaced for the filtered list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_library_filters_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/library/library_filter_sheet.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/library/library_grid.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/library/library_sort_tabs.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/library/topic_chips_bar.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermons_empty_state.dart';

class SermonLibraryScreen extends ConsumerWidget {
  const SermonLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(availableTopicsProvider);
    final asyncSermons = ref.watch(filteredLibrarySermonsProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showLibraryFilterSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: asyncSermons.when(
        data: (sermons) {
          if (sermons.isEmpty) {
            return SermonsEmptyState(
              icon: Icons.filter_alt_off_rounded,
              title: 'No sermons match these filters',
              description:
                  'Try clearing some filters or pick a different topic.',
              actionLabel: 'Clear filters',
              onAction: () => ref
                  .read(sermonLibraryFiltersProvider.notifier)
                  .state = SermonLibraryFilters.empty,
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: TopicChipsBar(topics: topics)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: LibrarySortTabs(),
                ),
              ),
              LibraryGrid(sermons: sermons),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(filteredLibrarySermonsProvider),
        ),
      ),
      floatingActionButton: asyncSermons.value == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showLibraryFilterSheet(context),
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              icon: const Icon(Icons.tune_rounded),
              label: Text(
                ref.watch(sermonLibraryFiltersProvider).activeCount > 0
                    ? 'Filters (${ref.watch(sermonLibraryFiltersProvider).activeCount})'
                    : 'Filters',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}
