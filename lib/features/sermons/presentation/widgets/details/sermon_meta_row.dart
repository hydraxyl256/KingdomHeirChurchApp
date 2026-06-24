// Kingdom Heir — Sermon Meta Row (Details)
//
// Row of meta pills: speaker name with avatar, series link, date,
// duration, scripture chip, view count.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';

class SermonMetaRow extends StatelessWidget {
  const SermonMetaRow({required this.sermon, super.key});
  final Sermon sermon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          _MetaPill(
            icon: Icons.person_rounded,
            label: sermon.speakerName,
            onTap: () => context.push(
              '/home/sermons/library',
            ),
          ),
          _MetaPill(
            icon: Icons.collections_bookmark_rounded,
            label: sermon.seriesName,
          ),
          _MetaPill(
            icon: Icons.calendar_today_rounded,
            label: DateFormat.yMMMd().format(sermon.publishedAt),
          ),
          _MetaPill(
            icon: Icons.schedule_rounded,
            label: sermon.durationLabel,
          ),
          if (sermon.primaryScripture.isNotEmpty)
            _MetaPill(
              icon: Icons.menu_book_rounded,
              label: sermon.primaryScripture,
              accent: true,
            ),
          _MetaPill(
            icon: Icons.visibility_rounded,
            label: '${sermon.viewCount} views',
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final fg =
        accent ? AppColors.gold : Theme.of(context).colorScheme.onSurface;
    final bg = accent
        ? AppColors.gold.withValues(alpha: 0.12)
        : AppColors.surfaceContainerLight;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: accent ? AppColors.gold : AppColors.dividerLight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
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
