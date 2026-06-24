// Kingdom Heir — Sermon Player Screen
//
// Full-screen video player. Premium controls overlay; routes to YouTube
// when the sermon has a youtubeId, otherwise mounts a chewie player
// with the videoUrl. Below the player: a related-sermons carousel.
// Progress is recorded to the continue-watching provider on dispose.

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/features/sermons/data/mock/mock_sermons_seed.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_continue_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/player/premium_video_controls.dart';
import 'package:kingdom_heir/features/sermons/presentation/widgets/player/related_carousel.dart';
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
      if (sermon.youtubeId != null && sermon.youtubeId!.isNotEmpty) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: sermon.youtubeId!,
          autoPlay: true,
        );
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

  @override
  void dispose() {
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
              message: 'Sermon not found',
              onRetry: () =>
                  ref.invalidate(sermonDetailProvider(widget.sermonId)),
            );
          }
          final related = MockSermonSeed.allSermons
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
