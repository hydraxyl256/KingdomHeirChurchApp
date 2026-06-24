import 'package:equatable/equatable.dart';

/// Visibility of a prayer request.
enum PrayerVisibility { public, leadersOnly, private }

/// Status lifecycle of a prayer request.
enum PrayerStatus { active, answered, archived }

/// Domain entity for a prayer request.
class PrayerRequest extends Equatable {
  const PrayerRequest({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.category,
    required this.visibility,
    required this.isAnonymous,
    required this.status,
    required this.prayerCount,
    required this.hasPrayed,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.answeredNote,
    this.answeredAt,
  });

  final String id;
  final String authorId;
  final String title;
  final String body;
  final String category;
  final PrayerVisibility visibility;
  final bool isAnonymous;
  final PrayerStatus status;
  final int prayerCount;
  final bool hasPrayed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final String? answeredNote;
  final DateTime? answeredAt;

  PrayerRequest copyWith({
    String? id,
    String? authorId,
    String? title,
    String? body,
    String? category,
    PrayerVisibility? visibility,
    bool? isAnonymous,
    PrayerStatus? status,
    int? prayerCount,
    bool? hasPrayed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatarUrl,
    String? answeredNote,
    DateTime? answeredAt,
  }) =>
      PrayerRequest(
        id: id ?? this.id,
        authorId: authorId ?? this.authorId,
        title: title ?? this.title,
        body: body ?? this.body,
        category: category ?? this.category,
        visibility: visibility ?? this.visibility,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        status: status ?? this.status,
        prayerCount: prayerCount ?? this.prayerCount,
        hasPrayed: hasPrayed ?? this.hasPrayed,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        authorName: authorName ?? this.authorName,
        authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
        answeredNote: answeredNote ?? this.answeredNote,
        answeredAt: answeredAt ?? this.answeredAt,
      );

  @override
  List<Object?> get props => [
        id,
        authorId,
        title,
        body,
        category,
        visibility,
        isAnonymous,
        status,
        prayerCount,
        hasPrayed,
        createdAt,
        updatedAt,
        authorName,
        authorAvatarUrl,
        answeredNote,
        answeredAt,
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
