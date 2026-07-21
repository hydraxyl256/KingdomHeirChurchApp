// Kingdom Heir — Devotional Streak Service
//
// Manages reading streak state in SharedPreferences.
// All operations are synchronous after init — no async blocking.

import 'dart:convert';

import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevotionalStreakService {
  DevotionalStreakService(this._prefs);

  final SharedPreferences _prefs;

  static const _streakKey = 'devotional_streak_v1';
  static const _progressPrefix = 'devotional_progress_v1_';

  // ── Streak ─────────────────────────────────────────────────────────────────

  DevotionalStreak getStreak() {
    final raw = _prefs.getString(_streakKey);
    if (raw == null) return const DevotionalStreak.empty();
    try {
      return DevotionalStreak.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const DevotionalStreak.empty();
    }
  }

  /// Marks today as completed and updates streak.
  Future<DevotionalStreak> markTodayComplete() async {
    final current = getStreak();
    if (current.completedToday) return current; // idempotent

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Was yesterday completed?
    final wasYesterday = current.lastCompletedDate != null &&
        current.lastCompletedDate!.year == yesterday.year &&
        current.lastCompletedDate!.month == yesterday.month &&
        current.lastCompletedDate!.day == yesterday.day;

    final newStreak = wasYesterday ? current.currentStreak + 1 : 1;
    final longest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;

    // Update weekly completion (0=Mon, 6=Sun)
    final weekday = today.weekday - 1; // Mon=0
    final weekly = List<bool>.from(current.weeklyCompletion);
    // Reset if new week started
    if (!wasYesterday && current.currentStreak == 0) {
      weekly.fillRange(0, 7, false);
    }
    if (weekday >= 0 && weekday < 7) {
      weekly[weekday] = true;
    }

    final updated = current.copyWith(
      currentStreak: newStreak,
      longestStreak: longest,
      totalCompletedDays: current.totalCompletedDays + 1,
      lastCompletedDate: today,
      weeklyCompletion: weekly,
    );

    await _prefs.setString(_streakKey, json.encode(updated.toJson()));
    return updated;
  }

  Future<void> resetStreak() async {
    await _prefs.remove(_streakKey);
  }

  // ── Progress ───────────────────────────────────────────────────────────────

  DevotionalProgress? getProgress(String devotionalId) {
    final raw = _prefs.getString('$_progressPrefix$devotionalId');
    if (raw == null) return null;
    try {
      return DevotionalProgress.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProgress(DevotionalProgress progress) async {
    await _prefs.setString(
      '$_progressPrefix${progress.devotionalId}',
      json.encode(progress.toJson()),
    );
  }

  Future<DevotionalProgress> updateStep(
    String devotionalId, {
    bool? scriptureRead,
    bool? contentRead,
    bool? reflectionDone,
    bool? prayerDone,
    bool? journalDone,
  }) async {
    final current =
        getProgress(devotionalId) ?? DevotionalProgress.start(devotionalId);

    final updated = current.copyWith(
      scriptureRead: scriptureRead,
      contentRead: contentRead,
      reflectionDone: reflectionDone,
      prayerDone: prayerDone,
      journalDone: journalDone,
    );

    await saveProgress(updated);
    return updated;
  }

  Future<DevotionalProgress> markComplete(String devotionalId) async {
    final current =
        getProgress(devotionalId) ?? DevotionalProgress.start(devotionalId);

    final completed = current.copyWith(
      scriptureRead: true,
      contentRead: true,
      reflectionDone: true,
      prayerDone: true,
      journalDone: true,
      completed: true,
      completedAt: DateTime.now(),
    );

    await saveProgress(completed);
    return completed;
  }

  // ── Journal Draft ──────────────────────────────────────────────────────────

  static const _draftKey = 'devotional_journal_draft_v1';

  String? getDraft() => _prefs.getString(_draftKey);

  Future<void> saveDraft(String text) => _prefs.setString(_draftKey, text);

  Future<void> clearDraft() => _prefs.remove(_draftKey);

  // ── Journal Entries (local) ────────────────────────────────────────────────

  static const _journalKey = 'devotional_journal_entries_v1';

  List<JournalEntry> getLocalJournalEntries() {
    final raw = _prefs.getString(_journalKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<JournalEntry> saveJournalEntry({
    required String body,
    required List<JournalTag> tags,
    MoodTag? mood,
    String? devotionalId,
    String? devotionalTitle,
    String? bibleRef,
  }) async {
    final entries = getLocalJournalEntries();
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.millisecondsSinceEpoch.toString(),
      body: body,
      createdAt: now,
      devotionalId: devotionalId,
      devotionalTitle: devotionalTitle,
      bibleRef: bibleRef,
      mood: mood,
      tags: tags,
    );
    entries.insert(0, entry);
    await _prefs.setString(
      _journalKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
    return entry;
  }

  Future<void> deleteJournalEntry(String id) async {
    final entries = getLocalJournalEntries()..removeWhere((e) => e.id == id);
    await _prefs.setString(
      _journalKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
