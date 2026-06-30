// Kingdom Heir — Favorites Strip (smart feature)
//
// A horizontal strip of "pinned" features the user can rearrange. Each
// pill is a tappable chip with icon + label. The strip lives near the
// top of the More screen so pinned items are always one tap away.
//
// State:
//   • The strip watches `moreFavoritesProvider` for the order.
//   • Tapping a pill routes to the feature; long-press is reserved for
//     future reorder UI (Riverpod already supports reorder).
//
// Layout note: the strip uses a horizontal `ListView.separated` wrapped
// in a height-bounded `SizedBox` inside the host's `SliverToBoxAdapter`.
// It is intentionally **not** a nested vertical scrollable — the only
// vertical scroller in the screen is the root `CustomScrollView`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/providers/more_providers.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_catalog.dart';

class FavoritesStrip extends ConsumerWidget {
  const FavoritesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(moreFavoritesProvider);

    return favsAsync.when(
      loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      error: (_, __) => Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error, size: 20,),
                const SizedBox(height: 4),
                Text(
                  'Could not load favorites.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      data: (favorites) {
        if (favorites.ids.isEmpty) {
          return const _EmptyFavorites();
        }
        return _FavoritesRow(ids: favorites.ids);
      },
    );
  }
}

class _FavoritesRow extends StatelessWidget {
  const _FavoritesRow({required this.ids});
  final List<MoreFeature> ids;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = layoutBandFromWidth(constraints.maxWidth);
        final maxVisible = switch (band) {
          LayoutBand.xs => 4,
          LayoutBand.sm => 4,
          LayoutBand.md => 5,
          LayoutBand.lg => 6,
          LayoutBand.xl => 7,
          LayoutBand.xxl => 8,
        };
        final shown = ids.take(maxVisible).toList();
        final overflow = ids.length - shown.length;

        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            itemCount: shown.length + (overflow > 0 ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(width: insets.sm),
            itemBuilder: (context, i) {
              if (i == shown.length) {
                return _OverflowChip(count: overflow);
              }
              final f = shown[i];
              // Self-contained opacity + Y-translate fade-in. Replaces
              // flutter_animate to avoid the Builder that crashed
              // RenderBox.size inside SliverToBoxAdapter.
              return _PillFadeIn(
                delayMs: 40 * i,
                child: _FavoritePill(feature: f),
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoritePill extends StatelessWidget {
  const _FavoritePill({required this.feature});
  final MoreFeature feature;

  @override
  Widget build(BuildContext context) {
    final spec = FeatureCatalog.of(feature);
    final palette = AccentPalette.of(spec.accent, isDark: false);
    final insets = Insets.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.goToFeature(feature),
        child: Container(
          width: 84,
          padding: EdgeInsets.symmetric(
            horizontal: insets.sm,
            vertical: insets.sm,
          ),
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: palette.border, width: 0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.fg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(spec.icon, color: palette.fg, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                spec.feature.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: palette.fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, 0),
      child: const AppEmptyState(
        isCompact: true,
        icon: Icons.push_pin_outlined,
        title: 'Pin your favorites',
        description:
            'Tap the pin on any feature to bring it to the top of this list.',
      ),
    );
  }
}

/// Self-contained opacity + Y-translate fade-in for a single favorite
/// pill. Replaces `flutter_animate`'s chain to keep the SliverToBoxAdapter
/// measurement path free of internal `Builder` widgets.
class _PillFadeIn extends StatelessWidget {
  const _PillFadeIn({required this.delayMs, required this.child});

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
            offset: Offset(0, (1 - value) * 8),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
