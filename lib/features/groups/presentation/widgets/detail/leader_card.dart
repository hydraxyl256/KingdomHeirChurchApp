// Kingdom Heir — Leader Card (DETAIL SECTION 2)
//
// Leader avatar + name + role + bio + years in role + languages.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

class LeaderCard extends ConsumerWidget {
  const LeaderCard({required this.leader, required this.group, super.key});
  final GroupLeaderProfile leader;
  final CommunityGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, 0),
      child: Container(
        padding: EdgeInsets.all(insets.lg),
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
          children: [
            Row(
              children: [
                Text(
                  'YOUR LEADER',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: insets.sm),
            Row(
              children: [
                AppAvatar(
                  name: leader.member.displayName,
                  imageUrl: leader.member.avatarUrl,
                  size: 56,
                  borderColor: AppColors.gold,
                  borderWidth: 2,
                ),
                SizedBox(width: insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leader.member.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_outlined,
                            size: 12,
                            color: AppColors.goldDark,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Leading for ${leader.yearsInRole} years',
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
                    ],
                  ),
                ),
              ],
            ),
            if (leader.bio != null) ...[
              SizedBox(height: insets.sm),
              Text(
                leader.bio!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
            ],
            if (leader.languages.isNotEmpty) ...[
              SizedBox(height: insets.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: leader.languages
                    .map(
                      (l) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          l,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            SizedBox(height: insets.sm),
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: AppColors.goldDark,
                ),
                const SizedBox(width: 4),
                Text(
                  '${leader.prayerCount} prayers lifted this year',
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
    );
  }
}
