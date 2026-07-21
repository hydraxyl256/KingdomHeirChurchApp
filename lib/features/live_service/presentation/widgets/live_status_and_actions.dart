// Kingdom Heir — Live Status Bar + Quick Actions
//
// A single-file widget pair:
//   LiveStatusBar — shows LIVE/countdown/scripture info
//   LiveQuickActions — 8-button horizontal pill row

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/live_prayer_panel.dart';
import 'package:kingdom_heir/features/live_service/presentation/widgets/sermon_notes_panel.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIVE STATUS BAR
// ─────────────────────────────────────────────────────────────────────────────

class LiveStatusBar extends ConsumerWidget {
  const LiveStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(liveServiceStateProvider);

    return stateAsync.when(
      loading: () => const SizedBox(height: 52),
      error: (_, __) => Container(
        height: 52,
        color: AppColors.errorContainer,
        child: const Center(
          child: Text(
            'Live service unavailable',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
          ),
        ),
      ),
      data: (state) => state.isLive
          ? _LiveStatusContent(state: state)
          : _CountdownContent(state: state),
    );
  }
}

class _LiveStatusContent extends ConsumerWidget {
  const _LiveStatusContent({required this.state});
  final LiveServiceState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripture = state.currentScriptureRef;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Duration
          if (state.durationLabel.isNotEmpty) ...[
            const Icon(
              Icons.timer_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              state.durationLabel,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],

          // Connection quality
          Icon(
            _qualityIcon(state.connectionQuality),
            size: 14,
            color: _qualityColor(state.connectionQuality),
          ),
          const SizedBox(width: 4),
          Text(
            state.connectionQuality.label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: _qualityColor(state.connectionQuality),
            ),
          ),

          const Spacer(),

          // Scripture chip — tappable → Bible panel
          if (scripture != null)
            GestureDetector(
              onTap: () {
                ref.read(livePanelTabProvider.notifier).state =
                    LivePanelTab.bible;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldDark),
                ),
                child: Text(
                  '📖 $scripture',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _qualityIcon(ConnectionQuality q) => switch (q) {
        ConnectionQuality.excellent => Icons.signal_wifi_4_bar_rounded,
        ConnectionQuality.good => Icons.network_wifi_3_bar_rounded,
        ConnectionQuality.poor => Icons.network_wifi_1_bar_rounded,
        ConnectionQuality.offline => Icons.wifi_off_rounded,
      };

  Color _qualityColor(ConnectionQuality q) => switch (q) {
        ConnectionQuality.excellent => AppColors.success,
        ConnectionQuality.good => AppColors.success,
        ConnectionQuality.poor => AppColors.gold,
        ConnectionQuality.offline => AppColors.error,
      };
}

class _CountdownContent extends StatefulWidget {
  const _CountdownContent({required this.state});
  final LiveServiceState state;

  @override
  State<_CountdownContent> createState() => _CountdownContentState();
}

class _CountdownContentState extends State<_CountdownContent> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _computeRemaining();
    });
  }

  void _computeRemaining() {
    final nextAt = widget.state.nextServiceAt;
    if (nextAt == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = nextAt.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hasNext = widget.state.nextServiceAt != null;

    if (!hasNext) return const SizedBox.shrink();

    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.04),
        border: const Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.church_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.state.nextServiceTitle ?? 'Next Service',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.state.nextServiceSpeaker != null)
                  Text(
                    widget.state.nextServiceSpeaker!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Countdown
          if (_remaining > Duration.zero)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                d > 0
                    ? '${d}d ${_pad(h)}:${_pad(m)}:${_pad(s)}'
                    : '${_pad(h)}:${_pad(m)}:${_pad(s)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'STARTING',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ─────────────────────────────────────────────────────────────────────────────

class LiveQuickActions extends ConsumerWidget {
  const LiveQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(liveServiceStateProvider);
    final state = stateAsync.valueOrNull;

    final actions = [
      _Action(
        icon: Icons.menu_book_rounded,
        label: 'Bible',
        onTap: () {
          ref.read(livePanelTabProvider.notifier).state = LivePanelTab.bible;
          _showPanelSheet(context, ref, LivePanelTab.bible, state);
        },
      ),
      _Action(
        icon: Icons.edit_note_rounded,
        label: 'Notes',
        onTap: () => _showPanelSheet(context, ref, LivePanelTab.notes, state),
      ),
      _Action(
        icon: Icons.self_improvement_rounded,
        label: 'Prayer',
        color: AppColors.gold,
        onTap: () => _showPrayerSheet(context, ref),
      ),
      _Action(
        icon: Icons.share_rounded,
        label: 'Share',
        onTap: () => _share(state),
      ),
      _Action(
        icon: Icons.bookmark_border_rounded,
        label: 'Bookmark',
        onTap: () {},
      ),
      _Action(
        icon: Icons.cast_rounded,
        label: 'Cast',
        onTap: () {},
      ),
      _Action(
        icon: Icons.favorite_border_rounded,
        label: 'Give',
        color: AppColors.gold,
        onTap: () => openDonationPage(context),
      ),
      _Action(
        icon: Icons.flag_outlined,
        label: 'Report',
        color: AppColors.textDisabled,
        onTap: () {},
      ),
    ];

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: actions
              .asMap()
              .entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _ActionPill(action: e.value)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: e.key * 50),
                        duration: 300.ms,
                      )
                      .slideX(
                        begin: 0.1,
                        end: 0,
                        delay: Duration(milliseconds: e.key * 50),
                      ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _share(LiveServiceState? state) {
    Share.share(
      state != null && state.isLive
          ? 'Watch "${state.serviceTitle ?? 'Sunday Service'}" LIVE with Kingdom Heirs Church! Download the Kingdom Heirs Church App.'
          : 'Watch Kingdom Heirs Church services anytime. Download the Kingdom Heirs Church App!',
    );
  }

  void _showPrayerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LivePrayerPanel(),
    );
  }

  void _showPanelSheet(
    BuildContext context,
    WidgetRef ref,
    LivePanelTab tab,
    LiveServiceState? state,
  ) {
    final sermonId = state?.serviceId ?? 'live';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => tab == LivePanelTab.notes
          ? SermonNotesPanel(sermonId: sermonId)
          : const _BiblePanelStub(),
    );
  }
}

class _BiblePanelStub extends StatelessWidget {
  const _BiblePanelStub();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: AppColors.gold,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bible Reference',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scripture references from the sermon will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Model ─────────────────────────────────────────────────────────────

class _Action {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
}

// ─── Action Pill ──────────────────────────────────────────────────────────────

class _ActionPill extends StatefulWidget {
  const _ActionPill({required this.action});
  final _Action action;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.action.color ?? AppColors.navy;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.action.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(widget.action.icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              widget.action.label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
