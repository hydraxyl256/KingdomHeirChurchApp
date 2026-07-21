// Kingdom Heir — Recently Active Section (SECTION 3)
//
// Vertical list of up to 4 groups with the most recent activity. Each
// row shows last-message preview and a relative timestamp. Tapping a
// row jumps to that group's chat.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
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

class RecentlyActiveSection extends ConsumerWidget {
  const RecentlyActiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActive = ref.watch(recentlyActiveGroupsProvider);
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Lively right now',
          subtitle: 'Pick up where the conversation is flowing',
          icon: Icons.bolt_rounded,
        ),
        asyncActive.when(
          loading: () => SizedBox(
            height: 80 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: AppErrorWidget(
              message: AppLocalizations.of(context)!.couldntLoadActiveGroups,
              onRetry: () => ref.invalidate(recentlyActiveGroupsProvider),
            ),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No active conversations',
                  description:
                      'Once you join a group, the latest messages will surface here.',
                  isCompact: true,
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(
                insets.lg,
                0,
                insets.lg,
                insets.md,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < groups.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == groups.length - 1 ? 0 : insets.sm,
                      ),
                      child: _ActiveRow(group: groups[i])
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

class _ActiveRow extends StatelessWidget {
  const _ActiveRow({required this.group});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${group.id}/chat'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: EdgeInsets.all(insets.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              GroupAvatar(
                name: group.name,
                imageUrl: group.coverUrl,
                size: 44,
              ),
              SizedBox(width: insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (group.lastMessageAt != null) ...[
                          const ActivityDot(size: 6),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (group.lastMessagePreview != null)
                      Text(
                        group.lastMessagePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: insets.sm),
              Text(
                _relative(group.lastMessageAt),
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
      ),
    );
  }

  static String _relative(DateTime? when) {
    if (when == null) return '';
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(when);
  }
}
