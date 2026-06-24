// Kingdom Heir — More (Kingdom Center) Domain Models
//
// Pure value types for the redesigned "More" screen. The screen is
// organized as eight discrete sections — each section consumes a different
// subset of these models. The data layer maps Supabase/JSON to these
// shapes; the presentation layer renders them.
//
// All models are `const`-constructible and `==`-stable so Riverpod
// selectors can short-circuit rebuilds.

import 'package:flutter/foundation.dart';

/// The set of features the More screen exposes. Every feature is identified
/// by an enum so we can:
//   • Serialize favorites / recents via `name`
///   • Look up the route, icon, and accent color in one place
///   • Add new features without touching call-sites
enum MoreFeature {
  // My Journey (high-value spiritual content)
  bible,
  devotionals,
  prayer,
  sermons,
  podcasts,

  // Community
  groups,
  members,
  testimonies,
  prayerWall,
  news,

  // Kingdom Service
  volunteers,
  leadership,
  challenges,
  ministryAssignments,

  // Kingdom Giving
  give,
  givingHistory,
  campaigns,

  // Family & Events
  events,
  eventsCalendar,
  kids,

  // Resources
  bookstore,
  learning,
  downloads,

  // Account
  myProfile,
  language,
  notifications,
  settings,
}

extension MoreFeatureX on MoreFeature {
  String get label {
    switch (this) {
      // Journey
      case MoreFeature.bible:
        return 'Bible';
      case MoreFeature.devotionals:
        return 'Devotionals';
      case MoreFeature.prayer:
        return 'Prayer';
      case MoreFeature.sermons:
        return 'Sermons';
      case MoreFeature.podcasts:
        return 'Podcasts';
      // Community
      case MoreFeature.groups:
        return 'Groups';
      case MoreFeature.members:
        return 'Members';
      case MoreFeature.testimonies:
        return 'Testimonies';
      case MoreFeature.prayerWall:
        return 'Prayer Wall';
      case MoreFeature.news:
        return 'News';
      // Service
      case MoreFeature.volunteers:
        return 'Volunteer';
      case MoreFeature.leadership:
        return 'Leadership';
      case MoreFeature.challenges:
        return 'Challenges';
      case MoreFeature.ministryAssignments:
        return 'Assignments';
      // Giving
      case MoreFeature.give:
        return 'Give';
      case MoreFeature.givingHistory:
        return 'History';
      case MoreFeature.campaigns:
        return 'Campaigns';
      // Family
      case MoreFeature.events:
        return 'Events';
      case MoreFeature.eventsCalendar:
        return 'Calendar';
      case MoreFeature.kids:
        return 'Kids';
      // Resources
      case MoreFeature.bookstore:
        return 'Bookstore';
      case MoreFeature.learning:
        return 'Learning';
      case MoreFeature.downloads:
        return 'Downloads';
      // Account
      case MoreFeature.myProfile:
        return 'My Profile';
      case MoreFeature.language:
        return 'Language';
      case MoreFeature.notifications:
        return 'Notifications';
      case MoreFeature.settings:
        return 'Settings';
    }
  }

  /// Short helper text shown beneath the label in journey cards.
  String? get tagline {
    switch (this) {
      case MoreFeature.bible:
        return 'Read & study';
      case MoreFeature.devotionals:
        return 'Daily reflections';
      case MoreFeature.prayer:
        return 'Pray & intercede';
      case MoreFeature.sermons:
        return 'Watch & grow';
      case MoreFeature.podcasts:
        return 'Listen anytime';
      case MoreFeature.give:
        return 'Tithe & offering';
      case MoreFeature.givingHistory:
        return 'Your generosity';
      case MoreFeature.campaigns:
        return 'Active campaigns';
      // ignore: no_default_cases
      default:
        return null;
    }
  }
}

/// A user's favorite features (order matters — first is most-pinned).
@immutable
class FavoriteFeatures {
  const FavoriteFeatures(this.ids);
  final List<MoreFeature> ids;
  bool contains(MoreFeature f) => ids.contains(f);
}

/// Visual accent bucket for a feature — picks a color family and icon
/// background tint. Designed so all journey/community/service tiles share
/// a calm gold/navy/sky palette and don't compete with each other.
enum FeatureAccent {
  gold, // primary, devotional / stewardship
  navy, // leadership / account
  sky, // events / news
  mint, // prayer / community
  rose, // testimonies / family
  violet, // groups / leadership path
}

/// Lightweight visual spec for a feature tile.
@immutable
class FeatureTileSpec {
  const FeatureTileSpec({
    required this.feature,
    required this.route,
    required this.iconKey,
    required this.accent,
    this.progress, // 0..1; non-null enables a progress chip
  });

  final MoreFeature feature;
  final String route;
  final String iconKey; // resolved by icon helper
  final FeatureAccent accent;
  final double? progress;
}

/// A "recently used" feature entry. The screen shows the 3 most-recent ones
/// as a "Continue" rail at the top.
@immutable
class RecentItem {
  const RecentItem({
    required this.feature,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.usedAt,
    this.progress,
  });

  final MoreFeature feature;
  final String label;
  final String subtitle;
  final String route;
  final DateTime usedAt;
  final double? progress;
}

/// Profile hero payload shown at the top of the More screen.
@immutable
class MoreProfileHero {
  const MoreProfileHero({
    required this.displayName,
    required this.email,
    required this.roleLabel,
    required this.streakDays,
    required this.memberSinceLabel,
    this.avatarUrl,
  });

  final String displayName;
  final String email;
  final String roleLabel;
  final int streakDays;
  final String memberSinceLabel;
  final String? avatarUrl;
}

/// Giving summary shown inside the Kingdom Giving card.
@immutable
class MoreGivingSummary {
  const MoreGivingSummary({
    required this.monthLabel,
    required this.amountGiven,
    required this.goalAmount,
    required this.campaignTitle,
    required this.campaignRaised,
    required this.campaignGoal,
    required this.recentMonths,
  });

  final String monthLabel;
  final double amountGiven;
  final double goalAmount;
  final String campaignTitle;
  final double campaignRaised;
  final double campaignGoal;

  /// Last 6 months of giving (oldest → newest) for a tiny sparkline.
  final List<double> recentMonths;

  double get monthProgress =>
      goalAmount <= 0 ? 0 : (amountGiven / goalAmount).clamp(0.0, 1.0);
  double get campaignProgress =>
      campaignGoal <= 0 ? 0 : (campaignRaised / campaignGoal).clamp(0.0, 1.0);
}

/// Family & events payload — events, calendar, kids.
@immutable
class FamilyEvents {
  const FamilyEvents({
    required this.upcomingCount,
    required this.thisWeekCount,
    required this.kidsCheckedInToday,
    required this.nextEventLabel,
    required this.nextEventWhen,
  });

  final int upcomingCount;
  final int thisWeekCount;
  final int kidsCheckedInToday;
  final String nextEventLabel;
  final String nextEventWhen;
}

/// Aggregate payload returned by `MoreRepository.fetchAll`.
@immutable
class MoreData {
  const MoreData({
    required this.profile,
    required this.favorites,
    required this.recents,
    required this.giving,
    required this.familyEvents,
  });

  final MoreProfileHero profile;
  final FavoriteFeatures favorites;
  final List<RecentItem> recents;
  final MoreGivingSummary giving;
  final FamilyEvents familyEvents;
}
