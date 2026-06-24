// Kingdom Heir — Sermon Download
//
// Local-record of a downloaded sermon. Audio-only in this iteration;
// video downloads are stubbed UI.

import 'package:equatable/equatable.dart';

class SermonDownload extends Equatable {
  const SermonDownload({
    required this.sermonId,
    required this.localPath,
    required this.downloadedAt,
    required this.sizeBytes,
    this.completed = false,
  });

  factory SermonDownload.fromJson(Map<String, dynamic> json) => SermonDownload(
        sermonId: json['sermon_id'] as String,
        localPath: json['local_path'] as String,
        downloadedAt: DateTime.parse(json['downloaded_at'] as String),
        sizeBytes: json['size_bytes'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
      );

  final String sermonId;
  final String localPath;
  final DateTime downloadedAt;
  final int sizeBytes;
  final bool completed;

  String get humanSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'sermon_id': sermonId,
        'local_path': localPath,
        'downloaded_at': downloadedAt.toIso8601String(),
        'size_bytes': sizeBytes,
        'completed': completed,
      };

  @override
  List<Object?> get props =>
      [sermonId, localPath, downloadedAt, sizeBytes, completed];
}
