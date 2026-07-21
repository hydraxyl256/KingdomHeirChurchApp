// Kingdom Heir — Announcements Section (SECTION 6)
//
// Vertical list of announcements across the user's groups. Pinned
// items surface first with a gold accent.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class AnnouncementsSection extends ConsumerWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(announcementsFeedForUserProvider);
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'From your leaders',
          subtitle: 'Pinned posts and important notes',
          icon: Icons.campaign_rounded,
        ),
        async.when(
          loading: () => SizedBox(
            height: 60 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: AppErrorWidget(
              message: AppLocalizations.of(context)!.couldntLoadAnnouncements,
              onRetry: () => ref.invalidate(announcementsFeedForUserProvider),
            ),
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
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == list.length - 1 ? 0 : insets.sm,
                      ),
                      child: _AnnouncementRow(announcement: list[i])
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                          )
                          .slideY(begin: 0.05, end: 0),
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

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({required this.announcement});
  final GroupAnnouncement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${announcement.groupId}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
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
                  Icon(
                    announcement.pinned
                        ? Icons.push_pin_rounded
                        : Icons.campaign_rounded,
                    size: 14,
                    color: announcement.pinned
                        ? AppColors.goldDark
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
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
