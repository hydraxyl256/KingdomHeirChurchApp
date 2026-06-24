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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
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
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.library_books_rounded,
                    color: AppColors.goldDark,
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
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.goldDark,
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
                                child: FeatureTileWidget(feature: _features[i])
                                    .animate()
                                    .fadeIn(
                                      duration: const Duration(
                                        milliseconds: 320,
                                      ),
                                      delay: Duration(milliseconds: 40 * i),
                                    )
                                    .slideY(begin: 0.04, end: 0),
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
