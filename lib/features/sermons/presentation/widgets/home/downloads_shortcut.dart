// Kingdom Heir — Downloads Shortcut (Sermon Home)
//
// Compact row showing the user's most recent 3 downloads with a "See all"
// CTA. Hidden entirely when the user has no downloads.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_download.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class DownloadsShortcut extends ConsumerWidget {
  const DownloadsShortcut({
    required this.downloads,
    super.key,
  });

  final List<SermonDownload> downloads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (downloads.isEmpty) return const SizedBox.shrink();
    
    final sermonsList = ref.watch(sermonsListProvider).valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.dividerLight),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.download_done_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Your downloads',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/home/sermons/downloads'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                  ),
                  child: Text(AppLocalizations.of(context)!.seeAll),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ...downloads.map((d) {
              final sermon = sermonsList.where((s) => s.id == d.sermonId).firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        sermon?.title ?? 'Sermon',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${d.humanSize} · ${DateFormat.MMMd().format(d.downloadedAt)}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
