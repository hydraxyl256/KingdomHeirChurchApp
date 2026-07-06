// Kingdom Heir — FeatureTile (More screen)
//
// Universal square-ish tile used by every grid section on the More screen.
// Renders an icon block in the tile's accent color, then a label and an
// optional tagline. The tile is tappable and routes to the feature's page.
//
// Layout strategy:
//   • The tile is given a fixed slot by its grid (via `SliverGridDelegate`)
//     so its width is known — we then derive the icon block + radius from
//     that width with `LayoutBuilder`.
//   • On < 360 dp we trim the icon to 40 dp and hide the tagline to keep
//     every tile inside its slot.
//
// We avoid hardcoded widths. The gridDelegate controls the slot size and
// the tile adapts.

import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_catalog.dart';

class FeatureTileWidget extends StatelessWidget {
  const FeatureTileWidget({
    required this.feature,
    super.key,
    this.compact = false,
  });

  final MoreFeature feature;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spec = FeatureCatalog.of(feature);
    final palette = AccentPalette.of(
      spec.accent,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Derive icon block from the tile width. Hardcoded slots overflow
        // on 320 dp; derived sizes always fit.
        final tileWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 100.0;
        final iconBlockSize = tileWidth * 0.42;
        final clampedIcon = iconBlockSize.clamp(36.0, 56.0);

        return InkWell(
          onTap: () => context.goToFeature(feature),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            decoration: BoxDecoration(
              color: palette.bg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: palette.border, width: 0.6),
              boxShadow: [
                BoxShadow(
                  color: palette.fg.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: tileWidth * 0.07,
              vertical: tileWidth * 0.08,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: clampedIcon,
                  height: clampedIcon,
                  decoration: BoxDecoration(
                    color: palette.fg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    spec.icon,
                    color: palette.fg,
                    size: clampedIcon * 0.55,
                  ),
                ),
                SizedBox(height: tileWidth * 0.06),
                Text(
                  spec.feature.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: palette.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!compact) ...[
                  SizedBox(height: tileWidth * 0.02),
                  Text(
                    spec.feature.tagline ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: palette.fg.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Returns the number of grid columns a [LayoutBand] should use for the
/// 2:3 (tall) feature tile. Two columns on a 320 dp phone is already
/// tight; four is the upper bound so tiles stay readable on tablets.
int featureColumnsFor(LayoutBand band) => switch (band) {
      LayoutBand.xs => 3,
      LayoutBand.sm => 3,
      LayoutBand.md => 3,
      LayoutBand.lg => 4,
      LayoutBand.xl => 4,
      LayoutBand.xxl => 5,
    };
