// Kingdom Heir — My Groups Section (SECTION 2)
//
// Horizontal rail of pinned groups. Each card: cover image, name,
// member count, last-activity dot, chevron. Width is band-derived.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/activity_dot.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/group_avatar.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class MyGroupsSection extends ConsumerWidget {
  const MyGroupsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMyGroups = ref.watch(myGroupsCarouselProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'My Communities',
          subtitle: 'Groups you’re part of right now',
          icon: Icons.groups_rounded,
          actionLabel: 'See all',
          onAction: () => context.push(RouteNames.groupDiscover),
        ),
        asyncMyGroups.when(
          loading: () => const _MyGroupsSkeleton(),
          error: (err, _) => AppErrorWidget(
            message: AppLocalizations.of(context)!.couldntLoadYourGroups,
            onRetry: () => ref.invalidate(myGroupsCarouselProvider),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Insets.of(context).lg,
                ),
                child: AppEmptyState(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Find your first community',
                  description:
                      'Browse groups to connect, grow, and serve alongside others.',
                  actionLabel: 'Discover groups',
                  onAction: () => context.push(RouteNames.groupDiscover),
                  isCompact: true,
                ),
              );
            }
            return _MyGroupsRail(groups: groups);
          },
        ),
      ],
    );
  }
}

class _MyGroupsRail extends StatelessWidget {
  const _MyGroupsRail({required this.groups});
  final List<CommunityGroup> groups;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = layoutBandFromWidth(constraints.maxWidth);
        final cardWidth = switch (band) {
          LayoutBand.xs => constraints.maxWidth * 0.74,
          LayoutBand.sm => constraints.maxWidth * 0.62,
          LayoutBand.md => constraints.maxWidth * 0.5,
          LayoutBand.lg => constraints.maxWidth * 0.4,
          LayoutBand.xl => constraints.maxWidth * 0.28,
          LayoutBand.xxl => constraints.maxWidth * 0.22,
        };
        return SizedBox(
          height: 168 + insets.md,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, 0),
            itemCount: groups.length,
            separatorBuilder: (_, __) => SizedBox(width: insets.sm),
            itemBuilder: (context, i) {
              final g = groups[i];
              return SizedBox(
                width: cardWidth,
                child: _MyGroupCard(group: g)
                    .animate()
                    .fadeIn(
                      duration: AppMotion.standard,
                      delay: Duration(milliseconds: i * 60),
                    )
                    .slideY(begin: 0.06, end: 0, duration: AppMotion.standard),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyGroupCard extends StatelessWidget {
  const _MyGroupCard({required this.group});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final hasActivity = group.lastMessageAt != null &&
        DateTime.now().difference(group.lastMessageAt!).inDays < 2;

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
                color: AppColors.navy.withValues(alpha: 0.04),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: insets.xxxs),
                        Row(
                          children: [
                            if (hasActivity) ...[
                              const ActivityDot(size: 6),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                hasActivity
                                    ? 'Active now'
                                    : '${group.weeklyActiveMembers} active this week',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textTheme.labelSmall
                                    ?.copyWith(
                                  color: hasActivity
                                      ? AppColors.success
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
              SizedBox(height: insets.sm),
              if (group.lastMessagePreview != null)
                Text(
                  group.lastMessagePreview!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MyGroupsSkeleton extends StatelessWidget {
  const _MyGroupsSkeleton();

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return SizedBox(
      height: 168 + insets.md,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, 0),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: insets.sm),
        itemBuilder: (_, __) => Container(
          width: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}
