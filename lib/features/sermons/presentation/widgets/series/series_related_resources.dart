// Kingdom Heir — Series Related Resources
//
// List of downloadable resources attached to a series (PDFs, links,
// audio clips). Each row has a kind icon, title, and a download CTA.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_resource.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SeriesRelatedResources extends StatelessWidget {
  const SeriesRelatedResources({
    required this.resources,
    super.key,
  });

  final List<SermonResource> resources;

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resources',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...resources.map((r) => _ResourceRow(resource: r)),
          ],
        ),
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource});
  final SermonResource resource;

  IconData get _icon => switch (resource.kind) {
        SermonResourceKind.pdf => Icons.picture_as_pdf_rounded,
        SermonResourceKind.link => Icons.link_rounded,
        SermonResourceKind.audio => Icons.headphones_rounded,
        SermonResourceKind.video => Icons.play_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(_icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  [
                    resource.kind.label,
                    if (resource.sizeBytes != null) resource.humanSize,
                  ].join(' · '),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.openLink,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: resource.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link copied: ${resource.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}
