// Kingdom Heir — Library Sort Tabs
//
// Tab-style segmented control for choosing the sort order of the
// library grid (Trending / Most viewed / Recently added / All).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

enum SermonLibrarySort {
  trending,
  mostViewed,
  recentlyAdded,
  all,
}

extension SermonLibrarySortX on SermonLibrarySort {
  String get label => switch (this) {
        SermonLibrarySort.trending => 'Trending',
        SermonLibrarySort.mostViewed => 'Most viewed',
        SermonLibrarySort.recentlyAdded => 'Recently added',
        SermonLibrarySort.all => 'All',
      };
}

final sermonLibrarySortProvider =
    StateProvider<SermonLibrarySort>((ref) => SermonLibrarySort.trending);

class LibrarySortTabs extends ConsumerWidget {
  const LibrarySortTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sermonLibrarySortProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: SermonLibrarySort.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final sort = SermonLibrarySort.values[i];
          final isActive = sort == selected;
          return InkWell(
            onTap: () =>
                ref.read(sermonLibrarySortProvider.notifier).state = sort,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.gold : AppColors.dividerLight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                sort.label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: isActive
                      ? AppColors.gold
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
