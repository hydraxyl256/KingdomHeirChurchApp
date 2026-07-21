import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class ScriptureHeroCard extends StatelessWidget {
  const ScriptureHeroCard({
    required this.scripture,
    super.key,
    this.roster = const <ScriptureCard>[],
    this.onBookmark,
    this.onShare,
    this.onAudio,
    this.onReflect,
    this.onFavorite,
    this.onVerseIndexChanged,
  });

  final ScriptureCard scripture;
  final List<ScriptureCard> roster;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAudio;
  final VoidCallback? onReflect;
  final VoidCallback? onFavorite;
  final void Function(int index)? onVerseIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppElevation.shadowFor(AppElevation.level2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (scripture.backgroundUrl != null)
                Image.asset(
                  scripture.backgroundUrl!,
                  fit: BoxFit.cover,
                )
              else
                Container(color: AppColors.surfaceVariantLight),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.surfaceLight.withValues(alpha: 0.9),
                      AppColors.surfaceLight.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'VERSE OF THE DAY',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.goldDark,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '"${scripture.verseText}"',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontFamily: 'Playfair Display',
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scripture.reference,
                              style:
                                  AppTypography.textTheme.titleMedium?.copyWith(
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              scripture.translation,
                              style:
                                  AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        // Listen Button
                        InkWell(
                          onTap: onAudio,
                          borderRadius: BorderRadius.circular(999),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight
                                      .withValues(alpha: 0.5),
                                  border: Border.all(
                                    color: AppColors.dividerLight,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 20,
                                      color: AppColors.goldDark,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Listen',
                                      style: AppTypography.textTheme.labelLarge
                                          ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
