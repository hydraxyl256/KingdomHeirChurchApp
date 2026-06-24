// Kingdom Heir — Members Strip (DETAIL SECTION 4)
//
// Horizontal row of member avatars + "View all N members" link.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class MembersStrip extends ConsumerWidget {
  const MembersStrip({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupMembersProvider(groupId));
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Members',
          subtitle: 'The people in this community',
          icon: Icons.groups_2_rounded,
          actionLabel: 'View all',
          onAction: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Member list coming soon')),
            );
          },
        ),
        async.when(
          loading: () => SizedBox(
            height: 56 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: Text('Error: $err'),
          ),
          data: (members) {
            if (members.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: Text(
                  'No members yet — be the first to join!',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final preview = members.take(8).toList();
            final overflow = members.length - preview.length;
            return SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                children: [
                  for (var i = 0; i < preview.length; i++)
                    Padding(
                      padding: EdgeInsets.only(right: insets.xs),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppAvatar(
                            name: preview[i].displayName,
                            imageUrl: preview[i].avatarUrl,
                            borderColor: AppColors.gold,
                            borderWidth: 1.2,
                            isOnline: i % 3 == 0,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Text(
                              preview[i].displayName.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (overflow > 0)
                    Padding(
                      padding: EdgeInsets.only(right: insets.xs),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+$overflow',
                              style:
                                  AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Text(
                              'more',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
