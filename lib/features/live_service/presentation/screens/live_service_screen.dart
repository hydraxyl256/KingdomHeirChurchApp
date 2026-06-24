import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermons_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LiveServiceScreen extends ConsumerStatefulWidget {
  const LiveServiceScreen({super.key});

  @override
  ConsumerState<LiveServiceScreen> createState() => _LiveServiceScreenState();
}

class _LiveServiceScreenState extends ConsumerState<LiveServiceScreen> {
  bool _isChatVisible = true;
  final _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [
    {'name': 'Sarah', 'msg': 'God is good! 🙌', 'time': '9:02'},
    {'name': 'James', 'msg': 'Amen! Powerful message', 'time': '9:05'},
  ];

  YoutubePlayerController? _youtubeController;
  String? _currentLiveYoutubeId;

  @override
  void dispose() {
    _chatController.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  void _initYoutubePlayer(String youtubeId) {
    if (_currentLiveYoutubeId == youtubeId) return;
    _currentLiveYoutubeId = youtubeId;
    _youtubeController?.close();
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liveStreamAsync = ref.watch(activeLiveStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '● LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Sunday Service',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isChatVisible
                  ? Icons.chat_bubble_rounded
                  : Icons.chat_bubble_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isChatVisible = !_isChatVisible),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player Area
          Container(
            width: double.infinity,
            color: const Color(0xFF0A0015),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: liveStreamAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),),
                error: (err, _) => Center(
                    child: Text('Error loading live stream: $err',
                        style: const TextStyle(color: Colors.white),),),
                data: (sermon) {
                  if (sermon == null || sermon.youtubeId == null) {
                    return const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.live_tv_rounded,
                          color: Colors.white24,
                          size: 80,
                        ),
                        Positioned(
                          bottom: AppSpacing.md,
                          child: Text(
                            'No active live stream at the moment.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  }

                  _initYoutubePlayer(sermon.youtubeId!);

                  return YoutubePlayer(
                    controller: _youtubeController!,
                    backgroundColor: Colors.black,
                  );
                },
              ),
            ),
          ),

          // Chat section
          if (_isChatVisible)
            Expanded(
              child: ColoredBox(
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Live Chat',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, i) {
                          final m = _chatMessages[i];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${m['name']}  ',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextSpan(
                                    text: m['msg'],
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: i * 60),
                              );
                        },
                      ),
                    ),

                    // Chat input
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Say something…',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton.filled(
                            icon: const Icon(Icons.send_rounded),
                            onPressed: () {
                              if (_chatController.text.trim().isNotEmpty) {
                                setState(() {
                                  _chatMessages.add({
                                    'name': 'You',
                                    'msg': _chatController.text.trim(),
                                    'time': TimeOfDay.now().format(context),
                                  });
                                  _chatController.clear();
                                });
                              }
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
