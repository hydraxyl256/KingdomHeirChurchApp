import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: status.isLive
          ? _LiveCard(status: status, onWatchNow: onWatchNow)
          : (status.startsAt == null
              ? const SizedBox.shrink()
              : _NextServiceCard(
                  status: status,
                  onInvite: onAddReminder, // Using for Invite Friend
                  onDetails: onDirections,  // Using for Details
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconography.live, color: Color(0xFFDC2626), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Watch',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
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
    this.onInvite,
    this.onDetails,
  });

  final ServiceStatus status;
  final VoidCallback? onInvite;
  final VoidCallback? onDetails;

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        // Adaptive card surface
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background decorative glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.goldDark),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'NEXT SERVICE',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: AppColors.goldDark,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.status.title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    // Adaptive primary text
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.status.locationLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${widget.status.locationLabel} · 9:00 AM',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      // Adaptive secondary/muted text
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),

                // Countdown Timer Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    // Slightly raised surface inside the card
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeBlock(value: two(days), label: 'Days'),
                      const SizedBox(width: AppSpacing.sm),
                      _TimeBlock(value: two(hours), label: 'Hrs'),
                      const SizedBox(width: AppSpacing.sm),
                      _TimeBlock(value: two(minutes), label: 'Mins', highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onInvite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldDark,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.group_add_rounded, size: 18),
                        label: const Text('Invite Friend', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onDetails,
                        style: ElevatedButton.styleFrom(
                          // Adaptive secondary action button
                          backgroundColor: cs.surfaceContainerHigh,
                          foregroundColor: cs.onSurface,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.value, required this.label, this.highlight = false});
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            // Adaptive: gold for highlighted unit, onSurface for others
            color: highlight ? AppColors.goldDark : cs.onSurface,
            fontFamily: 'Roboto',
            letterSpacing: -1,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: highlight ? AppColors.goldDark : cs.onSurfaceVariant,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
