import 'package:equatable/equatable.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';

class MediaContentModel extends Equatable {
  const MediaContentModel({
    required this.id,
    required this.youtubeVideoId,
    required this.youtubeUrl,
    required this.title,
    required this.contentType, required this.status, this.description,
    this.thumbnailUrl,
    this.publishedAt,
    this.durationSeconds,
    this.speakerName,
    this.seriesName,
    this.tags = const [],
    this.isFeatured = false,
  });

  factory MediaContentModel.fromJson(Map<String, dynamic> json) {
    return MediaContentModel(
      id: json['id'] as String,
      youtubeVideoId: json['youtube_video_id'] as String,
      youtubeUrl: json['youtube_url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      contentType: json['content_type'] as String? ?? 'sermon',
      publishedAt: json['published_at'] != null 
          ? DateTime.tryParse(json['published_at'] as String) 
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      status: json['status'] as String? ?? 'pending_review',
      speakerName: json['speaker_name'] as String?,
      seriesName: json['series_name'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtube_video_id': youtubeVideoId,
      'youtube_url': youtubeUrl,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'content_type': contentType,
      'published_at': publishedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': status,
      'speaker_name': speakerName,
      'series_name': seriesName,
      'tags': tags,
      'is_featured': isFeatured,
    };
  }

  final String id;
  final String youtubeVideoId;
  final String youtubeUrl;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String contentType;
  final DateTime? publishedAt;
  final int? durationSeconds;
  final String status;
  final String? speakerName;
  final String? seriesName;
  final List<String> tags;
  final bool isFeatured;

  @override
  List<Object?> get props => [
        id,
        youtubeVideoId,
        youtubeUrl,
        title,
        description,
        thumbnailUrl,
        contentType,
        publishedAt,
        durationSeconds,
        status,
        speakerName,
        seriesName,
        tags,
        isFeatured,
      ];
}


extension MediaContentModelX on MediaContentModel {
  Sermon toSermon() {
    return Sermon(
      id: id,
      title: title,
      speakerName: speakerName ?? 'Kingdom Heirs',
      seriesName: seriesName ?? 'General',
      publishedAt: publishedAt ?? DateTime.now(),
      durationSeconds: durationSeconds ?? 0,
      mediaType: SermonMediaType.video,
      videoUrl: youtubeUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      youtubeId: youtubeVideoId,
      tags: tags,
      trendingScore: isFeatured ? 100 : 0,
    );
  }
}
