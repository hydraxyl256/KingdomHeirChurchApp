// Kingdom Heir — Suggested Groups Section (SECTION 7)
//
// Horizontal rail of suggested groups. Each card: cover gradient,
// name, member count, "Join" CTA. Tapping a card opens the group
// detail screen.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/groups_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/shared/join_button.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class SuggestedGroupsSection extends ConsumerWidget {
  const SuggestedGroupsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(suggestedGroupsProvider);
    final insets = Insets.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ResponsiveSectionHeader(
          title: 'You might love these',
          subtitle: 'Communities picked for you',
          icon: Icons.favorite_rounded,
        ),
        async.when(
          loading: () => SizedBox(
            height: 200 + insets.md,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: insets.lg),
            child: AppErrorWidget(
              message: AppLocalizations.of(context)!.couldntLoadSuggestions,
              onRetry: () => ref.invalidate(suggestedGroupsProvider),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: insets.lg),
                child: const AppEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No suggestions right now',
                  description:
                      'We’ll suggest communities once we learn more about what you love.',
                  isCompact: true,
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final band = layoutBandFromWidth(constraints.maxWidth);
                final cardWidth = switch (band) {
                  LayoutBand.xs => constraints.maxWidth * 0.78,
                  LayoutBand.sm => constraints.maxWidth * 0.62,
                  LayoutBand.md => constraints.maxWidth * 0.45,
                  LayoutBand.lg => constraints.maxWidth * 0.32,
                  LayoutBand.xl => constraints.maxWidth * 0.24,
                  LayoutBand.xxl => constraints.maxWidth * 0.2,
                };
                return SizedBox(
                  height: 240 + insets.md,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(
                      insets.lg,
                      0,
                      insets.lg,
                      insets.md,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => SizedBox(width: insets.sm),
                    itemBuilder: (context, i) => SizedBox(
                      width: cardWidth,
                      child: _SuggestedCard(group: list[i])
                          .animate()
                          .fadeIn(
                            duration: AppMotion.standard,
                            delay: Duration(milliseconds: 60 * i),
                          )
                          .slideY(begin: 0.06, end: 0),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({required this.group});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/home/groups/${group.id}'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover gradient
                if (group.coverUrl != null && group.coverUrl!.isNotEmpty)
                  Image.network(
                    group.coverUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _CoverFallback(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const _CoverFallback(),
                  )
                else
                  const _CoverFallback(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.navy.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(insets.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (group.categoryName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                group.categoryName!,
                                style: AppTypography.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          JoinButton(
                            state: joinButtonStateFromGroup(group),
                            compact: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTypography.textTheme.titleMedium?.copyWith(
                              color: AppColors.warmWhite,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${group.memberCount} members · ${group.weeklyActiveMembers} active',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color:
                                  AppColors.warmWhite.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyAccent, AppColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
