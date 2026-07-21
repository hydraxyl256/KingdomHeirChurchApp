// Kingdom Heir — Prayer Requests Section (SECTION 5)
//
// Vertical list of prayer requests posted across the user's groups.
// Each card: author, body excerpt, prayer count chip, "I prayed" action.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_prayer_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/group_avatar.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class PrayerRequestsSection extends ConsumerWidget {
  const PrayerRequestsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prayerFeedForUserProvider);
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'Pray with us',
          subtitle: 'Requests from your community this week',
          icon: Icons.volunteer_activism_rounded,
        ),
        async.when(
          loading: () => SizedBox(
            height: 80 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: AppErrorWidget(
              message: AppLocalizations.of(context)!.couldntLoadPrayerRequests,
              onRetry: () => ref.invalidate(prayerFeedForUserProvider),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.spa_rounded,
                  title: 'No prayer requests yet',
                  description:
                      'When brothers and sisters in your groups share a need, it’ll surface here.',
                  isCompact: true,
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(insets.lg, 0, insets.lg, insets.md),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == list.length - 1 ? 0 : insets.sm,
                      ),
                      child: _PrayerRow(request: list[i])
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                          )
                          .slideY(begin: 0.05, end: 0),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PrayerRow extends ConsumerWidget {
  const _PrayerRow({required this.request});
  final GroupPrayerRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insets = Insets.of(context);
    final catIcon = switch (request.category) {
      PrayerCategory.healing => Icons.healing_rounded,
      PrayerCategory.family => Icons.family_restroom_rounded,
      PrayerCategory.provision => Icons.attach_money_rounded,
      PrayerCategory.guidance => Icons.explore_rounded,
      PrayerCategory.thanks => Icons.celebration_rounded,
      PrayerCategory.other => Icons.eco_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${request.groupId}/prayer'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: EdgeInsets.all(insets.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GroupAvatar(
                    name: request.authorName,
                    size: 36,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  SizedBox(width: insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          request.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              catIcon,
                              size: 12,
                              color: AppColors.goldDark,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                request.category.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textTheme.labelSmall
                                    ?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (request.isAnswered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.celebration_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Answered',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: insets.sm),
              Text(
                request.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
              SizedBox(height: insets.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 12,
                          color: AppColors.goldDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.prayingCount} praying',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _PrayedButton(
                    request: request,
                    onTap: () async {
                      try {
                        await ref.read(groupMutationsProvider).markPraying(
                              prayerId: request.id,
                              groupId: request.groupId,
                            );
                      } catch (_) {/* swallow — UI already updates */}
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayedButton extends StatefulWidget {
  const _PrayedButton({required this.request, required this.onTap});

  final GroupPrayerRequest request;
  final Future<void> Function() onTap;

  @override
  State<_PrayedButton> createState() => _PrayedButtonState();
}

class _PrayedButtonState extends State<_PrayedButton> {
  bool _pressed = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _pressed = true);
          widget.onTap();
          _resetTimer?.cancel();
          _resetTimer = Timer(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _pressed = false);
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.overshoot,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _pressed ? 1.18 : 1.0,
              _pressed ? 1.18 : 1.0,
              _pressed ? 1.18 : 1.0,
              1,
            ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 14,
                color: AppColors.ink,
              ),
              const SizedBox(width: 4),
              Text(
                'I prayed',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
