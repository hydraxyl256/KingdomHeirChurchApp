// Kingdom Heir — Section 9: Premium Continue Watching Carousel
//
// Netflix-style horizontal carousel of in-progress sermons/podcasts.
// Each card features:
//   • 16:9 thumbnail with gradient overlay
//   • Phosphor kind badge (top-left)
//   • Downloaded badge (top-right, when isDownloaded)
//   • Resume / Watch CTA pill (gold)
//   • Bottom progress bar + duration
//
// Empty state shows a "No sermons watched yet" CTA.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class ContinueWatchingCarousel extends StatelessWidget {
  const ContinueWatchingCarousel({
    required this.cards,
    super.key,
    this.onCardTap,
    this.onSeeAll,
  });

  final List<WatchCard> cards;
  final void Function(WatchCard)? onCardTap;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Iconography.sermon,
                  color: AppColors.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Continue Watching',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'See all',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 350.ms),
        if (cards.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.goldContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconography.sermon,
                    color: AppColors.goldDark,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No sermons watched yet — tap “See all” to browse.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _WatchCard(
                  card: cards[index],
                  index: index,
                  onTap: () => onCardTap?.call(cards[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({
    required this.card,
    required this.index,
    this.onTap,
  });

  final WatchCard card;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSermon = card.kind == WatchKind.sermon;
    final cta = card.progress > 0 ? 'Resume' : 'Watch';
    return Semantics(
      button: true,
      label: '${card.title}, $cta',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 168,
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: AppColors.navyMid,
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Thumbnail / gradient background
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientForKind(card.kind),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Dark overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xDD0F172A),
                      ],
                      stops: [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              // Kind badge — top-left
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSermon ? Iconography.sermon : Iconography.audio,
                        color: Colors.white70,
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isSermon ? 'Sermon' : 'Podcast',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Downloaded badge — top-right
              if (card.isDownloaded)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.goldDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconography.download,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              // Play circle (center)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Iconography.live,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              // Bottom info + progress
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.title,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              card.speakerName.isNotEmpty
                                  ? card.speakerName
                                  : (card.durationLabel ?? ''),
                              style: AppTypography.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (card.durationLabel != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              card.durationLabel!,
                              style: AppTypography.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.white70,
                                fontSize: 10,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: card.progress,
                          minHeight: 3,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
              delay: Duration(milliseconds: 620 + index * 60),
              duration: 350.ms,
            ),
      ),
    );
  }

  List<Color> _gradientForKind(WatchKind k) => switch (k) {
        WatchKind.sermon => [
            const Color(0xFF1E3A8A),
            const Color(0xFF1E40AF),
          ],
        WatchKind.podcast => [
            const Color(0xFF7C3AED),
            const Color(0xFF6D28D9),
          ],
      };
}
