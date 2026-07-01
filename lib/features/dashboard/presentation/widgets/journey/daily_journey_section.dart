// Kingdom Heir — Section 5: Premium Daily Journey
//
// Vertical timeline + completion ring. Each task kind gets its own
// category color (gold, navy, purple, teal, coral, rose). Tapping a
// task navigates to its screen; tapping a completed task toggles it
// back to incomplete (optimistic update via the repository).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_categories.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class DailyJourneySection extends StatelessWidget {
  const DailyJourneySection({
    required this.journey,
    super.key,
    this.onTaskTap,
    this.onTaskToggle,
  });

  final DailyJourney journey;
  final void Function(SpiritualTask)? onTaskTap;
  // ignore: avoid_positional_boolean_parameters
  final void Function(SpiritualTaskKind, bool)? onTaskToggle;

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
              // Header row — title + completion ring
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Daily Spiritual Journey',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconography.streak,
                              size: 14,
                              color: AppColors.goldDark,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                journey.streakDays >= 3
                                    ? '${journey.streakDays}-day streak — keep going!'
                                    : '${journey.completedCount} of ${journey.tasks.length} complete',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _CompletionRing(progress: journey.progress),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(height: 0.5, color: AppColors.dividerLight),
              const SizedBox(height: AppSpacing.md),
              // Vertical timeline of tasks
              _TaskTimeline(
                tasks: journey.tasks,
                onTaskTap: onTaskTap,
                onTaskToggle: onTaskToggle,
              ),
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

// ── Completion Ring ───────────────────────────────────────────────────────────

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return SizedBox(
      width: 64,
      height: 64,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            // Track
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 6,
                color: AppColors.dividerLight,
              ),
            ),
            // Progress arc
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                color: value >= 1.0 ? AppColors.success : AppColors.goldDark,
              ),
            ),
            // Center label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pct%',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'done',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task Timeline ─────────────────────────────────────────────────────────────

class _TaskTimeline extends StatelessWidget {
  const _TaskTimeline({
    required this.tasks,
    this.onTaskTap,
    this.onTaskToggle,
  });

  final List<SpiritualTask> tasks;
  final void Function(SpiritualTask)? onTaskTap;
  // ignore: avoid_positional_boolean_parameters
  final void Function(SpiritualTaskKind, bool)? onTaskToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < tasks.length; i++)
          _TimelineNode(
            task: tasks[i],
            isFirst: i == 0,
            isLast: i == tasks.length - 1,
            index: i,
            onTap: () => onTaskTap?.call(tasks[i]),
            onToggle: (val) => onTaskToggle?.call(tasks[i].kind, val),
          ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.task,
    required this.isFirst,
    required this.isLast,
    required this.index,
    this.onTap,
    this.onToggle,
  });

  final SpiritualTask task;
  final bool isFirst;
  final bool isLast;
  final int index;
  final VoidCallback? onTap;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onToggle;

  @override
  Widget build(BuildContext context) {
    final style = JourneyCategory.forKind(task.kind);
    final color = style.color;
    final icon = style.icon;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rail with dot
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 8,
                    color: AppColors.dividerLight,
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? color
                        : Colors.white,
                    border: Border.all(
                      color: task.isCompleted
                          ? color
                          : AppColors.dividerLight,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.dividerLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Task content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(
                  top: !isFirst ? 4 : 0,
                  bottom: !isLast ? AppSpacing.md : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
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
                          fontWeight: task.isCompleted
                              ? FontWeight.w500
                              : FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Toggle switch (tap to flip)
                    Semantics(
                      button: true,
                      toggled: task.isCompleted,
                      label: task.isCompleted
                          ? 'Mark ${task.displayLabel} incomplete'
                          : 'Mark ${task.displayLabel} complete',
                      child: GestureDetector(
                        onTap: () => onToggle?.call(!task.isCompleted),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 36,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: task.isCompleted
                                ? color
                                : AppColors.dividerLight,
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            alignment: task.isCompleted
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 420 + index * 50),
          duration: 320.ms,
        )
        .slideX(begin: 0.06, end: 0, duration: 320.ms, curve: Curves.easeOut);
  }
}
