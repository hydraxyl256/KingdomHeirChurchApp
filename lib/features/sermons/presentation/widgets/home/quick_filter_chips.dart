// Kingdom Heir — Quick Filter Chips (Sermon Home)
//
// Floating horizontal chip bar above the home feed. Tapping a chip
// updates the quick-filter state on `sermonLibraryFiltersProvider`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_library_filters_provider.dart';

class QuickFilterChips extends ConsumerWidget {
  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(sermonLibraryFiltersProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _Chip(
            label: 'All',
            active: !filters.audioOnly && !filters.videoOnly,
            onTap: () => _update(
              ref,
              filters.copyWith(
                audioOnly: false,
                videoOnly: false,
              ),
            ),
          ),
          _Chip(
            label: 'Audio-only',
            active: filters.audioOnly,
            onTap: () => _update(
              ref,
              filters.copyWith(
                audioOnly: !filters.audioOnly,
                videoOnly: false,
              ),
            ),
          ),
          _Chip(
            label: 'Video',
            active: filters.videoOnly,
            onTap: () => _update(
              ref,
              filters.copyWith(
                videoOnly: !filters.videoOnly,
                audioOnly: false,
              ),
            ),
          ),
          _Chip(
            label: 'This week',
            active: filters.dateRange == SermonDateRange.thisWeek,
            onTap: () {
              final isThis = filters.dateRange == SermonDateRange.thisWeek;
              _update(
                ref,
                filters.copyWith(
                  dateRange: isThis ? null : SermonDateRange.thisWeek,
                  clearDateRange: isThis,
                ),
              );
            },
          ),
          _Chip(
            label: 'Favorites',
            active: filters.favoritesOnly,
            onTap: () => _update(
              ref,
              filters.copyWith(
                favoritesOnly: !filters.favoritesOnly,
              ),
            ),
          ),
          _Chip(
            label: 'Downloads',
            active: filters.downloadsOnly,
            onTap: () => _update(
              ref,
              filters.copyWith(
                downloadsOnly: !filters.downloadsOnly,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _update(WidgetRef ref, SermonLibraryFilters next) {
    ref.read(sermonLibraryFiltersProvider.notifier).state = next;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.surfaceContainerLight,
        labelStyle: TextStyle(
          color: active ? AppColors.ink : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: BorderSide(
            color: active ? AppColors.gold : AppColors.dividerLight,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
