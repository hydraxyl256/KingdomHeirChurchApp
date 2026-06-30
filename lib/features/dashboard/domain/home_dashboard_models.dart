// Kingdom Heir — Home Dashboard Domain Models
//
// Pure Dart value types — no Flutter, no Supabase.
// Every model is const-constructable and ==-stable.

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

enum GreetingMoment { morning, afternoon, evening, night }

GreetingMoment resolveGreetingMoment(DateTime now) {
  final h = now.hour;
  if (h < 5) return GreetingMoment.night;
  if (h < 12) return GreetingMoment.morning;
  if (h < 17) return GreetingMoment.afternoon;
  if (h < 21) return GreetingMoment.evening;
  return GreetingMoment.night;
}

@immutable
class DashboardGreeting {
  const DashboardGreeting({
    required this.firstName,
    required this.moment,
    required this.streakDays,
    this.avatarUrl,
    this.unreadNotifications = 0,
  });

  final String firstName;
  final GreetingMoment moment;
  final int streakDays;
  final String? avatarUrl;
  final int unreadNotifications;
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Scripture (Hero Card)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ScriptureCard {
  const ScriptureCard({
    required this.verseText,
    required this.reference,
    required this.translation,
    this.isBookmarked = false,
    this.audioUrl,
  });

  final String verseText;
  final String reference;
  final String translation;
  final bool isBookmarked;
  final String? audioUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Your Journey
// ─────────────────────────────────────────────────────────────────────────────

enum ContinueKind { sermon, biblePlan, devotional, podcast, prayerChallenge }

@immutable
class ContinueCard {
  const ContinueCard({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.thumbnailUrl,
    this.durationLabel,
  });

  final String id;
  final ContinueKind kind;
  final String title;
  final String subtitle;
  final double progress;
  final String? thumbnailUrl;
  final String? durationLabel;

  String get kindLabel => switch (kind) {
        ContinueKind.sermon => 'Sermon',
        ContinueKind.biblePlan => 'Bible Plan',
        ContinueKind.devotional => 'Devotional',
        ContinueKind.podcast => 'Podcast',
        ContinueKind.prayerChallenge => 'Prayer Challenge',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Live / Next Service
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ServiceStatus {
  const ServiceStatus({
    required this.isLive,
    required this.title,
    this.hostLabel,
    this.startsAt,
    this.viewerCount,
    this.locationLabel,
    this.streamUrl,
  });

  final bool isLive;
  final String title;
  final String? hostLabel;
  final DateTime? startsAt;
  final int? viewerCount;
  final String? locationLabel;
  final String? streamUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Spiritual Journey
// ─────────────────────────────────────────────────────────────────────────────

enum SpiritualTaskKind { scripture, devotional, prayer, reflection, worship, journal }

@immutable
class SpiritualTask {
  const SpiritualTask({
    required this.kind,
    required this.isCompleted,
    this.label,
  });

  final SpiritualTaskKind kind;
  final bool isCompleted;
  final String? label;

  String get defaultLabel => switch (kind) {
        SpiritualTaskKind.scripture => 'Read Scripture',
        SpiritualTaskKind.devotional => 'Devotional',
        SpiritualTaskKind.prayer => 'Prayer Time',
        SpiritualTaskKind.reflection => 'Reflection',
        SpiritualTaskKind.worship => 'Worship',
        SpiritualTaskKind.journal => 'Journal',
      };

  String get displayLabel => label ?? defaultLabel;
}

@immutable
class DailyJourney {
  const DailyJourney({
    required this.tasks,
    required this.streakDays,
  });

  final List<SpiritualTask> tasks;
  final int streakDays;

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get isComplete => completedCount == tasks.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Church Today (Today + Tomorrow events only)
// ─────────────────────────────────────────────────────────────────────────────

/// Premium timeline category for a Church Today event. Drives the colored
/// dot and label badge on the redesigned Church Today timeline. Paired with
/// the matching color palette in `dashboard_categories.dart`.
enum TodayEventCategory {
  prayer,
  bibleStudy,
  youth,
  sundayService,
  outreach,
  choir,
  other,
}

@immutable
class TodayEvent {
  const TodayEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.locationLabel,
    this.isOnline = false,
    this.isToday = true,
    this.joinUrl,
    this.leaderName,
    this.category = TodayEventCategory.other,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final String locationLabel;
  final bool isOnline;
  final bool isToday;
  final String? joinUrl;
  final String? leaderName;

  /// Premium timeline category — drives the colored dot and label badge
  /// on the redesigned Church Today timeline. Defaults to [other] for
  /// backward compatibility with existing data sources.
  final TodayEventCategory category;
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer Corner
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PrayerRequest {
  const PrayerRequest({
    required this.id,
    required this.authorName,
    required this.preview,
    this.avatarUrl,
    this.prayerCount = 0,
  });

  final String id;
  final String authorName;
  final String preview;
  final String? avatarUrl;
  final int prayerCount;
}

@immutable
class PrayerCorner {
  const PrayerCorner({
    required this.requests,
    required this.usersPrayedToday,
    this.answeredPrayerHighlight,
  });

  final List<PrayerRequest> requests;
  final int usersPrayedToday;
  final String? answeredPrayerHighlight;
}

// ─────────────────────────────────────────────────────────────────────────────
// Community Highlight
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class CommunityHighlight {
  const CommunityHighlight({
    this.unreadGroupMessages = 0,
    this.birthdayName,
    this.leaderAnnouncement,
    this.upcomingGroupMeeting,
  });

  final int unreadGroupMessages;
  final String? birthdayName;
  final String? leaderAnnouncement;
  final String? upcomingGroupMeeting;

  bool get hasContent =>
      unreadGroupMessages > 0 ||
      birthdayName != null ||
      leaderAnnouncement != null ||
      upcomingGroupMeeting != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Watching (Netflix-style)
// ─────────────────────────────────────────────────────────────────────────────

enum WatchKind { sermon, podcast }

@immutable
class WatchCard {
  const WatchCard({
    required this.id,
    required this.kind,
    required this.title,
    required this.speakerName,
    required this.progress,
    this.thumbnailUrl,
    this.durationLabel,
    this.isDownloaded = false,
  });

  final String id;
  final WatchKind kind;
  final String title;
  final String speakerName;
  final double progress;
  final String? thumbnailUrl;
  final String? durationLabel;

  /// `true` when the sermon/podcast is downloaded for offline playback.
  /// Surfaced as a small Phosphor `downloadSimple` badge overlay on the
  /// card thumbnail in the redesigned Continue Watching carousel.
  final bool isDownloaded;
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

enum QuickActionItem { bible, prayer, sermons, give }

extension QuickActionItemX on QuickActionItem {
  String get label => switch (this) {
        QuickActionItem.bible => 'Bible',
        QuickActionItem.prayer => 'Prayer',
        QuickActionItem.sermons => 'Sermons',
        QuickActionItem.give => 'Give',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Aggregate — Home Dashboard Data
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class HomeDashboardData {
  const HomeDashboardData({
    required this.greeting,
    required this.scripture,
    required this.continueCards,
    required this.serviceStatus,
    required this.dailyJourney,
    required this.todayEvents,
    required this.prayerCorner,
    required this.communityHighlight,
    required this.watchCards,
  });

  final DashboardGreeting greeting;
  final ScriptureCard scripture;
  final List<ContinueCard> continueCards;
  final ServiceStatus serviceStatus;
  final DailyJourney dailyJourney;
  final List<TodayEvent> todayEvents;
  final PrayerCorner prayerCorner;
  final CommunityHighlight communityHighlight;
  final List<WatchCard> watchCards;
}
