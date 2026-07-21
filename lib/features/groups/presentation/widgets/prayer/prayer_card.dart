// Kingdom Heir — Prayer Card
//
// Single prayer request inside the prayer wall list. Header with
// category chip + author + body (3-line max) + footer with praying
// count + "I prayed" / "Celebrate answer" actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/prayer/prayer_count_chip.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class PrayerCard extends ConsumerStatefulWidget {
  const PrayerCard({
    required this.request,
    required this.groupId,
    super.key,
  });

  final GroupPrayerRequest request;
  final String groupId;

  @override
  ConsumerState<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends ConsumerState<PrayerCard> {
  bool _busy = false;

  Future<void> _markPraying() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupMutationsProvider).markPraying(
            prayerId: widget.request.id,
            groupId: widget.groupId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.yourePraying)),
        );
      }
    } catch (_) {
      // Silent — the count will re-sync on the next invalidate.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final r = widget.request;

    return Container(
      decoration: BoxDecoration(
        color: r.isAnswered
            ? AppColors.goldContainer.withValues(alpha: 0.4)
            : theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: r.isAnswered
              ? AppColors.gold.withValues(alpha: 0.7)
              : theme.colorScheme.outlineVariant,
          width: r.isAnswered ? 1.2 : 0.7,
        ),
      ),
      padding: EdgeInsets.all(insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: r.authorName, size: 36),
              SizedBox(width: insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${r.category.label} • ${_relative(r.createdAt)}',
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
              if (r.isAnswered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        size: 12,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Answered',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: insets.sm),
          Text(
            r.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.45,
            ),
          ),
          SizedBox(height: insets.sm),
          Wrap(
            spacing: insets.xs,
            runSpacing: insets.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PrayerCountChip(count: r.prayingCount),
              if (r.hasTestimony)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.goldContainer,
                    borderRadius: AppRadius.brFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_edu_rounded,
                        size: 12,
                        color: AppColors.goldDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Testimony',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: insets.sm),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: _busy ? null : _markPraying,
                icon: const Icon(Icons.favorite_rounded, size: 16),
                label: Text(AppLocalizations.of(context)!.iPrayed),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldContainer,
                  foregroundColor: AppColors.goldDark,
                  padding: EdgeInsets.symmetric(
                    horizontal: insets.md,
                    vertical: 6,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brFull,
                  ),
                  textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: insets.sm),
              if (!r.isAnswered)
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .praiseReportFeatureComingSoon,),
                      ),
                    );
                  },
                  icon: const Icon(Icons.celebration_outlined, size: 16),
                  label: Text(AppLocalizations.of(context)!.praise),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(when);
  }
}
