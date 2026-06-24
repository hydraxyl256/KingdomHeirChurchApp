// Kingdom Heir — Join Button
//
// Single canonical "Join / Request / Pending / Member / Leader" button
// used on every group card, the discovery grid, the detail hero, and
// the chat app-bar. Handles every membership state in one place so
// downstream widgets don't have to think about it.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

enum JoinButtonState { join, request, pending, member, leader }

extension on JoinButtonState {
  String get _label => switch (this) {
        JoinButtonState.join => 'Join',
        JoinButtonState.request => 'Request',
        JoinButtonState.pending => 'Pending',
        JoinButtonState.member => 'Member',
        JoinButtonState.leader => 'Leader',
      };

  IconData get _icon => switch (this) {
        JoinButtonState.join => Icons.add_rounded,
        JoinButtonState.request => Icons.lock_outline_rounded,
        JoinButtonState.pending => Icons.hourglass_top_rounded,
        JoinButtonState.member => Icons.check_circle_rounded,
        JoinButtonState.leader => Icons.workspace_premium_rounded,
      };
}

/// Resolve the button state from a [CommunityGroup] record. Pulled out
/// of the [JoinButton] class so call sites can use it without building
/// a widget.
JoinButtonState joinButtonStateFromGroup(CommunityGroup group) {
  if (group.isLeader) return JoinButtonState.leader;
  if (group.isMember) return JoinButtonState.member;
  if (group.isPending) return JoinButtonState.pending;
  return group.privacy == GroupPrivacy.private
      ? JoinButtonState.request
      : JoinButtonState.join;
}

class JoinButton extends StatelessWidget {
  const JoinButton({
    required this.state,
    super.key,
    this.onPressed,
    this.compact = false,
  });

  final JoinButtonState state;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isReadOnly =
        state == JoinButtonState.leader || state == JoinButtonState.member;
    final insets = Insets.of(context);

    final (bg, fg) = switch (state) {
      JoinButtonState.join => (AppColors.gold, AppColors.ink),
      JoinButtonState.request => (AppColors.ink, AppColors.gold),
      JoinButtonState.pending => (AppColors.goldContainer, AppColors.goldDark),
      JoinButtonState.member => (AppColors.successContainer, AppColors.success),
      JoinButtonState.leader => (AppColors.navy, AppColors.gold),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isReadOnly ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? insets.sm : insets.md,
            vertical: compact ? insets.xxs : insets.xs,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: state == JoinButtonState.request
                ? Border.all(color: AppColors.gold, width: 1.5)
                : null,
            boxShadow: state == JoinButtonState.join
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(state._icon, size: compact ? 12 : 14, color: fg),
              SizedBox(width: compact ? 4 : 6),
              Flexible(
                child: Text(
                  state._label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
