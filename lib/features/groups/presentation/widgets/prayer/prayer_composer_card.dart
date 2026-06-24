// Kingdom Heir — Prayer Composer Card
//
// A sticky-top composer for the prayer screen. Body field + category
// dropdown + "Share request" CTA. On submit it calls `mutations.postPrayer`
// and clears the field.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';

class PrayerComposerCard extends ConsumerStatefulWidget {
  const PrayerComposerCard({required this.groupId, super.key});
  final String groupId;

  @override
  ConsumerState<PrayerComposerCard> createState() => _PrayerComposerCardState();
}

class _PrayerComposerCardState extends ConsumerState<PrayerComposerCard> {
  final _controller = TextEditingController();
  PrayerCategory _category = PrayerCategory.other;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(groupMutationsProvider).postPrayer(
            groupId: widget.groupId,
            body: body,
            category: _category,
          );
      if (mounted) {
        _controller.clear();
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer request shared')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(insets.lg, insets.sm, insets.lg, insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: AppColors.ink,
                  size: 18,
                ),
              ),
              SizedBox(width: insets.sm),
              Text(
                'Share a prayer request',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: insets.sm),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What’s on your heart?',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: AppRadius.brLg,
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.brLg,
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.brLg,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.4,
                ),
              ),
              contentPadding: EdgeInsets.all(insets.md),
            ),
          ),
          SizedBox(height: insets.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: PrayerCategory.values.map((cat) {
              final selected = cat == _category;
              return ChoiceChip(
                label: Text(cat.label),
                selected: selected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: AppColors.gold,
                backgroundColor: theme.colorScheme.surfaceContainerLow,
                side: BorderSide(
                  color: selected
                      ? AppColors.gold
                      : theme.colorScheme.outlineVariant,
                ),
                labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.ink : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: insets.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: const Text('Share with the group'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.ink,
                padding: EdgeInsets.symmetric(vertical: insets.md - 2),
                shape:
                    const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                textStyle: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
