// Kingdom Heir — Sermon Domain Entity
//
// Core media record for a church message. Carries everything needed to
// render the home / library / details / player surfaces, plus the fields
// the new platform surfaces rely on (scriptures list, topics, ministry,
// trendingScore, updatedAt).
//
// Backwards compatibility: keeps the existing `scriptureReference`
// string label for the legacy list/grid subtitle and `fromJson` for
// Supabase decoding.

import 'package:equatable/equatable.dart';

/// Media type of a sermon.
enum SermonMediaType { video, audio, both }

/// A single scripture reference attached to a sermon.
class SermonScriptureRef extends Equatable {
  const SermonScriptureRef({
    required this.book,
    required this.chapter,
    required this.verse,
    this.endVerse,
  });

  factory SermonScriptureRef.parse(String raw) {
    // Accepts "Book C:V" or "Book C:V-V2" (case-insensitive, spaces flexible).
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final match = RegExp(r'^(\d?\s?[A-Za-z]+)\s+(\d+):(\d+)(?:-(\d+))?$')
        .firstMatch(cleaned);
    if (match == null) {
      return SermonScriptureRef(book: cleaned, chapter: 1, verse: 1);
    }
    return SermonScriptureRef(
      book: match.group(1)!.trim(),
      chapter: int.parse(match.group(2)!),
      verse: int.parse(match.group(3)!),
      endVerse: int.tryParse(match.group(4) ?? ''),
    );
  }

  factory SermonScriptureRef.fromJson(Map<String, dynamic> json) =>
      SermonScriptureRef(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        endVerse: json['end_verse'] as int?,
      );

  final String book;
  final int chapter;
  final int verse;
  final int? endVerse;

  /// Display label e.g. "John 3:16" or "John 3:16-18".
  String get label => endVerse == null
      ? '$book $chapter:$verse'
      : '$book $chapter:$verse-$endVerse';

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'end_verse': endVerse,
      };

  @override
  List<Object?> get props => [book, chapter, verse, endVerse];
}

