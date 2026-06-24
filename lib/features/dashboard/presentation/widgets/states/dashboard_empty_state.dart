// Kingdom Heir — Dashboard Empty State
//
// Reused by every section that can be empty (events, sermons, prayer requests,
// giving history, etc.). Renders inside the section's content area with a
// friendly message and an optional CTA.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({
    required this.title,
    required this.body,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: insets.xl,
        vertical: insets.xxl,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(insets.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(icon, size: 28, color: AppColors.gold),
          ),
          SizedBox(height: insets.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: insets.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: insets.lg),
            FilledButton.tonal(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                foregroundColor: AppColors.goldDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: insets.xl,
                  vertical: insets.sm,
                ),
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
