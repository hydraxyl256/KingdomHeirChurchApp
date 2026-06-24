// Kingdom Heir — Community Home Screen
//
// The new entry point for the Community tab. Eight sliver sections:
//
//   1. HomeHeroCard — greeting + counts
//   2. MyGroupsSection — pinned groups rail
//   3. RecentlyActiveSection — groups with fresh activity
//   4. UpcomingMeetingsSection — next events
//   5. PrayerRequestsSection — group prayer feed
//   6. AnnouncementsSection — pinned posts
//   7. SuggestedGroupsSection — discovery rail
//   8. QuickActionsRow — Discover / Create / Invite pills
//
// Everything loads in parallel via `communityHomeProvider`. Each
// section degrades gracefully (skeleton → error → empty → content).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/announcements_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/hero_card.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/my_groups_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/prayer_requests_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/quick_actions_row.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/recently_active_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/suggested_groups_section.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/home/upcoming_meetings_section.dart';

class CommunityHomeScreen extends ConsumerWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insets = Insets.of(context);
    final user = ref.watch(currentUserProvider);
    final asyncHome = ref.watch(communityHomeProvider);
    final allGroupsAsync = ref.watch(groupsListProvider);
    final totalGroups = allGroupsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () async {
          ref
            ..invalidate(communityHomeProvider)
            ..invalidate(groupsListProvider);
          await ref.read(communityHomeProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: insets.lg)),
            asyncHome.when(
              loading: () => const SliverToBoxAdapter(child: _HomeSkeleton()),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorWidget(
                  message: 'Couldn’t load your community',
                  onRetry: () => ref.invalidate(communityHomeProvider),
                ),
              ),
              data: (data) {
                final displayName = user?.displayName ?? 'Friend';
                final activeCount = data.myGroups.length;

                return SliverList(
                  delegate: SliverChildListDelegate([
                    HomeHeroCard(
                      displayName: displayName,
                      totalGroups: totalGroups,
                      activeGroups: activeCount,
                      prayerCount: data.prayerFeed.length,
                    ),
                    const MyGroupsSection(),
                    if (data.recentlyActive.isNotEmpty)
                      const RecentlyActiveSection(),
                    const UpcomingMeetingsSection(),
                    const PrayerRequestsSection(),
                    const AnnouncementsSection(),
                    const SuggestedGroupsSection(),
                    const QuickActionsRow(),
                    SizedBox(height: insets.huge),
                  ]),
                );
              },
            ),
            if (asyncHome.valueOrNull == null &&
                !asyncHome.isLoading &&
                !asyncHome.hasError)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Nothing here yet',
                  description: 'Pull down to refresh.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.of(context).lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          SizedBox(height: Insets.of(context).md),
          Container(
            height: 22,
            width: 200,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          SizedBox(height: Insets.of(context).sm),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
