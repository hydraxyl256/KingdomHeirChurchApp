// Kingdom Heir — Sermon Notes Panel (Details)
//
// Collapsible panel showing existing notes for a sermon with a composer
// field. Persists via NotesController / notesBySermonProvider.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/domain/entities/sermon_note.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_engagement_provider.dart';

class SermonNotesPanel extends ConsumerStatefulWidget {
  const SermonNotesPanel({required this.sermonId, super.key});
  final String sermonId;

  @override
  ConsumerState<SermonNotesPanel> createState() => _SermonNotesPanelState();
}

class _SermonNotesPanelState extends ConsumerState<SermonNotesPanel> {
  final _controller = TextEditingController();
  bool _expanded = true;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(notesControllerProvider).addNote(
            sermonId: widget.sermonId,
            body: body,
          );
      _controller.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesBySermonProvider(widget.sermonId));
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
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined,
                        color: AppColors.gold, size: 18,),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Your notes',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Write a note…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilledButton(
                      onPressed: _saving ? null : _add,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.ink,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                notesAsync.when(
                  data: (notes) => notes.isEmpty
                      ? Text(
                          'No notes yet — capture a thought to revisit later.',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Column(
                          children: notes
                              .map(
                                (n) => _NoteTile(
                                  note: n,
                                  onDelete: () => ref
                                      .read(notesControllerProvider)
                                      .deleteNote(n.id, widget.sermonId),
                                ),
                              )
                              .toList(),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            color: AppColors.error, size: 24,),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'Could not load notes.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: () => ref
                              .refresh(notesBySermonProvider(widget.sermonId)),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(AppColors.gold),
                            foregroundColor:
                                WidgetStateProperty.all(AppColors.ink),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onDelete});
  final SermonNote note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.hasTimestamp)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      note.timestampLabel,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Text(
                  note.body,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMMMd().add_jm().format(note.createdAt),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
