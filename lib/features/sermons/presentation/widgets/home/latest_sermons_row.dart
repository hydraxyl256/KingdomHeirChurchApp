// Kingdom Heir — Latest Sermons Row (Sermon Home)
//
// Horizontal rail of recent sermon cards. Each card: thumbnail, NEW
// pill, title, speaker, date, duration.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';

class LatestSermonsRow extends StatelessWidget {
  const LatestSermonsRow({
    required this.sermons,
    super.key,
    this.title = 'Latest sermons',
    this.subtitle = 'Newest messages from the team',
  });

  final List<Sermon> sermons;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (sermons.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(title: title, subtitle: subtitle),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: sermons.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) => _SermonCard(sermon: sermons[i])
                .animate(delay: Duration(milliseconds: 50 * i))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08, end: 0),
          ),
        ),
      ],
    );
  }
}

class _SermonCard extends StatelessWidget {
  const _SermonCard({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    final isNew = DateTime.now().difference(sermon.publishedAt).inDays < 7;
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/sermons/${sermon.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SermonThumbnail(
                        thumbnailUrl: sermon.thumbnailUrl,
                        title: sermon.title,
                        borderRadius: BorderRadius.zero,
                      ),
                      Positioned(
                        top: AppSpacing.xs,
                        left: AppSpacing.xs,
                        child: Row(
                          children: [
                            if (isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  'NEW',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            if (sermon.hasAudio && !sermon.hasVideo) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navy.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.headphones_rounded,
                                  color: AppColors.warmWhite,
                                  size: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                sermon.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${sermon.speakerName} · ${DateFormat.MMMd().format(sermon.publishedAt)} · ${sermon.durationLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
