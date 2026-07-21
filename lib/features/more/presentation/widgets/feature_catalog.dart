// Kingdom Heir — More Feature Catalog
//
// Maps every [MoreFeature] enum value to its icon, accent color, and route.
// Kept separate from `more_models.dart` so the domain layer stays UI-free.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/features/more/domain/more_models.dart';

/// Visual + navigation spec for every [MoreFeature]. The widget tree looks
/// these up once via [FeatureCatalog.of] rather than carrying 30 switch
/// statements in the UI layer.
class FeatureSpec {
  const FeatureSpec({
    required this.feature,
    required this.icon,
    required this.accent,
    required this.route,
    this.opensDonationPage = false,
  });

  final MoreFeature feature;
  final IconData icon;
  final FeatureAccent accent;
  final String route;

  /// When true, tapping a tile for this feature should open the hosted
  /// donation page in the device's external browser (via
  /// `openDonationPage`) instead of pushing [route] onto the navigator.
  final bool opensDonationPage;
}

/// Single source of truth. Adding a new feature is a one-line change here.
class FeatureCatalog {
  const FeatureCatalog();

  static const Map<MoreFeature, FeatureSpec> _specs = {
    // ── Journey ────────────────────────────────────────────────────────────
    MoreFeature.bible: FeatureSpec(
      feature: MoreFeature.bible,
      icon: Icons.menu_book_rounded,
      accent: FeatureAccent.gold,
      route: RouteNames.bible,
    ),
    MoreFeature.devotionals: FeatureSpec(
      feature: MoreFeature.devotionals,
      icon: Icons.auto_stories_rounded,
      accent: FeatureAccent.gold,
      route: RouteNames.devotionals,
    ),
    MoreFeature.prayer: FeatureSpec(
      feature: MoreFeature.prayer,
      icon: Icons.self_improvement_rounded,
      accent: FeatureAccent.mint,
      route: RouteNames.prayerFeed,
    ),
    MoreFeature.sermons: FeatureSpec(
      feature: MoreFeature.sermons,
      icon: Icons.play_circle_rounded,
      accent: FeatureAccent.gold,
      route: RouteNames.sermons,
    ),
    MoreFeature.podcasts: FeatureSpec(
      feature: MoreFeature.podcasts,
      icon: Icons.podcasts_rounded,
      accent: FeatureAccent.violet,
      route: RouteNames.podcasts,
    ),

    // ── Community ──────────────────────────────────────────────────────────
    MoreFeature.groups: FeatureSpec(
      feature: MoreFeature.groups,
      icon: Icons.groups_2_rounded,
      accent: FeatureAccent.violet,
      route: RouteNames.groups,
    ),
    MoreFeature.members: FeatureSpec(
      feature: MoreFeature.members,
      icon: Icons.people_alt_rounded,
      accent: FeatureAccent.sky,
      route: RouteNames.members,
    ),
    MoreFeature.testimonies: FeatureSpec(
      feature: MoreFeature.testimonies,
      icon: Icons.record_voice_over_rounded,
      accent: FeatureAccent.rose,
      route: RouteNames.testimonies,
    ),
    MoreFeature.prayerWall: FeatureSpec(
      feature: MoreFeature.prayerWall,
      icon: Icons.volunteer_activism_rounded,
      accent: FeatureAccent.mint,
      route: RouteNames.prayerFeed,
    ),
    MoreFeature.news: FeatureSpec(
      feature: MoreFeature.news,
      icon: Icons.campaign_rounded,
      accent: FeatureAccent.sky,
      route: RouteNames.news,
    ),

    // ── Service ────────────────────────────────────────────────────────────
    MoreFeature.volunteers: FeatureSpec(
      feature: MoreFeature.volunteers,
      icon: Icons.handshake_rounded,
      accent: FeatureAccent.mint,
      route: RouteNames.volunteers,
    ),
    MoreFeature.leadership: FeatureSpec(
      feature: MoreFeature.leadership,
      icon: Icons.workspace_premium_rounded,
      accent: FeatureAccent.violet,
      route: RouteNames.leaderApplication,
    ),
    MoreFeature.challenges: FeatureSpec(
      feature: MoreFeature.challenges,
      icon: Icons.emoji_events_rounded,
      accent: FeatureAccent.gold,
      route: RouteNames.challenge,
    ),
    MoreFeature.ministryAssignments: FeatureSpec(
      feature: MoreFeature.ministryAssignments,
      icon: Icons.assignment_rounded,
      accent: FeatureAccent.navy,
      route: RouteNames.ministryAssignments,
    ),

    // ── Giving ─────────────────────────────────────────────────────────────
    MoreFeature.give: FeatureSpec(
      feature: MoreFeature.give,
      icon: Icons.volunteer_activism_rounded,
      accent: FeatureAccent.gold,
      route: RouteNames.giving,
      opensDonationPage: true,
    ),
    MoreFeature.campaigns: FeatureSpec(
      feature: MoreFeature.campaigns,
      icon: Icons.flag_rounded,
      accent: FeatureAccent.rose,
      route: RouteNames.giving,
      opensDonationPage: true,
    ),

    // ── Family / Events ────────────────────────────────────────────────────
    MoreFeature.events: FeatureSpec(
      feature: MoreFeature.events,
      icon: Icons.event_rounded,
      accent: FeatureAccent.sky,
      route: RouteNames.events,
    ),
    MoreFeature.eventsCalendar: FeatureSpec(
      feature: MoreFeature.eventsCalendar,
      icon: Icons.calendar_month_rounded,
      accent: FeatureAccent.sky,
      route: RouteNames.eventsCalendar,
    ),
    MoreFeature.kids: FeatureSpec(
      feature: MoreFeature.kids,
      icon: Icons.child_care_rounded,
      accent: FeatureAccent.rose,
      route: RouteNames.kids,
    ),

    // ── Resources ──────────────────────────────────────────────────────────
    MoreFeature.bookstore: FeatureSpec(
      feature: MoreFeature.bookstore,
      icon: Icons.storefront_rounded,
      accent: FeatureAccent.violet,
      route: RouteNames.bookstore,
    ),
    MoreFeature.learning: FeatureSpec(
      feature: MoreFeature.learning,
      icon: Icons.school_rounded,
      accent: FeatureAccent.violet,
      route: RouteNames.leaderResources,
    ),
    MoreFeature.downloads: FeatureSpec(
      feature: MoreFeature.downloads,
      icon: Icons.download_for_offline_rounded,
      accent: FeatureAccent.navy,
      route: RouteNames.sermons,
    ),

    // ── Account ────────────────────────────────────────────────────────────
    MoreFeature.myProfile: FeatureSpec(
      feature: MoreFeature.myProfile,
      icon: Icons.person_outline_rounded,
      accent: FeatureAccent.navy,
      route: RouteNames.myProfile,
    ),
    MoreFeature.language: FeatureSpec(
      feature: MoreFeature.language,
      icon: Icons.language_rounded,
      accent: FeatureAccent.sky,
      route: '/language',
    ),
    MoreFeature.notifications: FeatureSpec(
      feature: MoreFeature.notifications,
      icon: Icons.notifications_outlined,
      accent: FeatureAccent.gold,
      route: '/notifications',
    ),
    MoreFeature.settings: FeatureSpec(
      feature: MoreFeature.settings,
      icon: Icons.settings_rounded,
      accent: FeatureAccent.navy,
      route: RouteNames.settings,
    ),
  };

