// Kingdom Heir — Upcoming Meetings Section (SECTION 4)
//
// Horizontal rail of upcoming events (next 14 days) across the user's
// groups. Each card: date chip + title + time + RSVP count.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_event_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class UpcomingMeetingsSection extends ConsumerWidget {
  const UpcomingMeetingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingMeetingsProvider);
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Upcoming meetings',
          subtitle: 'The next gatherings on your calendar',
          icon: Icons.event_rounded,
        ),
        async.when(
          loading: () => SizedBox(
            height: 140 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: AppErrorWidget(
              message: 'Couldn’t load meetings',
              onRetry: () => ref.invalidate(upcomingMeetingsProvider),
            ),
          ),
          data: (events) {
            if (events.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No meetings on the horizon',
                  description:
                      'When your groups schedule events, they’ll appear here.',
                  isCompact: true,
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final band = layoutBandFromWidth(constraints.maxWidth);
                final cardWidth = switch (band) {
                  LayoutBand.xs => constraints.maxWidth * 0.78,
                  LayoutBand.sm => constraints.maxWidth * 0.6,
                  LayoutBand.md => constraints.maxWidth * 0.45,
                  LayoutBand.lg => constraints.maxWidth * 0.32,
                  LayoutBand.xl => constraints.maxWidth * 0.24,
                  LayoutBand.xxl => constraints.maxWidth * 0.2,
                };
                return SizedBox(
                  height: 168 + insets.md,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => SizedBox(width: insets.sm),
                    itemBuilder: (context, i) => SizedBox(
                      width: cardWidth,
                      child: _MeetingCard(event: events[i])
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                          )
                          .slideY(begin: 0.06, end: 0),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.event});
  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final day = DateFormat('d').format(event.startsAt);
    final month = DateFormat('MMM').format(event.startsAt).toUpperCase();
    final time = DateFormat('h:mm a').format(event.startsAt);

    final meetingIcon = switch (event.meetingType) {
      GroupMeetingType.online => Icons.videocam_outlined,
      GroupMeetingType.physical => Icons.location_on_outlined,
      GroupMeetingType.hybrid => Icons.public_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${event.groupId}/events'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: EdgeInsets.all(insets.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                        letterSpacing: 0.6,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: insets.xxs),
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
                            time,
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
        ),
      ),
    );
  }
}
