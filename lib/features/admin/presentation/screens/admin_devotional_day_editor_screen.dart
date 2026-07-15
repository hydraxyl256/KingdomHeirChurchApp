// Kingdom Heir — Admin Devotional Day Editor Screen
//
// Full editor for a single devotional_entries row.
// Shows all text fields + a translation sub-panel per language.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _entryEditorProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, ({String seriesId, int dayNumber})>(
  (ref, key) async {
    final data = await Supabase.instance.client
        .from('devotional_entries')
        .select()
        .eq('series_id', key.seriesId)
        .eq('day_number', key.dayNumber)
        .maybeSingle();
    return data;
  },
);

final _translationsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>(
  (ref, entryId) async {
    final data = await Supabase.instance.client
        .from('devotional_translations')
        .select()
        .eq('devotional_entry_id', entryId)
        .order('language_code');
    return (data as List<dynamic>).cast<Map<String, dynamic>>();
  },
);

class AdminDevotionalDayEditorScreen extends ConsumerStatefulWidget {
  const AdminDevotionalDayEditorScreen({
    required this.seriesId,
    required this.dayNumber,
    super.key,
  });

  final String seriesId;
  final int dayNumber;

  @override
  ConsumerState<AdminDevotionalDayEditorScreen> createState() =>
      _AdminDevotionalDayEditorScreenState();
}

