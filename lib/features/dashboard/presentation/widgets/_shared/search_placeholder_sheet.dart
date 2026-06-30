// Kingdom Heir — Search Placeholder Sheet
//
// Temporary modal bottom sheet shown when the user taps the search
// icon in the dashboard header. The production search experience is a
// future task; this gives a clean "coming soon" surface so the tap
// target is never a dead button (per the redesign spec rule: "every
// visible button must work").

import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';

class SearchPlaceholderSheet extends StatelessWidget {
  const SearchPlaceholderSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SearchPlaceholderSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.goldContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconography.search,
                color: AppColors.goldDark,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Global Search',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Search across Bible, devotionals, sermons, prayer requests and church events is coming soon.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Search the kingdom…',
                prefixIcon: const Icon(
                  Iconography.search,
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.goldContainer.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}