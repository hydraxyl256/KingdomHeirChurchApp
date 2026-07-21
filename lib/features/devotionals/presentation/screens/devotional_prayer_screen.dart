// Kingdom Heir — Devotional Journey: Screen 5 — Prayer
//
// Guided prayer experience with optional timer, written prayer,
// and completion tracking.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

// ─── Timer durations ──────────────────────────────────────────────────────────

enum _PrayerDuration {
  none,
  oneMin,
  threeMin,
  fiveMin,
}

extension _PrayerDurationX on _PrayerDuration {
  String get label => switch (this) {
        _PrayerDuration.none => 'No timer',
        _PrayerDuration.oneMin => '1 min',
        _PrayerDuration.threeMin => '3 min',
        _PrayerDuration.fiveMin => '5 min',
      };

  int get seconds => switch (this) {
        _PrayerDuration.none => 0,
        _PrayerDuration.oneMin => 60,
        _PrayerDuration.threeMin => 180,
        _PrayerDuration.fiveMin => 300,
      };
}

// ─────────────────────────────────────────────────────────────────────────────

class DevotionalPrayerScreen extends ConsumerStatefulWidget {
  const DevotionalPrayerScreen({required this.devotionalId, super.key});
  final String devotionalId;

  @override
  ConsumerState<DevotionalPrayerScreen> createState() =>
      _DevotionalPrayerScreenState();
}

class _DevotionalPrayerScreenState
    extends ConsumerState<DevotionalPrayerScreen> {
  final _prayerController = TextEditingController();
  bool _prayerComplete = false;
  _PrayerDuration _selectedDuration = _PrayerDuration.none;

  // Timer state
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _timerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    _prayerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_selectedDuration == _PrayerDuration.none) return;
    setState(() {
      _secondsRemaining = _selectedDuration.seconds;
      _timerRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timerRunning = false;
          t.cancel();
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _secondsRemaining = 0;
    });
  }

  void _onTimerComplete() {
    setState(() => _prayerComplete = true);
  }

  String get _timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _markComplete() async {
    await ref
        .read(journeyProgressProvider(widget.devotionalId).notifier)
        .markPrayerDone();
    if (mounted) {
      unawaited(
        context.push('/home/devotionals/${widget.devotionalId}/journal'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final devotionalAsync = ref.watch(dailyDevotionalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Prayer',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: devotionalAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (devotional) {
          final guidedPrayer = devotional?.prayer ??
              "Lord, thank You for the gift of today's Word. May it take root in my heart and bear fruit in my life. Let Your will be done in all that I do today. Amen.";

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                MediaQuery.of(context).padding.bottom + AppSpacing.massive,
              ),
              child: Column(
                children: [
                  // Gold glow icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [AppColors.gold, AppColors.goldDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.self_improvement_rounded,
                      color: AppColors.ink,
                      size: 36,
                    ),
                  ).animate().fadeIn(duration: AppMotion.reverent).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: AppMotion.reverent,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Time to Pray',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Speak to God from your heart.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Guided prayer card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.goldLight,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Guided Prayer',
                              style: AppTypography.scriptureRef.copyWith(
                                color: AppColors.goldLight,
                                letterSpacing: 1,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          guidedPrayer,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.75,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: AppMotion.emphasized)
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        delay: 350.ms,
                        duration: AppMotion.emphasized,
                        curve: AppMotion.decelerate,
                      ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Timer section
                  _TimerSection(
                    selected: _selectedDuration,
                    timerRunning: _timerRunning,
                    secondsRemaining: _secondsRemaining,
                    timerDisplay: _timerDisplay,
                    onSelect: (d) {
                      setState(() => _selectedDuration = d);
                      _stopTimer();
                    },
                    onStart: _startTimer,
                    onStop: _stopTimer,
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Write your prayer
                  _WritePrayerField(controller: _prayerController),

                  const SizedBox(height: AppSpacing.xxl),

                  // Complete toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _prayerComplete = !_prayerComplete),
                    child: AnimatedContainer(
                      duration: AppMotion.standard,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _prayerComplete
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                          color: _prayerComplete
                              ? AppColors.gold
                              : Colors.white.withValues(alpha: 0.1),
                          width: _prayerComplete ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: AppMotion.standard,
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _prayerComplete
                                  ? AppColors.goldDark
                                  : Colors.transparent,
                              borderRadius: AppRadius.brCircle,
                              border: Border.all(
                                color: _prayerComplete
                                    ? AppColors.goldDark
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: _prayerComplete
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            _prayerComplete
                                ? 'Prayer completed ✓'
                                : 'Mark prayer as complete',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: _prayerComplete
                                  ? AppColors.goldLight
                                  : Colors.white.withValues(alpha: 0.7),
                              fontWeight: _prayerComplete
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 650.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Continue
                  GestureDetector(
                    onTap: _markComplete,
                    child: Container(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldDark, AppColors.gold],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Journal',
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.ink,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 750.ms, duration: 400.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Timer Section ─────────────────────────────────────────────────────────────

class _TimerSection extends StatelessWidget {
  const _TimerSection({
    required this.selected,
    required this.timerRunning,
    required this.secondsRemaining,
    required this.timerDisplay,
    required this.onSelect,
    required this.onStart,
    required this.onStop,
  });

  final _PrayerDuration selected;
  final bool timerRunning;
  final int secondsRemaining;
  final String timerDisplay;
  final ValueChanged<_PrayerDuration> onSelect;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'OPTIONAL PRAYER TIMER',
          style: AppTypography.scriptureRef.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 1.5,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Duration chips
        Row(
          children: _PrayerDuration.values.map((d) {
            final isSelected = d == selected;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelect(d),
                child: AnimatedContainer(
                  duration: AppMotion.quick,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.goldDark
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: AppRadius.brFull,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.goldDark
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    d.label,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isSelected ? AppColors.ink : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Timer display + controls
        if (selected != _PrayerDuration.none) ...[
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timerRunning || secondsRemaining > 0)
                  Text(
                    timerDisplay,
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: timerRunning ? onStop : onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: timerRunning
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.goldDark.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: timerRunning
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.goldDark,
                      ),
                    ),
                    child: Text(
                      timerRunning ? 'Stop Timer' : 'Start Timer',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color:
                            timerRunning ? Colors.white70 : AppColors.goldLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Write Prayer Field ────────────────────────────────────────────────────────

class _WritePrayerField extends StatefulWidget {
  const _WritePrayerField({required this.controller});
  final TextEditingController controller;

  @override
  State<_WritePrayerField> createState() => _WritePrayerFieldState();
}

class _WritePrayerFieldState extends State<_WritePrayerField> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expanded ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _expanded
                ? AppColors.gold.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_rounded,
                  color: AppColors.goldLight,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Write Your Prayer',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: widget.controller,
                maxLines: 5,
                minLines: 3,
                autofocus: _expanded,
                keyboardType: TextInputType.multiline,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.65,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.speakToGodInYourOwn,
                  hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap to write your personal prayer…',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
