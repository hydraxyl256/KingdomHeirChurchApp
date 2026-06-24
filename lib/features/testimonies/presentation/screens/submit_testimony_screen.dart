import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/core/widgets/app_text_field.dart';
import 'package:kingdom_heir/features/testimonies/presentation/providers/testimony_provider.dart';

const _categories = [
  'General',
  'Healing',
  'Provision',
  'Salvation',
  'Deliverance',
  'Relationships',
  'Business / Career',
];

class SubmitTestimonyScreen extends ConsumerStatefulWidget {
  const SubmitTestimonyScreen({super.key});

  @override
  ConsumerState<SubmitTestimonyScreen> createState() =>
      _SubmitTestimonyScreenState();
}

class _SubmitTestimonyScreenState extends ConsumerState<SubmitTestimonyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _selectedCategory = 0;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
      'category': _categories[_selectedCategory],
      'is_anonymous': _isAnonymous,
    };

    await ref.read(submitTestimonyProvider.notifier).submit(data);

    if (mounted) {
      final state = ref.read(submitTestimonyProvider);

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.error}')),
        );
      } else {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🙌 Testimony submitted for review. Thank you!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Testimony'),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Gold header ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldDark, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.ink,
                    size: 36,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell what God has done',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Your story will encourage thousands.',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.ink.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: AppSpacing.xxl),

            // ── Scripture prompt ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.goldContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '"And they overcame him by the blood of the Lamb and by '
                'the word of their testimony." — Rev 12:11',
                style: AppTypography.quote.copyWith(
                  fontSize: 13,
                  color: AppColors.goldDark,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xl),

            // ── Category ──────────────────────────────────────────────
            Text('Category', style: AppTypography.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _categories.asMap().entries.map((e) {
                final isSelected = e.key == _selectedCategory;
                return FilterChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = e.key),
                  selectedColor: AppColors.gold.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.goldDark,
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : theme.dividerColor,
                  ),
                  labelStyle: AppTypography.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? AppColors.goldDark : null,
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: AppSpacing.xl),

            // ── Title ─────────────────────────────────────────────────
            AppTextField(
              controller: _titleController,
              label: 'Testimony title',
              hint: 'A bold headline for what God did',
              prefixIcon: Icons.title_rounded,
              isRequired: true,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Please add a title' : null,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: AppSpacing.lg),

            // ── Story ─────────────────────────────────────────────────
            AppTextField(
              controller: _bodyController,
              label: 'Your testimony',
              hint: 'Tell the full story — what happened, '
                  'how you prayed, and what God did...',
              maxLines: 10,
              minLines: 6,
              isRequired: true,
              validator: (v) => (v?.isEmpty ?? true)
                  ? 'Please share your testimony'
                  : v!.length < 50
                      ? 'Please write at least 50 characters'
                      : null,
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: AppSpacing.xl),

            // ── Anonymous ─────────────────────────────────────────────
            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Share anonymously'),
                subtitle: const Text(
                  'Your name will be hidden from other members',
                ),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                activeThumbColor: AppColors.ink,
                activeTrackColor: AppColors.gold,
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: AppSpacing.sm),

            // ── Moderation notice ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.infoContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: AppSpacing.iconSm,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Testimonies are reviewed by church leadership '
                      'before being published. Usually within 24 hours.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Submit ────────────────────────────────────────────────
            AppButton(
              label: 'Submit Testimony',
              icon: Icons.send_rounded,
              isLoading: ref.watch(submitTestimonyProvider).isLoading,
              onPressed: _submit,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }
}
