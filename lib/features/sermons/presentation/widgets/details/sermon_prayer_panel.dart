// Kingdom Heir — Sermon Prayer Panel (Details)
//
// Single free-text composer for the user's prayer response to a sermon.
// Includes a private toggle. Persists via PrayerController.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/features/sermons/presentation/providers/sermon_engagement_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SermonPrayerPanel extends ConsumerStatefulWidget {
  const SermonPrayerPanel({required this.sermonId, super.key});
  final String sermonId;

  @override
  ConsumerState<SermonPrayerPanel> createState() => _SermonPrayerPanelState();
}

class _SermonPrayerPanelState extends ConsumerState<SermonPrayerPanel> {
  final _controller = TextEditingController();
  bool _isPrivate = true;
  bool _saving = false;
  bool _initialised = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(prayerControllerProvider).savePrayerResponse(
            sermonId: widget.sermonId,
            body: body,
            isPrivate: _isPrivate,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerAsync =
        ref.watch(prayerResponseBySermonProvider(widget.sermonId));
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
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Prayer response',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              prayerAsync.maybeWhen(
                data: (existing) {
                  if (existing != null && !_initialised) {
                    _controller.text = existing.body;
                    _isPrivate = existing.isPrivate;
                    _initialised = true;
                  }
                  return const SizedBox.shrink();
                },
                orElse: SizedBox.shrink,
              ),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)!.howIsGodStirringYourHeart,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                title: Text(AppLocalizations.of(context)!.keepThisPrivate),
                subtitle: Text(
                    AppLocalizations.of(context)!.onlyYouWillSeeThisResponse,),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.ink,
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(AppLocalizations.of(context)!.savePrayer),
                  ),
                ],
              ),
              prayerAsync.maybeWhen(
                data: (existing) {
                  if (existing == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Last saved ${DateFormat.MMMd().add_jm().format(existing.createdAt)}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
                orElse: SizedBox.shrink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
