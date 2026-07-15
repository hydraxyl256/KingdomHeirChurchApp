// Kingdom Heir — Devotional Series Domain Models
//
// Pure Dart value types covering the 90-Day Devotional Journey system.
// Separate from the legacy Devotional / DevotionalProgress models.
//
// Naming:
//   DevotionalSeries        → maps devotional_series table
//   DevotionalEntry         → maps devotional_entries + merged translation
//   DevotionalSeriesProgress→ maps devotional_progress table
//   DevotionalJournalReflection → maps devotional_reflections table

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DevotionalSeries
// ─────────────────────────────────────────────────────────────────────────────

class DevotionalSeries extends Equatable {
  const DevotionalSeries({
    required this.id,
    required this.slug,
    required this.title,
    required this.totalDays,
    required this.status,
    required this.isPrimaryChallengesSeries,
    required this.createdAt,
    required this.updatedAt,
    this.subtitle,
    this.authorName,
    this.coverImageUrl,
    this.description,
    this.amazonPurchaseUrl,
  });

  factory DevotionalSeries.fromJson(Map<String, dynamic> json) =>
      DevotionalSeries(
        id:                       json['id'] as String,
        slug:                     json['slug'] as String,
        title:                    json['title'] as String,
        subtitle:                 json['subtitle'] as String?,
        authorName:               json['author_name'] as String?,
        coverImageUrl:            json['cover_image_url'] as String?,
        description:              json['description'] as String?,
        totalDays:                json['total_days'] as int,
        amazonPurchaseUrl:        json['amazon_purchase_url'] as String?,
        isPrimaryChallengesSeries:
            json['is_primary_challenge_series'] as bool? ?? false,
        status:                   json['status'] as String,
        createdAt:                DateTime.parse(json['created_at'] as String),
        updatedAt:                DateTime.parse(json['updated_at'] as String),
      );

  final String  id;
  final String  slug;
  final String  title;
  final String? subtitle;
  final String? authorName;
  final String? coverImageUrl;
  final String? description;
  final int     totalDays;
  final String? amazonPurchaseUrl;
  final bool    isPrimaryChallengesSeries;
  final String  status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPublished => status == 'published';

  Map<String, dynamic> toJson() => {
        'id':                          id,
        'slug':                        slug,
        'title':                       title,
        'subtitle':                    subtitle,
        'author_name':                 authorName,
        'cover_image_url':             coverImageUrl,
        'description':                 description,
        'total_days':                  totalDays,
        'amazon_purchase_url':         amazonPurchaseUrl,
        'is_primary_challenge_series': isPrimaryChallengesSeries,
        'status':                      status,
        'created_at':                  createdAt.toIso8601String(),
        'updated_at':                  updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id, slug, title, subtitle, authorName, coverImageUrl,
        description, totalDays, amazonPurchaseUrl,
        isPrimaryChallengesSeries, status, createdAt, updatedAt,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// DevotionalEntry  (English base + optional merged translation)
// ─────────────────────────────────────────────────────────────────────────────

class DevotionalEntry extends Equatable {
  const DevotionalEntry({
    required this.id,
    required this.seriesId,
    required this.dayNumber,
    required this.title,
    required this.devotionalBody,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.scriptureReference,
    this.scriptureText,
    this.reflectionQuestion,
    this.actionStep,
    this.prayerText,
    this.estimatedReadMinutes,
    /// True when content is English fallback (no published translation found).
    this.isFallback = false,
    /// Language code of the displayed content.
    this.displayedLanguageCode = 'en',
  });

  /// Constructs from a Supabase row.
  /// If [translationJson] is provided and non-null, its fields overlay the base.
  factory DevotionalEntry.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? translationJson,
  }) {
    final hasTx = translationJson != null && translationJson.isNotEmpty;
    // Non-null alias used only when hasTx is true — safe by the guard above.
    final tx = translationJson ?? const <String, dynamic>{};
    return DevotionalEntry(
      id:                    json['id'] as String,
      seriesId:              json['series_id'] as String,
      dayNumber:             json['day_number'] as int,
      // Translated fields overlay base when a translation exists
      title:                 hasTx
          ? (tx['title'] as String? ?? json['title'] as String)
          : json['title'] as String,
      devotionalBody:        hasTx
          ? (tx['devotional_body'] as String? ?? json['devotional_body'] as String)
          : json['devotional_body'] as String,
      scriptureReference:    hasTx
          ? (tx['scripture_reference'] as String? ?? json['scripture_reference'] as String?)
          : json['scripture_reference'] as String?,
      scriptureText:         hasTx
          ? (tx['scripture_text'] as String? ?? json['scripture_text'] as String?)
          : json['scripture_text'] as String?,
      reflectionQuestion:    hasTx
          ? (tx['reflection_question'] as String? ?? json['reflection_question'] as String?)
          : json['reflection_question'] as String?,
      actionStep:            hasTx
          ? (tx['action_step'] as String? ?? json['action_step'] as String?)
          : json['action_step'] as String?,
      prayerText:            hasTx
          ? (tx['prayer_text'] as String? ?? json['prayer_text'] as String?)
          : json['prayer_text'] as String?,
      estimatedReadMinutes:  json['estimated_read_minutes'] as int?,
      status:                json['status'] as String,
      createdAt:             DateTime.parse(json['created_at'] as String),
      updatedAt:             DateTime.parse(json['updated_at'] as String),
      isFallback:            !hasTx,
      displayedLanguageCode: hasTx
          ? (tx['language_code'] as String? ?? 'en')
          : 'en',
    );
  }

