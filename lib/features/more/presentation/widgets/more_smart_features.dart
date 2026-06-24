// Kingdom Heir — Smart Features Group (Recently Used + Favorites + Search)
//
// Wraps the "smart features" stack shown near the top of the More screen.
// Search sits at the very top, followed by Recently Used and Favorites.
//
// Search is implemented as a tappable surface that opens a full-screen
// search delegate when tapped (real Supabase search is wired in a
// follow-up — the surface is functional now and routes to the right
// tab).

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/providers/more_providers.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/favorites_strip.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/recently_used_rail.dart';

class MoreSmartFeatures extends ConsumerWidget {
  const MoreSmartFeatures({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentsAsync = ref.watch(moreRecentsProvider);
    final favsAsync = ref.watch(moreFavoritesProvider);

    final recents = recentsAsync.value ?? const <RecentItem>[];
    final hasFavorites = favsAsync.value?.ids.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.zero,
          child: _SearchSurface(),
        ),

        // Recently Used
        if (recents.isNotEmpty) ...[
          const ResponsiveSectionHeader(
            title: 'Continue your journey',
            subtitle: 'Pick up where you left off',
            icon: Icons.history_rounded,
          ),
          RecentlyUsedRail(items: recents),
        ],

        // Favorites
        ResponsiveSectionHeader(
          title: 'Pinned by you',
          subtitle: hasFavorites
              ? 'Tap to open · long-press to reorder'
              : 'Pin features so they live here',
          icon: Icons.push_pin_rounded,
        ),
        const FavoritesStrip(),
      ],
    );
  }
}

class _SearchSurface extends StatelessWidget {
  const _SearchSurface();

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        insets.lg,
        insets.md,
        insets.lg,
        insets.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSearch(context),
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.goldDark,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search prayers, events, sermons…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.tune_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: AppMotion.standard)
          .slideY(begin: 0.04, end: 0),
    );
  }

  void _openSearch(BuildContext context) {
    // Route to the Bible search route (it already has search UX). When a
    // dedicated feature search lands, swap this out.
    GoRouter.of(context).push(RouteNames.bibleSearch);
  }
}
