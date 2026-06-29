// Kingdom Heir — Live Service Domain Models
//
// Pure Dart value types for the digital worship platform.
// No Flutter dependencies.

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum ConnectionQuality { excellent, good, poor, offline }

extension ConnectionQualityX on ConnectionQuality {
  String get label => switch (this) {
        ConnectionQuality.excellent => 'Excellent',
        ConnectionQuality.good => 'Good',
        ConnectionQuality.poor => 'Poor',
        ConnectionQuality.offline => 'Offline',
      };
}

enum PrayerRequestType {
  publicPrayer,
  privatePrayer,
  emergency,
  praiseReport,
  followUp,
}

extension PrayerRequestTypeX on PrayerRequestType {
  String get label => switch (this) {
        PrayerRequestType.publicPrayer => 'Prayer Request',
        PrayerRequestType.privatePrayer => 'Private Prayer',
        PrayerRequestType.emergency => 'Emergency Prayer',
        PrayerRequestType.praiseReport => 'Praise Report',
        PrayerRequestType.followUp => 'Prayer Follow-up',
      };

  String get emoji => switch (this) {
        PrayerRequestType.publicPrayer => '🙏',
        PrayerRequestType.privatePrayer => '🔒',
        PrayerRequestType.emergency => '🚨',
        PrayerRequestType.praiseReport => '🎉',
        PrayerRequestType.followUp => '💬',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Chat Message
// ─────────────────────────────────────────────────────────────────────────────

class LiveChatReaction extends Equatable {
  const LiveChatReaction({
    required this.emoji,
    required this.count,
    this.userReacted = false,
  });

  factory LiveChatReaction.fromJson(Map<String, dynamic> json) =>
      LiveChatReaction(
        emoji: json['emoji'] as String,
        count: json['count'] as int? ?? 0,
        userReacted: json['user_reacted'] as bool? ?? false,
      );

  final String emoji;
  final int count;
  final bool userReacted;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'count': count,
        'user_reacted': userReacted,
      };

  @override
  List<Object?> get props => [emoji, count, userReacted];
}

class LiveChatMessage extends Equatable {
  const LiveChatMessage({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.body,
    required this.sentAt,
    this.avatarUrl,
    this.isLeader = false,
    this.isModerator = false,
    this.isPinned = false,
    this.replyToId,
    this.replyToDisplayName,
    this.replyToBody,
    this.reactions = const [],
    this.isDeleted = false,
  });

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) =>
      LiveChatMessage(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String? ?? 'Member',
        body: json['body'] as String,
        sentAt: DateTime.parse(json['sent_at'] as String),
        avatarUrl: json['avatar_url'] as String?,
        isLeader: json['is_leader'] as bool? ?? false,
        isModerator: json['is_moderator'] as bool? ?? false,
        isPinned: json['is_pinned'] as bool? ?? false,
        replyToId: json['reply_to_id'] as String?,
        replyToDisplayName: json['reply_to_display_name'] as String?,
        replyToBody: json['reply_to_body'] as String?,
        reactions: (json['reactions'] as List<dynamic>?)
                ?.map((r) => LiveChatReaction.fromJson(
                      r as Map<String, dynamic>,
                    ),)
                .toList() ??
            [],
        isDeleted: json['is_deleted'] as bool? ?? false,
      );

  final String id;
  final String userId;
  final String displayName;
  final String body;
  final DateTime sentAt;
  final String? avatarUrl;
  final bool isLeader;
  final bool isModerator;
  final bool isPinned;
  final String? replyToId;
  final String? replyToDisplayName;
  final String? replyToBody;
  final List<LiveChatReaction> reactions;
  final bool isDeleted;

  Map<String, dynamic> toInsertJson(String serviceId) => {
        'service_id': serviceId,
        'user_id': userId,
        'display_name': displayName,
        'body': body,
        'sent_at': sentAt.toIso8601String(),
        'avatar_url': avatarUrl,
        'is_pinned': isPinned,
        'reply_to_id': replyToId,
      };

