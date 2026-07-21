// Kingdom Heir — Dashboard Error State
//
// Friendly retry experience. Rendered when a section's provider throws.
// The "Try again" button invalidates the dashboard so it re-fetches.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class DashboardErrorState extends ConsumerWidget {
  const DashboardErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.body =
        "We couldn't load the latest updates. Check your connection and try again.",
    this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: insets.xl,
        vertical: insets.xxl,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(insets.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 28,
              color: theme.colorScheme.error,
            ),
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
          SizedBox(height: insets.lg),
          FilledButton.icon(
            onPressed: onRetry ?? () => ref.invalidate(dashboardDataProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.tryAgain),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: insets.xl,
                vertical: insets.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
