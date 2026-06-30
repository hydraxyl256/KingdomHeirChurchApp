// Kingdom Heir — Section 7: Premium Prayer Corner
//
// Header with hands-praying icon, 3 request cards, animated heart-fill
// "I prayed" button, answered-prayer banner, and a CTA to submit a new
// prayer request. Tapping a request's "I prayed" button calls
// `onPray(req)` so the parent can update the count via the repository.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/features/dashboard/domain/home_dashboard_models.dart';

class PrayerCornerSection extends StatelessWidget {
  const PrayerCornerSection({
    required this.corner,
    super.key,
    this.onPray,
    this.onSubmit,
    this.onSeeAll,
  });

  final PrayerCorner corner;
  final void Function(PrayerRequest)? onPray;
  final VoidCallback? onSubmit;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Iconography.prayer,
                  color: AppColors.goldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Prayer Corner',
                      style:
                          AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${corner.usersPrayedToday} people prayed today',
                      style:
                          AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'See all',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Request cards
          if (corner.requests.isEmpty)
            _EmptyState(onSubmit: onSubmit)
          else
            ...corner.requests.take(3).toList().asMap().entries.map((e) {
              final i = e.key;
              final req = e.value;
              return _PrayerRequestTile(
                request: req,
                index: i,
                onPray: () => onPray?.call(req),
              );
            }),
          // Answered prayer highlight
          if (corner.answeredPrayerHighlight != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AnsweredPrayerBanner(text: corner.answeredPrayerHighlight!),
          ],
          const SizedBox(height: AppSpacing.md),
          // Submit prayer CTA
          if (onSubmit != null)
            Semantics(
              button: true,
              label: 'Submit a prayer request',
              child: Material(
                color: AppColors.goldContainer,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                child: InkWell(
                  onTap: onSubmit,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconography.favorite,
                          color: AppColors.goldDark,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Submit a Prayer Request',
                          style:
                              AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }
}

class _PrayerRequestTile extends StatelessWidget {
  const _PrayerRequestTile({
    required this.request,
    required this.index,
    this.onPray,
  });

  final PrayerRequest request;
  final int index;
  final VoidCallback? onPray;

  @override
  Widget build(BuildContext context) {
    final initial = request.authorName.isNotEmpty
        ? request.authorName[0].toUpperCase()
        : 'A';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    request.authorName,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.preview,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Animated "I prayed" button
            _PrayButton(
              count: request.prayerCount,
              onTap: onPray,
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 520 + index * 50),
            duration: 300.ms,
          ),
    );
  }
}

class _PrayButton extends StatefulWidget {
  const _PrayButton({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  State<_PrayButton> createState() => _PrayButtonState();
}

class _PrayButtonState extends State<_PrayButton> {
  bool _pulse = false;

  void _handleTap() {
    setState(() => _pulse = true);
    widget.onTap?.call();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _pulse = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'I prayed for this request (${widget.count} prayers)',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pulse ? 1.18 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconography.favorite,
                  color: Color(0xFF6366F1),
                  size: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.count}',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnsweredPrayerBanner extends StatelessWidget {
  const _AnsweredPrayerBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldContainer.withValues(alpha: 0.7),
            AppColors.goldContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.goldDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Iconography.favorite,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ANSWERED PRAYER',
                  style: AppTypography.scriptureRef.copyWith(
                    color: AppColors.goldDark,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onSubmit});
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.goldContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconography.prayer,
            size: 36,
            color: AppColors.goldDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No prayer requests yet. Be the first to share.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (onSubmit != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tap “Submit” above to add yours.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}