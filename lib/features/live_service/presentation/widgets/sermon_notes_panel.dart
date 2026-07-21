// Kingdom Heir — Sermon Notes Panel
//
// Rich text note-taking with autosave (3s debounce), scripture attachment,
// export via share_plus, and Supabase background sync.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class SermonNotesPanel extends ConsumerStatefulWidget {
  const SermonNotesPanel({required this.sermonId, super.key});
  final String sermonId;

  @override
  ConsumerState<SermonNotesPanel> createState() => _SermonNotesPanelState();
}

class _SermonNotesPanelState extends ConsumerState<SermonNotesPanel> {
  late final TextEditingController _ctrl;
  Timer? _autosaveTimer;
  bool _isSaved = false;
  String? _attachedScripture;

  @override
  void initState() {
    super.initState();
    final existingNote = ref.read(sermonNotesProvider(widget.sermonId));
    _ctrl = TextEditingController(text: existingNote?.body ?? '')
      ..addListener(_onChanged);
    _attachedScripture = existingNote?.scriptureRef;
  }

  void _onChanged() {
    setState(() => _isSaved = false);
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 3), _save);
  }

  Future<void> _save() async {
    await ref.read(sermonNotesProvider(widget.sermonId).notifier).updateNote(
          widget.sermonId,
          _ctrl.text,
          scriptureRef: _attachedScripture,
        );
    if (mounted) setState(() => _isSaved = true);
  }

  Future<void> _export() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final header = 'Sermon Notes — Kingdom Heirs Church\n'
        '${_attachedScripture != null ? "Scripture: $_attachedScripture\n" : ""}'
        '${DateTime.now().toLocal().toString().substring(0, 10)}\n'
        '─────────────────────────────────\n\n';
    await Share.share(header + text);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _ctrl
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = ref.watch(sermonNotesProvider(widget.sermonId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Toolbar
            _NotesToolbar(
              isSaved: _isSaved,
              isSynced: note?.isSynced ?? false,
              onExport: _export,
              onSave: _save,
              attachedScripture: _attachedScripture,
              onAttachScripture: _showScriptureAttach,
              onClearScripture: () => setState(() => _attachedScripture = null),
            ),

            // Attached scripture banner
            if (_attachedScripture != null)
              _ScriptureBanner(
                scripture: _attachedScripture!,
                onRemove: () => setState(() => _attachedScripture = null),
              ).animate().fadeIn(duration: 200.ms),

            // Notes text field
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  minLines: 12,
                  keyboardType: TextInputType.multiline,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.navy,
                    height: 1.75,
                    fontFamily: 'Georgia',
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.takeNotesAsYouListenKey,
                    hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textDisabled,
                      height: 1.75,
                      fontFamily: 'Georgia',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),

            // Word count footer
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border(
                  top: BorderSide(color: AppColors.dividerLight, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_ctrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isSaved
                        ? Row(
                            key: const ValueKey('saved'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_done_rounded,
                                color: AppColors.success,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Saved',
                                style:
                                    AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            key: const ValueKey('editing'),
                            'Autosave in 3s',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScriptureAttach() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.attachScripture_1),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.egJohn316,
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: Text(AppLocalizations.of(context)!.attach),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _attachedScripture = result.trim());
    }
  }
}

// ─── Notes Toolbar ────────────────────────────────────────────────────────────

class _NotesToolbar extends StatelessWidget {
  const _NotesToolbar({
    required this.isSaved,
    required this.isSynced,
    required this.onExport,
    required this.onSave,
    required this.attachedScripture,
    required this.onAttachScripture,
    required this.onClearScripture,
  });

  final bool isSaved;
  final bool isSynced;
  final VoidCallback onExport;
  final VoidCallback onSave;
  final String? attachedScripture;
  final VoidCallback onAttachScripture;
  final VoidCallback onClearScripture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_note_rounded,
            size: 18,
            color: AppColors.navy,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sermon Notes',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),

          // Scripture attach
          _ToolbarBtn(
            icon: Icons.menu_book_outlined,
            label: '+ Scripture',
            onTap: onAttachScripture,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Export
          _ToolbarBtn(
            icon: Icons.share_outlined,
            label: 'Export',
            onTap: onExport,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Save
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSaved ? AppColors.successContainer : AppColors.navy,
                borderRadius: AppRadius.brFull,
              ),
              child: Text(
                isSaved ? 'Saved ✓' : 'Save',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: isSaved ? AppColors.success : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scripture Banner ─────────────────────────────────────────────────────────

class _ScriptureBanner extends StatelessWidget {
  const _ScriptureBanner({
    required this.scripture,
    required this.onRemove,
  });
  final String scripture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.goldContainer,
      child: Row(
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 14,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              scripture,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.goldDark,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}
