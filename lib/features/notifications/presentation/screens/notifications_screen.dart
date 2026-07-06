// Kingdom Heir — Notifications Center Screen
//
// Premium, theme-aware list of the user's notifications. Renders:
//   • Header (back, title, "Mark all read" action)
//   • Grouped sections (Today / Earlier) by createdAt
//   • Per-card: kind icon, title, body, timestamp, unread dot
//   • Empty state (no notifications yet)
//   • Error state (with retry)
//   • Loading skeleton
//   • Pull-to-refresh
//
// Tapping a card marks it read and, when the kind has a deep-link in
// the `data` payload, navigates to the relevant feature.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/notifications/domain/entities/app_notification.dart';
import 'package:kingdom_heir/features/notifications/presentation/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;
    final titleColor =
        isDark ? AppColors.warmWhite : AppColors.navy;
    final muted =
        isDark ? AppColors.warmWhite.withValues(alpha: 0.6) : AppColors.textSecondary;

    final async = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: titleColor,
            size: AppSpacing.iconSm,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          async.maybeWhen(
            data: (list) => list.any((n) => !n.isRead)
                ? TextButton.icon(
                    onPressed: () => ref
                        .read(notificationsProvider.notifier)
                        .markAllAsRead(),
                    icon: const Icon(
                      Icons.done_all_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.goldDark,
                    ),
                    label: Text(
                      'Mark all read',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => _NotificationsSkeleton(cardColor: cardColor),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyNotifications();
          }
          return RefreshIndicator.adaptive(
            color: AppColors.goldDark,
            backgroundColor: cardColor,
            onRefresh: () =>
                ref.read(notificationsProvider.notifier).refresh(),
            child: _NotificationsList(
              notifications: notifications,
              cardColor: cardColor,
              titleColor: titleColor,
              muted: muted,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List — grouped by Today / Earlier
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({
    required this.notifications,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });

  final List<AppNotification> notifications;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groupByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final group = groups[i];
        return Padding(
          padding: EdgeInsets.only(
            bottom: i == groups.length - 1 ? 0 : AppSpacing.lg,
          ),
          child: _Section(
            title: group.label,
            count: group.items.length,
            cardColor: cardColor,
            titleColor: titleColor,
            muted: muted,
            children: [
              for (var j = 0; j < group.items.length; j++)
                _NotificationCard(
                  notification: group.items[j],
                  cardColor: cardColor,
                  titleColor: titleColor,
                  muted: muted,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
    required this.children,
  });

  final String title;
  final int count;
  final Color cardColor;
  final Color titleColor;
  final Color muted;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            0,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({
    required this.notification,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });

  final AppNotification notification;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kindMeta = _kindMeta(notification.kind);
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => _onTap(context, ref),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isUnread
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : Colors.transparent,
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kind icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kindMeta.bg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    kindMeta.icon,
                    color: kindMeta.fg,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(
                                color: titleColor,
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: muted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: muted.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    if (!notification.isRead) {
      ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
    }
    final data = notification.data;
    if (data == null) return;
    final kind = notification.kind;
    final id = data['id'] as String?;
    if (id == null) return;
    switch (kind) {
      case NotificationKind.event:
        context.push(RouteNames.eventDetail.replaceAll(':id', id));
      case NotificationKind.sermon:
        context.push(RouteNames.sermonDetails.replaceAll(':id', id));
      case NotificationKind.devotional:
      case NotificationKind.general:
        // No specific deep link; stay on the notifications screen.
        break;
      case NotificationKind.prayer:
        context.push(RouteNames.prayerFeed);
      case NotificationKind.prayerApproved:
      case NotificationKind.prayerRejected:
        context.push(RouteNames.myPrayers);
      case NotificationKind.giving:
        openDonationPage(context);
      case NotificationKind.unknown:
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.warmWhite : AppColors.navy;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.goldContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconography.notifications,
                color: AppColors.goldDark,
                size: AppSpacing.iconLg,
              ),
            )
                .animate()
                .scale(
                  duration: 400.ms,
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                )
                .fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You’re all caught up',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'New updates from your church, prayer requests,\nsermons and events will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton (loading state)
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton({required this.cardColor});
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _KindMeta {
  const _KindMeta(this.icon, this.bg, this.fg);
  final IconData icon;
  final Color bg;
  final Color fg;
}

_KindMeta _kindMeta(NotificationKind kind) {
  switch (kind) {
    case NotificationKind.event:
      return const _KindMeta(
        Iconography.calendar,
        AppColors.goldContainer,
        AppColors.goldDark,
      );
    case NotificationKind.prayer:
      return const _KindMeta(
        Iconography.prayer,
        Color(0xFFE0F2FE),
        Color(0xFF0369A1),
      );
    case NotificationKind.prayerApproved:
    case NotificationKind.prayerRejected:
      return const _KindMeta(
        Iconography.prayer,
        Color(0xFFDCFCE7),
        Color(0xFF166534),
      );
    case NotificationKind.sermon:
      return const _KindMeta(
        Iconography.sermon,
        Color(0xFFEDE9FE),
        Color(0xFF6D28D9),
      );
    case NotificationKind.devotional:
      return const _KindMeta(
        Iconography.devotional,
        Color(0xFFFEF3C7),
        Color(0xFFB45309),
      );
    case NotificationKind.giving:
      return const _KindMeta(
        Iconography.giving,
        Color(0xFFDCFCE7),
        Color(0xFF166534),
      );
    case NotificationKind.general:
      return const _KindMeta(
        Iconography.announcement,
        Color(0xFFFEF3C7),
        Color(0xFFB45309),
      );
    case NotificationKind.unknown:
      return const _KindMeta(
        Iconography.notifications,
        AppColors.goldContainer,
        AppColors.goldDark,
      );
  }
}

class _DateGroup {
  const _DateGroup(this.label, this.items);
  final String label;
  final List<AppNotification> items;
}

List<_DateGroup> _groupByDate(List<AppNotification> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final todayList = <AppNotification>[];
  final earlier = <AppNotification>[];

  for (final n in items) {
    final created = n.createdAt;
    final createdDate = DateTime(created.year, created.month, created.day);
    if (createdDate == today) {
      todayList.add(n);
    } else if (createdDate == yesterday) {
      // Bucket yesterday into "Earlier" to keep the section count small.
      earlier.add(n);
    } else {
      earlier.add(n);
    }
  }

  final groups = <_DateGroup>[];
  if (todayList.isNotEmpty) groups.add(_DateGroup('TODAY', todayList));
  if (earlier.isNotEmpty) {
    groups.add(_DateGroup('EARLIER', earlier));
  }
  return groups;
}

String _formatTimestamp(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat.MMMd().format(dt);
}
