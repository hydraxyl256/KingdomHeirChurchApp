import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/news/domain/entities/news_models.dart';

class NewsArticleDetailsScreen extends StatelessWidget {
  const NewsArticleDetailsScreen({required this.article, super.key});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: article.imageUrl != null ? 250 : null,
            pinned: true,
            flexibleSpace: article.imageUrl != null
                ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3,),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.categoryName!,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${article.publishedAt.day}/${article.publishedAt.month}/${article.publishedAt.year}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(article.title,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),),
                  const SizedBox(height: AppSpacing.xl),
                  Html(
                    data: article.content,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.6),
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
