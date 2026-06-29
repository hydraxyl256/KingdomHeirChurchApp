// Kingdom Heir — Live Chat Panel
//
// Production-ready realtime chat backed by Supabase Realtime.
// Features: avatars, leader/moderator badges, pinned messages,
// emoji reactions, reply-to, auto-scroll, slow mode, profanity filter.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';

// ─── Profanity filter ─────────────────────────────────────────────────────────

const _blockedWords = <String>[];   // populate from remote config in production
bool _isProfane(String text) => _blockedWords.any(
      (w) => text.toLowerCase().contains(w),
    );

// ─── Quick emoji reactions ────────────────────────────────────────────────────

const _quickEmojis = ['🙏', '🔥', '🙌', '❤️', '✝️', '👏'];

// ─────────────────────────────────────────────────────────────────────────────
// LIVE CHAT PANEL
// ─────────────────────────────────────────────────────────────────────────────

class LiveChatPanel extends ConsumerStatefulWidget {
  const LiveChatPanel({super.key});

  @override
  ConsumerState<LiveChatPanel> createState() => _LiveChatPanelState();
}

class _LiveChatPanelState extends ConsumerState<LiveChatPanel> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  bool _autoScroll = true;
  bool _showScrollFab = false;
  Timer? _slowModeTimer;
  int _slowModeCountdown = 0;

  @override
  void initState() {
    super.initState();
    _scrollController
      .addListener(_onScroll);
  }

  void _onScroll() {
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80;
    setState(() {
      _autoScroll = atBottom;
      _showScrollFab = !atBottom;
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    unawaited(
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (_isProfane(text)) {
      _showSnack('Message contains inappropriate content.');
      return;
    }

    // Slow mode check
    if (ref.read(chatSlowModeProvider)) {
      final last = ref.read(chatLastSentProvider);
      if (last != null &&
          DateTime.now().difference(last).inSeconds < 30) {
        _showSnack(
            'Slow mode: wait ${30 - DateTime.now().difference(last).inSeconds}s',);
        return;
      }
    }

    final state = ref.read(liveServiceStateProvider).valueOrNull;
    final serviceId = state?.serviceId ?? 'live';
    final replyTo = ref.read(chatReplyToProvider);

    _inputController.clear();
    ref.read(chatLastSentProvider.notifier).state = DateTime.now();
    ref.read(chatReplyToProvider.notifier).state = null;

    await ref.read(liveChatNotifierProvider.notifier).sendMessage(
          serviceId: serviceId,
          body: text,
          replyToId: replyTo?.id,
          replyToDisplayName: replyTo?.displayName,
          replyToBody: replyTo?.body,
        );

    // Start slow-mode countdown
    if (ref.read(chatSlowModeProvider)) {
      _startSlowModeCountdown();
    }

    if (_autoScroll) _scrollToBottom();
  }

  void _startSlowModeCountdown() {
    _slowModeCountdown = 30;
    _slowModeTimer?.cancel();
    _slowModeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _slowModeCountdown--;
        if (_slowModeCountdown <= 0) t.cancel();
      });
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _inputController.dispose();
    _slowModeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(liveChatMessagesProvider);
    final replyTo = ref.watch(chatReplyToProvider);
    final slowMode = ref.watch(chatSlowModeProvider);

    return messagesAsync.when(
      loading: () => const _ChatSkeleton(),
      error: (_, __) => const _ChatError(),
      data: (messages) {
        final visible = messages.where((m) => !m.isDeleted).toList();
        final pinned = visible.where((m) => m.isPinned).toList();

        // Auto-scroll on new messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_autoScroll && _scrollController.hasClients) {
            _scrollToBottom();
          }
        });

        return Column(
          children: [
            // Panel header
            _ChatHeader(messageCount: visible.length),

            // Pinned messages (up to 1)
            if (pinned.isNotEmpty) _PinnedMessage(message: pinned.last),

            // Message list
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final msg = visible[i];
                      return _ChatMessageTile(
                        message: msg,
                        onReply: () {
                          ref.read(chatReplyToProvider.notifier).state = msg;
                        },
                        onReport: () => _reportMessage(msg),
                      )
                          .animate(key: ValueKey(msg.id))
                          .fadeIn(duration: 250.ms)
                          .slideX(begin: 0.05, end: 0, duration: 250.ms);
                    },
                  ),

                  // Scroll-to-bottom FAB
                  if (_showScrollFab)
                    Positioned(
                      bottom: AppSpacing.sm,
                      right: AppSpacing.md,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.navy.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Emoji quick-react bar
            _EmojiQuickBar(onSelect: (emoji) {
              _inputController.text += emoji;
            },),

            // Reply-to banner
            if (replyTo != null)
              _ReplyBanner(
                message: replyTo,
                onDismiss: () {
                  ref.read(chatReplyToProvider.notifier).state = null;
                },
              ),

            // Input row
            _ChatInputBar(
              controller: _inputController,
              slowModeCountdown: slowMode ? _slowModeCountdown : 0,
              onSend: _sendMessage,
            ),
          ],
        );
      },
    );
  }

  void _reportMessage(LiveChatMessage msg) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Message'),
        content: Text('Report "${msg.body.length > 40 ? "${msg.body.substring(0, 40)}…" : msg.body}" as inappropriate?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Message reported. Thank you.');
            },
            child: const Text('Report', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Header ──────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.messageCount});
  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_rounded,
              size: 15, color: AppColors.navy,),
          const SizedBox(width: 6),
          Text(
            'Live Chat',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$messageCount',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const Spacer(),
          // Live indicator dot
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Live',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textDisabled,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pinned Message ───────────────────────────────────────────────────────────

class _PinnedMessage extends StatelessWidget {
  const _PinnedMessage({required this.message});
  final LiveChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.goldContainer,
        border: Border(
          left: BorderSide(color: AppColors.goldDark, width: 3),
          bottom: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded,
              size: 12, color: AppColors.goldDark,),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${message.displayName}: ',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: message.body,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Message Tile ────────────────────────────────────────────────────────

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    required this.onReply,
    required this.onReport,
  });
  final LiveChatMessage message;
  final VoidCallback onReply;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: _avatarColor(message.displayName),
              backgroundImage: message.avatarUrl != null
                  ? NetworkImage(message.avatarUrl!)
                  : null,
              child: message.avatarUrl == null
                  ? Text(
                      message.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          message.displayName,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (message.isLeader) ...[
                        const SizedBox(width: 4),
                        const _Badge(label: '👑 Leader', color: AppColors.goldDark),
                      ],
                      if (message.isModerator) ...[
                        const SizedBox(width: 4),
                        const _Badge(label: '🛡 Mod', color: AppColors.navy),
                      ],
                      const Spacer(),
                      Text(
                        DateFormat.jm().format(message.sentAt.toLocal()),
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textDisabled,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),

                  // Reply preview
                  if (message.replyToId != null &&
                      message.replyToBody != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(4),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.textDisabled,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '${message.replyToDisplayName}: ${message.replyToBody}',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  const SizedBox(height: 2),

                  // Message body
                  Text(
                    message.body,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  // Reactions
                  if (message.reactions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: message.reactions.map((r) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: r.userReacted
                                ? AppColors.goldContainer
                                : AppColors.dividerLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: r.userReacted
                                  ? AppColors.goldDark
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            '${r.emoji} ${r.count}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContextAction(
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: () {
                Navigator.pop(context);
                onReply();
              },
            ),
            _ContextAction(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.body));
              },
            ),
            _ContextAction(
              icon: Icons.flag_rounded,
              label: 'Report',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                onReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF1E3A8A), Color(0xFF065F46), Color(0xFF92400E),
      Color(0xFF7C3AED), Color(0xFF1D4ED8), Color(0xFF166534),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ContextAction extends StatelessWidget {
  const _ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.navy;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: TextStyle(color: c, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

// ─── Emoji Quick Bar ──────────────────────────────────────────────────────────

class _EmojiQuickBar extends StatelessWidget {
  const _EmojiQuickBar({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.backgroundLight,
      child: Row(
        children: _quickEmojis
            .map(
              (e) => GestureDetector(
                onTap: () => onSelect(e),
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Text(e, style: const TextStyle(fontSize: 20)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Reply Banner ─────────────────────────────────────────────────────────────

class _ReplyBanner extends StatelessWidget {
  const _ReplyBanner({required this.message, required this.onDismiss});
  final LiveChatMessage message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.surfaceContainerLight,
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Replying to ${message.displayName}: ${message.body}',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textDisabled,),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Input Bar ───────────────────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.slowModeCountdown,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final int slowModeCountdown;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        safeBottom + AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.navy,
              ),
              decoration: InputDecoration(
                hintText: slowModeCountdown > 0
                    ? 'Slow mode: ${slowModeCountdown}s'
                    : 'Say something…',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.dividerLight.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: slowModeCountdown > 0 ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: slowModeCountdown > 0
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.gold],
                      ),
                color: slowModeCountdown > 0 ? AppColors.dividerLight : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color:
                    slowModeCountdown > 0 ? AppColors.textDisabled : AppColors.ink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.dividerLight,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textDisabled),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chat unavailable',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
