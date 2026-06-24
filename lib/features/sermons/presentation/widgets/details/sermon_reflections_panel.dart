// Kingdom Heir — Sermon Reflections Panel (Details)
//
// Lists reflection Q&A pairs the user has saved, and shows the next
// suggested prompt to answer. Driven by ReflectionPrompts and the
// reflectionsBySermonProvider.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/data/mock/reflection_prompts.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_reflection.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_engagement_provider.dart';

class SermonReflectionsPanel extends ConsumerStatefulWidget {
  const SermonReflectionsPanel({required this.sermon, super.key});
  final Sermon sermon;

  @override
  ConsumerState<SermonReflectionsPanel> createState() =>
      _SermonReflectionsPanelState();
}

class _SermonReflectionsPanelState
    extends ConsumerState<SermonReflectionsPanel> {
  int _promptIndex = 0;
  final _answerController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;
    setState(() => _saving = true);
    try {
      final topic =
          widget.sermon.topics.isNotEmpty ? widget.sermon.topics.first : null;
      final prompts = ReflectionPrompts.forTopic(topic);
      final question = prompts[_promptIndex % prompts.length];
      await ref.read(reflectionsControllerProvider).saveReflection(
            sermonId: widget.sermon.id,
            question: question,
            answer: answer,
          );
      _answerController.clear();
      setState(() => _promptIndex++);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reflectionsAsync =
        ref.watch(reflectionsBySermonProvider(widget.sermon.id));
    final topic =
        widget.sermon.topics.isNotEmpty ? widget.sermon.topics.first : null;
    final prompts = ReflectionPrompts.forTopic(topic);
    final currentPrompt = prompts[_promptIndex % prompts.length];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.gold, size: 18,),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Reflections',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPrompt,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _answerController,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write your reflection…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _promptIndex =
                              (_promptIndex + 1) % prompts.length,),
                          child: const Text('Next prompt'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.ink,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              reflectionsAsync.when(
                data: (list) => list.isEmpty
                    ? Text(
                        'No reflections yet.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Column(
                        children: list
                            .map((r) => _ReflectionTile(reflection: r))
                            .toList(),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.reflection});
  final SermonReflection reflection;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reflection.question,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reflection.answer,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat.MMMd().format(reflection.createdAt),
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
