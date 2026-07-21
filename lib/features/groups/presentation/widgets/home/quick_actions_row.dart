// Kingdom Heir — Quick Actions Row (SECTION 8)
//
// Three pill buttons: Join, Create, Invite. Single-line on phone,
// wraps on tablet via `Wrap` with runSpacing.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.md, insets.lg, insets.xxl),
      child: Wrap(
        spacing: insets.sm,
        runSpacing: insets.sm,
        children: [
          _Pill(
            icon: Icons.search_rounded,
            label: 'Discover',
            tone: _Tone.filled,
            onTap: () => context.push(RouteNames.groupDiscover),
          )
              .animate()
              .fadeIn(duration: AppMotion.standard)
              .slideY(begin: 0.06, end: 0),
          _Pill(
            icon: Icons.add_circle_outline_rounded,
            label: 'Create',
            tone: _Tone.outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!
                      .groupCreationComingSoonTalkTo,),
                ),
              );
            },
          )
              .animate()
              .fadeIn(duration: AppMotion.standard, delay: 60.ms)
              .slideY(begin: 0.06, end: 0),
          _Pill(
            icon: Icons.share_rounded,
            label: 'Invite',
            tone: _Tone.outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.tapAGroupToShareAn),
                ),
              );
            },
          )
              .animate()
              .fadeIn(duration: AppMotion.standard, delay: 120.ms)
              .slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

enum _Tone { filled, outlined }

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final bg = tone == _Tone.filled ? AppColors.gold : Colors.transparent;
    final fg = tone == _Tone.filled ? AppColors.ink : AppColors.goldDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: insets.md,
            vertical: insets.xs,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: tone == _Tone.outlined
                ? Border.all(color: AppColors.gold, width: 1.5)
                : null,
            boxShadow: tone == _Tone.filled
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
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
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
