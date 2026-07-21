// Kingdom Heir — Sermon Hero (Details)
//
// Full-bleed hero with thumbnail, parallax-ready gradient overlay, play
// CTA, back button, and a row of share/save/download actions.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/shared/sermon_thumbnail.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SermonHero extends StatelessWidget {
  const SermonHero({
    required this.sermon,
    super.key,
    this.onShare,
    this.onFavorite,
    this.onDownload,
    this.isFavorited = false,
  });

  final Sermon sermon;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final VoidCallback? onDownload;
  final bool isFavorited;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.navy,
      iconTheme: const IconThemeData(color: AppColors.warmWhite),
      actions: [
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_rounded),
          color: AppColors.warmWhite,
          tooltip: AppLocalizations.of(context)!.scriptureShare,
        ),
        IconButton(
          onPressed: onFavorite,
          icon: Icon(
            isFavorited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFavorited ? AppColors.gold : AppColors.warmWhite,
          ),
          tooltip: AppLocalizations.of(context)!.scriptureSave,
        ),
        IconButton(
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded),
          color: AppColors.warmWhite,
          tooltip: AppLocalizations.of(context)!.download,
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            SermonThumbnail(
              thumbnailUrl: sermon.thumbnailUrl,
              title: sermon.title,
              borderRadius: BorderRadius.zero,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.navy.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  72,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      sermon.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Center(
                child: Material(
                  color: AppColors.gold,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        context.push('/home/sermons/${sermon.id}/player'),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
