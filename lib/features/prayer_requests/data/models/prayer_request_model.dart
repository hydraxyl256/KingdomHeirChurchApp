// Kingdom Heir — Prayer request data model
//
// Maps rows from the `prayer_requests` table (or its approved-only view
// `prayer_requests_approved`) to the [PrayerRequest] domain entity.

import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';

class PrayerRequestModel {
  const PrayerRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.visibility,
    required this.isAnonymous,
    required this.status,
    required this.prayerCount,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.displayName,
    this.adminNote,
    this.reviewedBy,
    this.reviewedAt,
    this.approvedAt,
  });

  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) {
    // The profiles join may be keyed as 'profiles' when using
    // select('*, profiles(...)') or 'profiles!user_id(...)'.
    // We support both shapes defensively.
    final profileRaw = json['profiles'];
    final profile = profileRaw is Map<String, dynamic> ? profileRaw : null;

    // Some Supabase setups use 'prayer_count', others 'pray_count'.
    // We check both and fall back to 0.
    final prayerCount = (json['prayer_count'] as int?) ??
        (json['pray_count'] as int?) ??
        0;

    // updated_at is nullable: some tables omit it or set it to null
    // on the first insert before a trigger fires.
    final updatedAtRaw = json['updated_at'] as String?;
    final createdAtRaw =
        json['created_at'] as String? ?? DateTime.now().toIso8601String();

    return PrayerRequestModel(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      authorName: profile?['full_name'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
      displayName: json['display_name'] as String?,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
      // visibility is the new replacement for is_public on the canonical
      // table. We read it from the row when present and fall back to
      // a reasonable default. The legacy `is_public` boolean is honored
      // for backwards compatibility with the dashboard view.
      visibility: _parseVisibility(json),
      isAnonymous: (json['is_anonymous'] as bool?) ?? false,
      status: (json['status'] as String?) ?? 'pending',
      prayerCount: prayerCount,
      adminNote: json['admin_note'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: _parseDate(json['reviewed_at']),
      approvedAt: _parseDate(json['approved_at']),
      createdAt: DateTime.parse(createdAtRaw),
      // Fall back to createdAt when updated_at is absent
      updatedAt: updatedAtRaw != null
          ? DateTime.parse(updatedAtRaw)
          : DateTime.parse(createdAtRaw),
    );
  }

  final String id;
  final String userId;
  final String? authorName;
  final String? authorAvatarUrl;
  final String? displayName;
  final String title;
  final String content;
  final String category;
  final String visibility;
  final bool isAnonymous;
  final String status;
  final int prayerCount;
  final String? adminNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Build the JSON to send to `insert('prayer_requests', …)`.
  ///
  /// Intentionally omits `status` (the BEFORE INSERT trigger forces it
  /// to 'pending'), `reviewed_by/at`, `approved_at`, and `admin_note`
  /// (the trigger nulls them). It also omits `requester_name` — the
  /// trigger sets it from `profiles.full_name` for non-anonymous rows.
  Map<String, dynamic> toInsertJson() => {
        'title': title,
        'content': content,
        'category': category,
        'visibility': visibility,
        'is_anonymous': isAnonymous,
      };

  /// Build the JSON for an admin's `update('prayer_requests', …)` of a
  /// row that is still in `pending`. Only `content` and `title` may be
  /// edited; everything else is server-controlled.
  Map<String, dynamic> toMemberEditJson() => {
        'title': title,
        'content': content,
      };

  PrayerRequest toEntity({bool hasPrayed = false}) {
    final authorForEntity = isAnonymous ? null : authorName;
    final avatarForEntity = isAnonymous ? null : authorAvatarUrl;
    // Public view always returns 'Anonymous' as display_name for anonymous
    // rows. For non-anonymous it returns the requester_name.
    final displayForEntity = isAnonymous
        ? 'Anonymous'
        : (displayName ?? authorName ?? 'Member');
    return PrayerRequest(
      id: id,
      userId: userId,
      authorName: authorForEntity,
      authorAvatarUrl: avatarForEntity,
      displayName: displayForEntity,
      title: title,
      content: content,
      category: category,
      visibility: visibility,
      isAnonymous: isAnonymous,
      status: _parseStatus(status),
      prayerCount: prayerCount,
      hasPrayed: hasPrayed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminNote: adminNote,
      reviewedAt: reviewedAt,
      approvedAt: approvedAt,
    );
  }

  static String _parseVisibility(Map<String, dynamic> json) {
    final v = json['visibility'];
    if (v is String && v.isNotEmpty) return v;
    // Legacy rows from the dashboard view used `is_public`.
    final legacy = json['is_public'];
    if (legacy is bool) return legacy ? 'public' : 'private';
    return 'public';
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.parse(raw);
    return null;
  }

  static PrayerStatus _parseStatus(String s) => switch (s) {
        'pending' => PrayerStatus.pending,
        'approved' => PrayerStatus.approved,
        'rejected' => PrayerStatus.rejected,
        // Legacy mappings — keep so any stale JSON still parses cleanly.
        'active' => PrayerStatus.approved,
        'archived' => PrayerStatus.rejected,
        'answered' => PrayerStatus.approved,
        _ => PrayerStatus.pending,
      };
}
