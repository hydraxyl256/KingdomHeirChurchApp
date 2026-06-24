// Kingdom Heir — Sermons Empty State
//
// Shared "no data" widget for sermon surfaces. Mirrors the
// pattern of `AppEmptyState` but is sermon-themed (gold icon + actions).

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

class SermonsEmptyState extends StatelessWidget {
  const SermonsEmptyState({
    required this.title,
    super.key,
    this.description,
    this.icon = Icons.menu_book_outlined,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: isCompact ? AppSpacing.xl : AppSpacing.huge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 56 : 72,
            height: isCompact ? 56 : 72,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(icon, color: AppColors.gold, size: isCompact ? 24 : 32),
          ),
          SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description!,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
