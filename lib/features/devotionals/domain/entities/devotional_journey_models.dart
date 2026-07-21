// Kingdom Heir — Devotional Journey Domain Models
//
// Pure Dart value types — no Flutter dependencies.
// Models the 7-step daily spiritual journey.

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

/// The 7 steps of a daily devotional journey.
enum JourneyStep {
  home, // 0 — Devotional home / selection
  scripture, // 1 — Read scripture
  content, // 2 — Read devotional body
  reflection, // 3 — Reflect on prompts
  prayer, // 4 — Guided prayer
  journal, // 5 — Journal entry
  complete, // 6 — Journey complete
}

extension JourneyStepX on JourneyStep {
  int get index => JourneyStep.values.indexOf(this);
  bool get isFirst => this == JourneyStep.home;
  bool get isLast => this == JourneyStep.complete;

  JourneyStep? get next {
    final i = index;
    if (i >= JourneyStep.values.length - 1) return null;
    return JourneyStep.values[i + 1];
  }

  String get label => switch (this) {
        JourneyStep.home => 'Home',
        JourneyStep.scripture => 'Scripture',
        JourneyStep.content => 'Devotional',
        JourneyStep.reflection => 'Reflection',
        JourneyStep.prayer => 'Prayer',
        JourneyStep.journal => 'Journal',
        JourneyStep.complete => 'Complete',
      };
}

/// Mood a user can attach to a journal entry.
enum MoodTag {
  grateful,
  hopeful,
  peaceful,
  challenged,
  joyful,
  searching,
}

extension MoodTagX on MoodTag {
  String get emoji => switch (this) {
        MoodTag.grateful => '🙏',
        MoodTag.hopeful => '✨',
        MoodTag.peaceful => '☮️',
        MoodTag.challenged => '🔥',
        MoodTag.joyful => '😊',
        MoodTag.searching => '🔍',
      };

  String get label => switch (this) {
        MoodTag.grateful => 'Grateful',
        MoodTag.hopeful => 'Hopeful',
        MoodTag.peaceful => 'Peaceful',
        MoodTag.challenged => 'Challenged',
        MoodTag.joyful => 'Joyful',
        MoodTag.searching => 'Searching',
      };
}

/// Preset tags for journal entries.
enum JournalTag {
  faith,
  prayer,
  growth,
  gratitude,
  challenge,
  revelation,
}

extension JournalTagX on JournalTag {
  String get label => switch (this) {
        JournalTag.faith => 'Faith',
        JournalTag.prayer => 'Prayer',
        JournalTag.growth => 'Growth',
        JournalTag.gratitude => 'Gratitude',
        JournalTag.challenge => 'Challenge',
        JournalTag.revelation => 'Revelation',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class DevotionalStreak {
  const DevotionalStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedDays,
    required this.lastCompletedDate,
    required this.weeklyCompletion,
  });

  const DevotionalStreak.empty()
      : currentStreak = 0,
        longestStreak = 0,
        totalCompletedDays = 0,
        lastCompletedDate = null,
        weeklyCompletion = const [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ];

