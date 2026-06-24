// Kingdom Heir — Prayer Count Chip
//
// A small pill that shows "N praying" with a heart icon. Used on prayer
// cards and the prayer wall section.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class PrayerCountChip extends StatelessWidget {
  const PrayerCountChip({
    required this.count,
    super.key,
    this.compact = false,
  });

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: AppRadius.brFull,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: compact ? 12 : 14,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 4),
          Text(
            '$count praying',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
