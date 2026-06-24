// Kingdom Heir — Topic Chips Bar (Sermon Library)
//
// Horizontal scrolling row of topic chips. The active chip is filled gold;
// others are outlined. Tapping a chip toggles the topic filter in
// SermonLibraryFilters.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_library_filters_provider.dart';

class TopicChipsBar extends ConsumerWidget {
  const TopicChipsBar({
    required this.topics,
    super.key,
  });

  final List<String> topics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(sermonLibraryFiltersProvider).topic;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final topic = topics[i];
          final isActive = active == topic;
          return _Chip(
            label: topic,
            isActive: isActive,
            onTap: () {
              final current = ref.read(sermonLibraryFiltersProvider);
              ref.read(sermonLibraryFiltersProvider.notifier).state =
                  current.copyWith(
                topic: isActive ? null : topic,
                clearTopic: isActive,
              );
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.gold : AppColors.dividerLight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: isActive
                  ? AppColors.ink
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
