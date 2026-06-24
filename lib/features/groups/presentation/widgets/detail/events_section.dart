// Kingdom Heir — Detail Events Section (DETAIL SECTION 7)
//
// Top 2 events with "See all" CTA.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class EventsSection extends ConsumerWidget {
  const EventsSection({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupEventsProvider(groupId));
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Events',
          subtitle: 'What’s coming up',
          icon: Icons.event_rounded,
          actionLabel: 'See all',
          onAction: () => context.push('/home/groups/$groupId/events'),
        ),
        async.when(
          loading: () => SizedBox(
            height: 80 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: Text('Error: $err'),
          ),
          data: (events) {
            if (events.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No events scheduled',
                  description:
                      'Leaders can schedule meetings, retreats, and socials here.',
                  isCompact: true,
                ),
              );
            }
            final next = events.take(2).toList();
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < next.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == next.length - 1 ? 0 : insets.sm,
                      ),
                      child: _EventRow(event: next[i]),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final day = DateFormat('d').format(event.startsAt);
    final month = DateFormat('MMM').format(event.startsAt).toUpperCase();

    final meetingIcon = switch (event.meetingType) {
      GroupMeetingType.online => Icons.videocam_outlined,
      GroupMeetingType.physical => Icons.location_on_outlined,
      GroupMeetingType.hybrid => Icons.public_rounded,
    };

    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: EdgeInsets.symmetric(vertical: insets.xs),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldDark, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  month,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  day,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
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
                Row(
                  children: [
                    Icon(
                      meetingIcon,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.rsvpCount} going',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
