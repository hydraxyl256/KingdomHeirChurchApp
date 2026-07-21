// Kingdom Heir — Group Chat Screen
//
// The conversation view for a single community.
//
//   • App bar — avatar + name + member count + info icon
//   • Pinned banner (when at least one announcement is pinned)
//   • Message list — band-aware bubbles (text / prayer / scripture /
//     media / announcement), chronological, auto-scroll on send
//   • Chat input bar — attach / scripture / text / send-as-prayer (long press)
//   • Optional ScriptureChip above the bar
//
// Reads from `groupChatStreamProvider` (live) and `groupAnnouncementsProvider`
// (for the pinned strip). Sends go through `groupsRepositoryProvider.sendMessage`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_announcement_models.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/chat/chat_bubble.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/chat/chat_input_bar.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/chat/pinned_message_banner.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/chat/prayer_composer.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/chat/scripture_chip.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({required this.groupId, super.key});
  final String groupId;

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _scrollController = ScrollController();
  String? _attachedScripture;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _send(String text) async {
    final repo = ref.read(groupsRepositoryProvider);
    final kind = _attachedScripture != null ? 'SCRIPTURE' : null;
    final metadata = _attachedScripture != null
        ? {'reference': _attachedScripture!}
        : const <String, String>{};
    final result = await repo.sendMessage(
      widget.groupId,
      text,
      kind: kind,
      metadata: metadata,
    );
    if (!mounted) return;
    setState(() => _attachedScripture = null);
    result.fold(
      (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $err')),
        );
      },
      (_) => _scrollToBottom(),
    );
  }

  Future<void> _openPrayerComposer() async {
    await showPrayerComposer(context, groupId: widget.groupId);
  }

  void _showScripturePicker() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.attachScripture),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.egJohn316,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isEmpty) return;
              setState(() => _attachedScripture = v);
              Navigator.of(ctx).pop();
            },
            child: Text(AppLocalizations.of(context)!.attach),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatStream = ref.watch(groupChatStreamProvider(widget.groupId));
    final announcementsAsync =
        ref.watch(groupAnnouncementsProvider(widget.groupId));
    final allGroupsAsync = ref.watch(groupsListProvider);
    final groups = allGroupsAsync.valueOrNull ?? const <CommunityGroup>[];
    final group = groups
        .where((g) => g.id == widget.groupId)
        .cast<CommunityGroup?>()
        .firstWhere((_) => true, orElse: () => null);
    final theme = Theme.of(context);
    final insets = Insets.of(context);

    final pinnedList =
        announcementsAsync.valueOrNull?.where((a) => a.pinned).toList() ??
            const <GroupAnnouncement>[];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: _ChatHeader(
          name: group?.name ?? 'Group',
          memberCount: group?.memberCount ?? 0,
          avatarUrl: group?.imageUrl,
          subtitle: group?.categoryName ?? 'Community',
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.groupInfo,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showGroupInfo(context, group, pinnedList),
          ),
        ],
      ),
      body: Column(
        children: [
          if (pinnedList.isNotEmpty)
            PinnedMessageBanner(
              authorName: pinnedList.first.authorName,
              body: pinnedList.first.body,
              groupId: widget.groupId,
            ),
          if (_attachedScripture != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                insets.md,
                insets.sm,
                insets.md,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ScriptureChip(
                  reference: _attachedScripture!,
                  onClose: () => setState(() => _attachedScripture = null),
                ),
              ),
            ),
          Expanded(
            child: chatStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => AppErrorWidget(
                message:
                    AppLocalizations.of(context)!.couldntLoadTheConversation,
                onRetry: () =>
                    ref.invalidate(groupChatStreamProvider(widget.groupId)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyChat(groupName: group?.name ?? 'this group');
                }
                _scrollToBottom(animate: false);
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    insets.md,
                    insets.md,
                    insets.md,
                    insets.md,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMine = m.userId == _currentUserId;
                    return ChatBubble(message: m, isMine: isMine);
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: _send,
            onAttachTap: () => _showAttachSheet(context),
            onScriptureTap: _showScripturePicker,
            onLongPressSend: _openPrayerComposer,
          ),
        ],
      ),
    );
  }

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brModalTop),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AppLocalizations.of(context)!.shareImage),
              onTap: () => Navigator.of(ctx).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism_rounded),
              title: Text(AppLocalizations.of(context)!.sharePrayerRequest),
              onTap: () {
                Navigator.of(ctx).pop();
                _openPrayerComposer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(AppLocalizations.of(context)!.shareScripture),
              onTap: () {
                Navigator.of(ctx).pop();
                _showScripturePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupInfo(
    BuildContext context,
    CommunityGroup? group,
    List<GroupAnnouncement> pinned,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brModalTop),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: AppRadius.brFull,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                group?.name ?? 'Group',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${group?.memberCount ?? 0} members • ${group?.meetingTime ?? 'Schedule TBA'}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (pinned.isNotEmpty) ...[
                Text(
                  'Pinned announcements',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final a in pinned)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.push_pin_rounded,
                      color: AppColors.goldDark,
                    ),
                    title: Text(
                      a.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(a.authorName),
                  ),
                const SizedBox(height: 16),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.share_outlined),
                title: Text(AppLocalizations.of(context)!.shareGroup),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_off_outlined),
                title: Text(AppLocalizations.of(context)!.muteNotifications),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.memberCount,
    required this.subtitle,
    this.avatarUrl,
  });
  final String name;
  final int memberCount;
  final String subtitle;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: name, imageUrl: avatarUrl, size: 36),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$memberCount members • $subtitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No messages yet',
      description:
          'Be the first to say hello in $groupName — share a verse, a prayer, or a kind word.',
    );
  }
}
