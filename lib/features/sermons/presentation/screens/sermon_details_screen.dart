// Kingdom Heir — Sermon Details Screen
//
// The pre-player detail page. Sliver app bar hero, meta row, description,
// scripture chips, resources, notes / reflections / prayer panels,
// discussion prompts, and a "Recommended next" rail. A sticky bottom
// action bar offers Watch (gold), Audio only, Save, Share.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_discussion_prompts.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_hero.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_meta_row.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_notes_panel.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_prayer_panel.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_recommended_next.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_reflections_panel.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_resources_section.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/details/sermon_scripture_chips.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SermonDetailsScreen extends ConsumerWidget {
  const SermonDetailsScreen({required this.sermonId, super.key});
  final String sermonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sermonAsync = ref.watch(sermonDetailProvider(sermonId));
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: sermonAsync.when(
        data: (sermon) {
          if (sermon == null) {
            return AppErrorWidget(
              message: AppLocalizations.of(context)!.sermonNotFound,
              onRetry: () => ref.invalidate(sermonDetailProvider(sermonId)),
            );
          }
          return _DetailsBody(sermon: sermon);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(sermonDetailProvider(sermonId)),
        ),
      ),
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSermons = ref.watch(sermonsListProvider).valueOrNull ?? [];
    final related = _relatedFor(sermon, allSermons);
    final seriesEpisodesAsync =
        ref.watch(sermonSeriesEpisodesProvider(sermon.seriesName));
    final seriesName = seriesEpisodesAsync.value != null &&
            seriesEpisodesAsync.value!.isNotEmpty
        ? sermon.seriesName
        : null;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SermonHero(
              sermon: sermon,
              isFavorited: sermon.isFavorited,
              onShare: () {
                Clipboard.setData(ClipboardData(text: sermon.title));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied "${sermon.title}" to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onFavorite: () => ref
                  .read(sermonsListProvider.notifier)
                  .toggleFavourite(sermon.id),
              onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.audioDownloadComingSoon,),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SermonMetaRow(sermon: sermon)),
            if ((sermon.description ?? '').isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    sermon.description!,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            SermonScriptureChips(sermon: sermon),
            const SermonResourcesSection(resources: []),
            SermonNotesPanel(sermonId: sermon.id),
            SermonReflectionsPanel(sermon: sermon),
            SermonPrayerPanel(sermonId: sermon.id),
            SermonDiscussionPrompts(sermon: sermon),
            SermonRecommendedNext(
              recommendations: related,
              seriesName: seriesName,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomActionBar(sermon: sermon),
        ),
      ],
    );
  }

  List<Sermon> _relatedFor(Sermon s, List<Sermon> all) {
    final sameSeries = all
        .where(
          (x) => x.id != s.id && x.seriesName == s.seriesName,
        )
        .toList();
    if (sameSeries.length >= 3) return sameSeries.take(3).toList();
    final sameTopic = all
        .where(
          (x) =>
              x.id != s.id &&
              !sameSeries.contains(x) &&
              x.topics.any(s.topics.contains),
        )
        .toList();
    return [...sameSeries, ...sameTopic].take(3).toList();
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.sermon});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(
          top: BorderSide(color: AppColors.dividerLight),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () =>
                  context.push('/home/sermons/${sermon.id}/player'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(AppLocalizations.of(context)!.watch),
            ),
          ),
          if (sermon.hasAudio) ...[
            const SizedBox(width: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: () => context.push('/home/sermons/${sermon.id}/audio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.headphones_rounded),
              label: Text(AppLocalizations.of(context)!.audio),
            ),
          ],
        ],
      ),
    );
  }
}
