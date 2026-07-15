// Kingdom Heir — Devotional Series List Screen
//
// Shows all published devotional series as premium cards.
// Each card: cover image, title, author, description, progress,
// "Buy Physical Copy on Amazon" link.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_series_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionalSeriesListScreen extends ConsumerWidget {
  const DevotionalSeriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(publishedSeriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Devotional Series'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: seriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => _ErrorState(message: err.toString()),
        data: (list) {
          if (list.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.length,
            itemBuilder: (context, index) => _SeriesCard(series: list[index]),
          );
        },
      ),
    );
  }
}

// ─── Series card ──────────────────────────────────────────────────────────────

class _SeriesCard extends ConsumerWidget {
  const _SeriesCard({required this.series});
  final DevotionalSeries series;

  static const _amazonUrl =
      'https://www.amazon.com/s?k=james+maddalone&crid=33XGMCSH8QWPF&sprefix=james+maddalone+%2Caps%2C194&ref=nb_sb_noss';

  Future<void> _launchAmazon(BuildContext context) async {
    final uri = Uri.parse(series.amazonPurchaseUrl ?? _amazonUrl);
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Amazon. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(devotionalProgressProvider(series.id));

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: () => context.push(
          RouteNames.devotionalSeriesDetail
              .replaceFirst(':seriesId', series.id),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ───────────────────────────────────────
            if (series.coverImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
                child: CachedNetworkImage(
                  imageUrl: series.coverImageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: AppColors.navyMid,
                    child: const Center(
                      child: Icon(Icons.menu_book_rounded,
                          color: AppColors.gold, size: 40,),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.navyMid,
                    child: const Center(
                      child: Icon(Icons.menu_book_rounded,
                          color: AppColors.gold, size: 40,),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, AppColors.navyAccent],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_rounded,
                      color: AppColors.gold, size: 48,),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Primary badge ───────────────────────────────
                  if (series.isPrimaryChallengesSeries) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3,),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '90-DAY CHALLENGE',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  Text(
                    series.title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (series.authorName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'by ${series.authorName}',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  if (series.description != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      series.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // ── Progress bar ────────────────────────────────
                  progressAsync.whenData((progress) {
                    if (progress == null) return const SizedBox.shrink();
                    final fraction =
                        progress.completedDays.length / series.totalDays;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${progress.completedDays.length} / ${series.totalDays} days',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        LinearProgressIndicator(
                          value: fraction.clamp(0.0, 1.0),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          minHeight: 4,
                        ),
                      ],
                    );
                  }).value ??
                      Text(
                        '${series.totalDays} days',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Row: Open CTA + Amazon ──────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push(
                            RouteNames.devotionalSeriesDetail
                                .replaceFirst(':seriesId', series.id),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('View Journey'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => _launchAmazon(context),
                        icon: const Icon(Icons.shopping_cart_outlined,
                            size: 16,),
                        label: const Text('Buy Book'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 56, color: AppColors.gold,),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No devotional series available yet.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load series.\n$message',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
