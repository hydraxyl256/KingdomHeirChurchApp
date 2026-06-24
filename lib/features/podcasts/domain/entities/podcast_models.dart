import 'package:equatable/equatable.dart';

class PodcastSeries extends Equatable {
  const PodcastSeries({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.createdAt,
    this.description,
    this.thumbnailUrl,
  });

  factory PodcastSeries.fromJson(Map<String, dynamic> json) {
    return PodcastSeries(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      author: json['author'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String author;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'author': author,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, title, description, thumbnailUrl, author, status, createdAt];
}

class PodcastEpisode extends Equatable {
  const PodcastEpisode({
    required this.id,
    required this.seriesId,
    required this.title,
    required this.audioUrl,
    required this.publishedAt,
    required this.status,
    required this.viewCount,
    required this.createdAt,
    this.description,
    this.durationSeconds,
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'] as String,
      seriesId: json['series_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      audioUrl: json['audio_url'] as String,
      durationSeconds: json['duration_seconds'] as int?,
      publishedAt: DateTime.parse(json['published_at'] as String),
      status: json['status'] as String,
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String seriesId;
  final String title;
  final String? description;
  final String audioUrl;
  final int? durationSeconds;
  final DateTime publishedAt;
  final String status;
  final int viewCount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'series_id': seriesId,
      'title': title,
      'description': description,
      'audio_url': audioUrl,
      'duration_seconds': durationSeconds,
      'published_at': publishedAt.toIso8601String(),
      'status': status,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        seriesId,
        title,
        description,
        audioUrl,
        durationSeconds,
        publishedAt,
        status,
        viewCount,
        createdAt,
      ];
}

class PodcastSubscription extends Equatable {
  const PodcastSubscription({
    required this.id,
    required this.userId,
    required this.seriesId,
    required this.createdAt,
  });

  factory PodcastSubscription.fromJson(Map<String, dynamic> json) {
    return PodcastSubscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      seriesId: json['series_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String seriesId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, seriesId, createdAt];
}

class PlaybackPosition extends Equatable {
  const PlaybackPosition({
    required this.id,
    required this.userId,
    required this.episodeId,
    required this.positionSeconds,
    required this.updatedAt,
  });

  factory PlaybackPosition.fromJson(Map<String, dynamic> json) {
    return PlaybackPosition(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      episodeId: json['episode_id'] as String,
      positionSeconds: json['position_seconds'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String episodeId;
  final int positionSeconds;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, userId, episodeId, positionSeconds, updatedAt];
}

class PodcastDownload extends Equatable {
  const PodcastDownload({
    required this.id,
    required this.userId,
    required this.episodeId,
    required this.localFilePath,
    required this.downloadedAt,
  });

  factory PodcastDownload.fromJson(Map<String, dynamic> json) {
    return PodcastDownload(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      episodeId: json['episode_id'] as String,
      localFilePath: json['local_file_path'] as String,
      downloadedAt: DateTime.parse(json['downloaded_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String episodeId;
  final String localFilePath;
  final DateTime downloadedAt;

  @override
  List<Object?> get props =>
      [id, userId, episodeId, localFilePath, downloadedAt];
}
