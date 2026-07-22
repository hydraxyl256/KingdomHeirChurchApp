import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/media/domain/entities/media_content_model.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_note.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_prayer_response.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_reflection.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_resource.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_speaker.dart';
import 'package:kingdom_heir/features/sermons/domain/repositories/sermons_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SermonsRepositoryImpl implements SermonsRepository {
  SermonsRepositoryImpl(this._supabase, this._prefs);

  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  // ─── Storage keys ──────────────────────────────────────────────────
  static const String _kContinue = 'sermon_continue_v1';
  static const String _kDownloads = 'sermon_downloads_v1';
  static const String _kNotesPrefix = 'sermon_notes_v1::';
  static const String _kReflectionsPrefix = 'sermon_reflections_v1::';
  static const String _kPrayerPrefix = 'sermon_prayer_v1::';
  static const String _kSermonsCache = 'sermons_cache_v2';

  // ─── Cache mechanism ───────────────────────────────────────────────

  Future<List<Sermon>> _getAllProductionSermons() async {
    try {
      final response = await _supabase
          .from('media_content')
          .select()
          .eq('status', 'published')
          .eq('content_type', 'sermon')
          .order('published_at', ascending: false);

      if (response.isNotEmpty) {
        await _prefs.setString(_kSermonsCache, jsonEncode(response));
        return response
            .map((json) => MediaContentModel.fromJson(json).toSermon())
            .toList();
      }
    } catch (_) {}

    // Offline Fallback to SharedPreferences
    final cached = _prefs.getString(_kSermonsCache);
    if (cached != null && cached.isNotEmpty) {
      try {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded
            .map((json) => MediaContentModel.fromJson(json as Map<String, dynamic>).toSermon())
            .toList();
      } catch (_) {}
    }
    return [];
  }

  Future<Sermon?> _findSermon(String id) async {
    final all = await _getAllProductionSermons();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ─── Primary source: media_content (YouTube catalog) ─────────────────

  @override
  Future<Either<String, List<Sermon>>> getSermons({String languageCode = 'en'}) async {
    final all = await _getAllProductionSermons();
    return right(all);
  }

  /// Returns only featured media_content sermons (is_featured = true).
  Future<Either<String, List<Sermon>>> getFeaturedSermons() async {
    try {
      final response = await _supabase
          .from('media_content')
          .select()
          .eq('status', 'published')
          .not('youtube_video_id', 'is', null)
          .eq('is_featured', true)
          .order('sort_order', ascending: true);

      return right(
        (response as List<dynamic>)
            .map((json) => MediaContentModel.fromJson(json as Map<String, dynamic>).toSermon())
            .toList(),
      );
    } catch (_) {
      final all = await _getAllProductionSermons();
      return right(all.where((s) => s.trendingScore >= 100).toList());
    }
  }

  @override
  Future<Either<String, void>> incrementViewCount(String sermonId) async {
    try {
      await _supabase.rpc<void>('increment_sermon_views', params: {'s_id': sermonId});
    } catch (_) {}
    return right(null);
  }

  @override
  Future<Either<String, void>> updateWatchHistory(
    String sermonId,
    int positionSeconds, {
    required bool isCompleted,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return right(null);
      await _supabase.from('sermon_watch_history').upsert({
        'user_id': user.id,
        'sermon_id': sermonId,
        'position_seconds': positionSeconds,
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
    return right(null);
  }

  // ─── Series & speakers ─────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonSeries>>> getSeries() async {
    final all = await _getAllProductionSermons();
    final map = <String, SermonSeries>{};
    for (final s in all) {
      if (s.seriesName.isEmpty) continue;
      if (!map.containsKey(s.seriesName)) {
        map[s.seriesName] = SermonSeries(
          id: s.seriesName,
          title: s.seriesName,
          description: '',
          pastorName: s.speakerName,
          startedOn: s.publishedAt,
          episodeCount: 1,
          coverGradient: const [],
          scriptureAnchor: s.scriptures.isNotEmpty ? s.scriptures.first.label : '',
        );
      } else {
        final existing = map[s.seriesName]!;
        map[s.seriesName] = SermonSeries(
          id: existing.id,
          title: existing.title,
          description: existing.description,
          pastorName: existing.pastorName,
          startedOn: existing.startedOn,
          episodeCount: existing.episodeCount + 1,
          coverGradient: existing.coverGradient,
          scriptureAnchor: existing.scriptureAnchor,
          completedCount: existing.completedCount,
        );
      }
    }
    return right(map.values.toList());
  }

  @override
  Future<Either<String, SermonSeries>> getSeriesById(String seriesId) async {
    final seriesEither = await getSeries();
    final list = seriesEither.getOrElse((_) => []);
    for (final s in list) {
      if (s.id == seriesId) return right(s);
    }
    return const Left('Series not found');
  }

  @override
  Future<Either<String, List<SermonSpeaker>>> getSpeakers() async {
    final all = await _getAllProductionSermons();
    final map = <String, SermonSpeaker>{};
    for (final s in all) {
      if (s.speakerName.isEmpty) continue;
      if (!map.containsKey(s.speakerName)) {
        map[s.speakerName] = SermonSpeaker(
          id: s.speakerName,
          name: s.speakerName,
          role: 'Speaker',
          bio: '',
          sermonCount: 1,
        );
      } else {
        final existing = map[s.speakerName]!;
        map[s.speakerName] = SermonSpeaker(
          id: existing.id,
          name: existing.name,
          role: existing.role,
          bio: existing.bio,
          sermonCount: existing.sermonCount + 1,
          languages: existing.languages,
          yearsInMinistry: existing.yearsInMinistry,
        );
      }
    }
    return right(map.values.toList());
  }

  @override
  Future<Either<String, SermonSpeaker?>> getSpeakerByName(String name) async {
    final speakersEither = await getSpeakers();
    final list = speakersEither.getOrElse((_) => []);
    for (final s in list) {
      if (s.name == name) return right(s);
    }
    return right(null);
  }

  @override
  Future<Either<String, List<Sermon>>> getBySeries(String seriesId) async {
    final all = await _getAllProductionSermons();
    return right(all.where((s) => s.seriesName == seriesId).toList());
  }

  // ─── Continue watching ─────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonContinueItem>>> getContinueWatching() async {
    final raw = _prefs.getString(_kContinue);
    if (raw == null || raw.isEmpty) return right([]);
    try {
      final items = <SermonContinueItem>[];
      for (final entry in raw.split(',')) {
        if (entry.isEmpty) continue;
        final parts = entry.split(':');
        if (parts.length < 4) continue;
        final sermonId = parts[0];
        final pos = int.tryParse(parts[1]) ?? 0;
        final total = int.tryParse(parts[2]) ?? 0;
        final date = DateTime.tryParse(parts[3]) ?? DateTime.now();
        final sermon = await _findSermon(sermonId);
        if (sermon != null) {
          items.add(
            SermonContinueItem(
              sermon: sermon,
              positionSeconds: pos,
              totalSeconds: total == 0 ? sermon.durationSeconds : total,
              lastWatchedAt: date,
              isCompleted: pos >= total && total > 0,
            ),
          );
        }
      }
      return right(items);
    } catch (_) {
      return right([]);
    }
  }

  @override
  Future<Either<String, void>> recordWatchProgress({
    required String sermonId,
    required int positionSeconds,
    required bool isCompleted,
  }) async {
    final sermon = await _findSermon(sermonId);
    if (sermon == null) return const Left('Sermon not found');

    final items = await getContinueWatching();
    final list = <SermonContinueItem>[
      ...items.getOrElse((_) => <SermonContinueItem>[]),
    ]
      ..removeWhere((i) => i.sermon.id == sermonId)
      ..insert(
        0,
        SermonContinueItem(
          sermon: sermon,
          positionSeconds: positionSeconds,
          totalSeconds: sermon.durationSeconds,
          lastWatchedAt: DateTime.now(),
          isCompleted: isCompleted,
        ),
      );
    final encoded = list
        .map((i) => '${i.sermon.id}:${i.positionSeconds}:${i.totalSeconds}:${i.lastWatchedAt.toIso8601String()}')
        .join(',');
    await _prefs.setString(_kContinue, encoded);
    return right(null);
  }

  // ─── Downloads ─────────────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonDownload>>> getDownloads() async {
    final raw = _prefs.getString(_kDownloads);
    if (raw == null || raw.isEmpty) return right([]);
    try {
      final items = <SermonDownload>[];
      for (final entry in raw.split('|')) {
        if (entry.isEmpty) continue;
        final parts = entry.split(';');
        if (parts.length < 5) continue;
        items.add(
          SermonDownload(
            sermonId: parts[0],
            localPath: parts[1],
            downloadedAt: DateTime.tryParse(parts[2]) ?? DateTime.now(),
            sizeBytes: int.tryParse(parts[3]) ?? 0,
            completed: parts[4] == '1',
          ),
        );
      }
      return right(items);
    } catch (_) {
      return right([]);
    }
  }

  @override
  Future<Either<String, void>> registerDownload({
    required String sermonId,
    required String localPath,
    required int sizeBytes,
  }) async {
    final items = await getDownloads();
    final list = <SermonDownload>[
      ...items.getOrElse((_) => <SermonDownload>[]),
    ]
      ..removeWhere((d) => d.sermonId == sermonId)
      ..insert(
        0,
        SermonDownload(
          sermonId: sermonId,
          localPath: localPath,
          downloadedAt: DateTime.now(),
          sizeBytes: sizeBytes,
          completed: true,
        ),
      );
    final encoded = list
        .map((d) => '${d.sermonId};${d.localPath};${d.downloadedAt.toIso8601String()};${d.sizeBytes};${d.completed ? 1 : 0}')
        .join('|');
    await _prefs.setString(_kDownloads, encoded);
    return right(null);
  }

  @override
  Future<Either<String, void>> removeDownload(String sermonId) async {
    final items = await getDownloads();
    final list = <SermonDownload>[
      ...items.getOrElse((_) => <SermonDownload>[]),
    ]..removeWhere((d) => d.sermonId == sermonId);
    final encoded = list
        .map((d) => '${d.sermonId};${d.localPath};${d.downloadedAt.toIso8601String()};${d.sizeBytes};${d.completed ? 1 : 0}')
        .join('|');
    await _prefs.setString(_kDownloads, encoded);
    return right(null);
  }

  // ─── Engagement — notes ───────────────────────────────────────────

  @override
  Future<Either<String, List<SermonNote>>> getNotes(String sermonId) async {
    final raw = _prefs.getString('$_kNotesPrefix$sermonId');
    final fromUser = <SermonNote>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        for (final entry in raw.split('|')) {
          if (entry.isEmpty) continue;
          final parts = entry.split(';');
          if (parts.length < 4) continue;
          fromUser.add(
            SermonNote(
              id: parts[0],
              sermonId: parts[1],
              body: parts[2],
              createdAt: DateTime.tryParse(parts[3]) ?? DateTime.now(),
              timestampSeconds: parts.length >= 5 ? int.tryParse(parts[4]) : null,
            ),
          );
        }
      } catch (_) {}
    }
    return right(fromUser..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Either<String, void>> saveNote(SermonNote note) async {
    final currentEither = await getNotes(note.sermonId);
    final list = <SermonNote>[
      ...currentEither.getOrElse((_) => <SermonNote>[]),
    ]
      ..removeWhere((n) => n.id == note.id)
      ..insert(0, note)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = list
        .map((n) => '${n.id};${n.sermonId};${_escape(n.body)};${n.createdAt.toIso8601String()};${n.timestampSeconds ?? ''}')
        .join('|');
    await _prefs.setString('$_kNotesPrefix${note.sermonId}', encoded);
    return right(null);
  }

  @override
  Future<Either<String, void>> deleteNote(String noteId) async {
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(_kNotesPrefix)) continue;
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      final ids = raw.split('|').where((e) => e.isNotEmpty && !e.startsWith('$noteId;'));
      await _prefs.setString(key, ids.join('|'));
    }
    return right(null);
  }

  // ─── Engagement — reflections ──────────────────────────────────────

  @override
  Future<Either<String, List<SermonReflection>>> getReflections(String sermonId) async {
    final raw = _prefs.getString('$_kReflectionsPrefix$sermonId');
    final fromUser = <SermonReflection>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        for (final entry in raw.split('|')) {
          if (entry.isEmpty) continue;
          final parts = entry.split(';');
          if (parts.length < 5) continue;
          fromUser.add(
            SermonReflection(
              id: parts[0],
              sermonId: parts[1],
              question: parts[2],
              answer: parts[3],
              createdAt: DateTime.tryParse(parts[4]) ?? DateTime.now(),
            ),
          );
        }
      } catch (_) {}
    }
    return right(fromUser..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Either<String, void>> saveReflection(SermonReflection reflection) async {
    final currentEither = await getReflections(reflection.sermonId);
    final list = <SermonReflection>[
      ...currentEither.getOrElse((_) => <SermonReflection>[]),
    ]
      ..removeWhere((r) => r.id == reflection.id)
      ..insert(0, reflection)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = list
        .map((r) => '${r.id};${r.sermonId};${_escape(r.question)};${_escape(r.answer)};${r.createdAt.toIso8601String()}')
        .join('|');
    await _prefs.setString('$_kReflectionsPrefix${reflection.sermonId}', encoded);
    return right(null);
  }

  // ─── Engagement — prayer ───────────────────────────────────────────

  @override
  Future<Either<String, SermonPrayerResponse?>> getPrayerResponse(String sermonId) async {
    final raw = _prefs.getString('$_kPrayerPrefix$sermonId');
    if (raw != null && raw.isNotEmpty) {
      try {
        final parts = raw.split(';');
        if (parts.length >= 5) {
          return right(
            SermonPrayerResponse(
              id: parts[0],
              sermonId: parts[1],
              body: parts[2],
              createdAt: DateTime.tryParse(parts[3]) ?? DateTime.now(),
              isPrivate: parts[4] == '1',
            ),
          );
        }
      } catch (_) {}
    }
    return right(null);
  }

  @override
  Future<Either<String, void>> savePrayerResponse(SermonPrayerResponse response) async {
    final encoded = '${response.id};${response.sermonId};${_escape(response.body)};${response.createdAt.toIso8601String()};${response.isPrivate ? 1 : 0}';
    await _prefs.setString('$_kPrayerPrefix${response.sermonId}', encoded);
    return right(null);
  }

  // ─── Discovery feeds ───────────────────────────────────────────────

  @override
  Future<Either<String, List<Sermon>>> getTrending() async {
    final list = await _getAllProductionSermons();
    list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getMostViewed() async {
    final list = await _getAllProductionSermons();
    list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getRecentlyAdded() async {
    final list = await _getAllProductionSermons();
    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getRecommended() async {
    final list = await _getAllProductionSermons();
    return right(list.take(6).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getBySpeaker(
    String speakerName, {
    int limit = 10,
  }) async {
    final list = await _getAllProductionSermons();
    return right(list.where((s) => s.speakerName == speakerName).take(limit).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getByScripture(
    String book,
    int chapter,
  ) async {
    final all = await _getAllProductionSermons();
    final out = <Sermon>[];
    for (final s in all) {
      for (final ref in s.scriptures) {
        if (ref.book.toLowerCase() == book.toLowerCase() && ref.chapter == chapter) {
          out.add(s);
          break;
        }
      }
    }
    return right(out);
  }

  @override
  Future<Either<String, List<Sermon>>> getByTopic(String topic) async {
    final all = await _getAllProductionSermons();
    return right(all.where((s) => s.topics.contains(topic)).toList());
  }

  @override
  Future<Either<String, Sermon?>> getSermonById(String id) async {
    return right(await _findSermon(id));
  }

  // ─── Resources ─────────────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonResource>>> getResources(String sermonId) async {
    return right([]); // Production resources not yet implemented via Supabase
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  String _escape(String input) => input.replaceAll(r'\;', r'\\;').replaceAll(r'\|', r'\\|');
}
