// Kingdom Heir — Section 6: Premium Church Today Timeline
//
// Vertical timeline (similar in spirit to the Daily Journey) but for
// events. Each event has a category-tinted dot (prayer, bible study,
// youth, sunday service, outreach, choir, other). Shows today +
// tomorrow's events only — never past. Falls back to a friendly empty
// state when there's nothing on the schedule.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_categories.dart';
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
    final now = DateTime.now();
    final shown = events
        .where(
          (e) => e.startsAt.isAfter(now.subtract(const Duration(hours: 1))),
        )
        .take(4)
        .toList();

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
          // Header
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
                  Iconography.events,
                  color: AppColors.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Church Today',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onSeeAll != null)
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
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: AppEmptyState(
                isCompact: true,
                icon: Iconography.events,
                title: 'No events today',
                description: 'The week is open — explore upcoming services.',
                actionLabel: onSeeAll != null ? 'Browse Events' : null,
                onAction: onSeeAll,
              ),
            )
          else
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
    final style = EventCategory.forCategory(event.category);
    final color = style.color;
    final label = style.label;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'TODAY' : 'TOMORROW',
                  style: AppTypography.scriptureRef.copyWith(
                    color: isToday
                        ? AppColors.goldDark
                        : AppColors.textSecondary,
                    fontSize: 8,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
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
          // Timeline rail with category-colored dot
          SizedBox(
            width: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 64,
                    color: AppColors.dividerLight,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.scriptureRef.copyWith(
                          color: color,
                          fontSize: 8,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                if (event.leaderName != null) ...[
                  Text(
                    'with ${event.leaderName}',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      event.isOnline
                          ? Iconography.live
                          : Iconography.directions,
                      size: 12,
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
          Semantics(
            button: true,
            label: event.isOnline ? 'Join online' : 'Set reminder',
            child: GestureDetector(
              onTap: event.isOnline ? onJoin : onReminder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  color: event.isOnline
                      ? AppColors.navyAccent.withValues(alpha: 0.1)
                      : AppColors.goldContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
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
