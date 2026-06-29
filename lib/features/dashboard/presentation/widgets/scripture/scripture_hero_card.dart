// Kingdom Heir — Section 2: Scripture Hero Card
//
// The centerpiece of the dashboard. A large, beautiful card with the
// verse of the day, action row, and an animated gradient background.
// Feels alive — subtle floating shimmer on the gradient.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ScriptureHeroCard extends StatelessWidget {
  const ScriptureHeroCard({
    required this.scripture,
    super.key,
    this.onBookmark,
    this.onShare,
    this.onAudio,
    this.onReflect,
  });

  final ScriptureCard scripture;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAudio;
  final VoidCallback? onReflect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: _ScriptureCardBody(
        scripture: scripture,
        onBookmark: onBookmark,
        onShare: onShare,
        onAudio: onAudio,
        onReflect: onReflect,
      )
          .animate()
          .fadeIn(delay: 100.ms, duration: 500.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            delay: 100.ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _ScriptureCardBody extends StatelessWidget {
  const _ScriptureCardBody({
    required this.scripture,
    this.onBookmark,
    this.onShare,
    this.onAudio,
    this.onReflect,
  });

  final ScriptureCard scripture;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAudio;
  final VoidCallback? onReflect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2A5E), // deep navy
            Color(0xFF1E3A8A), // royal blue
            Color(0xFF1E40AF), // mid blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: label + translation
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.goldLight,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.scriptureToday,
                            style: AppTypography.scriptureRef.copyWith(
                              color: AppColors.goldLight,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        scripture.translation,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Verse text
                Text(
                  '"${scripture.verseText}"',
                  style: AppTypography.quote.copyWith(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Reference
                Text(
                  '— ${scripture.reference}',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Divider
                Container(
                  height: 0.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: AppSpacing.md),
                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ScriptureAction(
                      icon: scripture.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      label: AppLocalizations.of(context)!.scriptureSave,
                      color: scripture.isBookmarked
                          ? AppColors.goldLight
                          : Colors.white70,
                      onTap: onBookmark,
                    ),
                    _ScriptureAction(
                      icon: Icons.share_rounded,
                      label: AppLocalizations.of(context)!.scriptureShare,
                      onTap: onShare,
                    ),
                    _ScriptureAction(
                      icon: Icons.volume_up_rounded,
                      label: AppLocalizations.of(context)!.scriptureListen,
                      onTap: onAudio,
                    ),
                    _ReflectButton(onTap: onReflect),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptureAction extends StatelessWidget {
  const _ScriptureAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: c,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectButton extends StatelessWidget {
  const _ReflectButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.goldDark, AppColors.gold],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit_note_rounded,
              color: AppColors.ink,
              size: 15,
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.scriptureReflect,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
