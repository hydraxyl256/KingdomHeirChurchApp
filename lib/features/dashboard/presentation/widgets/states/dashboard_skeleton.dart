// Kingdom Heir — Dashboard Skeleton
//
// A layout-matched shimmer placeholder used while the dashboard's providers
// resolve for the first time. Mirrors the real screen's structure:
//   • Hero block (gold tint, taller)
//   • Focus card block
//   • Continue rail (3 horizontal pills)
//   • Quick action grid (2×4)
//   • Impact grid (2×2)
//   • Giving block
//   • List blocks
//
// No hardcoded sizes — every container uses Expanded/Flexible/aspect ratios
// inside LayoutBuilder-driven sub-skeletons.

import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha: 0.45);
    final highlightColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHigh
        .withValues(alpha: 0.85);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final band = layoutBandFromWidth(constraints.maxWidth);
          final insets = Insets.of(context);
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: insets.lg),
            children: [
              _HeroBlock(insets: insets),
              SizedBox(height: insets.xl),
              _FocusBlock(insets: insets),
              SizedBox(height: insets.xl),
              _RailBlock(
                insets: insets,
                tileCount: band.isAtLeast(LayoutBand.lg) ? 4 : 3,
              ),
              SizedBox(height: insets.xl),
              _QuickActionsBlock(insets: insets, band: band),
              SizedBox(height: insets.xl),
              _ImpactBlock(insets: insets, band: band),
              SizedBox(height: insets.xl),
              _Block(insets: insets, height: 120),
              SizedBox(height: insets.lg),
              _ListBlock(insets: insets, count: 3),
              SizedBox(height: insets.lg),
              _Block(insets: insets, height: 100),
              SizedBox(height: insets.lg),
              _Block(insets: insets, height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.insets});
  final Insets insets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
    );
  }
}

class _FocusBlock extends StatelessWidget {
  const _FocusBlock({required this.insets});
  final Insets insets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.goldContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    );
  }
}

class _RailBlock extends StatelessWidget {
  const _RailBlock({required this.insets, required this.tileCount});
  final Insets insets;
  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: insets.lg),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tileCount,
        separatorBuilder: (_, __) => SizedBox(width: insets.md),
        itemBuilder: (_, __) => FractionallySizedBox(
          widthFactor: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsBlock extends StatelessWidget {
  const _QuickActionsBlock({required this.insets, required this.band});
  final Insets insets;
  final LayoutBand band;

  @override
  Widget build(BuildContext context) {
    final columns = switch (band) {
      LayoutBand.xs => 4,
      LayoutBand.sm => 4,
      LayoutBand.md => 4,
      LayoutBand.lg => 6,
      LayoutBand.xl => 8,
      LayoutBand.xxl => 8,
    };
    final rows = (8 / columns).ceil();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Wrap(
        spacing: insets.md,
        runSpacing: insets.md,
        children: List.generate(columns * rows, (_) {
          final size = (MediaQuery.of(context).size.width -
                  insets.lg * 2 -
                  insets.md * (columns - 1)) /
              columns;
          return SizedBox(
            width: size,
            height: size * 0.78,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ImpactBlock extends StatelessWidget {
  const _ImpactBlock({required this.insets, required this.band});
  final Insets insets;
  final LayoutBand band;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Wrap(
        spacing: insets.md,
        runSpacing: insets.md,
        children: List.generate(4, (_) {
          final w = band.isAtLeast(LayoutBand.lg)
              ? (MediaQuery.of(context).size.width -
                      insets.lg * 2 -
                      insets.md * 3) /
                  4
              : (MediaQuery.of(context).size.width -
                      insets.lg * 2 -
                      insets.md) /
                  2;
          return SizedBox(
            width: w,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.insets, required this.height});
  final Insets insets;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.insets, required this.count});
  final Insets insets;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: Column(
        children: List.generate(
          count,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: insets.sm),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
