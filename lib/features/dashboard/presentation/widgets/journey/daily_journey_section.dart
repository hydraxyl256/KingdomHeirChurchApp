// Kingdom Heir — Section 5: Daily Spiritual Journey
//
// Today's task checklist + streak celebration + animated progress ring.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class DailyJourneySection extends StatelessWidget {
  const DailyJourneySection({
    required this.journey,
    super.key,
    this.onTaskTap,
  });

  final DailyJourney journey;
  final void Function(SpiritualTask)? onTaskTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Daily Spiritual Journey',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (journey.streakDays >= 3)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                '${journey.streakDays}-day streak! Keep going.',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '${journey.completedCount} of ${journey.tasks.length} completed today',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Progress ring
                  _ProgressRing(progress: journey.progress),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Divider
              Container(height: 0.5, color: AppColors.dividerLight),
              const SizedBox(height: AppSpacing.sm),
              // Task list
              ...journey.tasks.asMap().entries.map((e) {
                final i = e.key;
                final task = e.value;
                return _TaskRow(
                  task: task,
                  index: i,
                  onTap: () => onTaskTap?.call(task),
                );
              }),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 380.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 380.ms, duration: 400.ms);
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 5,
              backgroundColor: AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                value >= 1.0 ? AppColors.success : AppColors.goldDark,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$pct%',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.index, this.onTap});
  final SpiritualTask task;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.success
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.success
                      : AppColors.dividerLight,
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13,)
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.displayLabel,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: task.isCompleted
                      ? AppColors.textSecondary
                      : AppColors.navy,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight:
                      task.isCompleted ? FontWeight.w400 : FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              _taskIcon(task.kind),
              size: 16,
              color: task.isCompleted
                  ? AppColors.success
                  : AppColors.textDisabled,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 420 + index * 40),
            duration: 300.ms,
          ),
    );
  }

  IconData _taskIcon(SpiritualTaskKind k) => switch (k) {
        SpiritualTaskKind.scripture => Icons.menu_book_rounded,
        SpiritualTaskKind.devotional => Icons.volunteer_activism_rounded,
        SpiritualTaskKind.prayer => Icons.self_improvement_rounded,
        SpiritualTaskKind.reflection => Icons.edit_note_rounded,
        SpiritualTaskKind.worship => Icons.music_note_rounded,
      };
}
