import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Spiritual Journey',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${journey.completedCount}/${journey.tasks.length} Complete',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: AppElevation.shadowFor(AppElevation.level1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _TaskTimeline(
                tasks: journey.tasks,
                onTaskTap: onTaskTap,
                onTaskToggle: onTaskToggle,
              ),
            ),
          ).animate().fadeIn(delay: 380.ms, duration: 400.ms).slideY(
                begin: 0.05,
                end: 0,
                delay: 380.ms,
                duration: 400.ms,
              ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Vertical connector line — adaptive divider color
        Positioned(
          left: 19,
          top: 16,
          bottom: 16,
          child: Container(
            width: 2,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < tasks.length; i++)
              Padding(
                padding: EdgeInsets.only(
                    bottom: i == tasks.length - 1 ? 0 : AppSpacing.lg,),
                child: _TimelineNode(
                  task: tasks[i],
                  onTap: () => onTaskTap?.call(tasks[i]),
                  onToggle: (val) => onTaskToggle?.call(tasks[i].kind, val),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.task,
    this.onTap,
    this.onToggle,
  });

  final SpiritualTask task;
  final VoidCallback? onTap;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool)? onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = JourneyCategory.forKind(task.kind);
    final icon = style.icon;

    return Semantics(
      button: true,
      label:
          'Task: ${task.displayLabel}. ${task.isCompleted ? "Completed" : "Not completed"}',
      child: GestureDetector(
        onTap: () {
          if (task.isCompleted) {
            onToggle?.call(false);
          } else {
            onTap?.call();
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            GestureDetector(
              onTap: () => onToggle?.call(!task.isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Completed = gold filled; uncompleted = adaptive surface
                  color: task.isCompleted
                      ? AppColors.goldDark
                      : cs.surfaceContainerHigh,
                  border: Border.all(
                    color: AppColors.goldDark,
                    width: 2,
                  ),
                  boxShadow: AppElevation.shadowFor(AppElevation.level0),
                ),
                child: Center(
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20,)
                      : Icon(icon, color: AppColors.goldDark, size: 20),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.displayLabel,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      // Completed = muted; pending = primary adaptive
                      color:
                          task.isCompleted ? cs.onSurfaceVariant : cs.onSurface,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
