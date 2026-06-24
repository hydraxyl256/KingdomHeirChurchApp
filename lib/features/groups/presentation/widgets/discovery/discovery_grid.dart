// Kingdom Heir — Discovery Grid
//
// The grid of community cards on the Discovery screen. Band-aware
// column count: 1 on xs, 2 on sm/md, 3 on lg+.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_filters_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/group_avatar.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/join_button.dart';

class DiscoveryGrid extends ConsumerWidget {
  const DiscoveryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filteredDiscoverableGroupsProvider);
    final insets = Insets.of(context);

    return async.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: insets.lg),
          child: Text('Error: $err'),
        ),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: insets.lg),
              child: Container(
                padding: EdgeInsets.all(insets.xl),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.gold.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: insets.sm),
                    Text(
                      'No matches',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: insets.xxs),
                    Text(
                      'Try clearing a filter or two.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding:
              EdgeInsets.fromLTRB(insets.lg, insets.xs, insets.lg, insets.huge),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final band = layoutBandFromWidth(constraints.crossAxisExtent);
              final columns = switch (band) {
                LayoutBand.xs => 1,
                LayoutBand.sm => 2,
                LayoutBand.md => 2,
                LayoutBand.lg => 3,
                LayoutBand.xl => 3,
                LayoutBand.xxl => 3,
              };
              final spacing = insets.sm;
              final tileWidth = columns == 1
                  ? constraints.crossAxisExtent
                  : (constraints.crossAxisExtent - spacing * (columns - 1)) /
                      columns;

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => SizedBox(
                    width: tileWidth,
                    child: _DiscoveryCard(group: groups[i])
                        .animate()
                        .fadeIn(
                          duration: AppMotion.standard,
                          delay: Duration(milliseconds: 50 * i),
                        )
                        .slideY(begin: 0.05, end: 0),
                  ),
                  childCount: groups.length,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DiscoveryCard extends ConsumerWidget {
  const _DiscoveryCard({required this.group});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);

    final meetingIcon = switch (group.meetingType) {
      GroupMeetingType.online => Icons.videocam_outlined,
      GroupMeetingType.physical => Icons.location_on_outlined,
      GroupMeetingType.hybrid => Icons.public_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${group.id}'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: EdgeInsets.all(insets.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GroupAvatar(
                    name: group.name,
                    imageUrl: group.coverUrl,
                    size: 44,
                    categoryBadge: group.categoryName,
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          group.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.memberCount} members',
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
                ],
              ),
              SizedBox(height: insets.sm),
              Expanded(
                child: Text(
                  group.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: insets.xs),
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
                      '${group.meetingType.label} · ${group.lifeStage.label}',
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
              SizedBox(height: insets.xs),
              JoinButton(
                state: joinButtonStateFromGroup(group),
                onPressed: () => _onJoin(context, ref, group),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onJoin(BuildContext context, WidgetRef ref, CommunityGroup group) {
    final messenger = ScaffoldMessenger.of(context);
    ref.read(groupsListProvider.notifier).joinGroup(
          group.id,
          isPrivate: group.privacy == GroupPrivacy.private,
        );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          group.privacy == GroupPrivacy.private
              ? 'Request sent to the leader'
              : 'Joined ${group.name}!',
        ),
      ),
    );
  }
}
