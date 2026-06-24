// Kingdom Heir — Sermon Note
//
// A user-authored note attached to a sermon. Optionally anchored to a
// specific player timestamp.

import 'package:equatable/equatable.dart';

class SermonNote extends Equatable {
  const SermonNote({
    required this.id,
    required this.sermonId,
    required this.body,
    required this.createdAt,
    this.timestampSeconds,
  });

  factory SermonNote.fromJson(Map<String, dynamic> json) => SermonNote(
        id: json['id'] as String,
        sermonId: json['sermon_id'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        timestampSeconds: json['timestamp_seconds'] as int?,
      );

  final String id;
  final String sermonId;
  final String body;
  final DateTime createdAt;
  final int? timestampSeconds;

  bool get hasTimestamp => timestampSeconds != null;

  String get timestampLabel {
    if (timestampSeconds == null) return '';
    final m = timestampSeconds! ~/ 60;
    final s = timestampSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  SermonNote copyWith({String? body, int? timestampSeconds}) => SermonNote(
        id: id,
        sermonId: sermonId,
        body: body ?? this.body,
        createdAt: createdAt,
        timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sermon_id': sermonId,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'timestamp_seconds': timestampSeconds,
      };

  @override
  List<Object?> get props => [id, sermonId, body, createdAt, timestampSeconds];
}
