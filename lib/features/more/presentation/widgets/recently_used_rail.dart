// Kingdom Heir — Recently Used rail (smart feature)
//
// A horizontal scrolling rail of the 3 most recently used features,
// rendered as glassy progress cards. The rail sits just below the
// profile hero so users can resume their journey with one tap.
//
// Layout:
//   • Horizontal `ListView.separated` wrapped in a height-bounded
//     `SizedBox` and then in a `SliverToBoxAdapter` from the host screen.
//     The vertical axis is fully bounded by the `SizedBox`, so this is
//     **not** a nested scrollable in the vertical sense — the only
//     vertical scroller is the screen-level `CustomScrollView`.
//   • Card width derived from LayoutBuilder — never hardcoded
//   • Empty state: a single, full-width "Nothing yet" card with a CTA
//
// Animation:
//   • Per-card opacity + X-translate fade-in via a self-contained
//     `TweenAnimationBuilder` (60ms stagger). Replaces flutter_animate
//     whose internal Builder crashed inside SliverToBoxAdapter.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_catalog.dart';

class RecentlyUsedRail extends StatelessWidget {
  const RecentlyUsedRail({required this.items, super.key});

  final List<RecentItem> items;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, 0),
        child: _EmptyRecentCard(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Card width depends on band — never a hardcoded number.
        final band = layoutBandFromWidth(constraints.maxWidth);
        final cardWidth = switch (band) {
          LayoutBand.xs => constraints.maxWidth * 0.78,
          LayoutBand.sm => constraints.maxWidth * 0.72,
          LayoutBand.md => constraints.maxWidth * 0.62,
          LayoutBand.lg => constraints.maxWidth * 0.45,
          LayoutBand.xl => constraints.maxWidth * 0.32,
          LayoutBand.xxl => constraints.maxWidth * 0.28,
        };

        return SizedBox(
          height: 132 + insets.md,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, 0),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: insets.sm),
            itemBuilder: (context, i) {
              final item = items[i];
              return SizedBox(
                width: cardWidth,
                // Self-contained opacity+translate fade-in — no
                // flutter_animate Builder, which can interfere with
                // the surrounding LayoutBuilder / SliverToBoxAdapter.
                child: _RailFadeIn(
                  delayMs: i * 60,
                  child: _RecentCard(item: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item});
  final RecentItem item;

  @override
  Widget build(BuildContext context) {
    final spec = FeatureCatalog.of(item.feature);
    final palette = AccentPalette.of(
      spec.accent,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
    final insets = Insets.of(context);
    final surface = Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.goToFeature(item.feature),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: EdgeInsets.all(insets.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palette.bg,
                Color.alphaBlend(
                  surface.withValues(alpha: 0.55),
                  palette.bg,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: palette.border, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: palette.fg.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: palette.fg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(spec.icon, color: palette.fg, size: 18),
                  ),
                  SizedBox(width: insets.xs),
                  Expanded(
                    child: Text(
                      'CONTINUE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.fg.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    _relative(item.usedAt),
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: palette.fg.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: insets.xs),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: palette.fg,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: palette.fg.withValues(alpha: 0.7),
                ),
              ),
              // Use a `SizedBox(height: 8)` spacer in place of `Spacer`.
              // `Spacer` requires a flex parent to give it real space,
              // and a `Column(mainAxisSize: MainAxisSize.min)` plus the
              // height-bounded `SizedBox` host can interact badly with
              // flutter_animate's `LayoutBuilder` wrappers, producing a
              // `RenderBox.size` null-deref. A fixed gap is layout-stable
              // and always returns a valid size.
              const SizedBox(height: 8),
              // Safe handling: never use `!` here. The `progress` field
              // is nullable; we already checked `item.progress != null`
              // before calling _ProgressBar with the value. We pass it
              // through a local non-null binding so even if a hot-reload
              // or async update somehow makes it null between the check
              // and the read, we still get a defined layout.
              Builder(
                builder: (context) {
                  final p = item.progress;
                  if (p == null) return const SizedBox.shrink();
                  return _ProgressBar(value: p);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(when);
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 4,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            AnimatedContainer(
              duration: AppMotion.emphasized,
              curve: AppMotion.decelerate,
              height: 4,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.history_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          SizedBox(width: insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No recent activity yet',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: insets.xxxs),
                Text(
                  'Features you open will appear here so you can jump back in.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Self-contained opacity + X-translate fade-in. Replaces
/// `flutter_animate`'s `.animate().fadeIn().slideX()` chain, whose
/// internal `Builder` interacted badly with `SliverToBoxAdapter`.
class _RailFadeIn extends StatelessWidget {
  const _RailFadeIn({required this.delayMs, required this.child});

  final int delayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.decelerate,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset((1 - value) * 12, 0),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
