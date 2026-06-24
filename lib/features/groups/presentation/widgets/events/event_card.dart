// Kingdom Heir — Event Card
//
// A full card for the events screen list. Cover image (or meeting-type
// iconographic fallback), date chip, title, location, RSVP count, and
// a "Going" toggle. Band-aware padding.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.isGoing,
    required this.onToggleRsvp,
    super.key,
  });

  final GroupEvent event;
  final bool isGoing;
  final VoidCallback onToggleRsvp;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    final day = DateFormat('d').format(event.startsAt);
    final month = DateFormat('MMM').format(event.startsAt).toUpperCase();
    final time = DateFormat('EEE • HH:mm').format(event.startsAt);

    final meetingIcon = switch (event.meetingType) {
      GroupMeetingType.online => Icons.videocam_outlined,
      GroupMeetingType.physical => Icons.location_on_outlined,
      GroupMeetingType.hybrid => Icons.public_rounded,
    };
    final meetingLabel = event.meetingType.label;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.coverUrl != null && event.coverUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _EventCoverFallback(
                    meetingType: event.meetingType,
                  ),
                ),
              ),
            )
          else
            _EventCoverFallback(meetingType: event.meetingType),
          Padding(
            padding: EdgeInsets.all(insets.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  padding: EdgeInsets.symmetric(vertical: insets.xs),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.brMd,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
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
                            meetingIcon,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$meetingLabel • ${event.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
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
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              insets.md,
              0,
              insets.md,
              insets.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(width: insets.sm),
                FilledButton.tonalIcon(
                  onPressed: onToggleRsvp,
                  icon: Icon(
                    isGoing
                        ? Icons.check_circle_rounded
                        : Icons.event_available_rounded,
                    size: 16,
                    color: isGoing ? AppColors.goldDark : null,
                  ),
                  label: Text(isGoing ? 'Going' : 'RSVP'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isGoing
                        ? AppColors.goldContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: isGoing
                        ? AppColors.goldDark
                        : theme.colorScheme.onSurface,
                    padding: EdgeInsets.symmetric(
                      horizontal: insets.md,
                      vertical: 6,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brFull,
                    ),
                    textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCoverFallback extends StatelessWidget {
  const _EventCoverFallback({required this.meetingType});
  final GroupMeetingType meetingType;

  @override
  Widget build(BuildContext context) {
    final icon = switch (meetingType) {
      GroupMeetingType.online => Icons.videocam_rounded,
      GroupMeetingType.physical => Icons.church_rounded,
      GroupMeetingType.hybrid => Icons.public_rounded,
    };
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon,
                size: 110, color: AppColors.gold.withValues(alpha: 0.15),),
          ),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                borderRadius: AppRadius.brFull,
              ),
              child: Text(
                meetingType.label.toUpperCase(),
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
