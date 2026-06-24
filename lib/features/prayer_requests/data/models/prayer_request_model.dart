import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

class PrayerRequestModel {
  const PrayerRequestModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.category,
    required this.visibility,
    required this.isAnonymous,
    required this.status,
    required this.prayerCount,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.answeredNote,
    this.answeredAt,
  });

  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return PrayerRequestModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorName: profile?['full_name'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      category: (json['category'] as String?) ?? 'general',
      visibility: (json['visibility'] as String?) ?? 'public',
      isAnonymous: (json['is_anonymous'] as bool?) ?? false,
      status: (json['status'] as String?) ?? 'active',
      answeredNote: json['answered_note'] as String?,
      answeredAt: json['answered_at'] == null
          ? null
          : DateTime.parse(json['answered_at'] as String),
      prayerCount: (json['prayer_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String authorId;
  final String? authorName;
  final String? authorAvatarUrl;
  final String title;
  final String body;
  final String category;
  final String visibility;
  final bool isAnonymous;
  final String status;
  final String? answeredNote;
  final DateTime? answeredAt;
  final int prayerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        'body': body,
        'category': category,
        'visibility': visibility,
        'is_anonymous': isAnonymous,
      };

  PrayerRequest toEntity({bool hasPrayed = false}) => PrayerRequest(
        id: id,
        authorId: authorId,
        authorName: isAnonymous ? null : authorName,
        authorAvatarUrl: isAnonymous ? null : authorAvatarUrl,
        title: title,
        body: body,
        category: category,
        visibility: _parseVisibility(visibility),
        isAnonymous: isAnonymous,
        status: _parseStatus(status),
        answeredNote: answeredNote,
        answeredAt: answeredAt,
        prayerCount: prayerCount,
        hasPrayed: hasPrayed,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static PrayerVisibility _parseVisibility(String v) => switch (v) {
        'leaders_only' => PrayerVisibility.leadersOnly,
        'private' => PrayerVisibility.private,
        _ => PrayerVisibility.public,
      };

  static PrayerStatus _parseStatus(String s) => switch (s) {
        'answered' => PrayerStatus.answered,
        'archived' => PrayerStatus.archived,
        _ => PrayerStatus.active,
      };
}
