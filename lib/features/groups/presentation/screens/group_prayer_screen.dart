// Kingdom Heir — Group Prayer Screen
//
// Full prayer wall for one group. Layout:
//
//   • AppBar
//   • Sticky PrayerComposerCard
//   • Category filter chips
//   • SliverList of PrayerCards
//   • Empty state

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/prayer/prayer_card.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/prayer/prayer_composer_card.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GroupPrayerScreen extends ConsumerStatefulWidget {
  const GroupPrayerScreen({required this.groupId, super.key});
  final String groupId;

  @override
  ConsumerState<GroupPrayerScreen> createState() => _GroupPrayerScreenState();
}

class _GroupPrayerScreenState extends ConsumerState<GroupPrayerScreen> {
  PrayerCategory? _category; // null = all

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(groupPrayerProvider(widget.groupId));
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.prayerWall),
      ),
      body: Column(
        children: [
          PrayerComposerCard(groupId: widget.groupId),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: insets.lg),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                SizedBox(width: insets.xs),
                for (final cat in PrayerCategory.values) ...[
                  _FilterChip(
                    label: cat.label,
                    selected: _category == cat,
                    onTap: () => setState(() => _category = cat),
                  ),
                  SizedBox(width: insets.xs),
                ],
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => AppErrorWidget(
                message: AppLocalizations.of(context)!.couldntLoadPrayers,
                onRetry: () =>
                    ref.invalidate(groupPrayerProvider(widget.groupId)),
              ),
              data: (list) {
                final filtered = _category == null
                    ? list
                    : list.where((p) => p.category == _category).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.spa_rounded,
                    title: _category == null
                        ? 'No prayer requests yet'
                        : 'No ${_category!.label.toLowerCase()} prayers',
                    description: _category == null
                        ? 'Be the first to share what’s on your heart — your brothers and sisters will stand with you.'
                        : 'Try another category, or share the first request in this area.',
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    insets.md,
                    insets.lg,
                    insets.xxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: insets.sm),
                  itemBuilder: (_, i) {
                    return PrayerCard(
                      request: filtered[i],
                      groupId: widget.groupId,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 50 * i),
                          duration: 300.ms,
                        )
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.gold,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: selected ? AppColors.gold : theme.colorScheme.outlineVariant,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brFull),
      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: selected ? AppColors.ink : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
