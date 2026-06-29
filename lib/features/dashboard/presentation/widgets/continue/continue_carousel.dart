// Kingdom Heir — Section 3: Continue Your Journey Carousel
//
// Personalized horizontal carousel of in-progress content.
// If empty, shows a "Start Your Journey" call-to-action card.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class ContinueCarousel extends StatelessWidget {
  const ContinueCarousel({
    required this.cards,
    super.key,
    this.onCardTap,
    this.onStartJourney,
  });

  final List<ContinueCard> cards;
  final void Function(ContinueCard)? onCardTap;
  final VoidCallback? onStartJourney;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            'Continue Your Journey',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
        if (cards.isEmpty)
          _StartJourneyCard(onTap: onStartJourney)
        else
          SizedBox(
            height: 168,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _ContinueCard(
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

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.card,
    required this.index,
    this.onTap,
  });

  final ContinueCard card;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _kindStyle(card.kind);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 156,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Kind label
              Text(
                card.kindLabel.toUpperCase(),
                style: AppTypography.scriptureRef.copyWith(
                  color: color,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              // Title
              Text(
                card.title,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (card.durationLabel != null)
                    Text(
                      card.durationLabel!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: card.progress,
                      backgroundColor: AppColors.dividerLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 220 + index * 60),
            duration: 350.ms,
            curve: Curves.easeOut,
          )
          .slideX(
            begin: 0.1,
            end: 0,
            delay: Duration(milliseconds: 220 + index * 60),
            duration: 350.ms,
          ),
    );
  }

  (Color, IconData) _kindStyle(ContinueKind kind) => switch (kind) {
        ContinueKind.sermon => (AppColors.navyAccent, Icons.play_circle_rounded),
        ContinueKind.biblePlan => (AppColors.goldDark, Icons.menu_book_rounded),
        ContinueKind.devotional =>
          (AppColors.success, Icons.volunteer_activism_rounded),
        ContinueKind.podcast => (AppColors.tertiary, Icons.podcasts_rounded),
        ContinueKind.prayerChallenge =>
          (const Color(0xFF7C3AED), Icons.self_improvement_rounded),
      };
}

class _StartJourneyCard extends StatelessWidget {
  const _StartJourneyCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.goldContainer,
                AppColors.warmWhite,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.ink,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Your Journey',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Explore Bible plans, sermons, and devotionals.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.goldDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
