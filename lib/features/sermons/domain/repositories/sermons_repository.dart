import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_continue_item.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_note.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_prayer_response.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_reflection.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_resource.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_series.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_speaker.dart';

abstract class SermonsRepository {
  // ─── Legacy (kept for backwards compatibility) ─────────────────────
  Future<Either<String, List<Sermon>>> getSermons({String languageCode = 'en'});
  Future<Either<String, void>> incrementViewCount(String sermonId);
  Future<Either<String, void>> updateWatchHistory(
    String sermonId,
    int positionSeconds, {
    required bool isCompleted,
  });

  // ─── Series & speakers ─────────────────────────────────────────────
  Future<Either<String, List<SermonSeries>>> getSeries();
  Future<Either<String, SermonSeries>> getSeriesById(String seriesId);
  Future<Either<String, List<SermonSpeaker>>> getSpeakers();
  Future<Either<String, SermonSpeaker?>> getSpeakerByName(String name);
  Future<Either<String, List<Sermon>>> getBySeries(String seriesId);

  // ─── Continue watching ─────────────────────────────────────────────
  Future<Either<String, List<SermonContinueItem>>> getContinueWatching();
  Future<Either<String, void>> recordWatchProgress({
    required String sermonId,
    required int positionSeconds,
    required bool isCompleted,
  });

  // ─── Downloads (audio-only, metadata persisted) ────────────────────
  Future<Either<String, List<SermonDownload>>> getDownloads();
  Future<Either<String, void>> registerDownload({
    required String sermonId,
    required String localPath,
    required int sizeBytes,
  });
  Future<Either<String, void>> removeDownload(String sermonId);

  // ─── Engagement (per-sermon, local-first) ──────────────────────────
  Future<Either<String, List<SermonNote>>> getNotes(String sermonId);
  Future<Either<String, void>> saveNote(SermonNote note);
  Future<Either<String, void>> deleteNote(String noteId);

  Future<Either<String, List<SermonReflection>>> getReflections(
    String sermonId,
  );
  Future<Either<String, void>> saveReflection(SermonReflection reflection);

  Future<Either<String, SermonPrayerResponse?>> getPrayerResponse(
    String sermonId,
  );
  Future<Either<String, void>> savePrayerResponse(
    SermonPrayerResponse response,
  );

  // ─── Discovery feeds ───────────────────────────────────────────────
  Future<Either<String, List<Sermon>>> getTrending();
  Future<Either<String, List<Sermon>>> getMostViewed();
  Future<Either<String, List<Sermon>>> getRecentlyAdded();
  Future<Either<String, List<Sermon>>> getRecommended();
  Future<Either<String, List<Sermon>>> getBySpeaker(
    String speakerName, {
    int limit = 10,
  });
  Future<Either<String, List<Sermon>>> getByScripture(String book, int chapter);
  Future<Either<String, List<Sermon>>> getByTopic(String topic);
  Future<Either<String, Sermon?>> getSermonById(String id);

  // ─── Resources ─────────────────────────────────────────────────────
  Future<Either<String, List<SermonResource>>> getResources(String sermonId);
}
