// Kingdom Heir — Live Video Player
//
// YouTube-backed video player with:
// - 16:9 fixed aspect ratio (no layout jump)
// - Loading skeleton with shimmer
// - Error state with retry
// - Fullscreen via orientation lock
// - Replay support when live ends
// - Embed-restriction fallback ("Open in YouTube") so the user is
//   never left on a broken player.
//
// The `LiveServiceState.youtubeId` field is whatever the repository
// stored from `live_services.youtube_video_id`. That column is the
// canonical 11-char video ID — but to be defensive we still run it
// through `normaliseYouTubeId` before passing it to the IFrame.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/utils/youtube_player_utils.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LiveVideoPlayer extends ConsumerStatefulWidget {
  const LiveVideoPlayer({super.key});

  @override
  ConsumerState<LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends ConsumerState<LiveVideoPlayer> {
  YoutubePlayerController? _controller;
  String? _currentVideoId;
  bool _isFullscreen = false;
  StreamSubscription<YoutubePlayerValue>? _ytSub;
  bool _fallbackShown = false;
  String? _activeVideoId;
  String? _initError;

  @override
  void dispose() {
    _ytSub?.cancel();
    _controller?.close();
    super.dispose();
  }

  void _initController(String rawVideoId) {
    // The repository may have handed us a full URL rather than a
    // bare 11-char ID. Normalise once before mounting the WebView.
    final normalised = normaliseYouTubeId(rawVideoId);
    if (!normalised.isValid) {
      _initError = normalised.isPlaylistOnly
          ? 'This stream links to a YouTube playlist and cannot be '
              'played here. Open it in YouTube instead.'
          : 'This stream does not have a valid YouTube link.';
      _currentVideoId = null;
      _controller?.close();
      _controller = null;
      return;
    }
    final id = normalised.videoId!;
    _activeVideoId = id;
    _initError = null;
    if (_currentVideoId == id && _controller != null) return;
    _currentVideoId = id;
    _controller?.close();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        enableCaption: false,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
      ),
    );
    _fallbackShown = false;
    _ytSub?.cancel();
    _ytSub = _controller!.listen(
      _onYouTubeValue,
      onError: (_) => _maybeShowFallback(),
    );
  }

  void _onYouTubeValue(YoutubePlayerValue value) {
    // `value.error` is the IFrame Player API's current error state.
    // We only react to codes that mean "this video cannot be played
    // in an embedded player" — every other code is either the happy
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
    final id = _activeVideoId;
    if (id == null) return;
    _fallbackShown = true;
    await showYouTubeFallbackSheet(context, videoId: id);
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    setState(() => _isFullscreen = !_isFullscreen);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(liveServiceStateProvider);

    return RepaintBoundary(
      child: stateAsync.when(
        loading: () => const _PlayerSkeleton(),
        error: (_, __) => const _PlayerError(),
        data: (state) {
          final videoId = state.youtubeId ?? state.replayYoutubeId;
          if (videoId == null) {
            return _NoStreamPlaceholder(state: state);
          }

          // Side-effect: tear down / re-init the controller when the
          // resolved video ID changes. We call this from build
          // because `state` is the source of truth and the player
          // is otherwise pure.
          _initController(videoId);
          if (_controller == null) {
            return _InitErrorBanner(message: _initError ?? 'Invalid stream');
          }

          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                YoutubePlayer(
                  controller: _controller!,
                  backgroundColor: Colors.black,
                ),

                // Replay banner when not live
                if (!state.isLive && state.replayYoutubeId != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.replay_rounded,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'REPLAY',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Fullscreen button overlay (top-right)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: GestureDetector(
                    onTap: _toggleFullscreen,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Init error banner (used when the repository gives us a malformed
// video ID rather than a null one) ─────────────────────────────────────

class _InitErrorBanner extends StatelessWidget {
  const _InitErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: const Color(0xFF0A0F1E),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── No Stream Placeholder ────────────────────────────────────────────────────

class _NoStreamPlaceholder extends StatelessWidget {
  const _NoStreamPlaceholder({required this.state});
  final LiveServiceState state;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: const Color(0xFF0A0F1E),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv_rounded, color: Colors.white12, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Active Livestream',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Check back during service times',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _PlayerSkeleton extends StatefulWidget {
  const _PlayerSkeleton();

  @override
  State<_PlayerSkeleton> createState() => _PlayerSkeletonState();
}

class _PlayerSkeletonState extends State<_PlayerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FadeTransition(
        opacity: _opacity,
        child: const ColoredBox(
          color: Color(0xFF111827),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _PlayerError extends StatelessWidget {
  const _PlayerError();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: const Color(0xFF0A0F1E),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load stream',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
