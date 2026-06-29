// Kingdom Heir — Devotional Journey: Screen 7 — Journey Complete
//
// Premium celebration screen with animated streak, weekly progress,
// next devotional preview, encouraging verse, and share capability.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:share_plus/share_plus.dart';

// ─── Encouraging verses ───────────────────────────────────────────────────────

const _encouragingVerses = [
  (ref: 'Psalm 1:2', text: 'His delight is in the law of the Lord, and on His law he meditates day and night.'),
  (ref: 'Joshua 1:8', text: 'Keep this Book of the Law always on your lips; meditate on it day and night.'),
  (ref: 'Colossians 3:16', text: 'Let the word of Christ dwell in you richly as you teach and admonish one another.'),
  (ref: 'Psalm 119:105', text: 'Your word is a lamp for my feet, a light on my path.'),
  (ref: 'Romans 10:17', text: 'Faith comes from hearing the message, and the message is heard through the word of Christ.'),
];

class JourneyCompleteScreen extends ConsumerWidget {
  const JourneyCompleteScreen({required this.devotionalId, super.key});
  final String devotionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(devotionalStreakProvider);
    final progress = ref.watch(journeyProgressProvider(devotionalId));
    // Pick an encouraging verse based on day of year
    final verseIndex =
        DateTime.now().dayOfYear % _encouragingVerses.length;
    final verse = _encouragingVerses[verseIndex];

    // Haptic feedback on mount
    HapticFeedback.mediumImpact();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Stack(
          children: [
            // Background gradient orbs
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navyLight.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    // ── Trophy / celebration mark ─────────────────────────
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.goldDark, AppColors.gold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: Offset.zero,
                          end: const Offset(1, 1),
                          duration: AppMotion.reverent,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Title ─────────────────────────────────────────────
                    Text(
                      "Today's Journey\nComplete! 🎉",
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          duration: 500.ms,
                          curve: AppMotion.decelerate,
                        ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'Well done for spending time with God today.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Streak highlight ──────────────────────────────────
                    _StreakHighlight(streak: streak),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Weekly progress ───────────────────────────────────
                    _WeeklyProgressRow(streak: streak),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Steps completed ───────────────────────────────────
                    if (progress != null) _StepsCompleted(progress: progress),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Gold divider ──────────────────────────────────────
                    Container(
                      width: 48,
                      height: 1.5,
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ).animate().fadeIn(delay: 800.ms, duration: 300.ms),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Encouraging verse ─────────────────────────────────
                    _VerseCard(verse: verse),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Share button ──────────────────────────────────────
                    _ShareButton(streak: streak)
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 400.ms),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Done button ───────────────────────────────────────
                    GestureDetector(
                      onTap: () {
                        // Pop back to devotionals home
                        while (context.canPop()) {
                          context.pop();
                        }
                      },
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
                        child: Center(
                          child: Text(
                            'Done — Back to Devotionals',
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),

            // ── Particle celebration overlay ──────────────────────────────
            const _CelebrationParticles(),
          ],
        ),
      ),
    );
  }
}

// ─── Streak Highlight ─────────────────────────────────────────────────────────

class _StreakHighlight extends StatelessWidget {
  const _StreakHighlight({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(
            emoji: '🔥',
            value: '${streak.currentStreak}',
            label: 'Day Streak',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _StatCell(
            emoji: '🏆',
            value: '${streak.longestStreak}',
            label: 'Best Streak',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _StatCell(
            emoji: '⭐',
            value: '${streak.totalCompletedDays}',
            label: 'Total Days',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 650.ms, duration: AppMotion.emphasized).slideY(
          begin: 0.05,
          end: 0,
          delay: 650.ms,
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.goldLight,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ─── Weekly Progress ──────────────────────────────────────────────────────────

class _WeeklyProgressRow extends StatelessWidget {
  const _WeeklyProgressRow({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'THIS WEEK',
          style: AppTypography.scriptureRef.copyWith(
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final done = i < streak.weeklyCompletion.length &&
                streak.weeklyCompletion[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.standard,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.goldDark
                          : Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done
                            ? AppColors.goldDark
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16,)
                          : Text(
                              labels[i],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${streak.thisWeekCount} of 7 days this week',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 750.ms, duration: AppMotion.standard);
  }
}

// ─── Steps Completed ──────────────────────────────────────────────────────────

class _StepsCompleted extends StatelessWidget {
  const _StepsCompleted({required this.progress});
  final DevotionalProgress progress;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.menu_book_rounded, label: 'Scripture', done: progress.scriptureRead),
      (icon: Icons.auto_stories_rounded, label: 'Devotional', done: progress.contentRead),
      (icon: Icons.lightbulb_rounded, label: 'Reflection', done: progress.reflectionDone),
      (icon: Icons.self_improvement_rounded, label: 'Prayer', done: progress.prayerDone),
      (icon: Icons.edit_note_rounded, label: 'Journal', done: progress.journalDone),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'JOURNEY STEPS',
          style: AppTypography.scriptureRef.copyWith(
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: steps.map((s) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: s.done
                    ? AppColors.goldDark.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: AppRadius.brFull,
                border: Border.all(
                  color: s.done
                      ? AppColors.goldDark.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    s.done ? Icons.check_circle_rounded : s.icon,
                    color: s.done
                        ? AppColors.goldLight
                        : Colors.white.withValues(alpha: 0.3),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.label,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: s.done
                          ? AppColors.goldLight
                          : Colors.white.withValues(alpha: 0.35),
                      fontWeight: s.done ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 850.ms, duration: AppMotion.standard);
  }
}

// ─── Verse Card ───────────────────────────────────────────────────────────────

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.verse});
  final ({String ref, String text}) verse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '"',
            style: TextStyle(
              fontSize: 48,
              height: 0.5,
              color: AppColors.gold.withValues(alpha: 0.3),
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            verse.text,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '— ${verse.ref}',
            style: AppTypography.scriptureRef.copyWith(
              color: AppColors.goldLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms, duration: AppMotion.emphasized);
  }
}

// ─── Share Button ─────────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.streak});
  final DevotionalStreak streak;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Share.share(
          'I just completed my daily devotional on the Kingdom Heirs Church App! 🙏🔥 ${streak.currentStreak}-day streak!\n\n"His word is a lamp to my feet and a light to my path." — Psalm 119:105',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: AppRadius.brFull,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share_rounded, color: Colors.white70, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Share My Journey',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Celebration Particles ────────────────────────────────────────────────────

class _CelebrationParticles extends StatelessWidget {
  const _CelebrationParticles();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Subtle gold particle dots — no third-party confetti needed
    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: List.generate(12, (i) {
            final x = (i * 83.7 + 40) % size.width;
            final y = (i * 67.3 + 80) % (size.height * 0.5);
            final s = 4.0 + (i % 3) * 3;
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: i.isEven
                      ? AppColors.gold.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(delay: Duration(milliseconds: i * 80))
                  .fadeIn(duration: 400.ms)
                  .then()
                  .fadeOut(duration: 1200.ms)
                  .moveY(begin: 0, end: -30, duration: 1600.ms),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Date helper ──────────────────────────────────────────────────────────────

extension _DateTimeX on DateTime {
  int get dayOfYear {
    final start = DateTime(year);
    return difference(start).inDays;
  }
}