  @override
  List<Object?> get props => [id, userId, body, sentAt, isPinned, isDeleted];
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Service State
// ─────────────────────────────────────────────────────────────────────────────

class LiveServiceState extends Equatable {
  const LiveServiceState({
    required this.isLive,
    this.serviceId,
    this.serviceTitle,
    this.seriesName,
    this.speakerName,
    this.speakerBio,
    this.speakerAvatarUrl,
    this.currentTopic,
    this.currentScriptureRef,
    this.description,
    this.youtubeId,
    this.hlsStreamUrl,
    this.thumbnailUrl,
    this.startedAt,
    this.viewerCount = 0,
    this.connectionQuality = ConnectionQuality.good,
    this.nextServiceTitle,
    this.nextServiceAt,
    this.nextServiceSpeaker,
    this.replayYoutubeId,
  });

  const LiveServiceState.idle()
      : isLive = false,
        serviceId = null,
        serviceTitle = null,
        seriesName = null,
        speakerName = null,
        speakerBio = null,
        speakerAvatarUrl = null,
        currentTopic = null,
        currentScriptureRef = null,
        description = null,
        youtubeId = null,
        hlsStreamUrl = null,
        thumbnailUrl = null,
        startedAt = null,
        viewerCount = 0,
        connectionQuality = ConnectionQuality.good,
        nextServiceTitle = null,
        nextServiceAt = null,
        nextServiceSpeaker = null,
        replayYoutubeId = null;

  final bool isLive;
  final String? serviceId;
  final String? serviceTitle;
  final String? seriesName;
  final String? speakerName;
  final String? speakerBio;
  final String? speakerAvatarUrl;
  final String? currentTopic;
  final String? currentScriptureRef;
  final String? description;
  final String? youtubeId;
  final String? hlsStreamUrl;
  final String? thumbnailUrl;
  final DateTime? startedAt;
  final int viewerCount;
  final ConnectionQuality connectionQuality;

  // No-live state fields
  final String? nextServiceTitle;
  final DateTime? nextServiceAt;
  final String? nextServiceSpeaker;
  final String? replayYoutubeId;

  Duration? get duration =>
      startedAt != null ? DateTime.now().difference(startedAt!) : null;

