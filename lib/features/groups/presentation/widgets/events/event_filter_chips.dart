// Kingdom Heir — Event Filter Chips
//
// A horizontally scrollable row of choice chips that filter the events
// list by time window (Upcoming / Past / All). State is held by the
// parent — this is a presentational widget.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

enum EventFilter { upcoming, past, all }

extension on EventFilter {
  String get label => switch (this) {
        EventFilter.upcoming => 'Upcoming',
        EventFilter.past => 'Past',
        EventFilter.all => 'All',
      };
}

class EventFilterChips extends StatelessWidget {
  const EventFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final EventFilter selected;
  final ValueChanged<EventFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: insets.lg),
        itemCount: EventFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: insets.xs),
        itemBuilder: (_, i) {
          final f = EventFilter.values[i];
          final isSel = f == selected;
          return ChoiceChip(
            label: Text(f.label),
            selected: isSel,
            onSelected: (_) => onChanged(f),
            selectedColor: AppColors.gold,
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            side: BorderSide(
              color: isSel ? AppColors.gold : theme.colorScheme.outlineVariant,
            ),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.brFull),
            labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
              color: isSel ? AppColors.ink : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}
