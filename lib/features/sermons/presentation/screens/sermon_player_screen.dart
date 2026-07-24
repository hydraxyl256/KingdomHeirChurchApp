// Kingdom Heir — Sermon Player Screen
//
// Full-screen video player. Premium controls overlay; routes to YouTube
// when the sermon has a youtubeId, otherwise mounts a chewie player
// with the videoUrl. Below the player: a related-sermons carousel.
// Progress is recorded to the continue-watching provider on dispose.
//
// YouTube handling:
//   • The `sermon.youtubeId` field can arrive as a bare 11-char ID
//     OR a full YouTube URL of any shape (watch, youtu.be, embed,
//     live, shorts, music, mobile). We normalise once via
//     `normaliseYouTubeId` before handing it to
//     `YoutubePlayerController.fromVideoId` — otherwise the WebView
//     shows "Video unavailable — error 152-4".
//   • We listen to the controller's `value.error` stream. When the
//     YouTube IFrame reports an embed-restriction error
//     (101 / 150 / 152 — code 152 is the iOS WebView variant of
//     101), we hand the user a friendly "Open in YouTube" sheet
//     and never leave them on a broken player.

import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/utils/youtube_player_utils.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_continue_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/player/premium_video_controls.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/player/related_carousel.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SermonPlayerScreen extends ConsumerStatefulWidget {
  const SermonPlayerScreen({required this.sermonId, super.key});
  final String sermonId;

  @override
  ConsumerState<SermonPlayerScreen> createState() => _SermonPlayerScreenState();
}

class _SermonPlayerScreenState extends ConsumerState<SermonPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  Sermon? _sermon;
  bool _initFailed = false;
  String? _initError;
  int _lastPositionSeconds = 0;
  String? _resolvedVideoId;
  StreamSubscription<YoutubePlayerValue>? _ytSub;
  bool _fallbackShown = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final asyncSermon = ref.read(sermonDetailProvider(widget.sermonId));
    final sermon = asyncSermon.value;
    if (sermon == null) return;
    _sermon = sermon;
    try {
      final rawYoutube = sermon.youtubeId;
      if (rawYoutube != null && rawYoutube.isNotEmpty) {
        final normalised = normaliseYouTubeId(rawYoutube);
        if (normalised.isValid) {
          _resolvedVideoId = normalised.videoId;
          _youtubeController = YoutubePlayerController.fromVideoId(
            videoId: normalised.videoId!,
            autoPlay: true,
            params: const YoutubePlayerParams(
              showFullscreenButton: true,
              enableCaption: false,
              showVideoAnnotations: false,
              strictRelatedVideos: true,
            ),
          );
          // Listen for embed-restriction errors and offer the
          // "Open in YouTube" fallback so the user is never
          // stranded on a broken player.
          _ytSub = _youtubeController!.listen(
            _onYouTubeValue,
            onError: (_) => _maybeShowFallback(),
          );
        } else if (normalised.isPlaylistOnly) {
          _initFailed = true;
          _initError =
              'This sermon links to a YouTube playlist. Please open it in YouTube.';
        } else {
          _initFailed = true;
          _initError = 'This sermon does not have a valid YouTube link.';
        }
      } else if (sermon.videoUrl != null && sermon.videoUrl!.isNotEmpty) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(sermon.videoUrl!),
        );
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.gold,
            handleColor: AppColors.gold,
            backgroundColor: AppColors.navy.withValues(alpha: 0.4),
            bufferedColor: AppColors.gold.withValues(alpha: 0.4),
          ),
        );
      } else {
        _initFailed = true;
        _initError = 'No playable source for this sermon.';
      }
      if (mounted) setState(() {});
    } catch (e) {
      _initFailed = true;
      _initError = e.toString();
      if (mounted) setState(() {});
    }
  }

  void _onYouTubeValue(YoutubePlayerValue value) {
    // `value.error` is the IFrame Player API's current error state. We
    // only react to codes that mean "this video cannot be played in
    // an embedded player" — every other code is either the happy
    // path (`none`) or transient and the IFrame will recover.
    switch (value.error) {
      case YoutubeError.none:
        break;
      case YoutubeError.notEmbeddable:
      case YoutubeError.sameAsNotEmbeddable:
      case YoutubeError.videoNotFound:
      case YoutubeError.cannotFindVideo:
      case YoutubeError.html5Error:
      case YoutubeError.invalidParam:
      case YoutubeError.unknown:
        _maybeShowFallback();
    }
  }

  Future<void> _maybeShowFallback() async {
    if (_fallbackShown) return;
    if (!mounted) return;
    final id = _resolvedVideoId;
    if (id == null) return;
    _fallbackShown = true;
    await showYouTubeFallbackSheet(context, videoId: id);
  }

  @override
  void dispose() {
    _ytSub?.cancel();
    final sermon = _sermon;
    if (sermon != null && _lastPositionSeconds > 0) {
      ref.read(continueWatchingListProvider.notifier).recordProgress(
            sermonId: sermon.id,
            positionSeconds: _lastPositionSeconds,
            isCompleted: false,
          );
    }
    _chewieController?.dispose();
    _videoController?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sermonAsync = ref.watch(sermonDetailProvider(widget.sermonId));
    return Scaffold(
      backgroundColor: Colors.black,
      body: sermonAsync.when(
        data: (sermon) {
          if (sermon == null) {
            return AppErrorWidget(
              message: AppLocalizations.of(context)!.sermonNotFound,
              onRetry: () =>
                  ref.invalidate(sermonDetailProvider(widget.sermonId)),
            );
          }
          final allSermons = ref.watch(sermonsListProvider).valueOrNull ?? [];
          final related = allSermons
              .where((s) => s.id != sermon.id)
              .take(6)
              .toList();
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _PlayerBody(
                    sermon: sermon,
                    videoController: _videoController,
                    chewieController: _chewieController,
                    youtubeController: _youtubeController,
                    initFailed: _initFailed,
                    initError: _initError,
                    onPositionUpdate: (s) => _lastPositionSeconds = s,
                  ),
                ),
                if (related.isNotEmpty)
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: RelatedCarousel(sermons: related),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({
    required this.sermon,
    required this.videoController,
    required this.chewieController,
    required this.youtubeController,
    required this.initFailed,
    required this.initError,
    required this.onPositionUpdate,
  });

  final Sermon sermon;
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final YoutubePlayerController? youtubeController;
  final bool initFailed;
  final String? initError;
  final void Function(int seconds) onPositionUpdate;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (initFailed) {
      child = AppErrorWidget(message: initError ?? 'Could not load video');
    } else if (chewieController != null) {
      child = Chewie(controller: chewieController!);
    } else if (youtubeController != null) {
      child = YoutubePlayer(controller: youtubeController!);
    } else {
      child = const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: PremiumVideoControls(
        title: sermon.title,
        onBack: () => Navigator.of(context).maybePop(),
        child: child,
      ),
    );
  }
}