  final String  id;
  final String  seriesId;
  final int     dayNumber;
  final String  title;
  final String  devotionalBody;
  final String? scriptureReference;
  final String? scriptureText;
  final String? reflectionQuestion;
  final String? actionStep;
  final String? prayerText;
  final int?    estimatedReadMinutes;
  final String  status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool    isFallback;
  final String  displayedLanguageCode;

  bool get isPublished => status == 'published';

  @override
  List<Object?> get props => [
        id, seriesId, dayNumber, title, devotionalBody,
        scriptureReference, scriptureText, reflectionQuestion,
        actionStep, prayerText, estimatedReadMinutes, status,
        createdAt, updatedAt, isFallback, displayedLanguageCode,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// DevotionalSeriesProgress  (maps devotional_progress table)
// ─────────────────────────────────────────────────────────────────────────────

class DevotionalSeriesProgress extends Equatable {
  const DevotionalSeriesProgress({
    required this.id,
    required this.userId,
    required this.seriesId,
    required this.currentDay,
    required this.highestUnlockedDay,
    required this.completedDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.startedAt,
    this.lastCompletedAt,
    this.completedAt,
  });

  factory DevotionalSeriesProgress.fromJson(Map<String, dynamic> json) =>
      DevotionalSeriesProgress(
        id:                 json['id'] as String,
        userId:             json['user_id'] as String,
        seriesId:           json['series_id'] as String,
        currentDay:         json['current_day'] as int,
        highestUnlockedDay: json['highest_unlocked_day'] as int,
        completedDays:      (json['completed_days'] as List<dynamic>?)
                                ?.map((e) => e as int)
                                .toList() ??
                            const [],
        currentStreak:      json['current_streak'] as int,
        longestStreak:      json['longest_streak'] as int,
        lastCompletedAt:    json['last_completed_at'] != null
                                ? DateTime.parse(json['last_completed_at'] as String)
                                : null,
        startedAt:          DateTime.parse(json['started_at'] as String),
        completedAt:        json['completed_at'] != null
                                ? DateTime.parse(json['completed_at'] as String)
                                : null,
      );

  final String         id;
  final String         userId;
  final String         seriesId;
  final int            currentDay;
  final int            highestUnlockedDay;
  final List<int>      completedDays;
  final int            currentStreak;
  final int            longestStreak;
  final DateTime?      lastCompletedAt;
  final DateTime       startedAt;
  final DateTime?      completedAt;

  bool get isAllComplete => completedAt != null;
  bool get completedToday {
    if (lastCompletedAt == null) return false;
    final now   = DateTime.now();
    final last  = lastCompletedAt!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  bool isDayUnlocked(int day) => day <= highestUnlockedDay;
  bool isDayCompleted(int day) => completedDays.contains(day);

  @override
  List<Object?> get props => [
        id, userId, seriesId, currentDay, highestUnlockedDay,
        completedDays, currentStreak, longestStreak,
        lastCompletedAt, startedAt, completedAt,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// DevotionalJournalReflection  (maps devotional_reflections table)
// ─────────────────────────────────────────────────────────────────────────────

class DevotionalJournalReflection extends Equatable {
  const DevotionalJournalReflection({
    required this.id,
    required this.userId,
    required this.devotionalEntryId,
    required this.createdAt,
    required this.updatedAt,
    this.reflectionText,
    this.isPrivate = true,
  });

  factory DevotionalJournalReflection.fromJson(Map<String, dynamic> json) =>
      DevotionalJournalReflection(
        id:                 json['id'] as String,
        userId:             json['user_id'] as String,
        devotionalEntryId:  json['devotional_entry_id'] as String,
        reflectionText:     json['reflection_text'] as String?,
        isPrivate:          json['is_private'] as bool? ?? true,
        createdAt:          DateTime.parse(json['created_at'] as String),
        updatedAt:          DateTime.parse(json['updated_at'] as String),
      );

  final String  id;
  final String  userId;
  final String  devotionalEntryId;
  final String? reflectionText;
  final bool    isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id':                  id,
        'user_id':             userId,
        'devotional_entry_id': devotionalEntryId,
        'reflection_text':     reflectionText,
        'is_private':          isPrivate,
        'created_at':          createdAt.toIso8601String(),
        'updated_at':          updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, userId, devotionalEntryId, reflectionText, isPrivate, createdAt, updatedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardDevotionalState  (derived state for the challenge/dashboard card)
// ─────────────────────────────────────────────────────────────────────────────

enum DashboardDevotionalStatus {
  /// User has not joined the challenge series
  notJoined,
  /// User joined but today's day is not yet complete
  continueDay,
  /// User completed today's day — next day tomorrow
  completedToday,
  /// All 90 days finished
  allComplete,
}

class DashboardDevotionalState extends Equatable {
  const DashboardDevotionalState({
    required this.status,
    required this.seriesId,
    this.currentDay,
    this.totalDays,
    this.currentStreak,
  });

  final DashboardDevotionalStatus status;
  final String                    seriesId;
  final int?                      currentDay;
  final int?                      totalDays;
  final int?                      currentStreak;

  @override
  List<Object?> get props =>
      [status, seriesId, currentDay, totalDays, currentStreak];
}
