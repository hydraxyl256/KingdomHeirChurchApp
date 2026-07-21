// Kingdom Heir — Member Row
//
// A single row in the leader dashboard's members list. Avatar, name,
// role chip, joined date, and an overflow menu with Promote / Remove.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class MemberRow extends StatelessWidget {
  const MemberRow({
    required this.member,
    super.key,
    this.onPromote,
    this.onRemove,
  });

  final GroupMember member;
  final VoidCallback? onPromote;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final joined = DateFormat('MMM yyyy').format(member.joinedAt);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.md,
        vertical: insets.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          AppAvatar(name: member.displayName, size: 40),
          SizedBox(width: insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Joined $joined',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: insets.xs),
          _RoleChip(role: member.role),
          if (onPromote != null || onRemove != null)
            PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.memberActions,
              icon: Icon(
                Icons.more_vert_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSelected: (v) {
                if (v == 'promote') onPromote?.call();
                if (v == 'remove') onRemove?.call();
              },
              itemBuilder: (_) => [
                if (onPromote != null)
                  PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        const Icon(Icons.upgrade_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.promote),
                      ],
                    ),
                  ),
                if (onRemove != null)
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove_rounded,
                            size: 18, color: AppColors.error,),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.remove,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final GroupRole role;

  @override
  Widget build(BuildContext context) {
    final isLeader = role == GroupRole.leader;
    final color = isLeader ? AppColors.gold : AppColors.navyAccent;
    final fg = isLeader ? AppColors.ink : AppColors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.brFull,
      ),
      child: Text(
        role.label,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
