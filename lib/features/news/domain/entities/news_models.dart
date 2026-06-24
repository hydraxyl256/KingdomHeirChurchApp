import 'package:equatable/equatable.dart';

class NewsCategory extends Equatable {
  const NewsCategory({
    required this.id,
    required this.name,
  });

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class NewsArticle extends Equatable {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.preview,
    required this.isFeatured,
    required this.isPinned,
    required this.publishedAt,
    required this.status,
    required this.viewCount,
    required this.shareCount,
    required this.createdAt,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: (json['news_categories'] as Map<String, dynamic>?)?['name'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      preview: json['preview'] as String,
      imageUrl: json['image_url'] as String?,
      isFeatured: json['is_featured'] as bool,
      isPinned: json['is_pinned'] as bool,
      publishedAt: DateTime.parse(json['published_at'] as String),
      status: json['status'] as String,
      viewCount: json['view_count'] as int,
      shareCount: json['share_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String? categoryId;
  final String? categoryName; // Usually joined from DB
  final String title;
  final String content;
  final String preview;
  final String? imageUrl;
  final bool isFeatured;
  final bool isPinned;
  final DateTime publishedAt;
  final String status;
  final int viewCount;
  final int shareCount;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        title,
        content,
        preview,
        imageUrl,
        isFeatured,
        isPinned,
        publishedAt,
        status,
        viewCount,
        shareCount,
        createdAt,
      ];
}
