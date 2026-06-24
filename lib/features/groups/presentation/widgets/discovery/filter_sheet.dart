// Kingdom Heir — Filter Sheet
//
// Modal bottom sheet that lets the user toggle every filter facet
// (life stage, meeting type, privacy). "Clear all" resets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_filters_provider.dart';

void showFilterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (_) => const _FilterSheetBody(),
  );
}

class _FilterSheetBody extends ConsumerWidget {
  const _FilterSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(groupFiltersProvider);
    final notifier = ref.read(groupFiltersProvider.notifier);
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          insets.lg,
          insets.md,
          insets.lg,
          insets.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            SizedBox(height: insets.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (filters.activeCount > 0)
                  TextButton(
                    onPressed: notifier.clear,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldDark,
                    ),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            SizedBox(height: insets.md),
            const _SectionTitle('Life stage'),
            SizedBox(height: insets.xs),
            Wrap(
              spacing: insets.xs,
              runSpacing: insets.xs,
              children: GroupLifeStage.values
                  .map(
                    (l) => _ToggleChip(
                      label: l.label,
                      selected: filters.lifeStages.contains(l),
                      onTap: () => notifier.toggleLifeStage(l),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: insets.md),
            const _SectionTitle('Meeting type'),
            SizedBox(height: insets.xs),
            Wrap(
              spacing: insets.xs,
              runSpacing: insets.xs,
              children: GroupMeetingType.values
                  .map(
                    (t) => _ToggleChip(
                      label: t.label,
                      selected: filters.meetingTypes.contains(t),
                      onTap: () => notifier.toggleMeetingType(t),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: insets.md),
            const _SectionTitle('Privacy'),
            SizedBox(height: insets.xs),
            Wrap(
              spacing: insets.xs,
              runSpacing: insets.xs,
              children: GroupPrivacy.values
                  .map(
                    (p) => _ToggleChip(
                      label: p.label,
                      selected: filters.privacies.contains(p),
                      onTap: () => notifier.togglePrivacy(p),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: insets.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                  padding: EdgeInsets.symmetric(vertical: insets.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: const Text(
                  'Show results',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: AppTypography.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.ink : AppColors.goldDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
