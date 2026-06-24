// Kingdom Heir — Quick Stat Tile
//
// A single metric tile for the leader dashboard. Big number + label +
// optional delta indicator.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class QuickStatTile extends StatelessWidget {
  const QuickStatTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.delta,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? delta;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(icon, size: 18, color: c),
              ),
              SizedBox(width: insets.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: insets.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (delta != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                delta!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: c,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
