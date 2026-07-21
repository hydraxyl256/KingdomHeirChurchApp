// Kingdom Heir — Pending Request Card
//
// A row in the leader dashboard's pending-requests list. Avatar,
// display name + note, "when" label, Approve / Deny buttons.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_member_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class PendingRequestCard extends ConsumerStatefulWidget {
  const PendingRequestCard({
    required this.request,
    required this.groupId,
    super.key,
  });

  final PendingJoinRequest request;
  final String groupId;

  @override
  ConsumerState<PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends ConsumerState<PendingRequestCard> {
  bool _busy = false;

  Future<void> _approve() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupMutationsProvider).approveJoinRequest(
            groupId: widget.groupId,
            userId: widget.request.userId,
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deny() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupMutationsProvider).denyJoinRequest(
            groupId: widget.groupId,
            userId: widget.request.userId,
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final when = _relative(widget.request.requestedAt);

    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: widget.request.displayName, size: 40),
              SizedBox(width: insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.request.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Requested $when',
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
            ],
          ),
          if (widget.request.note != null &&
              widget.request.note!.trim().isNotEmpty) ...[
            SizedBox(height: insets.sm),
            Container(
              padding: EdgeInsets.all(insets.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: AppRadius.brMd,
              ),
              child: Text(
                '"${widget.request.note!}"',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
          SizedBox(height: insets.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _approve,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(AppLocalizations.of(context)!.approve),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brMd,
                    ),
                    textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(width: insets.xs),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _deny,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text(AppLocalizations.of(context)!.deny),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brMd,
                    ),
                    textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(when);
  }
}
