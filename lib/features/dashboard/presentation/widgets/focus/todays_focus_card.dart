// Kingdom Heir — Today's Spiritual Focus (SECTION 2)
//
// Single featured card with:
//   • Verse of the day (Playfair italic, large)
//   • Reference (uppercase label)
//   • Devotional title + subtitle
//   • Prayer focus line
//   • "Continue" primary CTA
//
// Layout:
//   • < 480 dp: stacked — icon block on top, text below
//   • ≥ 480 dp: side-by-side — icon block on the left, text on the right
//
// Uses AppCard (featured variant) so the gold gradient border wraps the
// surface and the gold shadow lifts it off the page.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_card.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';

class TodaysFocusCard extends StatelessWidget {
  const TodaysFocusCard({
    required this.data,
    super.key,
    this.onContinue,
  });

  final DailyFocus data;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: insets.lg),
      child: AppCard(
        variant: AppCardVariant.featured,
        padding: EdgeInsets.zero,
        onTap: onContinue,
        borderRadius: AppRadius.xxl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSideBySide = layoutBandFromWidth(constraints.maxWidth)
                .isAtLeast(LayoutBand.md);

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VERSE OF THE DAY',
                  style: AppTypography.scriptureRef.copyWith(
                    color: AppColors.goldDark,
                  ),
                ),
                SizedBox(height: insets.sm),
                Text(
                  '“${data.verseText}”',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.quote.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: insets.xs),
                Text(
                  data.verseReference,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: insets.md),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
                SizedBox(height: insets.md),
                Text(
                  data.devotionalTitle,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: insets.xxs),
                Text(
                  data.devotionalSubtitle,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: insets.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: insets.md,
                    vertical: insets.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volunteer_activism_rounded,
                        size: 16,
                        color: AppColors.goldDark,
                      ),
                      SizedBox(width: insets.xs),
                      Flexible(
                        child: Text(
                          data.prayerFocus,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: insets.md),
                AppButton(
                  label: data.continueLabel,
                  icon: Icons.play_arrow_rounded,
                  onPressed: onContinue,
                  height: 48,
                ),
              ],
            );

            final iconBlock = Container(
              width: isSideBySide ? 96 : double.infinity,
              height: isSideBySide ? double.infinity : 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldDark,
                    AppColors.gold,
                    AppColors.goldLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: isSideBySide
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.xxl),
                        bottomLeft: Radius.circular(AppRadius.xxl),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.xxl),
                        topRight: Radius.circular(AppRadius.xxl),
                      ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmWhite.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.navy.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            );

            final body = isSideBySide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        iconBlock,
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(insets.lg),
                            child: content,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      iconBlock,
                      Padding(
                        padding: EdgeInsets.all(insets.lg),
                        child: content,
                      ),
                    ],
                  );

            return body
                .animate()
                .fadeIn(
                  duration: AppMotion.emphasized,
                  curve: AppMotion.decelerate,
                )
                .slideY(begin: 0.06, end: 0, duration: AppMotion.emphasized);
          },
        ),
      ),
    );
  }
}
