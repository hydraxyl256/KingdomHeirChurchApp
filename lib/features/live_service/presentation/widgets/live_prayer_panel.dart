// Kingdom Heir — Prayer Panel
//
// Floating bottom sheet for submitting prayer requests.
// Types: Public, Private, Emergency, Praise Report, Follow-up.
// Does NOT interrupt video playback.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/live_service/domain/entities/live_service_models.dart';
import 'package:kingdom_heir/features/live_service/presentation/providers/live_service_provider.dart';

class LivePrayerPanel extends ConsumerStatefulWidget {
  const LivePrayerPanel({super.key});

  @override
  ConsumerState<LivePrayerPanel> createState() => _LivePrayerPanelState();
}

class _LivePrayerPanelState extends ConsumerState<LivePrayerPanel> {
  PrayerRequestType _selectedType = PrayerRequestType.publicPrayer;
  final _msgController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    ref.read(prayerRequestProvider.notifier).loadHistory();
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _submitting = true);
    await ref.read(prayerRequestProvider.notifier).submitRequest(
          type: _selectedType,
          message: msg,
        );
    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(prayerRequestProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
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

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _submitted
                    ? _SubmittedState(type: _selectedType)
                    : _FormContent(
                        selectedType: _selectedType,
                        msgController: _msgController,
                        submitting: _submitting,
                        history: history,
                        showHistory: _showHistory,
                        onTypeSelect: (t) =>
                            setState(() => _selectedType = t),
                        onSubmit: _submit,
                        onToggleHistory: () =>
                            setState(() => _showHistory = !_showHistory),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Content ─────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.selectedType,
    required this.msgController,
    required this.submitting,
    required this.history,
    required this.showHistory,
    required this.onTypeSelect,
    required this.onSubmit,
    required this.onToggleHistory,
  });

  final PrayerRequestType selectedType;
  final TextEditingController msgController;
  final bool submitting;
  final List<LivePrayerRequest> history;
  final bool showHistory;
  final ValueChanged<PrayerRequestType> onTypeSelect;
  final VoidCallback onSubmit;
  final VoidCallback onToggleHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            const Text(
              '🙏',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Prayer Request',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'How can we support you today?',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: AppSpacing.xl),

        // Prayer team availability
        const _PrayerTeamAvailability(),

        const SizedBox(height: AppSpacing.xl),

        // Type selector
        Text(
          'TYPE OF REQUEST',
          style: AppTypography.scriptureRef.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: PrayerRequestType.values.map((type) {
            final selected = type == selectedType;
            return GestureDetector(
              onTap: () => onTypeSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.navy : Colors.white,
                  borderRadius: AppRadius.brFull,
                  border: Border.all(
                    color: selected ? AppColors.navy : AppColors.dividerLight,
                  ),
                ),
                child: Text(
                  '${type.emoji} ${type.label}',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

        if (selectedType == PrayerRequestType.emergency) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 16,),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Emergency prayer requests are forwarded to a pastor immediately.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Message input
        Text(
          'YOUR REQUEST',
          style: AppTypography.scriptureRef.copyWith(
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: TextField(
            controller: msgController,
            maxLines: 5,
            minLines: 3,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.navy,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  'Share your prayer request here. Be as specific as you like…',
              hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textDisabled,
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              isDense: true,
            ),
          ),
        ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

        const SizedBox(height: AppSpacing.xl),

        // Submit button
        GestureDetector(
          onTap: submitting ? null : onSubmit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: AppSpacing.buttonHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: submitting
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                    ),
              color: submitting ? AppColors.dividerLight : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: submitting
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Prayer Request',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

        // History section
        if (history.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: onToggleHistory,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Previous Requests (${history.length})',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  showHistory
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (showHistory)
            ...history.take(5).map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${r.type.emoji} ${r.type.label}',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.message,
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ],
    );
  }
}

// ─── Prayer Team Availability ─────────────────────────────────────────────────

class _PrayerTeamAvailability extends StatelessWidget {
  const _PrayerTeamAvailability();

  bool get available => true;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: available ? AppColors.success : AppColors.textDisabled,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            available
                ? 'Prayer team is available now'
                : 'Prayer team offline — request saved',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: available ? AppColors.success : AppColors.textDisabled,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Submitted State ──────────────────────────────────────────────────────────

class _SubmittedState extends StatelessWidget {
  const _SubmittedState({required this.type});
  final PrayerRequestType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        const Text('🙏', style: TextStyle(fontSize: 56))
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Prayer Submitted',
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppSpacing.md),
        Text(
          type == PrayerRequestType.emergency
              ? 'A pastor has been notified and will be in touch shortly.'
              : 'Your ${type.label.toLowerCase()} has been received. Our prayer team is believing with you.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: AppSpacing.xxxl),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: AppSpacing.buttonHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldDark, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Center(
              child: Text(
                'Close',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}
