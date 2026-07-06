// Kingdom Heir — My Prayer Requests screen
//
// Shows the current user's own prayer requests with status chips for
// the moderation lifecycle:
//   * Pending review  — the request was submitted and is awaiting admin
//   * Approved        — the request is visible on the public Prayer Wall
//   * Not published   — the request was reviewed and decided to stay off
//                       the wall (uses pastoral copy, not "Rejected")
//
// When a "Not published" request carries an admin note, the note is
// surfaced under a respectful "From your church team:" label.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/core/widgets/app_loading_indicator.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/providers/prayer_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyPrayersScreen extends ConsumerWidget {
  const MyPrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final myAsync = ref.watch(myPrayersProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Prayer Requests'),
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          ref.invalidate(myPrayersProvider);
          await ref.read(myPrayersProvider.future);
        },
        child: myAsync.when(
          loading: () => const AppLoadingIndicator(
            label: 'Loading your prayers...',
          ),
          error: (err, _) => AppErrorWidget(
            message: 'We could not load your prayer requests. Please try again.',
            onRetry: () => ref.invalidate(myPrayersProvider),
          ),
          data: (requests) {
            if (requests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: AppEmptyState(
                      icon: Icons.self_improvement_rounded,
                      title: 'You haven\'t shared any prayer requests yet',
                      description:
                          'When you share a request, it will appear here while '
                          'our team reviews it. Approved requests will also be '
                          'visible on the public Prayer Wall.',
                      actionLabel: 'Share a prayer request',
                      onAction: () => context.go(RouteNames.submitPrayer),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => _MyPrayerCard(
                request: requests[i],
                isDark: isDark,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyPrayerCard extends StatelessWidget {
  const _MyPrayerCard({required this.request, required this.isDark});
  final PrayerRequest request;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatusChip(status: request.status, isDark: isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            request.content,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.75),
              height: 1.55,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 4),
              Text(
                request.category,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 4),
              Text(
                timeago.format(request.createdAt),
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (request.status == PrayerStatus.approved &&
                  request.prayerCount > 0) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 4),
                Text(
                  '${request.prayerCount} praying',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (request.status == PrayerStatus.rejected &&
              (request.adminNote?.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From your church team:',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.adminNote!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isDark});
  final PrayerStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, bg, fg) = _chipData(theme, isDark);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color, Color) _chipData(ThemeData theme, bool isDark) {
    final scheme = theme.colorScheme;
    switch (status) {
      case PrayerStatus.pending:
        final bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        return (
          'Pending review',
          Icons.schedule_rounded,
          bg,
          isDark ? const Color(0xFFFCD34D) : AppColors.warning,
        );
      case PrayerStatus.approved:
        final bg = isDark
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.successContainer;
        return (
          'Approved',
          Icons.check_circle_rounded,
          bg,
          isDark ? const Color(0xFF86EFAC) : AppColors.success,
        );
      case PrayerStatus.rejected:
        final bg = scheme.surfaceContainerHigh;
        return (
          'Not published',
          Icons.do_not_disturb_on_rounded,
          bg,
          scheme.onSurface.withValues(alpha: 0.7),
        );
    }
  }
}
