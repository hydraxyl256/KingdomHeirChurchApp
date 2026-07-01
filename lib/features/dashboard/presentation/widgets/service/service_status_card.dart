// Kingdom Heir — Section 4: Premium Service Status Card
//
// Renders one of three variants based on `status`:
//   • LIVE NOW    → red gradient card with pulsing dot + "Watch Live"
//   • UPCOMING    → white card with HH:MM:SS countdown + Reminder / Calendar
//                   / Directions actions
//   • EMPTY       → soft "Schedule coming soon" placeholder
//
// The countdown ticks every 1s via `Timer.periodic` and respects
// `MediaQuery.disableAnimations` (paused when the user prefers reduced
// motion).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard({
    required this.status,
    super.key,
    this.onWatchNow,
    this.onAddReminder,
    this.onAddToCalendar,
    this.onDirections,
  });

  final ServiceStatus status;
  final VoidCallback? onWatchNow;
  final VoidCallback? onAddReminder;
  final VoidCallback? onAddToCalendar;
  final VoidCallback? onDirections;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: status.isLive
          ? _LiveCard(status: status, onWatchNow: onWatchNow)
          : (status.startsAt == null
              ? const _EmptyServiceCard()
              : _NextServiceCard(
                  status: status,
                  onAddReminder: onAddReminder,
                  onAddToCalendar: onAddToCalendar,
                  onDirections: onDirections,
                )),
    ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(
          begin: 0.06,
          end: 0,
          delay: 320.ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Live Card ─────────────────────────────────────────────────────────────────

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.status, this.onWatchNow});
  final ServiceStatus status;
  final VoidCallback? onWatchNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulseDot(),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'LIVE NOW',
                        style: AppTypography.scriptureRef.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    status.title,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status.hostLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      status.hostLabel!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  if (status.viewerCount != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${status.viewerCount} watching',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Semantics(
              button: true,
              label: 'Watch live',
              child: GestureDetector(
                onTap: onWatchNow,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconography.live,
                        color: Color(0xFFDC2626),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watch',
                        style:
                            AppTypography.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(2.2, 2.2),
                duration: 1000.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(begin: 0.7, duration: 1000.ms),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next Service Card ─────────────────────────────────────────────────────────

class _NextServiceCard extends StatefulWidget {
  const _NextServiceCard({
    required this.status,
    this.onAddReminder,
    this.onAddToCalendar,
    this.onDirections,
  });

  final ServiceStatus status;
  final VoidCallback? onAddReminder;
  final VoidCallback? onAddToCalendar;
  final VoidCallback? onDirections;

  @override
  State<_NextServiceCard> createState() => _NextServiceCardState();
}

class _NextServiceCardState extends State<_NextServiceCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    // Tick once per second. If the user prefers reduced motion, the
    // UI rebuilds once per second instead of churning — the value
    // still updates. (We deliberately don't read MediaQuery here:
    // doing so in initState would throw.)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final target = widget.status.startsAt;
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Format as `HH:MM:SS` (days omitted if 0). Sub-hour shows `MM:SS`.
  String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    String two(int n) => n.toString().padLeft(2, '0');

    if (days > 0) {
      return '${days}d ${two(hours)}:${two(minutes)}:${two(seconds)}';
    }
    if (hours > 0) {
      return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    }
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row — icon + title + countdown
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.goldContainer,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Iconography.calendar,
                    color: AppColors.goldDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEXT SERVICE',
                        style: AppTypography.scriptureRef.copyWith(
                          color: AppColors.goldDark,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.title,
                        style:
                            AppTypography.textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s.hostLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'with ${s.hostLabel}',
                          style:
                              AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _format(_remaining),
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (s.locationLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Iconography.directions,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.locationLabel!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 0.5,
              color: AppColors.dividerLight,
            ),
            const SizedBox(height: AppSpacing.md),
            // Action row — equal-width tiles so they fit a 320dp card
            // (the dashboard uses 1080×2400 → ~360dp content width).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _MiniAction(
                    icon: Iconography.reminder,
                    label: 'Remind',
                    onTap: widget.onAddReminder,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _MiniAction(
                    icon: Iconography.calendar,
                    label: 'Calendar',
                    onTap: widget.onAddToCalendar,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _MiniAction(
                    icon: Iconography.directions,
                    label: 'Directions',
                    onTap: widget.onDirections,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.goldContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.goldDark),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.goldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyServiceCard extends StatelessWidget {
  const _EmptyServiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.goldContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconography.calendar,
            color: AppColors.goldDark,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Schedule coming soon',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'We’re preparing the next service schedule — check back shortly.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
