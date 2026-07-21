// Kingdom Heir — Prayer Composer
//
// A modal sheet that converts the current chat draft into a structured
// prayer request. The user picks a [PrayerCategory] and confirms; the
// resulting message is sent with `kind: GroupMessageKind.prayer`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

/// Opens the prayer composer for [groupId]. If [seed] is provided it
/// pre-fills the body field. Resolves with `true` if the user confirmed.
Future<bool?> showPrayerComposer(
  BuildContext context, {
  required String groupId,
  String? seed,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.brModalTop),
    builder: (_) => _PrayerComposerSheet(groupId: groupId, seed: seed),
  );
}

class _PrayerComposerSheet extends ConsumerStatefulWidget {
  const _PrayerComposerSheet({required this.groupId, this.seed});
  final String groupId;
  final String? seed;

  @override
  ConsumerState<_PrayerComposerSheet> createState() =>
      _PrayerComposerSheetState();
}

class _PrayerComposerSheetState extends ConsumerState<_PrayerComposerSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.seed ?? '');
  PrayerCategory _category = PrayerCategory.other;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(groupsRepositoryProvider).postPrayerRequest(
            groupId: widget.groupId,
            body: body,
            category: _category,
          );
      // Also fire a chat message so the prayer shows up in the live stream.
      await ref.read(groupsRepositoryProvider).sendMessage(
            widget.groupId,
            body,
            kind: 'PRAYER',
          );
      if (mounted) Navigator.of(context).pop(true);
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
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          insets.lg,
          insets.md,
          insets.lg,
          insets.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: AppRadius.brFull,
                ),
              ),
            ),
            SizedBox(height: insets.md),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
                SizedBox(width: insets.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Share a prayer request',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Brothers and sisters will stand with you',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: insets.md),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              autofocus: widget.seed == null,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.whatsOnYourHeart,
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
            SizedBox(height: insets.md),
            Text(
              'Category',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
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
                    color:
                        selected ? AppColors.ink : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: insets.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sending ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                  padding: EdgeInsets.symmetric(vertical: insets.md),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brLg,
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : const Text(
                        'Share with the group',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
