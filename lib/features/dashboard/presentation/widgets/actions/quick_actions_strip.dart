import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class QuickActionsStrip extends StatelessWidget {
  const QuickActionsStrip({
    required this.onActionTap,
    super.key,
  });

  final void Function(QuickActionItem) onActionTap;

  @override
  Widget build(BuildContext context) {
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Iconography.events,
                  color: AppColors.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Quick Actions',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 4;
              const spacing = AppSpacing.sm;
              final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: QuickActionItem.values.map((action) {
                  return SizedBox(
                    width: itemWidth,
                    child: _ActionButton(
                      action: action,
                      onTap: () => onActionTap(action),
                    ),
                  );
                }).toList(),
              );
            },
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    this.onTap,
  });

  final QuickActionItem action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _styleFor(action);

    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.dividerLight),
              boxShadow: AppElevation.shadowFor(AppElevation.level1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: AppSpacing.iconMd),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  action.label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _styleFor(QuickActionItem a) => switch (a) {
        QuickActionItem.bible => (Iconography.bible, const Color(0xFF6366F1)),
        QuickActionItem.prayer => (Iconography.prayer, const Color(0xFFEAB308)),
        QuickActionItem.live => (Icons.videocam_rounded, const Color(0xFFEF4444)),
        QuickActionItem.study => (Icons.menu_book_rounded, const Color(0xFF10B981)),
        QuickActionItem.groups => (Iconography.community, const Color(0xFFF97316)),
        QuickActionItem.giving => (Iconography.giving, const Color(0xFF8B5CF6)),
        QuickActionItem.events => (Iconography.events, const Color(0xFF06B6D4)),
        QuickActionItem.journal => (Icons.edit_note, const Color(0xFF14B8A6)),
      };
}
