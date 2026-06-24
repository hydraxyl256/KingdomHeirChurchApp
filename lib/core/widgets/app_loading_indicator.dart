import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

/// Full-screen centered loading indicator with optional message.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer skeleton placeholder for list items.
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({
    super.key,
    this.height = 80,
    this.borderRadius = AppSpacing.radiusMd,
  });

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:
          isDark ? AppColors.surfaceVariantDark : const Color(0xFFE8E3F2),
      highlightColor: isDark ? AppColors.cardDark : Colors.white,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton list of [AppShimmerCard]s.
class AppShimmerList extends StatelessWidget {
  const AppShimmerList({super.key, this.count = 5, this.cardHeight = 80});
  final int count;
  final double cardHeight;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: count,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (_, __) => AppShimmerCard(height: cardHeight),
      );
}
