// Kingdom Heir — Resources Section (SECTION 7)
//
// Collapsed-by-default expandable section with three tiles:
//   • Bookstore
//   • Learning Resources
//   • Downloads
//
// A small header row shows the section title and an arrow chevron that
// rotates 180° when expanded. The body animates open via
// `AnimatedSize`. Three feature tiles render in a `Wrap` so 320 dp
// phones stack them vertically and tablets render 3-wide.
//
// Safety: the per-tile entrance animation uses `TweenAnimationBuilder`
// rather than `flutter_animate`'s `.animate().fadeIn().slideY()` chain.
// `flutter_animate` mounts an internal `Builder` that can interfere
// with `AnimatedSize` and the surrounding `LayoutBuilder` during the
// first frame, producing a `RenderBox.size` null-deref in
// `RenderViewport → SliverToBoxAdapter → RenderBox.size`. The current
// implementation wraps each tile with a self-contained opacity + translate
// fade-in that doesn't need any external Builder.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_tile.dart';

class ResourcesExpandableSection extends StatefulWidget {
  const ResourcesExpandableSection({super.key});

  @override
  State<ResourcesExpandableSection> createState() =>
      _ResourcesExpandableSectionState();
}

class _ResourcesExpandableSectionState
    extends State<ResourcesExpandableSection> {
  bool _expanded = false;

  static const _features = [
    MoreFeature.bookstore,
    MoreFeature.learning,
    MoreFeature.downloads,
  ];

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row — tappable to expand/collapse
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              insets.lg,
              insets.lg,
              insets.lg,
              insets.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.library_books_rounded,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
                SizedBox(width: insets.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Resources',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_features.length} tools for growth',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppMotion.standard,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body — AnimatedSize so the section grows smoothly
        AnimatedSize(
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    0,
                    insets.lg,
                    insets.lg,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final band = layoutBandFromWidth(constraints.maxWidth);
                      final columns = switch (band) {
                        LayoutBand.xs => 1,
                        LayoutBand.sm => 2,
                        LayoutBand.md => 3,
                        LayoutBand.lg => 3,
                        LayoutBand.xl => 3,
                        LayoutBand.xxl => 3,
                      };
                      final spacing = insets.sm;
                      final tileWidth = columns == 1
                          ? constraints.maxWidth
                          : (constraints.maxWidth - spacing * (columns - 1)) /
                              columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (var i = 0; i < _features.length; i++)
                            SizedBox(
                              width: tileWidth,
                              child: AspectRatio(
                                aspectRatio: 0.95,
                                // Self-contained opacity+translate fade-in.
                                // No Builder, no LayoutBuilder — predictable
                                // measurement so AnimatedSize can measure
                                // the body during the expand animation.
                                child: _TileFadeIn(
                                  delayMs: 40 * i,
                                  child: FeatureTileWidget(feature: _features[i]),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Self-contained opacity + translate fade-in. The animation runs once
/// on first build (with an optional `delayMs`). We deliberately avoid
/// `flutter_animate`'s `.animate().fadeIn().slideY()` here because that
/// pattern mounted an internal `Builder` that interacted badly with
/// `AnimatedSize` during the expand animation, producing a
/// `RenderBox.size` null-deref.
class _TileFadeIn extends StatelessWidget {
  const _TileFadeIn({required this.delayMs, required this.child});

  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.decelerate,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
