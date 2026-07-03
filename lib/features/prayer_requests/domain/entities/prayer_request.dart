import 'package:equatable/equatable.dart';

/// Status lifecycle of a prayer request.
enum PrayerStatus { active, answered, archived }

/// Domain entity for a prayer request.
class PrayerRequest extends Equatable {
  const PrayerRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.isPublic,
    required this.isAnonymous,
    required this.status,
    required this.prayerCount,
    required this.hasPrayed,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final bool isPublic;
  final bool isAnonymous;
  final PrayerStatus status;
  final int prayerCount;
  final bool hasPrayed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;

  PrayerRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    bool? isPublic,
    bool? isAnonymous,
    PrayerStatus? status,
    int? prayerCount,
    bool? hasPrayed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatarUrl,
  }) =>
      PrayerRequest(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        isPublic: isPublic ?? this.isPublic,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        status: status ?? this.status,
        prayerCount: prayerCount ?? this.prayerCount,
        hasPrayed: hasPrayed ?? this.hasPrayed,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        authorName: authorName ?? this.authorName,
        authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        category,
        isPublic,
        isAnonymous,
        status,
        prayerCount,
        hasPrayed,
        createdAt,
        updatedAt,
        authorName,
        authorAvatarUrl,
      ];
}

/// Domain entity for a prayer comment.
class PrayerComment extends Equatable {
  const PrayerComment({
    required this.id,
    required this.prayerRequestId,
    required this.authorId,
    required this.isAnonymous,
    required this.body,
    required this.createdAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  final String id;
  final String prayerRequestId;
  final String authorId;
  final bool isAnonymous;
  final String body;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatarUrl;

  @override
  List<Object?> get props => [
        id,
        prayerRequestId,
        authorId,
        isAnonymous,
        body,
        createdAt,
        authorName,
        authorAvatarUrl,
      ];
}
