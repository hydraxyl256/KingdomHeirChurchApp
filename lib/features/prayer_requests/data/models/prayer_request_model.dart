import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

class PrayerRequestModel {
  const PrayerRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.isPublic,
    required this.isAnonymous,
    required this.status,
    required this.prayerCount,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return PrayerRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: profile?['full_name'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      category: (json['category'] as String?) ?? 'general',
      isPublic: (json['is_public'] as bool?) ?? true,
      isAnonymous: (json['is_anonymous'] as bool?) ?? false,
      status: (json['status'] as String?) ?? 'active',
      prayerCount: (json['pray_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String? authorName;
  final String? authorAvatarUrl;
  final String title;
  final String content;
  final String category;
  final bool isPublic;
  final bool isAnonymous;
  final String status;
  final int prayerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toInsertJson() => {
        'title': title,
        'content': content,
        'category': category,
        'is_public': isPublic,
        'is_anonymous': isAnonymous,
      };

  PrayerRequest toEntity({bool hasPrayed = false}) => PrayerRequest(
        id: id,
        userId: userId,
        authorName: isAnonymous ? null : authorName,
        authorAvatarUrl: isAnonymous ? null : authorAvatarUrl,
        title: title,
        content: content,
        category: category,
        isPublic: isPublic,
        isAnonymous: isAnonymous,
        status: _parseStatus(status),
        prayerCount: prayerCount,
        hasPrayed: hasPrayed,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static PrayerStatus _parseStatus(String s) => switch (s) {
        'answered' => PrayerStatus.answered,
        'archived' => PrayerStatus.archived,
        _ => PrayerStatus.active,
      };
}