/// Domain entity for a Sermon.
class Sermon extends Equatable {
  const Sermon({
    required this.id,
    required this.title,
    required this.speakerName,
    required this.seriesName,
    required this.publishedAt,
    required this.durationSeconds,
    required this.mediaType,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.scriptureReference,
    this.description,
    this.isLive = false,
    this.youtubeId,
    this.hlsStreamUrl,
    this.isFavorited = false,
    this.isDownloaded = false,
    this.viewCount = 0,
    this.tags = const [],
    this.scriptures = const [],
    this.topics = const [],
    this.ministry,
    this.trendingScore = 0,
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  factory Sermon.fromJson(Map<String, dynamic> json) {
    // Infer media type based on URL presence
    var mediaType = SermonMediaType.audio;
    if (json['video_url'] != null && json['audio_url'] != null) {
      mediaType = SermonMediaType.both;
    } else if (json['video_url'] != null) {
      mediaType = SermonMediaType.video;
    }

    // Decode the scriptures list (new schema) — fall back to the legacy
    // scripture_ref string when absent.
    final scripturesJson = json['scriptures'];
    final scriptures = <SermonScriptureRef>[];
    if (scripturesJson is List) {
      for (final entry in scripturesJson) {
        if (entry is Map<String, dynamic>) {
          scriptures.add(SermonScriptureRef.fromJson(entry));
        }
      }
    }

    final legacyRef = json['scripture_ref'] as String?;
    if (scriptures.isEmpty && legacyRef != null && legacyRef.isNotEmpty) {
      scriptures.add(SermonScriptureRef.parse(legacyRef));
    }

    return Sermon(
      id: json['id'] as String,
      title: json['title'] as String,
      speakerName: json['speaker_name'] as String,
      seriesName: ((json['sermon_series'] as Map<String, dynamic>?)?['title'] as String?) ?? 'General',
      publishedAt: DateTime.parse(json['preached_on'] as String),
      durationSeconds: (json['duration_seconds'] as int?) ?? 3600, // fallback
      mediaType: mediaType,
      videoUrl: json['video_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      scriptureReference: legacyRef,
      description: json['description'] as String?,
      isLive: json['is_live'] as bool? ?? false,
      youtubeId: json['youtube_id'] as String?,
      hlsStreamUrl: json['hls_stream_url'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      scriptures: scriptures,
      topics: (json['topics'] as List?)?.cast<String>() ?? const [],
      ministry: json['ministry'] as String?,
      trendingScore: json['trending_score'] as int? ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String speakerName;
  final String seriesName;
  final DateTime publishedAt;

  /// Duration in seconds.
  final int durationSeconds;
  final SermonMediaType mediaType;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;

  /// Legacy single-scripture label (e.g. for compact subtitles).
  /// `primaryScripture` prefers [scriptures] when non-empty.
  final String? scriptureReference;
  final String? description;
  final bool isLive;
  final String? youtubeId;
  final String? hlsStreamUrl;
  final bool isFavorited;
  final bool isDownloaded;
  final int viewCount;

  /// Pre-existing tag list (chip text). Kept for backwards compat with
  /// the old filter bar.
  final List<String> tags;

  /// Full structured scripture references — used by the Details page.
  final List<SermonScriptureRef> scriptures;

  /// Topics for library filtering (Faith, Hope, Prayer, etc.).
  final List<String> topics;

  /// Ministry tag (e.g. "Youth", "Missions", "Family").
  final String? ministry;

  /// Trending rank for the "Trending" sort.
  final int trendingScore;

  final DateTime? _updatedAt;

  /// Most-recent update — used by the "Recently added" feed.
  DateTime get updatedAt => _updatedAt ?? publishedAt;

  /// Primary scripture reference (first in the list, or the legacy label).
  String get primaryScripture {
    if (scriptures.isNotEmpty) return scriptures.first.label;
    return scriptureReference ?? '';
  }

  /// Human-readable duration e.g. "45 min".
  String get durationLabel {
    final m = durationSeconds ~/ 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final rem = m % 60;
      return rem == 0 ? '${h}h' : '${h}h ${rem}m';
    }
    return '$m min';
  }

  /// Whether this sermon has a video stream.
  bool get hasVideo =>
      mediaType == SermonMediaType.video ||
      mediaType == SermonMediaType.both ||
      youtubeId != null;

  /// Whether this sermon has an audio stream.
  bool get hasAudio =>
      mediaType == SermonMediaType.audio ||
      mediaType == SermonMediaType.both ||
      audioUrl != null;

  Sermon copyWith({
    bool? isFavorited,
    bool? isDownloaded,
    int? viewCount,
    List<SermonScriptureRef>? scriptures,
    List<String>? topics,
    String? ministry,
    int? trendingScore,
    DateTime? updatedAt,
  }) =>
      Sermon(
        id: id,
        title: title,
        speakerName: speakerName,
        seriesName: seriesName,
        publishedAt: publishedAt,
        durationSeconds: durationSeconds,
        mediaType: mediaType,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        thumbnailUrl: thumbnailUrl,
        scriptureReference: scriptureReference,
        description: description,
        isLive: isLive,
        youtubeId: youtubeId,
        hlsStreamUrl: hlsStreamUrl,
        isFavorited: isFavorited ?? this.isFavorited,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        viewCount: viewCount ?? this.viewCount,
        tags: tags,
        scriptures: scriptures ?? this.scriptures,
        topics: topics ?? this.topics,
        ministry: ministry ?? this.ministry,
        trendingScore: trendingScore ?? this.trendingScore,
        updatedAt: updatedAt ?? _updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        speakerName,
        seriesName,
        publishedAt,
        durationSeconds,
        mediaType,
        videoUrl,
        audioUrl,
        thumbnailUrl,
        scriptureReference,
        description,
        isLive,
        youtubeId,
        hlsStreamUrl,
        isFavorited,
        isDownloaded,
        viewCount,
        tags,
        scriptures,
        topics,
        ministry,
        trendingScore,
        _updatedAt,
      ];
}
