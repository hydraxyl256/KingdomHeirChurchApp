// Kingdom Heir — Section 8: Premium Community Highlight
//
// 2×2 tile grid showcasing community signals:
//   1. Unread Messages  → RouteNames.groups
//   2. Birthdays        → RouteNames.members
//   3. Upcoming Meeting → RouteNames.groups
//   4. Leader Announcement → RouteNames.news
//
// Empty tiles render muted (0.5 opacity) so layout stays stable —
// designers don't want flicker as data loads.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class CommunityHighlightSection extends StatelessWidget {
  const CommunityHighlightSection({
    required this.highlight,
    super.key,
    this.onGroupsTap,
    this.onMembersTap,
    this.onNewsTap,
  });

  final CommunityHighlight highlight;
  final VoidCallback? onGroupsTap;
  final VoidCallback? onMembersTap;
  final VoidCallback? onNewsTap;

  @override
  Widget build(BuildContext context) {
    final tiles = <_TileData>[
      _TileData(
        icon: Iconography.community,
        color: AppColors.navyAccent,
        title: highlight.unreadGroupMessages > 0
            ? '${highlight.unreadGroupMessages} unread'
            : 'Messages',
        subtitle: highlight.unreadGroupMessages > 0
            ? 'Group chats'
            : 'No new messages',
        isEmpty: highlight.unreadGroupMessages == 0,
        badge: highlight.unreadGroupMessages > 0
            ? '${highlight.unreadGroupMessages}'
            : null,
        onTap: onGroupsTap,
      ),
      _TileData(
        icon: Iconography.birthday,
        color: const Color(0xFFEC4899),
        title: 'Birthdays',
        subtitle: highlight.birthdayName != null
            ? highlight.birthdayName!
            : 'No birthdays today',
        isEmpty: highlight.birthdayName == null,
        onTap: onMembersTap,
      ),
      _TileData(
        icon: Iconography.meeting,
        color: AppColors.success,
        title: 'Meeting',
        subtitle: highlight.upcomingGroupMeeting ??
            'No meeting scheduled',
        isEmpty: highlight.upcomingGroupMeeting == null,
        onTap: onGroupsTap,
      ),
      _TileData(
        icon: Iconography.announcement,
        color: AppColors.goldDark,
        title: 'Announcement',
        subtitle: highlight.leaderAnnouncement ?? 'Quiet on the news front',
        isEmpty: highlight.leaderAnnouncement == null,
        onTap: onNewsTap,
      ),
    ];

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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Iconography.community,
                  color: AppColors.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Community',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onGroupsTap != null)
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
          Row(
            children: [
              Expanded(
                child: _Tile(
                  data: tiles[0],
                  index: 0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Tile(
                  data: tiles[1],
                  index: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  data: tiles[2],
                  index: 2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Tile(
                  data: tiles[3],
                  index: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 560.ms, duration: 400.ms);
  }
}

class _TileData {
  const _TileData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isEmpty,
    this.badge,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isEmpty;
  final String? badge;
  final VoidCallback? onTap;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.data, required this.index});
  final _TileData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${data.title}: ${data.subtitle}',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: data.isEmpty ? 0.55 : 1.0,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: data.onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.dividerLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: data.color.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Icon(data.icon, color: data.color, size: 16),
                            if (data.badge != null)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.color,
                                    borderRadius:
                                        BorderRadius.circular(7),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Iconography.directions,
                        size: 12,
                        color: AppColors.textDisabled,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    data.title,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 580 + index * 80),
          duration: 320.ms,
        )
        .slideY(begin: 0.08, end: 0, duration: 320.ms, curve: Curves.easeOut);
  }
}
