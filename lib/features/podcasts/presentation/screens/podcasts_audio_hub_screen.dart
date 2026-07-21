import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/podcasts/presentation/providers/podcasts_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class PodcastsAudioHubScreen extends ConsumerWidget {
  const PodcastsAudioHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final episodesAsync = ref.watch(allEpisodesProvider);
    final seriesAsync = ref.watch(podcastSeriesProvider);

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.podcastsAudioHub)),
      body: CustomScrollView(
        slivers: [
          // Player Card
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: _MiniPlayer().animate().fadeIn(),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Text('All Episodes', style: theme.textTheme.titleLarge)
                  .animate()
                  .fadeIn(delay: 200.ms),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: episodesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              data: (episodes) {
                if (episodes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Text(
                            AppLocalizations.of(context)!.noEpisodesAvailable,),),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final e = episodes[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.tertiary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: const Icon(
                            Icons.podcasts_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          e.title,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          '${e.durationSeconds != null ? '${e.durationSeconds! ~/ 60} min' : 'Unknown length'} · ${e.publishedAt.day}/${e.publishedAt.month}/${e.publishedAt.year}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          color: AppColors.primary,
                          onPressed: () {
                            if (seriesAsync.hasValue) {
                              final series = seriesAsync.value!.firstWhere(
                                (s) => s.id == e.seriesId,
                                orElse: () => seriesAsync.value!.first,
                              );
                              ref.read(currentSeriesProvider.notifier).state =
                                  series;
                              ref.read(currentEpisodeProvider.notifier).state =
                                  e;
                              ref
                                  .read(audioPlayerServiceProvider)
                                  .loadEpisode(e, series)
                                  .then((_) {
                                ref.read(audioPlayerServiceProvider).play();
                              });
                            }
                          },
                        ),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 200 + i * 60),
                          );
                    },
                    childCount: episodes.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<_MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final episode = ref.watch(currentEpisodeProvider);
    final series = ref.watch(currentSeriesProvider);

    if (episode == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Center(
            child: Text(
                AppLocalizations.of(context)!.selectAnEpisodeToStartPlaying,),),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          const Icon(Icons.podcasts_rounded, color: Colors.white, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            episode.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            series?.author ?? 'Unknown Author',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<Duration>(
            stream: playerService.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: playerService.durationStream,
                builder: (context, durationSnapshot) {
                  final duration =
                      durationSnapshot.data ?? const Duration(minutes: 1);
                  final maxVal = duration.inMilliseconds.toDouble();
                  var currentVal = position.inMilliseconds.toDouble();
                  if (currentVal > maxVal) currentVal = maxVal;

                  return Slider(
                    value: currentVal,
                    max: maxVal > 0 ? maxVal : 1,
                    onChanged: (v) {
                      playerService.seek(Duration(milliseconds: v.toInt()));
                    },
                    activeColor: AppColors.secondary,
                    inactiveColor: Colors.white24,
                  );
                },
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  final pos = playerService.player.position;
                  playerService.seek(pos - const Duration(seconds: 10));
                },
              ),
              StreamBuilder(
                stream: playerService.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == null ||
                      processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 56,
                      height: 56,
                      child: const CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: const Icon(Icons.play_circle_filled_rounded),
                      iconSize: 56,
                      color: AppColors.secondary,
                      onPressed: playerService.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: const Icon(Icons.pause_circle_filled_rounded),
                      iconSize: 56,
                      color: AppColors.secondary,
                      onPressed: playerService.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.replay_rounded),
                      iconSize: 56,
                      color: AppColors.secondary,
                      onPressed: () => playerService.seek(Duration.zero),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.forward_30_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  final pos = playerService.player.position;
                  playerService.seek(pos + const Duration(seconds: 30));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
