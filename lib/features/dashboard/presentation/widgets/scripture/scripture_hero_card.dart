// Kingdom Heir — Section 2: Premium Scripture Hero Card
//
// The dashboard centerpiece. A swipeable PageView of 5 verses with the
// "today" verse anchored at index 0, soft mesh-glow background, and
// a 5-action row (bookmark, share, audio, reflect, favorite).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

/// Public-facing scripture hero. The widget receives the live
/// `ScriptureCard` for today, plus the wider roster for swipe-left.
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
    // If a roster is supplied, place today's verse first; otherwise fall
    // back to a single-page view.
    final pages = roster.isEmpty
        ? <ScriptureCard>[scripture]
        : <ScriptureCard>[
            scripture,
            ...roster.where((v) => v.reference != scripture.reference),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: _ScriptureSwipeStack(
        pages: pages,
        onBookmark: onBookmark,
        onShare: onShare,
        onAudio: onAudio,
        onReflect: onReflect,
        onFavorite: onFavorite,
        onVerseIndexChanged: onVerseIndexChanged,
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

class _ScriptureSwipeStack extends StatefulWidget {
  const _ScriptureSwipeStack({
    required this.pages,
    this.onBookmark,
    this.onShare,
    this.onAudio,
    this.onReflect,
    this.onFavorite,
    this.onVerseIndexChanged,
  });

  final List<ScriptureCard> pages;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAudio;
  final VoidCallback? onReflect;
  final VoidCallback? onFavorite;
  final void Function(int)? onVerseIndexChanged;

  @override
  State<_ScriptureSwipeStack> createState() => _ScriptureSwipeStackState();
}

class _ScriptureSwipeStackState extends State<_ScriptureSwipeStack> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.pages.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _index = i);
              widget.onVerseIndexChanged?.call(i);
            },
            itemBuilder: (_, i) => _ScriptureCardBody(
              scripture: widget.pages[i],
              onBookmark: widget.onBookmark,
              onShare: widget.onShare,
              onAudio: widget.onAudio,
              onReflect: widget.onReflect,
              onFavorite: widget.onFavorite,
              isToday: i == 0,
            ),
          ),
        ),
        if (widget.pages.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          _PageDots(count: widget.pages.length, index: _index),
        ],
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.goldDark
                : AppColors.dividerLight,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _ScriptureCardBody extends StatelessWidget {
  const _ScriptureCardBody({
    required this.scripture,
    required this.isToday,
    this.onBookmark,
    this.onShare,
    this.onAudio,
    this.onReflect,
    this.onFavorite,
  });

  final ScriptureCard scripture;
  final bool isToday;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAudio;
  final VoidCallback? onReflect;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2A5E),
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
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
            child: _glowOrb(140, AppColors.gold.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: _glowOrb(100, Colors.white.withValues(alpha: 0.05)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconography.favorite,
                            color: AppColors.goldLight,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isToday
                                ? (AppLocalizations.of(context)
                                        ?.scriptureToday ??
                                    "TODAY'S VERSE")
                                : 'VERSE',
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
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        scripture.translation,
                        style:
                            AppTypography.textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Text(
                    '"${scripture.verseText}"',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.quote.copyWith(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '— ${scripture.reference}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 0.5,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Action row — 4 actions (Save, Share, Listen, Reflect).
                // Favorite is intentionally omitted at this width to
                // avoid horizontal overflow on 360dp viewports.
                Row(
                  children: [
                    Expanded(
                      child: _ScriptureAction(
                        icon: Iconography.bookmark,
                        label: AppLocalizations.of(context)
                                ?.scriptureSave ??
                            'Save',
                        color: scripture.isBookmarked
                            ? AppColors.goldLight
                            : Colors.white70,
                        onTap: onBookmark,
                      ),
                    ),
                    Expanded(
                      child: _ScriptureAction(
                        icon: Iconography.share,
                        label: AppLocalizations.of(context)
                                ?.scriptureShare ??
                            'Share',
                        onTap: onShare,
                      ),
                    ),
                    Expanded(
                      child: _ScriptureAction(
                        icon: Iconography.audio,
                        label: AppLocalizations.of(context)
                                ?.scriptureListen ??
                            'Listen',
                        onTap: onAudio,
                      ),
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

  Widget _glowOrb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
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
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
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
      ),
    );
  }
}

class _ReflectButton extends StatelessWidget {
  const _ReflectButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)?.scriptureReflect ?? 'Reflect',
      child: GestureDetector(
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
                Iconography.reflect,
                color: AppColors.ink,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)?.scriptureReflect ?? 'Reflect',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
