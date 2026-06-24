import 'package:equatable/equatable.dart';

class Testimony extends Equatable {
  const Testimony({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
    required this.category,
    required this.isAnonymous,
    required this.status,
    required this.likeCount,
    required this.createdAt,
    this.authorAvatarUrl,
    this.isLiked = false,
    this.commentCount = 0,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String title;
  final String body;
  final String category;
  final bool isAnonymous;
  final String status;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;

  String get displayName => isAnonymous ? 'Anonymous' : authorName;

  Testimony copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
  }) {
    return Testimony(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      title: title,
      body: body,
      category: category,
      isAnonymous: isAnonymous,
      status: status,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        authorName,
        authorAvatarUrl,
        title,
        body,
        category,
        isAnonymous,
        status,
        likeCount,
        createdAt,
        isLiked,
        commentCount,
      ];
}
