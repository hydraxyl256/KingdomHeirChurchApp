// Kingdom Heir — Live & Upcoming (SECTION 5)
//
// Two related cards:
//   1. LiveServiceCard — pulsing red/gold live badge, hero gradient, viewer
//      count, "Watch now" CTA. Visible only when [live] is non-null.
//   2. UpcomingServiceCard — countdown timer to the next service, location
//      label, RSVP CTA. Visible only when [upcoming] is non-null.
//
// Layout:
//   • < 600 dp: cards stack vertically with insets.sm between them
//   • ≥ 600 dp: cards render side-by-side inside an IntrinsicHeight row
//     with two Expanded children
//
// The countdown uses a stateful widget that ticks every second via
// Timer.periodic and respects MediaQuery.disableAnimations.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/dashboard/domain/dashboard_models.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class LiveAndUpcomingSection extends StatelessWidget {
  const LiveAndUpcomingSection({
    required this.live,
    required this.upcoming,
    super.key,
    this.onWatchLive,
    this.onRsvp,
  });

  final LiveService? live;
  final UpcomingService? upcoming;
  final VoidCallback? onWatchLive;
  final VoidCallback? onRsvp;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    if (live == null && upcoming == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Live & upcoming',
          icon: Icons.podcasts_rounded,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSideBySide = layoutBandFromWidth(constraints.maxWidth)
                .isAtLeast(LayoutBand.lg);

            final liveCard = live == null
                ? null
                : LiveServiceCard(
                    service: live!,
                    onWatch: onWatchLive,
                  );
            final upcomingCard = upcoming == null
                ? null
                : UpcomingServiceCard(
                    service: upcoming!,
                    onRsvp: onRsvp,
                  );

            if (isSideBySide && liveCard != null && upcomingCard != null) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: liveCard),
                      SizedBox(width: insets.md),
                      Expanded(child: upcomingCard),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (liveCard != null) liveCard,
                  if (liveCard != null && upcomingCard != null)
                    SizedBox(height: insets.md),
                  if (upcomingCard != null) upcomingCard,
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class LiveServiceCard extends StatelessWidget {
  const LiveServiceCard({required this.service, this.onWatch, super.key});
  final LiveService service;
  final VoidCallback? onWatch;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid, AppColors.navyAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _LiveBadge(),
                    const Spacer(),
                    _ViewerChip(count: service.viewerCount),
                  ],
                ),
                SizedBox(height: insets.lg),
                Text(
                  service.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: insets.xs),
                Text(
                  service.hostLabel,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmWhite.withValues(alpha: 0.78),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: insets.md),
                AppButton(
                  label: 'Watch live',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onWatch,
                  height: 44,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.emphasized, curve: AppMotion.decelerate)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.emphasized);
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final shouldReduce = mq.disableAnimations;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: shouldReduce
                ? const AlwaysStoppedAnimation<double>(1)
                : Tween<double>(begin: 0.85, end: 1.1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                  ),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.warmWhite,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerChip extends StatelessWidget {
  const _ViewerChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.sm,
        vertical: insets.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility_rounded,
            color: AppColors.warmWhite,
            size: 14,
          ),
          SizedBox(width: insets.xxs),
          Text(
            _format(count),
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _format(int n) {
    if (n < 1000) return '$n';
    if (n < 10000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000).round()}K';
  }
}

class UpcomingServiceCard extends StatelessWidget {
  const UpcomingServiceCard({required this.service, this.onRsvp, super.key});
  final UpcomingService service;
  final VoidCallback? onRsvp;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(insets.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(insets.xs),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: AppColors.goldDark,
                ),
              ),
              SizedBox(width: insets.xs),
              Text(
                'NEXT SERVICE',
                style: AppTypography.scriptureRef.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
          SizedBox(height: insets.md),
          Text(
            service.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: insets.xs),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.goldDark,
              ),
              SizedBox(width: insets.xxs),
              Expanded(
                child: Text(
                  service.locationLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: insets.md),
          CountdownLabel(target: service.startsAt),
          SizedBox(height: insets.md),
          OutlinedButton.icon(
            onPressed: onRsvp,
            icon: const Icon(Icons.notifications_active_outlined, size: 16),
            label: Text(AppLocalizations.of(context)!.remindMe),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.goldDark,
              side: const BorderSide(color: AppColors.goldDark, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: AppMotion.emphasized,
          delay: const Duration(milliseconds: 80),
          curve: AppMotion.decelerate,
        )
        .slideY(begin: 0.06, end: 0, duration: AppMotion.emphasized);
  }
}

/// State widget that renders the time remaining until [target].
class CountdownLabel extends StatefulWidget {
  const CountdownLabel({required this.target, super.key});
  final DateTime target;

  @override
  State<CountdownLabel> createState() => _CountdownLabelState();
}

class _CountdownLabelState extends State<CountdownLabel> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recompute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
  }

  @override
  void didUpdateWidget(covariant CountdownLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) _recompute();
  }

  void _recompute() {
    final r = widget.target.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    final parts = _split(_remaining);
    return Row(
      children: [
        for (final part in parts) ...[
          _Cell(value: part.value, label: part.label),
          if (part != parts.last)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: insets.xxs),
              child: Text(
                ':',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ],
    );
  }

  static List<_CountdownPart> _split(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (days > 0) {
      return [
        _CountdownPart(days.toString().padLeft(2, '0'), 'd'),
        _CountdownPart(hours.toString().padLeft(2, '0'), 'h'),
        _CountdownPart(minutes.toString().padLeft(2, '0'), 'm'),
      ];
    }
    return [
      _CountdownPart(hours.toString().padLeft(2, '0'), 'h'),
      _CountdownPart(minutes.toString().padLeft(2, '0'), 'm'),
      _CountdownPart(seconds.toString().padLeft(2, '0'), 's'),
    ];
  }
}

class _CountdownPart {
  const _CountdownPart(this.value, this.label);
  final String value;
  final String label;
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: insets.sm,
        vertical: insets.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
