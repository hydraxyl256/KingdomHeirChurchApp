// Kingdom Heir — Pinned Message Banner
//
// Sticky strip above the chat list. Renders only when the group has at
// least one pinned announcement. Gold accent border, push-pin icon,
// author name + body excerpt. Tap → opens group detail or scrolls the
// pinned announcement into view.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';

class PinnedMessageBanner extends StatelessWidget {
  const PinnedMessageBanner({
    required this.authorName,
    required this.body,
    required this.groupId,
    super.key,
  });

  final String authorName;
  final String body;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return InkWell(
      onTap: () => context.push('/home/groups/$groupId'),
      borderRadius: AppRadius.brLg,
      child: Container(
        margin: EdgeInsets.fromLTRB(insets.md, insets.sm, insets.md, 0),
        padding: EdgeInsets.all(insets.md),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.10),
          borderRadius: AppRadius.brLg,
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.55),
            width: 1.1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.push_pin_rounded,
                color: AppColors.ink,
                size: 16,
              ),
            ),
            SizedBox(width: insets.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.campaign_rounded,
                        size: 12,
                        color: AppColors.goldDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pinned announcement',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppAvatar(name: authorName, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.goldDark,
            ),
          ],
        ),
      ),
    );
  }
}
