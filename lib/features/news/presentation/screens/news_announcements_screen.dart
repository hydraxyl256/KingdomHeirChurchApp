import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/news/presentation/providers/news_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class NewsAnnouncementsScreen extends ConsumerWidget {
  const NewsAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinnedAsync = ref.watch(pinnedAnnouncementProvider);
    final newsAsync = ref.watch(newsArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newsAnnouncements),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Pinned announcement
          pinnedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (pinned) {
              if (pinned == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => context.push('/news-details', extra: pinned),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.push_pin_rounded,
                            color: AppColors.onSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PINNED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        pinned.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: AppColors.onSecondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        pinned.preview,
                        style: TextStyle(
                          color: AppColors.onSecondary.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${pinned.publishedAt.day}/${pinned.publishedAt.month}/${pinned.publishedAt.year}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),
          Text('Latest News', style: theme.textTheme.titleLarge)
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.md),

          newsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (articles) {
              if (articles.isEmpty) {
                return Center(
                    child:
                        Text(AppLocalizations.of(context)!.noNewsArticlesYet),);
              }
              return Column(
                children: articles.asMap().entries.map((entry) {
                  final i = entry.key;
                  final n = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (n.categoryName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    n.categoryName!,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                '${n.publishedAt.day}/${n.publishedAt.month}/${n.publishedAt.year}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(n.title, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            n.preview,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () =>
                                context.push('/news-details', extra: n),
                            child: Text(AppLocalizations.of(context)!.readMore),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 200 + i * 80));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
