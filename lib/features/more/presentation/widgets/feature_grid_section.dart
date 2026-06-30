// Kingdom Heir — Feature Grid Section
//
// Shared section widget for Journey / Community / Service / Resources.
// Each section is a `ResponsiveSectionHeader` + an adaptive grid of
// `FeatureTile` widgets.
//
// Layout strategy:
//   • The grid uses a fixed cross-axis count derived from [LayoutBand]
//     so a 320 dp phone gets 3 columns and a tablet gets 4.
//   • Tile height is tied to tile width via `childAspectRatio` so the
//     grid stays balanced regardless of screen size.
//   • On `xl`/`xxl` bands we cap at 5 columns to keep tile labels
//     readable; we never use a 6-column grid on phones.
//
// Safety: per-tile entrance uses a self-contained `TweenAnimationBuilder`
// fade-in rather than `flutter_animate`'s chain. `flutter_animate` mounts
// an internal `Builder` that interacted badly with `LayoutBuilder`
// widgets inside `SliverToBoxAdapter`, producing a
// `RenderViewport → SliverToBoxAdapter → RenderBox.size` null-deref.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_tile.dart';

class FeatureGridSection extends StatelessWidget {
  const FeatureGridSection({
    required this.title,
    required this.features,
    super.key,
    this.subtitle,
    this.icon,
    this.compactTiles = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<MoreFeature> features;

  /// Hide taglines on tiles to fit narrow rows.
  final bool compactTiles;

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveSectionHeader(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final band = layoutBandFromWidth(constraints.maxWidth);
            final columns = featureColumnsFor(band);
            final insets = Insets.of(context);
            final spacing = insets.sm;

            // Aspect ratio: phone tiles are slightly taller than wide to
            // fit a 2-line label; tablet tiles are roughly square.
            final aspect = switch (band) {
              LayoutBand.xs => 0.92,
              LayoutBand.sm => 0.90,
              LayoutBand.md => 0.92,
              LayoutBand.lg => 1.00,
              LayoutBand.xl => 1.05,
              LayoutBand.xxl => 1.08,
            };

            return Padding(
              padding: EdgeInsets.fromLTRB(
                insets.lg,
                insets.xs,
                insets.lg,
                insets.lg,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: aspect,
                ),
                itemBuilder: (context, i) {
                  final f = features[i];
                  return _TileFadeIn(
                    delayMs: 30 * i,
                    child: FeatureTileWidget(feature: f, compact: compactTiles),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Self-contained opacity + translate fade-in used for each grid tile.
/// Avoids `flutter_animate`'s internal `Builder` which crashed with
/// `RenderBox.size` inside `SliverToBoxAdapter`.
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
