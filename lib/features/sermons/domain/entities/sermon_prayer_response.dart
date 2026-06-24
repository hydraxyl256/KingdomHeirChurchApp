// Kingdom Heir — Sermon Prayer Response
//
// Free-text response to a sermon. One per sermon per user; may be
// marked private (not shared in any social surface).

import 'package:equatable/equatable.dart';

class SermonPrayerResponse extends Equatable {
  const SermonPrayerResponse({
    required this.id,
    required this.sermonId,
    required this.body,
    required this.createdAt,
    required this.isPrivate,
  });

  factory SermonPrayerResponse.fromJson(Map<String, dynamic> json) =>
      SermonPrayerResponse(
        id: json['id'] as String,
        sermonId: json['sermon_id'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isPrivate: json['is_private'] as bool? ?? true,
      );

  final String id;
  final String sermonId;
  final String body;
  final DateTime createdAt;
  final bool isPrivate;

  SermonPrayerResponse copyWith({String? body, bool? isPrivate}) =>
      SermonPrayerResponse(
        id: id,
        sermonId: sermonId,
        body: body ?? this.body,
        createdAt: createdAt,
        isPrivate: isPrivate ?? this.isPrivate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sermon_id': sermonId,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'is_private': isPrivate,
      };

  @override
  List<Object?> get props => [id, sermonId, body, createdAt, isPrivate];
}
