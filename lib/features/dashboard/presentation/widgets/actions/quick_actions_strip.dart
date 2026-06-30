// Kingdom Heir — Section 10: Premium Quick Actions Strip
//
// Single-row 4-action rail (Bible, Prayer, Sermons, Give) rendered as
// gradient cards with Phosphor icons. Each tile is a real navigation
// entry — no decorative buttons.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
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
              Text(
                'Quick Actions',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: QuickActionItem.values.asMap().entries.map((e) {
              final index = e.key;
              final action = e.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < QuickActionItem.values.length - 1
                        ? AppSpacing.sm
                        : 0,
                  ),
                  child: _ActionButton(
                    action: action,
                    index: index,
                    onTap: () => onActionTap(action),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 680.ms, duration: 400.ms);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.index,
    this.onTap,
  });

  final QuickActionItem action;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, gradient, textColor) = _styleFor(action);

    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: _shadowColorFor(action),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: textColor, size: AppSpacing.iconMd),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  action.label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 700 + index * 40),
          duration: 300.ms,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 700 + index * 40),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  (IconData, Gradient, Color) _styleFor(QuickActionItem a) => switch (a) {
        QuickActionItem.bible => (
            Iconography.bible,
            const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            Colors.white,
          ),
        QuickActionItem.prayer => (
            Iconography.taskPrayer,
            const LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            Colors.white,
          ),
        QuickActionItem.sermons => (
            Iconography.sermon,
            const LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            AppColors.ink,
          ),
        QuickActionItem.give => (
            Iconography.giving,
            const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF16A34A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            Colors.white,
          ),
      };

  Color _shadowColorFor(QuickActionItem a) => switch (a) {
        QuickActionItem.bible =>
          const Color(0xFF1E40AF).withValues(alpha: 0.3),
        QuickActionItem.prayer =>
          const Color(0xFF7C3AED).withValues(alpha: 0.3),
        QuickActionItem.sermons => AppColors.gold.withValues(alpha: 0.3),
        QuickActionItem.give =>
          const Color(0xFF16A34A).withValues(alpha: 0.3),
      };
}