  String get durationLabel {
    final d = duration;
    if (d == null) return '';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get startedLabel {
    final d = duration;
    if (d == null) return '';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return 'Started ${h}h ${m}m ago';
    return 'Started ${m}m ago';
  }

  @override
  List<Object?> get props => [
        isLive,
        serviceId,
        youtubeId,
        currentScriptureRef,
        viewerCount,
        connectionQuality,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Sermon Note
// ─────────────────────────────────────────────────────────────────────────────

class SermonNote extends Equatable {
  const SermonNote({
    required this.id,
    required this.sermonId,
    required this.body,
    required this.createdAt,
    this.scriptureRef,
    this.updatedAt,
    this.isSynced = false,
  });

  factory SermonNote.fromJson(Map<String, dynamic> json) => SermonNote(
        id: json['id'] as String,
        sermonId: json['sermon_id'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        scriptureRef: json['scripture_ref'] as String?,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        isSynced: true,
      );

  final String id;
  final String sermonId;
  final String body;
  final DateTime createdAt;
  final String? scriptureRef;
  final DateTime? updatedAt;
  final bool isSynced;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sermon_id': sermonId,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'scripture_ref': scriptureRef,
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, sermonId, body, updatedAt, isSynced];
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Announcement
// ─────────────────────────────────────────────────────────────────────────────

class LiveAnnouncement extends Equatable {
  const LiveAnnouncement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
    this.expiresAt,
    this.badgeLabel,
  });

  factory LiveAnnouncement.fromJson(Map<String, dynamic> json) =>
      LiveAnnouncement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        imageUrl: json['image_url'] as String?,
        ctaLabel: json['cta_label'] as String?,
        ctaUrl: json['cta_url'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        badgeLabel: json['badge_label'] as String?,
      );

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;
  final DateTime? expiresAt;
  final String? badgeLabel;

  @override
  List<Object?> get props => [id, title, expiresAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer Request
// ─────────────────────────────────────────────────────────────────────────────

class LivePrayerRequest extends Equatable {
  const LivePrayerRequest({
    required this.id,
    required this.type,
    required this.message,
    required this.submittedAt,
    this.isFollowUp = false,
    this.isAnswered = false,
  });

  factory LivePrayerRequest.fromJson(Map<String, dynamic> json) =>
      LivePrayerRequest(
        id: json['id'] as String,
        type: PrayerRequestType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => PrayerRequestType.publicPrayer,
        ),
        message: json['message'] as String,
        submittedAt: DateTime.parse(json['submitted_at'] as String),
        isFollowUp: json['is_follow_up'] as bool? ?? false,
        isAnswered: json['is_answered'] as bool? ?? false,
      );

  final String id;
  final PrayerRequestType type;
  final String message;
  final DateTime submittedAt;
  final bool isFollowUp;
  final bool isAnswered;

  Map<String, dynamic> toInsertJson(String userId) => {
        'user_id': userId,
        'type': type.name,
        'message': message,
        'submitted_at': submittedAt.toIso8601String(),
        'is_follow_up': isFollowUp,
      };

  @override
  List<Object?> get props => [id, type, message, submittedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming Service
// ─────────────────────────────────────────────────────────────────────────────

class UpcomingService extends Equatable {
  const UpcomingService({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.speaker,
    this.topic,
    this.thumbnailUrl,
    this.location,
  });

  factory UpcomingService.fromJson(Map<String, dynamic> json) =>
      UpcomingService(
        id: json['id'] as String,
        title: json['title'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        speaker: json['speaker'] as String?,
        topic: json['topic'] as String?,
        thumbnailUrl: json['thumbnail_url'] as String?,
        location: json['location'] as String? ?? 'Main Sanctuary',
      );

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? speaker;
  final String? topic;
  final String? thumbnailUrl;
  final String? location;

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  @override
  List<Object?> get props => [id, title, scheduledAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// Supabase SQL Schema (for reference)
// ─────────────────────────────────────────────────────────────────────────────
//
// CREATE TABLE live_chat_messages (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   service_id TEXT NOT NULL,
//   user_id UUID REFERENCES auth.users(id),
//   display_name TEXT NOT NULL,
//   body TEXT NOT NULL,
//   sent_at TIMESTAMPTZ DEFAULT NOW(),
//   avatar_url TEXT,
//   is_leader BOOLEAN DEFAULT FALSE,
//   is_moderator BOOLEAN DEFAULT FALSE,
//   is_pinned BOOLEAN DEFAULT FALSE,
//   is_deleted BOOLEAN DEFAULT FALSE,
//   reply_to_id UUID REFERENCES live_chat_messages(id),
//   reply_to_display_name TEXT,
//   reply_to_body TEXT
// );
//
// ALTER TABLE live_chat_messages ENABLE ROW LEVEL SECURITY;
// CREATE POLICY "Anyone can read chat" ON live_chat_messages FOR SELECT USING (true);
// CREATE POLICY "Auth users can insert" ON live_chat_messages FOR INSERT
//   WITH CHECK (auth.uid() = user_id);
//
// CREATE TABLE live_prayer_requests (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   user_id UUID REFERENCES auth.users(id),
//   type TEXT NOT NULL,
//   message TEXT NOT NULL,
//   submitted_at TIMESTAMPTZ DEFAULT NOW(),
//   is_follow_up BOOLEAN DEFAULT FALSE,
//   is_answered BOOLEAN DEFAULT FALSE,
//   is_private BOOLEAN DEFAULT FALSE
// );
//
// CREATE TABLE live_announcements (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   title TEXT NOT NULL,
//   description TEXT NOT NULL,
//   image_url TEXT,
//   cta_label TEXT,
//   cta_url TEXT,
//   badge_label TEXT,
//   expires_at TIMESTAMPTZ,
//   created_at TIMESTAMPTZ DEFAULT NOW()
// );
//
// CREATE TABLE upcoming_services (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   title TEXT NOT NULL,
//   scheduled_at TIMESTAMPTZ NOT NULL,
//   speaker TEXT,
//   topic TEXT,
//   thumbnail_url TEXT,
//   location TEXT DEFAULT 'Main Sanctuary'
// );
//
// CREATE TABLE sermon_notes (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   user_id UUID REFERENCES auth.users(id),
//   sermon_id TEXT NOT NULL,
//   body TEXT NOT NULL,
//   scripture_ref TEXT,
//   created_at TIMESTAMPTZ DEFAULT NOW(),
//   updated_at TIMESTAMPTZ
// );