  factory DevotionalStreak.fromJson(Map<String, dynamic> json) {
    return DevotionalStreak(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalCompletedDays: json['total_completed_days'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'] as String)
          : null,
      weeklyCompletion: (json['weekly_completion'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
    );
  }

  final int currentStreak;
  final int longestStreak;
  final int totalCompletedDays;
  final DateTime? lastCompletedDate;
  // Mon=0 … Sun=6
  final List<bool> weeklyCompletion;

  bool get completedToday {
    if (lastCompletedDate == null) return false;
    final today = DateTime.now();
    final d = lastCompletedDate!;
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }

  int get thisWeekCount => weeklyCompletion.where((c) => c).length;

  Map<String, dynamic> toJson() => {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_completed_days': totalCompletedDays,
        'last_completed_date': lastCompletedDate?.toIso8601String(),
        'weekly_completion': weeklyCompletion,
      };

  DevotionalStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalCompletedDays,
    DateTime? lastCompletedDate,
    List<bool>? weeklyCompletion,
  }) =>
      DevotionalStreak(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
        weeklyCompletion: weeklyCompletion ?? this.weeklyCompletion,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Journey Progress (per devotional)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class DevotionalProgress {
  const DevotionalProgress({
    required this.devotionalId,
    required this.scriptureRead,
    required this.contentRead,
    required this.reflectionDone,
    required this.prayerDone,
    required this.journalDone,
    required this.completed,
    required this.startedAt,
    this.completedAt,
  });

  factory DevotionalProgress.start(String devotionalId) => DevotionalProgress(
        devotionalId: devotionalId,
        scriptureRead: false,
        contentRead: false,
        reflectionDone: false,
        prayerDone: false,
        journalDone: false,
        completed: false,
        startedAt: DateTime.now(),
      );

  factory DevotionalProgress.fromJson(Map<String, dynamic> json) =>
      DevotionalProgress(
        devotionalId: json['devotional_id'] as String,
        scriptureRead: json['scripture_read'] as bool? ?? false,
        contentRead: json['content_read'] as bool? ?? false,
        reflectionDone: json['reflection_done'] as bool? ?? false,
        prayerDone: json['prayer_done'] as bool? ?? false,
        journalDone: json['journal_done'] as bool? ?? false,
        completed: json['completed'] as bool? ?? false,
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  final String devotionalId;
  final bool scriptureRead;
  final bool contentRead;
  final bool reflectionDone;
  final bool prayerDone;
  final bool journalDone;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// 0–5 steps done (excludes 'completed' flag itself).
  int get stepsCompleted => [
        scriptureRead,
        contentRead,
        reflectionDone,
        prayerDone,
        journalDone,
      ].where((s) => s).length;

  double get progressFraction => stepsCompleted / 5;

  Map<String, dynamic> toJson() => {
        'devotional_id': devotionalId,
        'scripture_read': scriptureRead,
        'content_read': contentRead,
        'reflection_done': reflectionDone,
        'prayer_done': prayerDone,
        'journal_done': journalDone,
        'completed': completed,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  DevotionalProgress copyWith({
    bool? scriptureRead,
    bool? contentRead,
    bool? reflectionDone,
    bool? prayerDone,
    bool? journalDone,
    bool? completed,
    DateTime? completedAt,
  }) =>
      DevotionalProgress(
        devotionalId: devotionalId,
        scriptureRead: scriptureRead ?? this.scriptureRead,
        contentRead: contentRead ?? this.contentRead,
        reflectionDone: reflectionDone ?? this.reflectionDone,
        prayerDone: prayerDone ?? this.prayerDone,
        journalDone: journalDone ?? this.journalDone,
        completed: completed ?? this.completed,
        startedAt: startedAt,
        completedAt: completedAt ?? this.completedAt,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal Entry
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.tags,
    this.devotionalId,
    this.devotionalTitle,
    this.bibleRef,
    this.mood,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        devotionalId: json['devotional_id'] as String?,
        devotionalTitle: json['devotional_title'] as String?,
        bibleRef: json['bible_ref'] as String?,
        mood: json['mood'] != null
            ? MoodTag.values.firstWhere(
                (m) => m.name == json['mood'],
                orElse: () => MoodTag.grateful,
              )
            : null,
        tags: (json['tags'] as List<dynamic>?)
                ?.map(
                  (t) => JournalTag.values.firstWhere(
                    (tag) => tag.name == t,
                    orElse: () => JournalTag.faith,
                  ),
                )
                .toList() ??
            [],
      );

  final String id;
  final String body;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? devotionalId;
  final String? devotionalTitle;
  final String? bibleRef;
  final MoodTag? mood;
  final List<JournalTag> tags;

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'devotional_id': devotionalId,
        'devotional_title': devotionalTitle,
        'bible_ref': bibleRef,
        'mood': mood?.name,
        'tags': tags.map((t) => t.name).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Reflection Prompt
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ReflectionPrompt {
  const ReflectionPrompt({
    required this.question,
    required this.icon,
    this.response,
  });

  final String question;
  final String icon;
  final String? response;

  ReflectionPrompt withResponse(String r) =>
      ReflectionPrompt(question: question, icon: icon, response: r);

  static List<ReflectionPrompt> get defaults => const [
        ReflectionPrompt(
          question: "What spoke to you most from today's Scripture?",
          icon: '📖',
        ),
        ReflectionPrompt(
          question: "How will you apply today's teaching in your life?",
          icon: '🌱',
        ),
        ReflectionPrompt(
          question: 'What challenged or stretched your heart today?',
          icon: '🔥',
        ),
        ReflectionPrompt(
          question: 'What prayer arose in your heart from this devotional?',
          icon: '🙏',
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Devotional Home Data (aggregated for Screen 1)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class DevotionalHomeData {
  const DevotionalHomeData({
    required this.streak,
    required this.progress,
    this.todaysDevotionalId,
    this.todaysDevotionalTitle,
    this.todaysTheme,
    this.todaysScriptureRef,
    this.todaysReadingMinutes,
  });

  final DevotionalStreak streak;
  final DevotionalProgress? progress;
  final String? todaysDevotionalId;
  final String? todaysDevotionalTitle;
  final String? todaysTheme;
  final String? todaysScriptureRef;
  final int? todaysReadingMinutes;

  bool get hasToday => todaysDevotionalId != null;
  bool get todayComplete => progress?.completed ?? false;
}
