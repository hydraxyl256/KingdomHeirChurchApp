// Kingdom Heir — Schedule Card (DETAIL SECTION 3)
//
// Next 3 events + "View all" link to events screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ScheduleCard extends ConsumerWidget {
  const ScheduleCard({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupEventsProvider(groupId));
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, 0),
      child: Container(
        padding: EdgeInsets.all(insets.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'SCHEDULE',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/home/groups/$groupId/events'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppLocalizations.of(context)!.viewAll),
                ),
              ],
            ),
            SizedBox(height: insets.sm),
            async.when(
              loading: () => Padding(
                padding: EdgeInsets.symmetric(vertical: insets.md),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (err, _) => Text('Error: $err'),
              data: (events) {
                if (events.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: insets.md),
                    child: Text(
                      'No meetings scheduled yet.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final upcoming = events
                    .where((e) => e.startsAt.isAfter(DateTime.now()))
                    .toList()
                  ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
                final next = upcoming.take(3).toList();
                if (next.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: insets.md),
                    child: Text(
                      'No upcoming meetings scheduled yet.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < next.length; i++) ...[
                      _ScheduleRow(event: next[i], groupId: groupId),
                      if (i < next.length - 1)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: insets.xs),
                          child: Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.event, required this.groupId});
  final GroupEvent event;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final dateStr = DateFormat('EEE MMM d').format(event.startsAt);
    final timeStr = DateFormat('h:mm a').format(event.startsAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/$groupId/events'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: insets.xs),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              SizedBox(width: insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateStr · $timeStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
