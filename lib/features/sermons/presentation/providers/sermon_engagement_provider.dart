// Kingdom Heir — Sermon Engagement Provider
//
// Notes / reflections / prayer responses, all persisted to
// SharedPreferences. Per-sermon, user-scoped, local-first.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/sermons/domain/entities/sermon_note.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_prayer_response.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_reflection.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';

// ─── Notes ──────────────────────────────────────────────────────────

final notesBySermonProvider =
    FutureProvider.family<List<SermonNote>, String>((ref, sermonId) async {
  final result = await ref.watch(sermonsRepositoryProvider).getNotes(sermonId);
  return result.fold(
    (_) => throw Exception('Failed to load notes'),
    (r) => r,
  );
});

class NotesController {
  NotesController(this._ref);
  final Ref _ref;

  Future<void> addNote({
    required String sermonId,
    required String body,
    int? timestampSeconds,
  }) async {
    final note = SermonNote(
      id: 'note-${DateTime.now().microsecondsSinceEpoch}',
      sermonId: sermonId,
      body: body,
      createdAt: DateTime.now(),
      timestampSeconds: timestampSeconds,
    );
    await _ref.read(sermonsRepositoryProvider).saveNote(note);
    _ref.invalidate(notesBySermonProvider(sermonId));
  }

  Future<void> updateNote(SermonNote note) async {
    await _ref.read(sermonsRepositoryProvider).saveNote(note);
    _ref.invalidate(notesBySermonProvider(note.sermonId));
  }

  Future<void> deleteNote(String noteId, String sermonId) async {
    await _ref.read(sermonsRepositoryProvider).deleteNote(noteId);
    _ref.invalidate(notesBySermonProvider(sermonId));
  }
}

final notesControllerProvider = Provider<NotesController>((ref) {
  return NotesController(ref);
});

// ─── Reflections ────────────────────────────────────────────────────

final reflectionsBySermonProvider =
    FutureProvider.family<List<SermonReflection>, String>(
        (ref, sermonId) async {
  final result =
      await ref.watch(sermonsRepositoryProvider).getReflections(sermonId);
  return result.fold(
    (_) => throw Exception('Failed to load reflections'),
    (r) => r,
  );
});

class ReflectionsController {
  ReflectionsController(this._ref);
  final Ref _ref;

  Future<void> saveReflection({
    required String sermonId,
    required String question,
    required String answer,
  }) async {
    final reflection = SermonReflection(
      id: 'refl-${DateTime.now().microsecondsSinceEpoch}',
      sermonId: sermonId,
      question: question,
      answer: answer,
      createdAt: DateTime.now(),
    );
    await _ref.read(sermonsRepositoryProvider).saveReflection(reflection);
    _ref.invalidate(reflectionsBySermonProvider(sermonId));
  }
}

final reflectionsControllerProvider = Provider<ReflectionsController>((ref) {
  return ReflectionsController(ref);
});

// ─── Prayer response ────────────────────────────────────────────────

final prayerResponseBySermonProvider =
    FutureProvider.family<SermonPrayerResponse?, String>((ref, sermonId) async {
  final result =
      await ref.watch(sermonsRepositoryProvider).getPrayerResponse(sermonId);
  return result.fold(
    (_) => throw Exception('Failed to load prayer response'),
    (r) => r,
  );
});

class PrayerController {
  PrayerController(this._ref);
  final Ref _ref;

  Future<void> savePrayerResponse({
    required String sermonId,
    required String body,
    required bool isPrivate,
  }) async {
    final response = SermonPrayerResponse(
      id: 'pray-${DateTime.now().microsecondsSinceEpoch}',
      sermonId: sermonId,
      body: body,
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
    );
    await _ref.read(sermonsRepositoryProvider).savePrayerResponse(response);
    _ref.invalidate(prayerResponseBySermonProvider(sermonId));
  }
}

final prayerControllerProvider = Provider<PrayerController>((ref) {
  return PrayerController(ref);
});
