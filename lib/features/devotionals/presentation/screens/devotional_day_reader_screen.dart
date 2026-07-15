// Kingdom Heir — Devotional Day Reader Screen
//
// Displays a single devotional entry (by day number within a series).
// Steps: Scripture → Body → Reflection Question → Action Step → Prayer
// Bottom CTA: "Mark as Complete" — calls the secure DB function via provider.
// Shows language-fallback banner when displaying English instead of user's locale.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_series_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_series_provider.dart';

class DevotionalDayReaderScreen extends ConsumerStatefulWidget {
  const DevotionalDayReaderScreen({
    required this.seriesId,
    required this.dayNumber,
    super.key,
  });

  final String seriesId;
  final int dayNumber;

  @override
  ConsumerState<DevotionalDayReaderScreen> createState() =>
      _DevotionalDayReaderScreenState();
}

class _DevotionalDayReaderScreenState
    extends ConsumerState<DevotionalDayReaderScreen> {
  final _reflectionController = TextEditingController();
  bool _isCompleting = false;
  bool _reflectionDirty = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _markComplete(DevotionalEntry entry) async {
    setState(() => _isCompleting = true);

    // Save reflection first if user typed something
    if (_reflectionDirty && _reflectionController.text.trim().isNotEmpty) {
      await ref
          .read(reflectionSaveProvider.notifier)
          .save(entry.id, _reflectionController.text.trim());
    }

    final result = await ref
        .read(devotionalProgressProvider(widget.seriesId).notifier)
        .completeDay(widget.dayNumber);

    setState(() => _isCompleting = false);

    if (!mounted) return;

    result.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      ),
      _showCompletionDialog,
    );
  }

  void _showCompletionDialog(DevotionalSeriesProgress progress) {
    final nextDay = widget.dayNumber + 1;
    final isAllDone = progress.isAllComplete;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllDone
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle_rounded,
              color: AppColors.gold,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isAllDone ? '🎉 All 90 Days Complete!' : 'Day ${widget.dayNumber} Complete!',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isAllDone
                  ? 'Congratulations! You have completed the entire 90-Day Journey.'
                  : 'Streak: ${progress.currentStreak} day${progress.currentStreak == 1 ? '' : 's'} 🔥\nDay $nextDay unlocks tomorrow.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // back to series detail
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(isAllDone ? 'Celebrate!' : 'Back to Journey'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(devotionalEntryProvider(
      (seriesId: widget.seriesId, dayNumber: widget.dayNumber),
    ),);
    final progressAsync =
        ref.watch(devotionalProgressProvider(widget.seriesId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => _ErrorView(message: err.toString()),
        data: (entry) {
          if (entry == null) {
            return const _ErrorView(message: 'This day is not yet available.');
          }

          final progress = progressAsync.valueOrNull;
          final isAlreadyDone =
              progress?.isDayCompleted(widget.dayNumber) ?? false;
          final isDayUnlocked =
              progress?.isDayUnlocked(widget.dayNumber) ?? false;

          // Pre-fill reflection if saved
          ref
              .watch(devotionalReflectionProvider(entry.id))
              .whenData((reflection) {
            if (reflection != null &&
                _reflectionController.text.isEmpty) {
              _reflectionController.text = reflection.reflectionText ?? '';
            }
          });

          return CustomScrollView(
            slivers: [
              // ── App bar ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.navy,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Day ${widget.dayNumber}',
                    style: const TextStyle(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.navy, AppColors.navyAccent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          const Icon(Icons.menu_book_rounded,
                              color: AppColors.gold, size: 40,),
                          const SizedBox(height: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              entry.title,
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppColors.warmWhite,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Fallback language banner ───────────────────
                    if (entry.isFallback)
                      _FallbackBanner(theme: theme),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Scripture ─────────────────────────────────
                    if (entry.scriptureReference != null ||
                        entry.scriptureText != null) ...[
                      _SectionCard(
                        icon: Icons.book_rounded,
                        iconColor: AppColors.gold,
                        label: 'Scripture',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.scriptureReference != null)
                              Text(
                                entry.scriptureReference!,
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            if (entry.scriptureText != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                entry.scriptureText!,
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.65,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Devotional body ───────────────────────────
                    _SectionCard(
                      icon: Icons.auto_stories_rounded,
                      iconColor: const Color(0xFF6366F1),
                      label: "Today's Devotional",
                      child: Text(
                        entry.devotionalBody,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          height: 1.75,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Reflection question ───────────────────────
                    if (entry.reflectionQuestion != null) ...[
                      _SectionCard(
                        icon: Icons.psychology_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        label: 'Reflection',
                        child: Text(
                          entry.reflectionQuestion!,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Action step ───────────────────────────────
                    if (entry.actionStep != null) ...[
                      _SectionCard(
                        icon: Icons.directions_run_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: 'Action Step',
                        child: Text(
                          entry.actionStep!,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            height: 1.65,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Prayer ────────────────────────────────────
                    if (entry.prayerText != null) ...[
                      _SectionCard(
                        icon: Icons.volunteer_activism_rounded,
                        iconColor: AppColors.gold,
                        label: 'Prayer',
                        backgroundColor: AppColors.gold.withValues(alpha: 0.06),
                        borderColor: AppColors.gold.withValues(alpha: 0.25),
                        child: Text(
                          entry.prayerText!,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Journal reflection input ───────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note_rounded,
                                  color: AppColors.gold, size: 20,),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Your Reflection',
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _reflectionController,
                            maxLines: 5,
                            onChanged: (_) =>
                                setState(() => _reflectionDirty = true),
                            decoration: InputDecoration(
                              hintText:
                                  'Write your thoughts, prayers, or insights…',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.gold,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Mark complete CTA ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isAlreadyDone || _isCompleting || !isDayUnlocked
                              ? null
                              : () => _markComplete(entry),
                          icon: _isCompleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.navy,
                                  ),
                                )
                              : Icon(
                                  isAlreadyDone
                                      ? Icons.check_circle_rounded
                                      : Icons.done_all_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            isAlreadyDone
                                ? 'Day ${widget.dayNumber} Complete ✓'
                                : 'Mark as Complete',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAlreadyDone
                                ? AppColors.success
                                : AppColors.gold,
                            foregroundColor: AppColors.navy,
                            disabledBackgroundColor: isAlreadyDone
                                ? AppColors.success
                                : AppColors.gold.withValues(alpha: 0.4),
                            disabledForegroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            elevation: 0,
                            textStyle:
                                AppTypography.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label.toUpperCase(),
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ─── Fallback banner ──────────────────────────────────────────────────────────

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 18,),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Available in English — translation coming soon.',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 56, color: AppColors.warning,),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