class _AdminDevotionalDayEditorScreenState
    extends ConsumerState<AdminDevotionalDayEditorScreen> {
  final _titleCtrl          = TextEditingController();
  final _scriptureRefCtrl   = TextEditingController();
  final _scriptureTextCtrl  = TextEditingController();
  final _bodyCtrl           = TextEditingController();
  final _reflectionCtrl     = TextEditingController();
  final _actionStepCtrl     = TextEditingController();
  final _prayerCtrl         = TextEditingController();
  final _readMinsCtrl       = TextEditingController();

  String _status = 'draft';
  String? _entryId;
  bool _populated = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _scriptureRefCtrl.dispose();
    _scriptureTextCtrl.dispose();
    _bodyCtrl.dispose();
    _reflectionCtrl.dispose();
    _actionStepCtrl.dispose();
    _prayerCtrl.dispose();
    _readMinsCtrl.dispose();
    super.dispose();
  }

  void _populate(Map<String, dynamic> entry) {
    if (_populated) return;
    _populated = true;
    _entryId              = entry['id'] as String?;
    _titleCtrl.text       = entry['title'] as String? ?? '';
    _scriptureRefCtrl.text= entry['scripture_reference'] as String? ?? '';
    _scriptureTextCtrl.text= entry['scripture_text'] as String? ?? '';
    _bodyCtrl.text        = entry['devotional_body'] as String? ?? '';
    _reflectionCtrl.text  = entry['reflection_question'] as String? ?? '';
    _actionStepCtrl.text  = entry['action_step'] as String? ?? '';
    _prayerCtrl.text      = entry['prayer_text'] as String? ?? '';
    _readMinsCtrl.text    = (entry['estimated_read_minutes'] as int?)?.toString() ?? '';
    _status               = entry['status'] as String? ?? 'draft';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final payload = {
        'series_id':            widget.seriesId,
        'day_number':           widget.dayNumber,
        'title':                _titleCtrl.text.trim(),
        'scripture_reference':  _scriptureRefCtrl.text.trim().isEmpty
            ? null : _scriptureRefCtrl.text.trim(),
        'scripture_text':       _scriptureTextCtrl.text.trim().isEmpty
            ? null : _scriptureTextCtrl.text.trim(),
        'devotional_body':      _bodyCtrl.text.trim(),
        'reflection_question':  _reflectionCtrl.text.trim().isEmpty
            ? null : _reflectionCtrl.text.trim(),
        'action_step':          _actionStepCtrl.text.trim().isEmpty
            ? null : _actionStepCtrl.text.trim(),
        'prayer_text':          _prayerCtrl.text.trim().isEmpty
            ? null : _prayerCtrl.text.trim(),
        'estimated_read_minutes':
            int.tryParse(_readMinsCtrl.text.trim()),
        'status':               _status,
      };

      if (_entryId != null) {
        await Supabase.instance.client
            .from('devotional_entries')
            .update(payload)
            .eq('id', _entryId!);
      } else {
        final res = await Supabase.instance.client
            .from('devotional_entries')
            .insert(payload)
            .select('id')
            .single();
        _entryId = res['id'] as String;
      }

      ref.invalidate(_entryEditorProvider(
        (seriesId: widget.seriesId, dayNumber: widget.dayNumber),
      ),);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day saved successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(
      _entryEditorProvider(
        (seriesId: widget.seriesId, dayNumber: widget.dayNumber),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.dayNumber} Editor'),
        actions: [
          DropdownButton<String>(
            value: _status,
            underline: const SizedBox.shrink(),
            items: ['draft', 'published', 'archived']
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_saving ? 'Saving…' : 'Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (entry) {
          if (entry != null) _populate(entry);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Base content fields ─────────────────────────
                _SectionHeader(label: 'DAY ${widget.dayNumber} CONTENT'),
                const SizedBox(height: AppSpacing.md),
                _Field(ctrl: _titleCtrl,        label: 'Title', required: true),
                _Field(ctrl: _scriptureRefCtrl, label: 'Scripture Reference (e.g. John 3:16)'),
                _Field(ctrl: _scriptureTextCtrl,label: 'Scripture Text', maxLines: 4),
                _Field(ctrl: _bodyCtrl,         label: 'Devotional Body *', maxLines: 10),
                _Field(ctrl: _reflectionCtrl,   label: 'Reflection Question', maxLines: 3),
                _Field(ctrl: _actionStepCtrl,   label: 'Action Step', maxLines: 3),
                _Field(ctrl: _prayerCtrl,       label: 'Prayer Text', maxLines: 5),
                _Field(
                  ctrl: _readMinsCtrl,
                  label: 'Estimated Read Minutes',
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Translations panel ─────────────────────────
                if (_entryId != null) ...[
                  const _SectionHeader(label: 'TRANSLATIONS'),
                  const SizedBox(height: AppSpacing.md),
                  _TranslationsPanel(entryId: _entryId!, ref: ref),
                ] else
                  const Text(
                    'Save the base content first to add translations.',
                    style: TextStyle(color: AppColors.warning),
                  ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Translations panel ───────────────────────────────────────────────────────

class _TranslationsPanel extends ConsumerWidget {
  const _TranslationsPanel({required this.entryId, required this.ref});
  final String entryId;
  final WidgetRef ref;

  static const _supportedLanguages = [
    ('ur', 'Urdu'),
    ('bem', 'Bemba'),
    ('zu', 'Zulu'),
    ('ss', 'Swati'),
    ('pt', 'Portuguese'),
    ('fr', 'French'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(_translationsProvider(entryId));
    return txAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, __) => Text('Error: $e'),
      data: (txList) {
        final byLang = <String, Map<String, dynamic>>{
          for (final tx in txList) tx['language_code'] as String: tx,
        };
        return Column(
          children: _supportedLanguages.map((lang) {
            final (code, name) = lang;
            return _LanguageTile(
              languageCode: code,
              languageName: name,
              existing: byLang[code],
              entryId: entryId,
              onSaved: () => ref.invalidate(_translationsProvider(entryId)),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.languageCode,
    required this.languageName,
    required this.entryId,
    required this.onSaved,
    this.existing,
  });
  final String languageCode;
  final String languageName;
  final Map<String, dynamic>? existing;
  final String entryId;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final status = existing?['translation_status'] as String? ?? 'none';
    Color chipColor;
    switch (status) {
      case 'published':
        chipColor = AppColors.success;
      case 'review':
        chipColor = AppColors.warning;
      default:
        chipColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navyMid,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Text(
            languageCode.toUpperCase(),
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      title: Text(languageName),
      subtitle: Text(
        status == 'none' ? 'Not translated' : status.toUpperCase(),
        style: TextStyle(color: chipColor, fontWeight: FontWeight.w600, fontSize: 11),
      ),
      trailing: TextButton(
        child: Text(existing == null ? 'Add' : 'Edit'),
        onPressed: () => _openEditor(context),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    final titleCtrl      = TextEditingController(text: existing?['title'] as String? ?? '');
    final bodyCtrl       = TextEditingController(text: existing?['devotional_body'] as String? ?? '');
    final scriptureRefCtrl= TextEditingController(text: existing?['scripture_reference'] as String? ?? '');
    final scriptureTextCtrl=TextEditingController(text: existing?['scripture_text'] as String? ?? '');
    final reflectionCtrl = TextEditingController(text: existing?['reflection_question'] as String? ?? '');
    final actionCtrl     = TextEditingController(text: existing?['action_step'] as String? ?? '');
    final prayerCtrl     = TextEditingController(text: existing?['prayer_text'] as String? ?? '');
    var txStatus      = existing?['translation_status'] as String? ?? 'draft';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (_, scroll) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ListView(
              controller: scroll,
              children: [
                Text('$languageName Translation',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: txStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['draft', 'review', 'published']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setSt(() => txStatus = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(ctrl: titleCtrl,       label: 'Title *', required: true),
                _Field(ctrl: scriptureRefCtrl,label: 'Scripture Reference'),
                _Field(ctrl: scriptureTextCtrl,label: 'Scripture Text', maxLines: 4),
                _Field(ctrl: bodyCtrl,        label: 'Devotional Body *', maxLines: 10),
                _Field(ctrl: reflectionCtrl,  label: 'Reflection Question', maxLines: 3),
                _Field(ctrl: actionCtrl,      label: 'Action Step', maxLines: 3),
                _Field(ctrl: prayerCtrl,      label: 'Prayer Text', maxLines: 5),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () async {
                    await Supabase.instance.client
                        .from('devotional_translations')
                        .upsert(
                      {
                        'devotional_entry_id': entryId,
                        'language_code':       languageCode,
                        'title':               titleCtrl.text.trim(),
                        'scripture_reference': scriptureRefCtrl.text.trim().isEmpty
                            ? null : scriptureRefCtrl.text.trim(),
                        'scripture_text':      scriptureTextCtrl.text.trim().isEmpty
                            ? null : scriptureTextCtrl.text.trim(),
                        'devotional_body':     bodyCtrl.text.trim(),
                        'reflection_question': reflectionCtrl.text.trim().isEmpty
                            ? null : reflectionCtrl.text.trim(),
                        'action_step':         actionCtrl.text.trim().isEmpty
                            ? null : actionCtrl.text.trim(),
                        'prayer_text':         prayerCtrl.text.trim().isEmpty
                            ? null : prayerCtrl.text.trim(),
                        'translation_status':  txStatus,
                      },
                      onConflict: 'devotional_entry_id,language_code',
                    );
                    onSaved();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save Translation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared form helpers ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.textTheme.labelSmall?.copyWith(
        color: AppColors.gold,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    this.maxLines = 1,
    this.required = false,
    this.keyboard = TextInputType.text,
  });
  final TextEditingController ctrl;
  final String label;
  final int maxLines;
  final bool required;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
