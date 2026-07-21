// Kingdom Heir — Filter Chips Bar
//
// Horizontal scroll of active filter chips. "More filters" opens the
// full FilterSheet modal.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_filters_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/discovery/filter_sheet.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(groupFiltersProvider);
    final notifier = ref.read(groupFiltersProvider.notifier);
    final insets = Insets.of(context);

    final chips = <Widget>[
      ...filters.lifeStages.map(
        (l) => _ActiveChip(
          label: l.label,
          onClear: () => notifier.toggleLifeStage(l),
        ),
      ),
      ...filters.meetingTypes.map(
        (t) => _ActiveChip(
          label: t.label,
          onClear: () => notifier.toggleMeetingType(t),
        ),
      ),
      ...filters.privacies.map(
        (p) => _ActiveChip(
          label: p.label,
          onClear: () => notifier.togglePrivacy(p),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: insets.xs),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: insets.lg),
          itemCount: chips.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: insets.xs),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showFilterSheet(context),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filters.activeCount == 0
                              ? 'Filters'
                              : 'Filters (${filters.activeCount})',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return chips[i - 1];
          },
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onClear});
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.close_rounded,
                size: 12,
                color: AppColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
