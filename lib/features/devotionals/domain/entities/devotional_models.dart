import 'package:equatable/equatable.dart';

class Devotional extends Equatable {
  const Devotional({
    required this.id,
    required this.title,
    required this.scriptureRef,
    required this.scriptureText,
    required this.body,
    required this.scheduledFor,
    required this.status,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.reflection,
    this.prayer,
    this.authorId,
    this.imageUrl,
  });

  factory Devotional.fromJson(Map<String, dynamic> json) {
    return Devotional(
      id: json['id'] as String,
      title: json['title'] as String,
      scriptureRef: json['scripture_ref'] as String,
      scriptureText: json['scripture_text'] as String,
      body: json['body'] as String,
      reflection: json['reflection'] as String?,
      prayer: json['prayer'] as String?,
      authorId: json['author_id'] as String?,
      imageUrl: json['image_url'] as String?,
      scheduledFor: DateTime.parse(json['scheduled_for'] as String),
      status: json['status'] as String,
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String title;
  final String scriptureRef;
  final String scriptureText;
  final String body;
  final String? reflection;
  final String? prayer;
  final String? authorId;
  final String? imageUrl;
  final DateTime scheduledFor;
  final String status;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scripture_ref': scriptureRef,
      'scripture_text': scriptureText,
      'body': body,
      'reflection': reflection,
      'prayer': prayer,
      'author_id': authorId,
      'image_url': imageUrl,
      'scheduled_for': scheduledFor.toIso8601String(),
      'status': status,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        scriptureRef,
        scriptureText,
        body,
        reflection,
        prayer,
        authorId,
        imageUrl,
        scheduledFor,
        status,
        viewCount,
        createdAt,
        updatedAt,
      ];
}

class DevotionalCategory extends Equatable {
  const DevotionalCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory DevotionalCategory.fromJson(Map<String, dynamic> json) {
    return DevotionalCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];
}

class DevotionalComment extends Equatable {
  const DevotionalComment({
    required this.id,
    required this.devotionalId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DevotionalComment.fromJson(Map<String, dynamic> json) {
    return DevotionalComment(
      id: json['id'] as String,
      devotionalId: json['devotional_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String devotionalId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, devotionalId, userId, body, createdAt, updatedAt];
}

class DevotionalLike extends Equatable {
  const DevotionalLike({
    required this.id,
    required this.devotionalId,
    required this.userId,
    required this.createdAt,
  });

  factory DevotionalLike.fromJson(Map<String, dynamic> json) {
    return DevotionalLike(
      id: json['id'] as String,
      devotionalId: json['devotional_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String devotionalId;
  final String userId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, devotionalId, userId, createdAt];
}

class DevotionalBookmark extends Equatable {
  const DevotionalBookmark({
    required this.id,
    required this.devotionalId,
    required this.userId,
    required this.createdAt,
  });

  factory DevotionalBookmark.fromJson(Map<String, dynamic> json) {
    return DevotionalBookmark(
      id: json['id'] as String,
      devotionalId: json['devotional_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String devotionalId;
  final String userId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, devotionalId, userId, createdAt];
}

class DevotionalReflection extends Equatable {
  const DevotionalReflection({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.devotionalId,
  });

  factory DevotionalReflection.fromJson(Map<String, dynamic> json) {
    return DevotionalReflection(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      devotionalId: json['devotional_id'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String? devotionalId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, userId, devotionalId, body, createdAt, updatedAt];
}
