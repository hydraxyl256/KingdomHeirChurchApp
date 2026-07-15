import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/sermons/data/mock/mock_sermons_seed.dart';
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

  // ─── Primary source: media_content (YouTube catalog) ─────────────────

  @override
  Future<Either<String, List<Sermon>>> getSermons() async {
    // 1. Try the new YouTube media catalog first
    try {
      final response = await _supabase
          .from('media_content')
          .select()
          .eq('status', 'published')
          .eq('content_type', 'sermon')
          .order('published_at', ascending: false);

      if (response.isNotEmpty) {
        return right(
          response
              .map(Sermon.fromMediaContent)
              .toList(),
        );
      }
    } catch (_) {
      // media_content table not yet migrated — fall through
    }

    // 2. Fall back to the legacy sermons table
    try {
      final response = await _supabase
          .from('sermons')
          .select('*, sermon_series(title)')
          .eq('status', 'published')
          .order('preached_on', ascending: false);

      if (response.isNotEmpty) {
        return right(
          response
              .map(Sermon.fromJson)
              .toList(),
        );
      }
    } catch (_) {
      // Legacy table also unavailable — fall through to mock
    }

    // 3. Mock seed (development / CI only)
    return right(MockSermonSeed.allSermons);
  }

  /// Returns only featured media_content sermons (is_featured = true).
  Future<Either<String, List<Sermon>>> getFeaturedSermons() async {
    try {
      final response = await _supabase
          .from('media_content')
          .select()
          .eq('status', 'published')
          .eq('content_type', 'sermon')
          .eq('is_featured', true)
          .order('sort_order', ascending: true);

      return right(
        (response as List<dynamic>)
            .map((json) => Sermon.fromMediaContent(json as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return right(const []);
    }
  }

  @override
  Future<Either<String, void>> incrementViewCount(String sermonId) async {
    try {
      await _supabase
          .rpc<void>('increment_sermon_views', params: {'s_id': sermonId});
    } catch (_) {
      // Silent — analytics only.
    }
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
    } catch (_) {
      // Silent.
    }
    return right(null);
  }

  // ─── Series & speakers ─────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonSeries>>> getSeries() async {
    return right(MockSermonSeed.allSeries);
  }

  @override
  Future<Either<String, SermonSeries>> getSeriesById(String seriesId) async {
    final match = MockSermonSeed.allSeries
        .where((s) => s.id == seriesId)
        .cast<SermonSeries?>()
        .firstWhere((_) => true, orElse: () => null);
    if (match == null) {
      return const Left('Series not found');
    }
    return right(match);
  }

  @override
  Future<Either<String, List<SermonSpeaker>>> getSpeakers() async {
    return right(MockSermonSeed.allSpeakers);
  }

  @override
  Future<Either<String, SermonSpeaker?>> getSpeakerByName(String name) async {
    for (final s in MockSermonSeed.allSpeakers) {
      if (s.name == name) return right(s);
    }
    return right(null);
  }

  @override
  Future<Either<String, List<Sermon>>> getBySeries(String seriesId) async {
    final series = MockSermonSeed.allSeries
        .where((s) => s.id == seriesId)
        .cast<SermonSeries?>()
        .firstWhere((_) => true, orElse: () => null);
    if (series == null) return const Left('Series not found');
    return right(MockSermonSeed.sermonsBySeries(series.title));
  }

  // ─── Continue watching ─────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonContinueItem>>> getContinueWatching() async {
    final raw = _prefs.getString(_kContinue);
    if (raw == null || raw.isEmpty) {
      return right(MockSermonSeed.seedContinueWatching);
    }
    try {
      // Format: "sermonId:pos:total:isoDate,..."
      final items = <SermonContinueItem>[];
      for (final entry in raw.split(',')) {
        if (entry.isEmpty) continue;
        final parts = entry.split(':');
        if (parts.length < 4) continue;
        final sermonId = parts[0];
        final pos = int.tryParse(parts[1]) ?? 0;
        final total = int.tryParse(parts[2]) ?? 0;
        final date = DateTime.tryParse(parts[3]) ?? DateTime.now();
        final sermon = MockSermonSeed.findSermon(sermonId);
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
      // Merge in any seed items that aren't already in the persisted list.
      final persistedIds = items.map((i) => i.sermon.id).toSet();
      for (final seedItem in MockSermonSeed.seedContinueWatching) {
        if (!persistedIds.contains(seedItem.sermon.id)) {
          items.add(seedItem);
        }
      }
      return right(items);
    } catch (_) {
      return right(MockSermonSeed.seedContinueWatching);
    }
  }

  @override
  Future<Either<String, void>> recordWatchProgress({
    required String sermonId,
    required int positionSeconds,
    required bool isCompleted,
  }) async {
    final sermon = MockSermonSeed.findSermon(sermonId);
    if (sermon == null) return const Left('Sermon not found');

    final items = await getContinueWatching();
    final list = <SermonContinueItem>[
      ...items.getOrElse((_) => <SermonContinueItem>[]),
    ]..removeWhere((i) => i.sermon.id == sermonId)
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
        .map(
          (i) =>
              '${i.sermon.id}:${i.positionSeconds}:${i.totalSeconds}:${i.lastWatchedAt.toIso8601String()}',
        )
        .join(',');
    await _prefs.setString(_kContinue, encoded);
    return right(null);
  }

  // ─── Downloads ─────────────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonDownload>>> getDownloads() async {
    final raw = _prefs.getString(_kDownloads);
    if (raw == null || raw.isEmpty) {
      return right(MockSermonSeed.seedDownloads);
    }
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
      return right(MockSermonSeed.seedDownloads);
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
    ]..removeWhere((d) => d.sermonId == sermonId)
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
        .map(
          (d) =>
              '${d.sermonId};${d.localPath};${d.downloadedAt.toIso8601String()};${d.sizeBytes};${d.completed ? 1 : 0}',
        )
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
        .map(
          (d) =>
              '${d.sermonId};${d.localPath};${d.downloadedAt.toIso8601String()};${d.sizeBytes};${d.completed ? 1 : 0}',
        )
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
              timestampSeconds:
                  parts.length >= 5 ? int.tryParse(parts[4]) : null,
            ),
          );
        }
      } catch (_) {/* ignore */}
    }
    // Merge in seed notes for this sermon that aren't already present.
    final fromSeed =
        MockSermonSeed.seedNotes.where((n) => n.sermonId == sermonId).toList();
    final userIds = fromUser.map((n) => n.id).toSet();
    final merged = <SermonNote>[
      ...fromUser,
      ...fromSeed.where((n) => !userIds.contains(n.id)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(merged);
  }

  @override
  Future<Either<String, void>> saveNote(SermonNote note) async {
    final currentEither = await getNotes(note.sermonId);
    final list = <SermonNote>[
      ...currentEither.getOrElse((_) => <SermonNote>[]),
    ]..removeWhere((n) => n.id == note.id)
      ..insert(0, note)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = list
        .map(
          (n) =>
              '${n.id};${n.sermonId};${_escape(n.body)};${n.createdAt.toIso8601String()};${n.timestampSeconds ?? ''}',
        )
        .join('|');
    await _prefs.setString('$_kNotesPrefix${note.sermonId}', encoded);
    return right(null);
  }

  @override
  Future<Either<String, void>> deleteNote(String noteId) async {
    // Walk all per-sermon note keys and remove the matching id.
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(_kNotesPrefix)) continue;
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      final ids = raw
          .split('|')
          .where((e) => e.isNotEmpty && !e.startsWith('$noteId;'));
      await _prefs.setString(key, ids.join('|'));
    }
    return right(null);
  }

  // ─── Engagement — reflections ──────────────────────────────────────

  @override
  Future<Either<String, List<SermonReflection>>> getReflections(
    String sermonId,
  ) async {
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
      } catch (_) {/* ignore */}
    }
    final fromSeed = MockSermonSeed.seedReflections
        .where((r) => r.sermonId == sermonId)
        .toList();
    final userIds = fromUser.map((r) => r.id).toSet();
    final merged = <SermonReflection>[
      ...fromUser,
      ...fromSeed.where((r) => !userIds.contains(r.id)),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return right(merged);
  }

  @override
  Future<Either<String, void>> saveReflection(
      SermonReflection reflection,) async {
    final currentEither = await getReflections(reflection.sermonId);
    final list = <SermonReflection>[
      ...currentEither.getOrElse((_) => <SermonReflection>[]),
    ]..removeWhere((r) => r.id == reflection.id)
      ..insert(0, reflection)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final encoded = list
        .map(
          (r) =>
              '${r.id};${r.sermonId};${_escape(r.question)};${_escape(r.answer)};${r.createdAt.toIso8601String()}',
        )
        .join('|');
    await _prefs.setString(
      '$_kReflectionsPrefix${reflection.sermonId}',
      encoded,
    );
    return right(null);
  }

  // ─── Engagement — prayer ───────────────────────────────────────────

  @override
  Future<Either<String, SermonPrayerResponse?>> getPrayerResponse(
    String sermonId,
  ) async {
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
      } catch (_) {/* ignore */}
    }
    for (final p in MockSermonSeed.seedPrayerResponses) {
      if (p.sermonId == sermonId) return right(p);
    }
    return right(null);
  }

  @override
  Future<Either<String, void>> savePrayerResponse(
    SermonPrayerResponse response,
  ) async {
    final encoded =
        '${response.id};${response.sermonId};${_escape(response.body)};${response.createdAt.toIso8601String()};${response.isPrivate ? 1 : 0}';
    await _prefs.setString('$_kPrayerPrefix${response.sermonId}', encoded);
    return right(null);
  }

  // ─── Discovery feeds ───────────────────────────────────────────────

  @override
  Future<Either<String, List<Sermon>>> getTrending() async {
    final list = List<Sermon>.from(MockSermonSeed.allSermons)
      ..sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getMostViewed() async {
    final list = List<Sermon>.from(MockSermonSeed.allSermons)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getRecentlyAdded() async {
    final list = List<Sermon>.from(MockSermonSeed.allSermons)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return right(list.take(8).toList());
  }

  @override
  Future<Either<String, List<Sermon>>> getRecommended() async {
    // Heuristic: sermons whose topics overlap with the most-recently
    // watched sermon in the seed continue list.
    final reference = MockSermonSeed.seedContinueWatching.isEmpty
        ? null
        : MockSermonSeed.seedContinueWatching.first.sermon;
    if (reference == null) {
      return right(MockSermonSeed.allSermons.take(6).toList());
    }
    final scored = <(Sermon, int)>[];
    for (final s in MockSermonSeed.allSermons) {
      if (s.id == reference.id) continue;
      final overlap = s.topics.toSet().intersection(reference.topics.toSet());
      if (overlap.isNotEmpty) {
        scored.add((s, overlap.length));
      }
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    final top = scored.map((e) => e.$1).take(6).toList();
    if (top.length < 6) {
      // Pad with the highest-viewed sermons.
      final pad = MockSermonSeed.allSermons
          .where((s) => !top.any((t) => t.id == s.id))
          .take(6 - top.length);
      top.addAll(pad);
    }
    return right(top);
  }

  @override
  Future<Either<String, List<Sermon>>> getBySpeaker(
    String speakerName, {
    int limit = 10,
  }) async {
    return right(
        MockSermonSeed.sermonsBySpeaker(speakerName).take(limit).toList(),);
  }

  @override
  Future<Either<String, List<Sermon>>> getByScripture(
    String book,
    int chapter,
  ) async {
    final out = <Sermon>[];
    for (final s in MockSermonSeed.allSermons) {
      for (final ref in s.scriptures) {
        if (ref.book.toLowerCase() == book.toLowerCase() &&
            ref.chapter == chapter) {
          out.add(s);
          break;
        }
      }
    }
    return right(out);
  }

  @override
  Future<Either<String, List<Sermon>>> getByTopic(String topic) async {
    return right(MockSermonSeed.sermonsByTopic(topic));
  }

  @override
  Future<Either<String, Sermon?>> getSermonById(String id) async {
    return right(MockSermonSeed.findSermon(id));
  }

  // ─── Resources ─────────────────────────────────────────────────────

  @override
  Future<Either<String, List<SermonResource>>> getResources(
    String sermonId,
  ) async {
    // Seed a small fixture per sermon — alternating PDFs and links.
    final sermon = MockSermonSeed.findSermon(sermonId);
    if (sermon == null) return right(<SermonResource>[]);
    final id = int.tryParse(sermonId.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final hasPdf = id.isEven;
    return right(<SermonResource>[
      SermonResource(
        id: '$sermonId-res-1',
        title: 'Study Guide — ${sermon.seriesName}',
        kind: hasPdf ? SermonResourceKind.pdf : SermonResourceKind.link,
        url: hasPdf
            ? 'https://example.com/$sermonId/guide.pdf'
            : 'https://example.com/$sermonId/guide',
        sizeBytes: hasPdf ? 350000 : null,
      ),
      if (sermon.scriptures.isNotEmpty)
        SermonResource(
          id: '$sermonId-res-2',
          title: 'Scripture Sheet — ${sermon.primaryScripture}',
          kind: SermonResourceKind.pdf,
          url: 'https://example.com/$sermonId/scripture.pdf',
          sizeBytes: 180000,
        ),
      if (sermon.hasAudio)
        SermonResource(
          id: '$sermonId-res-3',
          title: 'Audio clip — first 60s',
          kind: SermonResourceKind.audio,
          url: '${sermon.audioUrl ?? ''}#t=0,60',
          sizeBytes: 900000,
        ),
    ]);
  }

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Escape `;` and `|` characters so we can round-trip free text in
  /// the compact `;`-delimited / `|`-delimited preference format.
  String _escape(String input) =>
      input.replaceAll(r'\;', r'\\;').replaceAll(r'\|', r'\\|');
}
