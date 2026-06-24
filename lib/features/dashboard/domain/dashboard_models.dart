// Kingdom Heir — Dashboard Domain Models
//
import 'package:flutter/foundation.dart';

// Pure value types. No Flutter, no Riverpod. The presentation layer maps these
// to widgets and the data layer maps them from Supabase/JSON. Every model is
// `const`-constructible and `==`-stable so Riverpod selectors can short-circuit
// rebuilds.

/// Time-of-day used to pick the greeting line on the personalized hero.
enum GreetingMoment { morning, afternoon, evening, night }

GreetingMoment resolveGreetingMoment(DateTime now) {
  final h = now.hour;
  if (h < 5) return GreetingMoment.night;
  if (h < 12) return GreetingMoment.morning;
  if (h < 17) return GreetingMoment.afternoon;
  if (h < 21) return GreetingMoment.evening;
  return GreetingMoment.night;
}

/// Personalized hero — greeting, name, streak, current season.
@immutable
class HeroGreeting {
  const HeroGreeting({
    required this.firstName,
    required this.streakDays,
    required this.seasonLabel,
    required this.moment,
    this.avatarUrl,
  });

  final String firstName;
  final int streakDays;
  final String seasonLabel;
  final GreetingMoment moment;
  final String? avatarUrl;

  String get greeting => switch (moment) {
        GreetingMoment.morning => 'Good Morning',
        GreetingMoment.afternoon => 'Good Afternoon',
        GreetingMoment.evening => 'Good Evening',
        GreetingMoment.night => 'Resting Well',
      };

  String get tagline => streakDays <= 1
      ? 'Continue growing in Christ today.'
      : 'You are on a $streakDays-day prayer journey.';
}

/// Today's featured scripture + devotional + prayer focus.
@immutable
class DailyFocus {
  const DailyFocus({
    required this.verseText,
    required this.verseReference,
    required this.devotionalTitle,
    required this.devotionalSubtitle,
    required this.prayerFocus,
    required this.continueLabel,
  });

  final String verseText;
  final String verseReference;
  final String devotionalTitle;
  final String devotionalSubtitle;
  final String prayerFocus;
  final String continueLabel;
}

/// A "continue where you left off" item — sermon / plan / devotional / podcast.
enum ContinueKind { sermon, biblePlan, devotional, podcast }

@immutable
class ContinueItem {
  const ContinueItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.thumbnailUrl,
  });

  final String id;
  final ContinueKind kind;
  final String title;
  final String subtitle;
  final double progress; // 0..1
  final String? thumbnailUrl;

  String get kindLabel => switch (kind) {
        ContinueKind.sermon => 'Sermon',
        ContinueKind.biblePlan => 'Bible Plan',
        ContinueKind.devotional => 'Devotional',
        ContinueKind.podcast => 'Podcast',
      };
}

/// Quick action — Pray / Give / Watch / Events / Groups / Bible / Testimonies / Serve.
enum QuickAction {
  pray,
  give,
  watch,
  events,
  groups,
  bible,
  testimonies,
  serve,
}

extension QuickActionX on QuickAction {
  String get label => switch (this) {
        QuickAction.pray => 'Pray',
        QuickAction.give => 'Give',
        QuickAction.watch => 'Watch',
        QuickAction.events => 'Events',
        QuickAction.groups => 'Groups',
        QuickAction.bible => 'Bible',
        QuickAction.testimonies => 'Testimonies',
        QuickAction.serve => 'Serve',
      };

  /// Material rounded icon for each action.
  // ignore: avoid_redundant_argument_values
  String get iconKey => name; // resolved by the widget
}

/// A single stat tile inside the Kingdom Impact section.
@immutable
class ImpactStat {
  const ImpactStat({
    required this.label,
    required this.value,
    required this.iconKey,
    this.deltaLabel,
  });

  final String label;
  final int value;
  final String iconKey; // icon lookup key resolved by the widget
  final String? deltaLabel; // e.g. "+12% MoM"
}

/// Live service right now.
@immutable
class LiveService {
  const LiveService({
    required this.title,
    required this.hostLabel,
    required this.startsAt,
    required this.viewerCount,
    required this.heroImageUrl,
    this.isLive = true,
  });

  final String title;
  final String hostLabel;
  final DateTime startsAt;
  final int viewerCount;
  final String heroImageUrl;
  final bool isLive;
}

/// Upcoming service (next scheduled).
@immutable
class UpcomingService {
  const UpcomingService({
    required this.title,
    required this.startsAt,
    required this.locationLabel,
  });

  final String title;
  final DateTime startsAt;
  final String locationLabel;
}

/// Financial Stewardship summary card.
@immutable
class GivingSummary {
  const GivingSummary({
    required this.monthLabel,
    required this.amountGiven,
    required this.goalAmount,
    required this.history,
    required this.presets,
    required this.campaignTitle,
    required this.campaignRaised,
    required this.campaignGoal,
  });

  final String monthLabel;
  final double amountGiven;
  final double goalAmount;

  /// Last 4 weekly totals (oldest → newest) for the sparkline-style strip.
  final List<double> history;

  /// Quick-give preset amounts (e.g. 10, 25, 50, 100).
  final List<double> presets;

  final String campaignTitle;
  final double campaignRaised;
  final double campaignGoal;

  double get progress =>
      goalAmount <= 0 ? 0 : (amountGiven / goalAmount).clamp(0, 1).toDouble();
  double get campaignProgress => campaignGoal <= 0
      ? 0
      : (campaignRaised / campaignGoal).clamp(0, 1).toDouble();
}

/// A community feed card — testimony / prayer / community win.
enum CommunityKind { testimony, prayerRequest, communityWin }

@immutable
class CommunityMoment {
  const CommunityMoment({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.authorName,
    required this.publishedAt,
    this.avatarUrl,
    this.reactionCount = 0,
  });

  final String id;
  final CommunityKind kind;
  final String title;
  final String body;
  final String authorName;
  final DateTime publishedAt;
  final String? avatarUrl;
  final int reactionCount;

  String get kindLabel => switch (kind) {
        CommunityKind.testimony => 'Testimony',
        CommunityKind.prayerRequest => 'Prayer Request',
        CommunityKind.communityWin => 'Community Win',
      };
}

/// Upcoming event shown in the carousel.
@immutable
class UpcomingEvent {
  const UpcomingEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.locationLabel,
    required this.iconKey,
    required this.accentIndex,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String locationLabel;
  final String iconKey;
  final int accentIndex; // 0..3 to pick an accent
}

/// Announcement card.
@immutable
class DashboardAnnouncement {
  const DashboardAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String body;
  final bool isPinned;
}

/// Rotating inspirational quote.
@immutable
class InspirationQuote {
  const InspirationQuote({
    required this.text,
    required this.author,
  });

  final String text;
  final String author;
}

/// Aggregate dashboard payload returned by `DashboardRepository.fetch`.
@immutable
class DashboardData {
  const DashboardData({
    required this.hero,
    required this.dailyFocus,
    required this.continueItems,
    required this.liveService,
    required this.upcomingService,
    required this.impact,
    required this.giving,
    required this.community,
    required this.events,
    required this.announcements,
    required this.inspirations,
  });

  final HeroGreeting hero;
  final DailyFocus dailyFocus;
  final List<ContinueItem> continueItems;
  final LiveService? liveService;
  final UpcomingService? upcomingService;
  final List<ImpactStat> impact;
  final GivingSummary giving;
  final List<CommunityMoment> community;
  final List<UpcomingEvent> events;
  final List<DashboardAnnouncement> announcements;
  final List<InspirationQuote> inspirations;
}
