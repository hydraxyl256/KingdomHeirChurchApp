// Kingdom Heir — Group Action Bar (DETAIL SECTION 5)
//
// Sticky footer with Join/Leave/Chat CTA + share icon.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class GroupActionBar extends ConsumerWidget {
  const GroupActionBar({required this.group, super.key});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insets = Insets.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, insets.lg),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: Material(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: InkWell(
                  onTap: group.isMember
                      ? () => context.push('/home/groups/${group.id}/chat')
                      : () {
                          ref.read(groupsListProvider.notifier).joinGroup(
                                group.id,
                                isPrivate:
                                    group.privacy == GroupPrivacy.private,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                group.privacy == GroupPrivacy.private
                                    ? 'Request sent!'
                                    : 'Joined ${group.name}!',
                              ),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          group.isMember
                              ? Icons.chat_rounded
                              : Icons.add_rounded,
                          color: AppColors.ink,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          group.isMember ? 'Open chat' : 'Join group',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (group.isLeader) ...[
            SizedBox(width: insets.xs),
            Material(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: InkWell(
                onTap: () => context.push('/home/groups/${group.id}/leader'),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(width: insets.xs),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.gold, width: 1.5),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Invite link copied for ${group.name}'),),
                );
              },
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.share_rounded,
                  color: AppColors.goldDark,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
