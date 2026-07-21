// Kingdom Heir — Devotional Journey Riverpod Providers
//
// Manages all state for the 7-step devotional journey:
//   streak, progress, journal draft, font size, mood, reflections.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/devotionals/data/services/devotional_streak_service.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service Provider
// ─────────────────────────────────────────────────────────────────────────────

final devotionalStreakServiceProvider =
    Provider<DevotionalStreakService>((ref) {
  return DevotionalStreakService(ref.watch(sharedPreferencesProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Streak Provider
// ─────────────────────────────────────────────────────────────────────────────

class StreakNotifier extends Notifier<DevotionalStreak> {
  @override
  DevotionalStreak build() {
    return ref.read(devotionalStreakServiceProvider).getStreak();
  }

  Future<void> markComplete() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.markTodayComplete();
  }

  void refresh() {
    state = ref.read(devotionalStreakServiceProvider).getStreak();
  }
}

final devotionalStreakProvider =
    NotifierProvider<StreakNotifier, DevotionalStreak>(StreakNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Progress Notifier (per devotional)
// ─────────────────────────────────────────────────────────────────────────────

class JourneyProgressNotifier
    extends FamilyNotifier<DevotionalProgress?, String> {
  @override
  DevotionalProgress? build(String devotionalId) {
    return ref.read(devotionalStreakServiceProvider).getProgress(devotionalId);
  }

  Future<void> markScriptureRead() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.updateStep(arg, scriptureRead: true);
  }

  Future<void> markContentRead() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.updateStep(arg, contentRead: true);
  }

  Future<void> markReflectionDone() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.updateStep(arg, reflectionDone: true);
  }

  Future<void> markPrayerDone() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.updateStep(arg, prayerDone: true);
  }

  Future<void> markJournalDone() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.updateStep(arg, journalDone: true);
  }

  Future<void> markComplete() async {
    final service = ref.read(devotionalStreakServiceProvider);
    state = await service.markComplete(arg);
    // Also update the streak
    await ref.read(devotionalStreakProvider.notifier).markComplete();
  }

  void ensureStarted() {
    if (state == null) {
      state = DevotionalProgress.start(arg);
      unawaited(
        ref.read(devotionalStreakServiceProvider).saveProgress(state!),
      );
    }
  }
}

final journeyProgressProvider = NotifierProviderFamily<JourneyProgressNotifier,
    DevotionalProgress?, String>(JourneyProgressNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Reflection Prompts State
// ─────────────────────────────────────────────────────────────────────────────

class ReflectionPromptsNotifier extends Notifier<List<ReflectionPrompt>> {
  @override
  List<ReflectionPrompt> build() => ReflectionPrompt.defaults;

  void updateResponse(int index, String response) {
    final updated = [...state];
    updated[index] = updated[index].withResponse(response);
    state = updated;
  }

  void reset() {
    state = ReflectionPrompt.defaults;
  }

  bool get hasAnyResponse => state.any((p) => p.response?.isNotEmpty ?? false);
}

final reflectionPromptsProvider =
    NotifierProvider<ReflectionPromptsNotifier, List<ReflectionPrompt>>(
  ReflectionPromptsNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Journal Draft
// ─────────────────────────────────────────────────────────────────────────────

final journalDraftProvider = StateProvider<String>((ref) {
  return ref.read(devotionalStreakServiceProvider).getDraft() ?? '';
});

final journalMoodProvider = StateProvider<MoodTag?>((ref) => null);

final journalTagsProvider = StateProvider<Set<JournalTag>>((ref) => {});

// ─────────────────────────────────────────────────────────────────────────────
// Reader Font Size
// ─────────────────────────────────────────────────────────────────────────────

final devotionalFontSizeProvider = StateProvider<double>((ref) => 18);

// ─────────────────────────────────────────────────────────────────────────────
// Local Journal Entries
// ─────────────────────────────────────────────────────────────────────────────

class JournalEntriesNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() {
    return ref.read(devotionalStreakServiceProvider).getLocalJournalEntries();
  }

  Future<void> addEntry({
    required String body,
    required List<JournalTag> tags,
    MoodTag? mood,
    String? devotionalId,
    String? devotionalTitle,
    String? bibleRef,
  }) async {
    final service = ref.read(devotionalStreakServiceProvider);
    final entry = await service.saveJournalEntry(
      body: body,
      tags: tags,
      mood: mood,
      devotionalId: devotionalId,
      devotionalTitle: devotionalTitle,
      bibleRef: bibleRef,
    );
    state = [entry, ...state];
    await service.clearDraft();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(devotionalStreakServiceProvider).deleteJournalEntry(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final journalEntriesProvider =
    NotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
  JournalEntriesNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Scripture bookmark state
// ─────────────────────────────────────────────────────────────────────────────

final scriptureBookmarkedProvider =
    StateProviderFamily<bool, String>((ref, verseRef) => false);
