// Kingdom Heir — Devotional Journey: Screen 3 — Devotional Reader
//
// Immersive reading experience for the full devotional body.
// Supports headings, blockquotes, prayer boxes, related verses, auto-save scroll.

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

class DevotionalReaderScreen extends ConsumerStatefulWidget {
  const DevotionalReaderScreen({required this.devotionalId, super.key});
  final String devotionalId;

  @override
  ConsumerState<DevotionalReaderScreen> createState() =>
      _DevotionalReaderScreenState();
}

class _DevotionalReaderScreenState extends ConsumerState<DevotionalReaderScreen> {
  final _scrollController = ScrollController();
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() {
      _scrollProgress =
          (_scrollController.offset / max).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devotionalAsync = ref.watch(dailyDevotionalProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Devotional',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _scrollProgress,
            minHeight: 3,
            backgroundColor: AppColors.dividerLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldDark),
          ),
        ),
      ),
      body: devotionalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (devotional) {
          if (devotional == null) {
            return const Center(child: Text('Devotional not found.'));
          }

          final estimatedMin = 3 + (devotional.body.length ~/ 700);
          final sections = _parseSections(devotional.body);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Read time estimate
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$estimatedMin min read',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: AppMotion.standard),

                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      Text(
                        devotional.title,
                        style:
                            AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 100.ms,
                            duration: AppMotion.emphasized,
                          )
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            delay: 100.ms,
                            duration: AppMotion.emphasized,
                            curve: AppMotion.decelerate,
                          ),

                      const SizedBox(height: AppSpacing.sm),

                      // Scripture ref
                      Text(
                        devotional.scriptureRef,
                        style: AppTypography.scriptureRef.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(
                            delay: 200.ms,
                            duration: AppMotion.standard,
                          ),

                      const SizedBox(height: AppSpacing.lg),

                      // Gold divider
                      Container(
                        width: 40,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.goldDark, AppColors.gold],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Parsed body sections
                      ...sections.asMap().entries.map(
                            (e) => _buildSection(e.value, e.key).animate().fadeIn(
                                  delay: Duration(
                                    milliseconds: 300 + e.key * 80,
                                  ),
                                  duration: AppMotion.standard,
                                ),
                          ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Related scripture chip
                      _RelatedScriptureChip(ref: devotional.scriptureRef),
                    ],
                  ),
                ),
              ),

              // Continue bar
              _ContinueBar(
                label: 'Time to Reflect',
                onContinue: () async {
                  await ref
                      .read(
                        journeyProgressProvider(widget.devotionalId).notifier,
                      )
                      .markContentRead();
                  if (context.mounted) {
                    unawaited(
                      context.push(
                        '/home/devotionals/${widget.devotionalId}/reflection',
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<_BodySection> _parseSections(String body) {
    // Simple parser: lines starting with # = heading, > = blockquote, rest = paragraph
    final lines = body.split('\n');
    final sections = <_BodySection>[];
    final buffer = StringBuffer();

    void flush() {
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        sections.add(_BodySection(type: _SectionType.paragraph, text: text));
        buffer.clear();
      }
    }

    for (final line in lines) {
      if (line.startsWith('# ')) {
        flush();
        sections.add(_BodySection(
          type: _SectionType.heading,
          text: line.substring(2),
        ),);
      } else if (line.startsWith('> ')) {
        flush();
        sections.add(_BodySection(
          type: _SectionType.blockquote,
          text: line.substring(2),
        ),);
      } else if (line.startsWith('🙏')) {
        flush();
        sections.add(_BodySection(
          type: _SectionType.prayerBox,
          text: line,
        ),);
      } else {
        if (buffer.isNotEmpty) buffer.writeln();
        buffer.write(line);
      }
    }
    flush();
    return sections;
  }

  Widget _buildSection(_BodySection section, int index) {
    switch (section.type) {
      case _SectionType.heading:
        return Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.md,
          ),
          child: Text(
            section.text,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

      case _SectionType.blockquote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.goldContainer,
            borderRadius: AppRadius.brMd,
            border: Border(
              left: BorderSide(color: AppColors.goldDark, width: 3),
            ),
          ),
          child: Text(
            section.text,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.navy,
              fontStyle: FontStyle.italic,
              height: 1.65,
            ),
          ),
        );

      case _SectionType.prayerBox:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.navyLight.withValues(alpha: 0.08),
                AppColors.navyLight.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: AppRadius.brLg,
            border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🙏', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  section.text,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );

      case _SectionType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Text(
            section.text,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.75,
              letterSpacing: 0.15,
            ),
          ),
        );
    }
  }
}

enum _SectionType { heading, blockquote, prayerBox, paragraph }

class _BodySection {
  const _BodySection({required this.type, required this.text});
  final _SectionType type;
  final String text;
}

class _RelatedScriptureChip extends StatelessWidget {
  const _RelatedScriptureChip({required this.ref});
  final String ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Key Scripture',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.goldContainer,
            borderRadius: AppRadius.brFull,
            border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppColors.goldDark, size: 14,),
              const SizedBox(width: 6),
              Text(
                ref,
                style: AppTypography.scriptureRef.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.label, required this.onContinue});
  final String label;
  final VoidCallback onContinue;

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
        color: AppColors.warmWhite,
        border: Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: onContinue,
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
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.ink, size: 18,),
            ],
          ),
        ),
      ),
    );
  }
}
