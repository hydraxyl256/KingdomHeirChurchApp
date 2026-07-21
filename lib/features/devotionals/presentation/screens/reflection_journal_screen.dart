import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/features/devotionals/domain/entities/devotional_models.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ReflectionJournalScreen extends ConsumerStatefulWidget {
  const ReflectionJournalScreen({super.key});

  @override
  ConsumerState<ReflectionJournalScreen> createState() =>
      _ReflectionJournalScreenState();
}

class _ReflectionJournalScreenState
    extends ConsumerState<ReflectionJournalScreen> {
  final _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reflectionJournal),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isEditing)
            _NewEntryPanel(
              controller: _controller,
              onSave: () {
                if (_controller.text.trim().isNotEmpty) {
                  ref
                      .read(reflectionsProvider.notifier)
                      .addReflection(_controller.text.trim());
                  _controller.clear();
                  setState(() => _isEditing = false);
                }
              },
            ).animate().fadeIn().slideY(begin: -0.2),
          Expanded(
            child: ref.watch(reflectionsProvider).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(
                            AppLocalizations.of(context)!.noJournalEntriesYet,),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final entry = entries[i];
                        return _JournalEntryCard(
                          entry: entry,
                          delay: Duration(milliseconds: i * 80),
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _NewEntryPanel extends StatelessWidget {
  const _NewEntryPanel({required this.controller, required this.onSave});
  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Journal Entry',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)!.writeYourReflectionForToday,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Save Entry',
            onPressed: onSave,
            icon: Icons.save_rounded,
          ),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry, required this.delay});
  final DevotionalReflection entry;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (entry.devotionalId != null) ...[
                  const Spacer(),
                  Text(
                    'Ref: ${entry.devotionalId!.substring(0, 8)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay);
  }
}