  /// Look up a spec by enum. Falls back to a neutral navy tile.
  static FeatureSpec of(MoreFeature f) =>
      _specs[f] ??
      const FeatureSpec(
        feature: MoreFeature.settings,
        icon: Icons.help_outline_rounded,
        accent: FeatureAccent.navy,
        route: RouteNames.home,
      );

  /// Specs grouped by their parent section.
  static const Map<MoreSection, List<MoreFeature>> sections = {
    MoreSection.journey: [
      MoreFeature.bible,
      MoreFeature.devotionals,
      MoreFeature.prayer,
      MoreFeature.sermons,
      MoreFeature.podcasts,
    ],
    MoreSection.community: [
      MoreFeature.groups,
      MoreFeature.members,
      MoreFeature.testimonies,
      MoreFeature.prayerWall,
      MoreFeature.news,
    ],
    MoreSection.service: [
      MoreFeature.volunteers,
      MoreFeature.leadership,
      MoreFeature.challenges,
      MoreFeature.ministryAssignments,
    ],
    MoreSection.resources: [
      MoreFeature.bookstore,
      MoreFeature.learning,
      MoreFeature.downloads,
    ],
  };
}

/// Logical sections for grouping in the UI.
enum MoreSection {
  journey,
  community,
  service,
  resources,
}

/// Map accent → color family. Mirrors the [FeatureAccent] tokens but
/// applies Material 3 tinting so light/dark mode both look balanced.
class AccentPalette {
  const AccentPalette._({
    required this.fg,
    required this.bg,
    required this.border,
  });

  final Color fg;
  final Color bg;
  final Color border;

  // ignore: prefer_constructors_over_static_methods
  static AccentPalette of(FeatureAccent a, {required bool isDark}) {
    switch (a) {
      case FeatureAccent.gold:
        return AccentPalette._(
          fg: isDark ? AppColors.goldLight : AppColors.goldDark,
          bg: isDark
              ? AppColors.goldContainer.withValues(alpha: 0.18)
              : AppColors.goldContainer,
          border: AppColors.gold.withValues(alpha: isDark ? 0.40 : 0.45),
        );
      case FeatureAccent.navy:
        return AccentPalette._(
          fg: isDark ? AppColors.navyLight : AppColors.navy,
          bg: isDark
              ? AppColors.navyAccent.withValues(alpha: 0.22)
              : const Color(0xFFDBEAFE),
          border: isDark
              ? AppColors.navyLight.withValues(alpha: 0.40)
              : AppColors.navyAccent.withValues(alpha: 0.30),
        );
      case FeatureAccent.sky:
        return AccentPalette._(
          fg: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
          bg: isDark
              ? const Color(0xFF0369A1).withValues(alpha: 0.22)
              : const Color(0xFFE0F2FE),
          border: const Color(0xFF38BDF8).withValues(alpha: 0.30),
        );
      case FeatureAccent.mint:
        return AccentPalette._(
          fg: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
          bg: isDark
              ? AppColors.success.withValues(alpha: 0.20)
              : const Color(0xFFDCFCE7),
          border: AppColors.success.withValues(alpha: 0.30),
        );
      case FeatureAccent.rose:
        return AccentPalette._(
          fg: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
          bg: isDark
              ? AppColors.error.withValues(alpha: 0.18)
              : const Color(0xFFFFE4E4),
          border: AppColors.error.withValues(alpha: 0.30),
        );
      case FeatureAccent.violet:
        return AccentPalette._(
          fg: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
          bg: isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.20)
              : const Color(0xFFEDE9FE),
          border: const Color(0xFF8B5CF6).withValues(alpha: 0.30),
        );
    }
  }
}

/// Convenience extension that wraps the `context.push` call.
extension MoreFeatureNav on BuildContext {
  void goToFeature(MoreFeature feature) {
    final spec = FeatureCatalog.of(feature);
    if (spec.opensDonationPage) {
      openDonationPage(this);
      return;
    }
    GoRouter.of(this).push(spec.route);
  }
}
