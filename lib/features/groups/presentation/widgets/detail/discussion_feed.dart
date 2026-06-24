// Kingdom Heir — Discussion Feed (DETAIL SECTION 9)
//
// Top 5 discussion posts. Each post has author, body, reaction count,
// comment count.

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

class DiscussionFeed extends ConsumerWidget {
  const DiscussionFeed({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupDiscussionProvider(groupId));
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Discussion',
          subtitle: 'Wrestle through the Word together',
          icon: Icons.forum_rounded,
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
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No discussion threads',
                  description:
                      'Start a thread — ask a question, share a story, or pass on a verse.',
                  isCompact: true,
                ),
              );
            }
            final shown = list.take(5).toList();
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == shown.length - 1 ? 0 : insets.sm,
                      ),
                      child: _PostCard(post: shown[i]),
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

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});
  final GroupDiscussionPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: post.authorName, size: 32),
              SizedBox(width: insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _relative(post.createdAt),
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
          Text(
            post.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: insets.sm),
          Row(
            children: [
              _Action(
                icon: Icons.favorite_rounded,
                count: post.reactionCount,
                color: AppColors.goldDark,
              ),
              SizedBox(width: insets.md),
              _Action(
                icon: Icons.mode_comment_outlined,
                count: post.commentCount,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(when);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.count, required this.color});
  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
