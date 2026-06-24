// Kingdom Heir — Detail Prayer Wall Section (DETAIL SECTION 6)
//
// Top 2 prayer requests from this group, plus an "Open prayer wall" CTA.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';

class PrayerWallSection extends ConsumerWidget {
  const PrayerWallSection({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupPrayerProvider(groupId));
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: 'Prayer wall',
          subtitle: 'Lift up our brothers and sisters',
          icon: Icons.volunteer_activism_rounded,
          actionLabel: 'Open wall',
          onAction: () => context.push('/home/groups/$groupId/prayer'),
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
                  icon: Icons.spa_rounded,
                  title: 'No prayer requests yet',
                  description: 'Be the first to share what’s on your heart.',
                  isCompact: true,
                ),
              );
            }
            final next = list.take(2).toList();
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < next.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == next.length - 1 ? 0 : insets.sm,
                      ),
                      child: _MiniPrayerRow(request: next[i]),
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

class _MiniPrayerRow extends StatelessWidget {
  const _MiniPrayerRow({required this.request});
  final GroupPrayerRequest request;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            name: request.authorName,
            size: 36,
          ),
          SizedBox(width: insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: insets.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: AppColors.goldDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.prayingCount} praying',
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
        ],
      ),
    );
  }
}
