// Kingdom Heir — Chat Bubble
//
// A single message bubble that adapts its styling to [GroupMessageKind]:
//   • text        — neutral surface, navy text
//   • prayer      — gold border + heart icon, scripture hint
//   • scripture   — gold-filled navy background, italic serif
//   • media       — image preview chip with caption
//   • announcement — gold-bordered banner with pin icon
//
// Avatar size + bubble padding scale with the parent `LayoutBuilder`'s
// constraints so the same widget renders correctly from xs (320 dp) up
// to desktop.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.isMine,
    super.key,
  });

  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Avatar size scales 28 → 32 → 36 across xs / sm / md+ bands.
        final w = constraints.maxWidth;
        final avatarSize = w < 360
            ? 28.0
            : w < 600
                ? 32.0
                : 36.0;

        // Bubble gutter scales 56 → 80 → 120 so phone feels airy and tablet
        // has a generous 1/4 margin (1/3 on phone).
        final gutter = w < 360
            ? 56.0
            : w < 600
                ? 80.0
                : 120.0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: insets.sm,
            left: isMine ? gutter : 0,
            right: isMine ? 0 : gutter,
          ),
          child: Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine) ...[
                AppAvatar(
                  name: message.senderName ?? 'U',
                  imageUrl: message.senderAvatarUrl,
                  size: avatarSize,
                ),
                SizedBox(width: insets.sm),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMine)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message.senderName ?? 'Member',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    _BubbleBody(
                      message: message,
                      isMine: isMine,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _time(message.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 220.ms).slideY(
              begin: 0.04,
              end: 0,
              duration: 220.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }
}

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    switch (message.kind) {
      case GroupMessageKind.text:
        return _TextBubble(message: message, isMine: isMine);
      case GroupMessageKind.prayer:
        return _PrayerBubble(message: message, isMine: isMine);
      case GroupMessageKind.scripture:
        return _ScriptureBubble(message: message, isMine: isMine);
      case GroupMessageKind.media:
        return _MediaBubble(message: message, isMine: isMine);
      case GroupMessageKind.announcement:
        return _AnnouncementBubble(message: message, isMine: isMine);
    }
  }
}

/// Plain text bubble — the default.
class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.md,
        vertical: insets.sm + 2,
      ),
      decoration: BoxDecoration(
        color:
            isMine ? AppColors.gold : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMine ? AppRadius.lg : 4),
          bottomRight: Radius.circular(isMine ? 4 : AppRadius.lg),
        ),
        border:
            isMine ? null : Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        message.content,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: isMine ? AppColors.ink : theme.colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Prayer request bubble — gold border, heart accent, subtle navy bg.
class _PrayerBubble extends StatelessWidget {
  const _PrayerBubble({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.md,
        vertical: insets.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldContainer,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMine ? AppRadius.lg : 4),
          bottomRight: Radius.circular(isMine ? 4 : AppRadius.lg),
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1.1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.volunteer_activism_rounded,
            size: 16,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message.content,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scripture bubble — navy fill, italic gold text, book icon.
class _ScriptureBubble extends StatelessWidget {
  const _ScriptureBubble({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final reference = message.metadata['reference'] ?? 'Scripture';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.md,
        vertical: insets.sm + 2,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMine ? AppRadius.lg : 4),
          bottomRight: Radius.circular(isMine ? 4 : AppRadius.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 14,
                color: AppColors.gold,
              ),
              const SizedBox(width: 4),
              Text(
                reference,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '"${message.content}"',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.warmWhite,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Media bubble — image preview chip with caption underneath.
class _MediaBubble extends StatelessWidget {
  const _MediaBubble({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final url = message.metadata['url'];
    final caption = message.content;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 360
            ? 200.0
            : constraints.maxWidth < 600
                ? 240.0
                : 280.0;

        return ClipRRect(
          borderRadius: AppRadius.brLg,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.brLg,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: url != null && url.isNotEmpty
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppColors.goldContainer,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ),
                        )
                      : const ColoredBox(
                          color: AppColors.goldContainer,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                ),
                if (caption.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      insets.md,
                      insets.sm,
                      insets.md,
                      insets.sm,
                    ),
                    child: Text(
                      caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Announcement bubble — gold border with pin icon.
class _AnnouncementBubble extends StatelessWidget {
  const _AnnouncementBubble({required this.message, required this.isMine});
  final GroupMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.md,
        vertical: insets.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(isMine ? AppRadius.lg : 4),
          bottomRight: Radius.circular(isMine ? 4 : AppRadius.lg),
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.push_pin_rounded,
              size: 16, color: AppColors.goldDark,),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message.content,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _time(DateTime when) {
  final now = DateTime.now();
  final isToday =
      when.year == now.year && when.month == now.month && when.day == now.day;
  if (isToday) {
    return DateFormat('HH:mm').format(when);
  }
  final diff = now.difference(when);
  if (diff.inDays < 7) return DateFormat('EEE HH:mm').format(when);
  return DateFormat('MMM d, HH:mm').format(when);
}
