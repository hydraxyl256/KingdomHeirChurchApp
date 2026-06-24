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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
                  return FeatureTileWidget(feature: f, compact: compactTiles)
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 320),
                        delay: Duration(milliseconds: 30 * i),
                      )
                      .slideY(begin: 0.04, end: 0);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
