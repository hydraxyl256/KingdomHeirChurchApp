// Kingdom Heir — Section 8: Community Highlight
// Only relevant snippets: unread messages, birthday, leader announcement.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class CommunityHighlightSection extends StatelessWidget {
  const CommunityHighlightSection({
    required this.highlight,
    super.key,
    this.onGroupsTap,
  });

  final CommunityHighlight highlight;
  final VoidCallback? onGroupsTap;

  @override
  Widget build(BuildContext context) {
    if (!highlight.hasContent) return const SizedBox.shrink();

    final items = <_HighlightItem>[];

    if (highlight.unreadGroupMessages > 0) {
      items.add(_HighlightItem(
        icon: Icons.forum_rounded,
        color: AppColors.navyAccent,
        label: '${highlight.unreadGroupMessages} unread group messages',
        onTap: onGroupsTap,
      ),);
    }
    if (highlight.birthdayName != null) {
      items.add(_HighlightItem(
        icon: Icons.cake_rounded,
        color: const Color(0xFFEC4899),
        label: 'Wish ${highlight.birthdayName} a happy birthday 🎂',
        onTap: onGroupsTap,
      ),);
    }
    if (highlight.leaderAnnouncement != null) {
      items.add(_HighlightItem(
        icon: Icons.campaign_rounded,
        color: AppColors.goldDark,
        label: highlight.leaderAnnouncement!,
        onTap: onGroupsTap,
      ),);
    }
    if (highlight.upcomingGroupMeeting != null) {
      items.add(_HighlightItem(
        icon: Icons.group_rounded,
        color: AppColors.success,
        label: highlight.upcomingGroupMeeting!,
        onTap: onGroupsTap,
      ),);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Community',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onGroupsTap,
                child: Text(
                  'My Groups',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.dividerLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final isLast = i == items.length - 1;
                return _CommunityTile(item: item, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 560.ms, duration: 400.ms);
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({required this.item, required this.isLast});
  final _HighlightItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 0.5,
            indent: AppSpacing.lg + 36 + AppSpacing.md,
            color: AppColors.dividerLight,
          ),
      ],
    );
  }
}
