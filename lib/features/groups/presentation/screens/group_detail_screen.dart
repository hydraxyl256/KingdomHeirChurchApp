// Kingdom Heir — Group Detail Screen
//
// The Detail screen for a single community. Sections:
//
//   1. GroupCover — full-width hero image + title + meta pills
//   2. LeaderCard — leader bio + languages + prayer count
//   3. ScheduleCard — next 3 meetings
//   4. MembersStrip — preview avatars
//   5. PrayerWallSection — top 2 prayer requests
//   6. EventsSection — top 2 events
//   7. AnnouncementsDetailSection — pinned + latest
//   8. DiscussionFeed — top 5 posts
//   9. GroupActionBar — sticky footer (Join / Chat / Leader / Share)
//
// All data loads in parallel via `groupSectionsProvider`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/announcements_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/discussion_feed.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/events_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/group_action_bar.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/group_cover.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/leader_card.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/members_strip.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/prayer_wall_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/detail/schedule_card.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(groupSectionsProvider(groupId));
    final insets = Insets.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: sections.detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: AppLocalizations.of(context)!.couldntLoadThisGroup,
          onRetry: () => ref.invalidate(groupSectionsProvider(groupId)),
        ),
        data: (detail) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                title: Text(
                  detail.group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  GroupCover(group: detail.group),
                  if (detail.mission.statement.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        insets.lg,
                        insets.md,
                        insets.lg,
                        0,
                      ),
                      child: Text(
                        detail.mission.statement,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.45),
                      ),
                    ),
                  if (detail.mission.scripture != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        insets.lg,
                        insets.xs,
                        insets.lg,
                        0,
                      ),
                      child: Text(
                        '📖 ${detail.mission.scripture}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ),
                  LeaderCard(leader: detail.leader, group: detail.group),
                  ScheduleCard(groupId: groupId),
                  MembersStrip(groupId: groupId),
                  PrayerWallSection(groupId: groupId),
                  EventsSection(groupId: groupId),
                  AnnouncementsDetailSection(groupId: groupId),
                  DiscussionFeed(groupId: groupId),
                  SizedBox(height: insets.lg),
                ]),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: sections.detail.maybeWhen(
        data: (detail) => GroupActionBar(group: detail.group),
        orElse: () => null,
      ),
    );
  }
}
