import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';

/// Riverpod providers that back the Bible engagement layer (notes,
/// highlights, bookmarks, reading plans, reader settings) using
/// SharedPreferences.

const _kHighlights = 'bible_highlights_v1';
const _kNotes = 'bible_notes_v1';
const _kBookmarks = 'bible_bookmarks_v1';
const _kPlanProgress = 'bible_plan_progress_v1';
const _kReaderSettings = 'bible_reader_settings_v1';

// ─────────────────────────────────────────────────────────────────────────
// Settings — single object
// ─────────────────────────────────────────────────────────────────────────

class ReaderSettingsNotifier extends StateNotifier<BibleReaderSettings> {
  ReaderSettingsNotifier(this._ref) : super(const BibleReaderSettings());

  final Ref _ref;

  Future<void> _persist() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_kReaderSettings, jsonEncode(state.toJson()));
  }

  Future<void> update(BibleReaderSettings next) async {
    state = next;
    await _persist();
  }

  Future<void> hydrate() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kReaderSettings);
    if (raw == null) return;
    try {
      state = BibleReaderSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // Keep defaults.
    }
  }
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, BibleReaderSettings>(
  ReaderSettingsNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────
// Highlights
// ─────────────────────────────────────────────────────────────────────────

class HighlightsNotifier extends StateNotifier<List<BibleHighlightLocal>> {
  HighlightsNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> _persist() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(state.map((h) => h.toJson()).toList());
    await prefs.setString(_kHighlights, encoded);
  }

  Future<void> hydrate() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kHighlights);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => BibleHighlightLocal.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {/* keep empty */}
  }

  Future<void> add({
    required String verseId,
    required String colorHex,
  }) async {
    final existing = state.where((h) => h.verseId == verseId).toList();
    if (existing.isNotEmpty) {
      // Replace color.
      state = state
          .map(
            (h) => h.verseId == verseId
                ? (BibleHighlightLocal(
                    id: h.id,
                    verseId: h.verseId,
                    colorHex: colorHex,
                    createdAt: DateTime.now(),
                  ))
                : h,
          )
          .toList();
    } else {
      state = [
        ...state,
        BibleHighlightLocal(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          verseId: verseId,
          colorHex: colorHex,
          createdAt: DateTime.now(),
        ),
      ];
    }
    await _persist();
  }

  Future<void> remove(String verseId) async {
    state = state.where((h) => h.verseId != verseId).toList();
    await _persist();
  }
}

final highlightsProvider =
    StateNotifierProvider<HighlightsNotifier, List<BibleHighlightLocal>>(
  HighlightsNotifier.new,
);

/// Convenience: lookup a highlight color for a verse (or null).
String? highlightColorFor(
  List<BibleHighlightLocal> highlights,
  String verseId,
) {
  for (final h in highlights) {
    if (h.verseId == verseId) return h.colorHex;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────
// Notes
// ─────────────────────────────────────────────────────────────────────────

class NotesNotifier extends StateNotifier<List<BibleNoteLocal>> {
  NotesNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> _persist() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(state.map((n) => n.toJson()).toList());
    await prefs.setString(_kNotes, encoded);
  }

  Future<void> hydrate() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kNotes);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => BibleNoteLocal.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {/* keep empty */}
  }

  Future<void> upsert({
    required String reference,
    required String verseId,
    required String body,
    String? id,
  }) async {
    final now = DateTime.now();
    if (id != null) {
      state = state
          .map(
            (n) => n.id == id
                ? BibleNoteLocal(
                    id: n.id,
                    reference: reference,
                    verseId: verseId,
                    body: body,
                    updatedAt: now,
                  )
                : n,
          )
          .toList();
    } else {
      state = [
        ...state,
        BibleNoteLocal(
          id: '${now.microsecondsSinceEpoch}',
          reference: reference,
          verseId: verseId,
          body: body,
          updatedAt: now,
        ),
      ];
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((n) => n.id != id).toList();
    await _persist();
  }
}

final notesProvider =
    StateNotifierProvider<NotesNotifier, List<BibleNoteLocal>>(
  NotesNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────
// Bookmarks
// ─────────────────────────────────────────────────────────────────────────

class BookmarksNotifier extends StateNotifier<List<BibleBookmarkLocal>> {
  BookmarksNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> _persist() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(state.map((b) => b.toJson()).toList());
    await prefs.setString(_kBookmarks, encoded);
  }

  Future<void> hydrate() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kBookmarks);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => BibleBookmarkLocal.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {/* keep empty */}
  }

  bool isBookmarked(String chapterId) =>
      state.any((b) => b.chapterId == chapterId);

  Future<void> toggle({
    required String bookId,
    required String chapterId,
    required String reference,
  }) async {
    final existing = state.where((b) => b.chapterId == chapterId).toList();
    if (existing.isNotEmpty) {
      state = state.where((b) => b.chapterId != chapterId).toList();
    } else {
      state = [
        ...state,
        BibleBookmarkLocal(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          bookId: bookId,
          chapterId: chapterId,
          reference: reference,
          createdAt: DateTime.now(),
        ),
      ];
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((b) => b.id != id).toList();
    await _persist();
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<BibleBookmarkLocal>>(
  BookmarksNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────
// Reading plan progress
// ─────────────────────────────────────────────────────────────────────────

class PlanProgressNotifier extends StateNotifier<List<BiblePlanProgress>> {
  PlanProgressNotifier(this._ref) : super(const []);

  final Ref _ref;

  Future<void> _persist() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final encoded = jsonEncode(state.map((p) => p.toJson()).toList());
    await prefs.setString(_kPlanProgress, encoded);
  }

  Future<void> hydrate() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kPlanProgress);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => BiblePlanProgress.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {/* keep empty */}
  }

  BiblePlanProgress? forPlan(String planId) {
    for (final p in state) {
      if (p.planId == planId) return p;
    }
    return null;
  }

  Future<void> start(String planId) async {
    if (forPlan(planId) != null) return;
    state = [
      ...state,
      BiblePlanProgress(
        planId: planId,
        currentIndex: 0,
        startedAt: DateTime.now(),
      ),
    ];
    await _persist();
  }

  Future<void> advance(String planId) async {
    state = state.map((p) {
      if (p.planId != planId) return p;
      return p.copyWith(currentIndex: p.currentIndex + 1);
    }).toList();
    await _persist();
  }

  Future<void> complete(String planId) async {
    state = state.map((p) {
      if (p.planId != planId) return p;
      return p.copyWith(completedAt: DateTime.now());
    }).toList();
    await _persist();
  }
}

final planProgressProvider =
    StateNotifierProvider<PlanProgressNotifier, List<BiblePlanProgress>>(
  PlanProgressNotifier.new,
);
