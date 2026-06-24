// Kingdom Heir — More Screen Skeleton
//
// Layout-matched shimmer placeholder shown while the More screen's
// per-section providers are still resolving. Mirrors the final layout
// proportions so the transition to real content feels seamless.
//
// Scrollability note: the skeleton is a flat `Column` of fixed-height
// shimmer boxes. It contains no vertical scrollables — the only
// vertical scroller in the screen is the root `CustomScrollView` from
// `MoreScreen`.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/profile_hero.dart';

class MoreScreenSkeleton extends StatelessWidget {
  const MoreScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    // NOTE: the host (`MoreScreen`) renders this widget inside a
    // `SliverToBoxAdapter`, which provides **bounded** vertical
    // constraints. A `ListView` without `shrinkWrap: true` requires
    // *unbounded* height in its scroll axis and immediately throws a
    // "Vertical viewport was given unbounded height" error — leaving the
    // screen blank. We use a `Column` instead so the skeleton lays out
    // inside the sliver's bounded box exactly like the real content.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileHeroSkeleton(),
        SizedBox(height: insets.md),
        // Search skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: insets.lg),
          child: const AppShimmerBox(
            height: 48,
            borderRadius: 999,
          ),
        ),
        SizedBox(height: insets.xl),

        // Section header skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: insets.lg),
          child: const AppShimmerBox(height: 22, width: 180),
        ),
        SizedBox(height: insets.md),

        // Grid skeleton (3-up)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: insets.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - insets.sm * 2) / 3;
              return Wrap(
                spacing: insets.sm,
                runSpacing: insets.sm,
                children: [
                  for (var i = 0; i < 6; i++)
                    AppShimmerBox(
                      width: tileWidth,
                      height: tileWidth,
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: insets.xl),
      ],
    );
  }
}
