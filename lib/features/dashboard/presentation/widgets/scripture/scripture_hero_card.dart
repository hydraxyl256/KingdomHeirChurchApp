import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        aspectRatio: 4 / 4.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: AppElevation.shadowFor(AppElevation.level2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                scripture.backgroundUrl ?? 'assets/images/dashboard/verse_of_the_day_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.navy),
              ),

              // Gradient Overlay (Darkened for readability)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 1.0],
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
                    // VERSE OF THE DAY Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        'VERSE OF THE DAY',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Verse Text
                    Text(
                      '"${scripture.verseText}"',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.warmWhite,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          const Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Reference
                    Text(
                      scripture.reference,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Read Full Chapter Button
                        InkWell(
                          onTap: onReflect, // Or appropriate action
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      PhosphorIconsRegular.bookOpen,
                                      size: 18,
                                      color: AppColors.warmWhite,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Read Full Chapter',
                                      style: AppTypography.textTheme.labelMedium?.copyWith(
                                        color: AppColors.warmWhite,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                      ],
                    ),
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
