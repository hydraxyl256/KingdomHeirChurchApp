// Kingdom Heir — More (Kingdom Center) screen
//
// Premium, sliver-based rewrite of the legacy "More" hub. The screen
// loads section data in parallel via per-section FutureProviders (see
// `more_providers.dart`) and composes the result inside a single
// `CustomScrollView` (the one and only scrollable in the tree). There
// are no nested `ListView`s, no nested `CustomScrollView`s, no nested
// `GridView`s, and no hardcoded widths/heights or fixed grids.
//
// Sections, top → bottom:
//   1.  Personalized profile hero (frosted GlassCard)
//   2.  Smart features: search surface + Continue rail + Pinned favorites
//   3.  My Journey grid
//   4.  Community grid
//   5.  Kingdom Giving premium card
//   6.  Family & Events card
//   7.  Kingdom Service grid
//   8.  Resources (expandable)
//   9.  Account settings list
//
// Loading: shimmer skeleton mirrors the final layout proportions.
// Error: friendly error widget with retry that invalidates the providers.
//
// Architecture note: every body branch returns a `List<Widget>` of slivers
// (never a single `Widget` child). This is intentional — wrapping a
// `Column`, `ListView` (without `shrinkWrap`), or `Center` directly in a
// `SliverToBoxAdapter` gives the child **unbounded vertical constraints**
// and immediately throws a "Vertical viewport was given unbounded height"
// / "RenderFlex children have non-zero flex but incoming height constraints
// are unbounded" layout error, leaving the screen blank. By emitting
// `SliverToBoxAdapter(child: ...)` **per section** (or by using
// `SliverFillRemaining` for the error state) each child gets a fully
// bounded context.
//
// Non-vertical child scrollables are allowed — the per-section widgets
// (e.g. `RecentlyUsedRail`, `FavoritesStrip`) use a HORIZONTAL
// `ListView.separated` inside a height-bounded `SizedBox`, which is safe
// because the vertical axis is fully bounded by the parent. If you add a
// new section, keep this invariant: do NOT introduce a vertical
// `ListView`/`GridView`/`CustomScrollView` as a direct child of
// `SliverToBoxAdapter` — use another `SliverList`/`SliverGrid` or
// restructure the section so it fits in a single bounded box.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';
import 'package:kingdom_heir/features/more/presentation/providers/more_providers.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/account_section.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/family_events_card.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_catalog.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/feature_grid_section.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/kingdom_giving_card.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/more_screen_skeleton.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/more_smart_features.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/profile_hero.dart';
import 'package:kingdom_heir/features/more/presentation/widgets/resources_expandable_section.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(moreDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // The body is always a `_ScreenChrome` whose `slivers` list is
      // supplied by the async branch. The `CustomScrollView` inside
      // `_ScreenChrome` gives the children *bounded* vertical
      // constraints (via `SliverToBoxAdapter` / `SliverFillRemaining`),
      // so a plain `Column` or `ListView` can lay out normally.
      body: _ScreenChrome(
        slivers: asyncData.when(
          loading: _loadingSlivers,
          error: (err, _) => _errorSlivers(context, ref, err),
          data: (data) => _dataSlivers(context, data),
        ),
      ),
    );
  }

  // ── LOADING ────────────────────────────────────────────────────────
  // One `SliverToBoxAdapter` per skeleton section — never a bare
  // `ListView` inside a sliver (would throw on unbounded height).
  List<Widget> _loadingSlivers() => const [
        SliverToBoxAdapter(child: MoreScreenSkeleton()),
      ];

  // ── ERROR ──────────────────────────────────────────────────────────
  // `SliverFillRemaining(hasScrollBody: false)` gives the `Center` a
  // bounded height equal to whatever the SliverAppBar didn't consume.
  List<Widget> _errorSlivers(BuildContext context, WidgetRef ref, Object err) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: AppErrorWidget(
            message: "Couldn't load the Kingdom Center. $err",
            onRetry: () => ref.invalidate(moreDataProvider),
          ),
        ),
      ),
    ];
  }

  // ── DATA ───────────────────────────────────────────────────────────
  // Each section is its own `SliverToBoxAdapter`. The staggered entrance
  // animation is applied per-section so each child still gets a
  // bounded context and can `mainAxisSize: MainAxisSize.max` if needed.
  List<Widget> _dataSlivers(BuildContext context, MoreData data) {
    final insets = Insets.of(context);

    // Local helper — every section goes through the same animation +
    // sliver wrapping. Centralised so adding/removing sections is a
    // one-line change and every entry point handles motion consistently.
    Widget section(Widget child) {
      return SliverToBoxAdapter(
        child: child
            .animate(delay: const Duration(milliseconds: 40))
            .fadeIn(duration: AppMotion.emphasized, curve: AppMotion.decelerate)
            .slideY(begin: 0.04, end: 0),
      );
    }

    return [
      // SECTION 1 — Profile hero
      section(ProfileHeroSection(hero: data.profile)),

      // SECTION 2 — Smart features (search / continue / pinned)
      section(const MoreSmartFeatures()),

      section(SizedBox(height: insets.md)),

      // SECTION 3 — My Journey
      section(
        FeatureGridSection(
          title: 'My Journey',
          subtitle: 'Daily spiritual practices',
          icon: Icons.auto_awesome_rounded,
          features: FeatureCatalog.sections[MoreSection.journey]!,
        ),
      ),

      // SECTION 4 — Community
      section(
        FeatureGridSection(
          title: 'Community',
          subtitle: 'Connect and grow together',
          icon: Icons.groups_rounded,
          features: FeatureCatalog.sections[MoreSection.community]!,
        ),
      ),

      // SECTION 5 — Kingdom Giving
      section(KingdomGivingCard(summary: data.giving)),

      // SECTION 6 — Family & Events
      section(FamilyEventsCard(data: data.familyEvents)),

      // SECTION 7 — Kingdom Service
      section(
        FeatureGridSection(
          title: 'Kingdom Service',
          subtitle: 'Volunteer, lead, and grow',
          icon: Icons.handshake_rounded,
          features: FeatureCatalog.sections[MoreSection.service]!,
        ),
      ),

      // SECTION 8 — Resources (expandable)
      section(const ResourcesExpandableSection()),

      // SECTION 9 — Account
      section(const AccountSection()),

      section(SizedBox(height: insets.xl)),
    ];
  }
}

/// Wraps the screen in the SliverAppBar chrome and renders the body
/// slivers. Centralised so loading, error, and content branches all
/// share the same header.
class _ScreenChrome extends StatelessWidget {
  const _ScreenChrome({required this.slivers});

  /// Body slivers — one per visual section. Already slivers, so the
  /// `CustomScrollView` can lay them out with bounded constraints.
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insets = Insets.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          centerTitle: false,
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          expandedHeight: 96,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.fromLTRB(
              insets.lg,
              0,
              insets.lg,
              14,
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.diamond_rounded,
                    color: AppColors.ink,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Kingdom Center',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.warmWhite : AppColors.navy,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.navy, AppColors.backgroundDark]
                      : [
                          AppColors.warmWhite,
                          AppColors.backgroundLight,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        // Caller-supplied body slivers. Each one is itself a sliver, so
        // the `CustomScrollView` can give them real (bounded) constraints
        // and they can be `Column`s, `ListView`s, or `Center`s as needed.
        ...slivers,
        // Breathing room above the bottom navigation bar.
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
