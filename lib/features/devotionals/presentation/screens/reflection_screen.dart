// Kingdom Heir — Devotional Journey: Screen 4 — Reflection
//
// Elegant swipeable prompt cards with autosave responses.

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
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_journey_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({required this.devotionalId, super.key});
  final String devotionalId;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final PageController _pageController = PageController();
  int _currentPrompt = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < ReflectionPrompt.defaults.length; i++) {
      _controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final prompts = ref.read(reflectionPromptsProvider);
    // Save current response
    final text = _controllers[_currentPrompt]?.text.trim() ?? '';
    if (text.isNotEmpty) {
      ref
          .read(reflectionPromptsProvider.notifier)
          .updateResponse(_currentPrompt, text);
    }

    if (_currentPrompt < prompts.length - 1) {
      unawaited(
        _pageController.nextPage(
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        ),
      );
    } else {
      await _finish();
    }
  }

  Future<void> _skip() async {
    final prompts = ref.read(reflectionPromptsProvider);
    if (_currentPrompt < prompts.length - 1) {
      unawaited(
        _pageController.nextPage(
          duration: AppMotion.emphasized,
          curve: AppMotion.decelerate,
        ),
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await ref
        .read(journeyProgressProvider(widget.devotionalId).notifier)
        .markReflectionDone();
    if (mounted) {
      unawaited(
        context.push('/home/devotionals/${widget.devotionalId}/prayer'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(reflectionPromptsProvider);
    final isLast = _currentPrompt == prompts.length - 1;

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
          'Reflection',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress dots ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(prompts.length, (i) {
                final isActive = i == _currentPrompt;
                final isDone = i < _currentPrompt;
                return AnimatedContainer(
                  duration: AppMotion.standard,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.success
                        : isActive
                            ? AppColors.goldDark
                            : AppColors.dividerLight,
                    borderRadius: AppRadius.brCircle,
                  ),
                );
              }),
            ),
          ),

          // ── Prompt header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Question ${_currentPrompt + 1} of ${prompts.length}',
                  style: AppTypography.scriptureRef.copyWith(
                    color: AppColors.goldDark,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Take a moment to reflect',
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppMotion.standard),

          const SizedBox(height: AppSpacing.xl),

          // ── Prompt PageView ────────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPrompt = i),
              itemCount: prompts.length,
              itemBuilder: (context, i) => _PromptCard(
                prompt: prompts[i],
                controller: _controllers[i]!,
                index: i,
              ),
            ),
          ),

          // ── Action bar ────────────────────────────────────────────────
          _ReflectionActionBar(
            isLast: isLast,
            onNext: _next,
            onSkip: _skip,
          ),
        ],
      ),
    );
  }
}

// ─── Prompt Card ──────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.prompt,
    required this.controller,
    required this.index,
  });

  final ReflectionPrompt prompt;
  final TextEditingController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji + prompt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.dividerLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prompt.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    prompt.question,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AppMotion.emphasized).slideY(
                  begin: 0.06,
                  end: 0,
                  duration: AppMotion.emphasized,
                  curve: AppMotion.decelerate,
                ),

            const SizedBox(height: AppSpacing.lg),

            // Response field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: TextField(
                controller: controller,
                maxLines: 6,
                minLines: 4,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.navy,
                  height: 1.65,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .writeYourThoughtsHereOptional,
                  hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textDisabled,
                    height: 1.65,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
              ),
            ).animate().fadeIn(
                  delay: 150.ms,
                  duration: AppMotion.standard,
                ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Your responses are saved privately.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textDisabled,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Bar ───────────────────────────────────────────────────────────────

class _ReflectionActionBar extends StatelessWidget {
  const _ReflectionActionBar({
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

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
        border:
            Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5)),
      ),
      child: Row(
        children: [
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
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onNext,
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
                      isLast ? 'Finish & Pray' : 'Next Prompt',
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
            ),
          ),
        ],
      ),
    );
  }
}
