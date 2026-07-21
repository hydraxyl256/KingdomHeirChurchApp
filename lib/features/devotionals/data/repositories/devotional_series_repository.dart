// Kingdom Heir — Devotional Series Repository
//
// Handles:
//   - Fetching published devotional series and entries
//   - Translation-aware entry fetching (falls back to English)
//   - Progress initialization and day completion (via secure DB functions)
//   - Reflection journal read/write

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final devotionalSeriesRepositoryProvider =
    Provider<DevotionalSeriesRepository>((ref) {
  return SupabaseDevotionalSeriesRepository(Supabase.instance.client);
});

// ─── Abstract interface ───────────────────────────────────────────────────────

abstract class DevotionalSeriesRepository {
  /// All published series visible to users.
  Future<Either<String, List<DevotionalSeries>>> getPublishedSeries();

  /// Single series by ID.
  Future<Either<String, DevotionalSeries>> getSeriesById(String seriesId);

  /// The primary 90-Day Challenge series (is_primary_challenge_series=true).
  Future<Either<String, DevotionalSeries?>> getPrimaryChallengeSeries();

  /// All unlocked entries for the user (day_number ≤ highest_unlocked_day).
  Future<Either<String, List<DevotionalEntry>>> getUnlockedEntries(
    String seriesId,
  );

  /// A single entry, with translation merged when [languageCode] ≠ 'en'
  /// and a published translation exists.
  Future<Either<String, DevotionalEntry?>> getEntry(
    String seriesId,
    int dayNumber, {
    String languageCode,
  });

  /// Current user's progress for a series, null if not yet joined.
  Future<Either<String, DevotionalSeriesProgress?>> getProgress(
    String seriesId,
  );

  /// Initialize progress (idempotent) — call when user joins the challenge.
  Future<Either<String, DevotionalSeriesProgress>> initializeProgress(
    String seriesId,
  );

  /// Mark a day complete and unlock the next — enforced in DB.
  Future<Either<String, DevotionalSeriesProgress>> completeDay(
    String seriesId,
    int dayNumber,
  );

  /// Save or update the user's reflection for an entry.
  Future<Either<String, void>> saveReflection(
    String entryId,
    String reflectionText, {
    bool isPrivate,
  });

  /// Get the user's saved reflection for an entry, or null.
  Future<Either<String, DevotionalJournalReflection?>> getReflection(
    String entryId,
  );
}

// ─── Supabase implementation ──────────────────────────────────────────────────

class SupabaseDevotionalSeriesRepository implements DevotionalSeriesRepository {
  SupabaseDevotionalSeriesRepository(this._supabase);

  final SupabaseClient _supabase;

