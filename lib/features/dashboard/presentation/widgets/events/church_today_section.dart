// Kingdom Heir — Section 6: Church Today
// Shows only today's and tomorrow's events. Never displays past events.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class ChurchTodaySection extends StatelessWidget {
  const ChurchTodaySection({
    required this.events,
    super.key,
    this.onJoin,
    this.onReminder,
    this.onSeeAll,
  });

  final List<TodayEvent> events;
  final void Function(TodayEvent)? onJoin;
  final void Function(TodayEvent)? onReminder;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final shown = events
        .where((e) =>
            e.startsAt.isAfter(now.subtract(const Duration(hours: 1))),)
        .take(3)
        .toList();

    if (shown.isEmpty) return const SizedBox.shrink();

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
                'Church Today',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...shown.asMap().entries.map((entry) {
            final i = entry.key;
            final event = entry.value;
            return _EventRow(
              event: event,
              index: i,
              isLast: i == shown.length - 1,
              onJoin: () => onJoin?.call(event),
              onReminder: () => onReminder?.call(event),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 440.ms, duration: 400.ms);
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.index,
    required this.isLast,
    this.onJoin,
    this.onReminder,
  });

  final TodayEvent event;
  final int index;
  final bool isLast;
  final VoidCallback? onJoin;
  final VoidCallback? onReminder;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(event.startsAt);
    final isToday = event.isToday;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 58,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isToday ? 'TODAY' : 'TOMORROW',
                  style: AppTypography.scriptureRef.copyWith(
                    color: isToday
                        ? AppColors.goldDark
                        : AppColors.textSecondary,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  timeStr,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Timeline dot + line
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.goldDark
                      : AppColors.textDisabled,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 40,
                  color: AppColors.dividerLight,
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      event.isOnline
                          ? Icons.videocam_rounded
                          : Icons.location_on_rounded,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        event.locationLabel,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // CTA button
          GestureDetector(
            onTap: event.isOnline ? onJoin : onReminder,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: event.isOnline
                    ? AppColors.navyAccent.withValues(alpha: 0.1)
                    : AppColors.goldContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: event.isOnline
                      ? AppColors.navyAccent.withValues(alpha: 0.2)
                      : AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                event.isOnline ? 'Join' : 'Remind',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: event.isOnline
                      ? AppColors.navyAccent
                      : AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 460 + index * 50),
          duration: 300.ms,
        );
  }
}
