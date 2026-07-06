import 'package:equatable/equatable.dart';

/// Status lifecycle of a prayer request.
///
/// Maps 1:1 to the `prayer_status` Postgres enum after the moderation
/// migration (`20260706000000_prayer_moderation_workflow.sql`):
///   * [pending]  — newly submitted, awaiting admin review (NOT public)
///   * [approved] — admin-approved, visible on the public Prayer Wall
///   * [rejected] — admin-decided as "not published" (NOT public)
enum PrayerStatus { pending, approved, rejected }

/// Domain entity for a prayer request.
class PrayerRequest extends Equatable {
  const PrayerRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
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
    this.displayName,
    this.adminNote,
    this.reviewedAt,
    this.approvedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;

  /// Public visibility of the request. Maps to the `prayer_visibility`
  /// Postgres enum. Submitters who pick "Private" get `private`; the
  /// default is `public`. The Prayer Wall view only returns `public` +
  /// `leaders_only`.
  final String visibility;

  final bool isAnonymous;
  final PrayerStatus status;
  final int prayerCount;
  final bool hasPrayed;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The full name of the requester (only populated when the user is
  /// allowed to see it — admins and the owner).
  final String? authorName;
  final String? authorAvatarUrl;

  /// Safe display name from the public view. For anonymous requests this
  /// is always `'Anonymous'`. For non-anonymous it is the requester's
  /// full name.
  final String? displayName;

  /// Optional note from the admin who moderated the request. Surfaced to
  /// the owner when the request is rejected.
  final String? adminNote;

  final DateTime? reviewedAt;
  final DateTime? approvedAt;

  PrayerRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    String? visibility,
    bool? isAnonymous,
    PrayerStatus? status,
    int? prayerCount,
    bool? hasPrayed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatarUrl,
    String? displayName,
    String? adminNote,
    DateTime? reviewedAt,
    DateTime? approvedAt,
  }) =>
      PrayerRequest(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        content: content ?? this.content,
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
        displayName: displayName ?? this.displayName,
        adminNote: adminNote ?? this.adminNote,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        approvedAt: approvedAt ?? this.approvedAt,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
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
        displayName,
        adminNote,
        reviewedAt,
        approvedAt,
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