  // ── Series ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<DevotionalSeries>>> getPublishedSeries() async {
    try {
      final data = await _supabase
          .from('devotional_series')
          .select()
          .eq('status', 'published')
          .order('is_primary_challenge_series', ascending: false)
          .order('created_at', ascending: true);

      final list = data.map(DevotionalSeries.fromJson).toList();
      return right(list);
    } catch (e) {
      return left('Failed to load devotional series: $e');
    }
  }

  @override
  Future<Either<String, DevotionalSeries>> getSeriesById(
    String seriesId,
  ) async {
    try {
      final data = await _supabase
          .from('devotional_series')
          .select()
          .eq('id', seriesId)
          .single();
      return right(DevotionalSeries.fromJson(data));
    } catch (e) {
      return left('Failed to load series: $e');
    }
  }

  @override
  Future<Either<String, DevotionalSeries?>> getPrimaryChallengeSeries() async {
    try {
      final data = await _supabase
          .from('devotional_series')
          .select()
          .eq('status', 'published')
          .eq('is_primary_challenge_series', true)
          .maybeSingle();

      if (data == null) return right(null);
      return right(DevotionalSeries.fromJson(data));
    } catch (e) {
      return left('Failed to load primary series: $e');
    }
  }

  // ── Entries ────────────────────────────────────────────────────────────────

  @override
  Future<Either<String, List<DevotionalEntry>>> getUnlockedEntries(
    String seriesId,
  ) async {
    try {
      // RLS ensures day_number <= highest_unlocked_day on the server
      final data = await _supabase
          .from('devotional_entries')
          .select(
              'id, series_id, day_number, title, status, created_at, updated_at, estimated_read_minutes',)
          .eq('series_id', seriesId)
          .eq('status', 'published')
          .order('day_number', ascending: true);

      final list = data
          .map(
            DevotionalEntry.fromJson,
          )
          .toList();
      return right(list);
    } catch (e) {
      return left('Failed to load entries: $e');
    }
  }

  @override
  Future<Either<String, DevotionalEntry?>> getEntry(
    String seriesId,
    int dayNumber, {
    String languageCode = 'en',
  }) async {
    try {
      // 1. Fetch base entry
      final entryData = await _supabase
          .from('devotional_entries')
          .select()
          .eq('series_id', seriesId)
          .eq('day_number', dayNumber)
          .eq('status', 'published')
          .maybeSingle();

      if (entryData == null) return right(null);
      final entryMap = entryData;

      // 2. If non-English, try to fetch published translation
      Map<String, dynamic>? translationMap;
      if (languageCode != 'en') {
        final txData = await _supabase
            .from('devotional_translations')
            .select()
            .eq('devotional_entry_id', entryMap['id'] as String)
            .eq('language_code', languageCode)
            .eq('translation_status', 'published')
            .maybeSingle();

        translationMap = txData;
      }

      return right(
        DevotionalEntry.fromJson(
          entryMap,
          translationJson: translationMap,
        ),
      );
    } catch (e) {
      return left('Failed to load devotional entry: $e');
    }
  }

  // ── Progress ───────────────────────────────────────────────────────────────

  @override
  Future<Either<String, DevotionalSeriesProgress?>> getProgress(
    String seriesId,
  ) async {
    try {
      // Call the SECURITY DEFINER function — avoids direct RLS complexity
      final data = await _supabase.rpc<dynamic>('get_devotional_progress',
          params: {'p_series_id': seriesId},);

      if (data == null) return right(null);
      return right(
        DevotionalSeriesProgress.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return left('Failed to load progress: $e');
    }
  }

  @override
  Future<Either<String, DevotionalSeriesProgress>> initializeProgress(
    String seriesId,
  ) async {
    try {
      final data = await _supabase.rpc<dynamic>(
        'initialize_devotional_progress',
        params: {'p_series_id': seriesId},
      );
      return right(
        DevotionalSeriesProgress.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return left('Failed to initialize progress: $e');
    }
  }

  @override
  Future<Either<String, DevotionalSeriesProgress>> completeDay(
    String seriesId,
    int dayNumber,
  ) async {
    try {
      final data = await _supabase.rpc<dynamic>(
        'complete_devotional_day',
        params: {
          'p_series_id': seriesId,
          'p_day_number': dayNumber,
        },
      );
      return right(
        DevotionalSeriesProgress.fromJson(data as Map<String, dynamic>),
      );
    } on PostgrestException catch (e) {
      // Surface meaningful DB-level errors (locked day, not initialized)
      return left(e.message);
    } catch (e) {
      return left('Failed to complete day: $e');
    }
  }

  // ── Reflections ────────────────────────────────────────────────────────────

  @override
  Future<Either<String, void>> saveReflection(
    String entryId,
    String reflectionText, {
    bool isPrivate = true,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left('Not authenticated');

      await _supabase.from('devotional_reflections').upsert(
        {
          'user_id': userId,
          'devotional_entry_id': entryId,
          'reflection_text': reflectionText,
          'is_private': isPrivate,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,devotional_entry_id',
      );
      return right(null);
    } catch (e) {
      return left('Failed to save reflection: $e');
    }
  }

  @override
  Future<Either<String, DevotionalJournalReflection?>> getReflection(
    String entryId,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return right(null);

      final data = await _supabase
          .from('devotional_reflections')
          .select()
          .eq('user_id', userId)
          .eq('devotional_entry_id', entryId)
          .maybeSingle();

      if (data == null) return right(null);
      return right(
        DevotionalJournalReflection.fromJson(data),
      );
    } catch (e) {
      return left('Failed to load reflection: $e');
    }
  }
}
