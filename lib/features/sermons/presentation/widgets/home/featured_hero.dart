// Kingdom Heir — Featured Hero (Sermon Home)
//
// Cinematic 280-320 dp hero with full-bleed thumbnail, dark gradient
// overlay, gold FEATURED pill, sermon title, speaker + series + duration
// row, and a primary "Watch now" CTA.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class FeaturedHero extends StatelessWidget {
  const FeaturedHero({
    required this.sermon,
    required this.onWatch,
    required this.height,
    super.key,
  });

  final Sermon sermon;
  final VoidCallback onWatch;
  final double height;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail / gradient fallback
            Positioned.fill(
              child: SermonThumbnail(
                thumbnailUrl: sermon.thumbnailUrl,
                title: sermon.title,
                borderRadius: BorderRadius.zero,
              ),
            ),
            // Dark gradient overlay for legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.navy.withValues(alpha: 0.55),
                    AppColors.navy.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      'FEATURED',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.3, end: 0),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    sermon.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  )
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${sermon.speakerName} · ${sermon.seriesName} · ${sermon.durationLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate(delay: 140.ms).fadeIn(duration: 500.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onWatch,
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: Text(AppLocalizations.of(context)!.watchNow),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.ink,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: onWatch,
                        icon: const Icon(Icons.headphones_rounded, size: 18),
                        label: Text(AppLocalizations.of(context)!.audio),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warmWhite,
                          side: const BorderSide(color: AppColors.warmWhite),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                            horizontal: AppSpacing.lg,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
