// Kingdom Heir — Detail Announcements Section (DETAIL SECTION 8)
//
// Pinned first, then latest 3 announcements.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class AnnouncementsDetailSection extends ConsumerWidget {
  const AnnouncementsDetailSection({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupAnnouncementsProvider(groupId));
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Announcements',
          subtitle: 'Pinned posts and updates from leaders',
          icon: Icons.campaign_rounded,
        ),
        async.when(
          loading: () => SizedBox(
            height: 80 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: Text('Error: $err'),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No announcements yet',
                  description:
                      'Leaders can pin important updates here for everyone in the group.',
                  isCompact: true,
                ),
              );
            }
            final sorted = [...list]..sort((a, b) {
                if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
                return b.createdAt.compareTo(a.createdAt);
              });
            final shown = sorted.take(3).toList();
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == shown.length - 1 ? 0 : insets.sm,
                      ),
                      child: _AnnouncementCard(announcement: shown[i]),
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});
  final GroupAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: announcement.pinned
            ? AppColors.gold.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: announcement.pinned
              ? AppColors.gold.withValues(alpha: 0.45)
              : theme.colorScheme.outlineVariant,
          width: announcement.pinned ? 1.2 : 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (announcement.pinned)
                const Icon(
                  Icons.push_pin_rounded,
                  size: 14,
                  color: AppColors.goldDark,
                )
              else
                Icon(
                  Icons.campaign_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 6),
              AppAvatar(
                name: announcement.authorName,
                size: 24,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  announcement.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _relative(announcement.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: insets.xs),
          Text(
            announcement.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(when);
  }
}
