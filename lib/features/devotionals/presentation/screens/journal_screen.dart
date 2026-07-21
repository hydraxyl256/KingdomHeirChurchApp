// Kingdom Heir — Devotional Journey: Screen 6 — Journal
//
// Premium journal editor with mood selection, tags, autosave,
// and previous entry history.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({
    required this.devotionalId,
    this.standalone = false,
    super.key,
  });
  final String devotionalId;
  final bool standalone;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  late TextEditingController _bodyController;
  Timer? _autosaveTimer;
  bool _saved = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(devotionalStreakServiceProvider).getDraft() ?? '';
    _bodyController = TextEditingController(text: draft)
      ..addListener(_onTextChange);
  }

  void _onTextChange() {
    _saved = false;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 3), _autosave);
  }

  Future<void> _autosave() async {
    await ref
        .read(devotionalStreakServiceProvider)
        .saveDraft(_bodyController.text);
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _bodyController
      ..removeListener(_onTextChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      // Skip with empty entry
      if (!widget.standalone) {
        await _markComplete();
      }
      return;
    }

    final mood = ref.read(journalMoodProvider);
    final tags = ref.read(journalTagsProvider);
    final devotionalAsync = ref.read(dailyDevotionalProvider);
    final devotional = devotionalAsync.valueOrNull;

    await ref.read(journalEntriesProvider.notifier).addEntry(
          body: body,
          tags: tags.toList(),
          mood: mood,
          devotionalId: devotional?.id,
          devotionalTitle: devotional?.title,
          bibleRef: devotional?.scriptureRef,
        );

    _bodyController.clear();

    if (!widget.standalone) {
      await _markComplete();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brFull),
            content: Text(
              'Journal entry saved!',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(milliseconds: 1800),
          ),
        );
      }
    }
  }

  Future<void> _markComplete() async {
    await ref
        .read(journeyProgressProvider(widget.devotionalId).notifier)
        .markJournalDone();
    await ref
        .read(journeyProgressProvider(widget.devotionalId).notifier)
        .markComplete();
    if (mounted) {
      unawaited(
        context.push(
          '/home/devotionals/${widget.devotionalId}/complete',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(journalMoodProvider);
    final tags = ref.watch(journalTagsProvider);
    final entries = ref.watch(journalEntriesProvider);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Journal',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Autosave indicator
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: AnimatedSwitcher(
                duration: AppMotion.quick,
                child: _saved
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_done_rounded,
                            color: AppColors.success,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Autosave on',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Editor area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Text(
                    today,
                    style: AppTypography.scriptureRef.copyWith(
                      color: AppColors.goldDark,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ).animate().fadeIn(duration: AppMotion.standard),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    "Today's Journal",
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 80.ms, duration: AppMotion.standard),

                  const SizedBox(height: AppSpacing.xl),

                  // Mood selector
                  _MoodSelector(
                    selected: mood,
                    onSelect: (m) =>
                        ref.read(journalMoodProvider.notifier).state = m,
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: AppMotion.standard),

                  const SizedBox(height: AppSpacing.lg),

                  // Tag selector
                  _TagSelector(
                    selected: tags,
                    onToggle: (tag) {
                      final current = Set<JournalTag>.from(tags);
                      if (current.contains(tag)) {
                        current.remove(tag);
                      } else {
                        current.add(tag);
                      }
                      ref.read(journalTagsProvider.notifier).state = current;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 220.ms, duration: AppMotion.standard),

                  const SizedBox(height: AppSpacing.xl),

                  // Journal text area
                  Container(
                    constraints: const BoxConstraints(minHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.dividerLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      minLines: 8,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.navy,
                        height: 1.75,
                        letterSpacing: 0.1,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .whatIsGodSpeakingToYour,
                        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textDisabled,
                          height: 1.75,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: AppMotion.emphasized),

                  const SizedBox(height: AppSpacing.xxl),

                  // Previous entries (collapsible)
                  if (entries.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () => setState(() => _showHistory = !_showHistory),
                      child: Row(
                        children: [
                          Text(
                            'Previous Entries (${entries.length})',
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _showHistory
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    if (_showHistory) ...[
                      const SizedBox(height: AppSpacing.md),
                      ...entries.take(5).map(
                            (e) => _JournalEntryCard(entry: e),
                          ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Action bar
          _JournalActionBar(
            onSkip: widget.standalone
                ? null
                : () async {
                    await _markComplete();
                  },
            onSave: _saveEntry,
            isStandalone: widget.standalone,
          ),
        ],
      ),
    );
  }
}

// ─── Mood Selector ────────────────────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.selected, required this.onSelect});
  final MoodTag? selected;
  final ValueChanged<MoodTag?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'HOW ARE YOU FEELING?',
          style: AppTypography.scriptureRef.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: MoodTag.values.map((m) {
              final isSelected = m == selected;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onSelect(isSelected ? null : m),
                  child: AnimatedContainer(
                    duration: AppMotion.quick,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.goldContainer : Colors.white,
                      borderRadius: AppRadius.brFull,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldDark
                            : AppColors.dividerLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          m.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.label,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? AppColors.goldDark
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Tag Selector ─────────────────────────────────────────────────────────────

class _TagSelector extends StatelessWidget {
  const _TagSelector({required this.selected, required this.onToggle});
  final Set<JournalTag> selected;
  final ValueChanged<JournalTag> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TAGS',
          style: AppTypography.scriptureRef.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: JournalTag.values.map((tag) {
            final isSelected = selected.contains(tag);
            return GestureDetector(
              onTap: () => onToggle(tag),
              child: AnimatedContainer(
                duration: AppMotion.quick,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.white,
                  borderRadius: AppRadius.brFull,
                  border: Border.all(
                    color: isSelected ? AppColors.navy : AppColors.dividerLight,
                  ),
                ),
                child: Text(
                  '# ${tag.label}',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Journal Entry Card ───────────────────────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.dividerLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date + mood
            Row(
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(entry.createdAt),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (entry.mood != null)
                  Text(
                    entry.mood!.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Bible ref
            if (entry.bibleRef != null)
              Text(
                entry.bibleRef!,
                style: AppTypography.scriptureRef.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            // Body preview
            Text(
              entry.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                children: entry.tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.dividerLight,
                          borderRadius: AppRadius.brFull,
                        ),
                        child: Text(
                          '# ${t.label}',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Action Bar ───────────────────────────────────────────────────────────────

class _JournalActionBar extends StatelessWidget {
  const _JournalActionBar({
    required this.onSave,
    required this.isStandalone,
    this.onSkip,
  });
  final VoidCallback onSave;
  final VoidCallback? onSkip;
  final bool isStandalone;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        safeBottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (onSkip != null) ...[
            Expanded(
              child: GestureDetector(
                onTap: onSkip,
                child: Container(
                  height: AppSpacing.buttonHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.dividerLight),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      'Skip',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: onSkip != null ? 2 : 1,
            child: GestureDetector(
              onTap: onSave,
              child: Container(
                height: AppSpacing.buttonHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldDark, AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isStandalone ? 'Save Entry' : 'Save & Complete',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      isStandalone
                          ? Icons.save_rounded
                          : Icons.check_circle_rounded,
                      color: AppColors.ink,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
