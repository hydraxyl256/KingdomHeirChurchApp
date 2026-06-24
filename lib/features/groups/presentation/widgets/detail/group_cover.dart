// Kingdom Heir — Group Cover (DETAIL SECTION 1)
//
// 180–240 dp tall hero with cover image, dark gradient overlay, and
// the group title + category badge anchored at the bottom.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/breakpoints.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/groups/domain/entities/group_models.dart';

class GroupCover extends StatelessWidget {
  const GroupCover({required this.group, super.key});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final band = layoutBandFromWidth(constraints.maxWidth);
        final height = switch (band) {
          LayoutBand.xs => 180.0,
          LayoutBand.sm => 200.0,
          LayoutBand.md => 220.0,
          LayoutBand.lg => 240.0,
          LayoutBand.xl => 260.0,
          LayoutBand.xxl => 280.0,
        };

        return Padding(
          padding: EdgeInsets.fromLTRB(insets.lg, insets.lg, insets.lg, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (group.coverUrl != null && group.coverUrl!.isNotEmpty)
                    Image.network(
                      group.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _Fallback(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : const _Fallback(),
                    )
                  else
                    const _Fallback(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.navy.withValues(alpha: 0.1),
                          AppColors.navy.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(insets.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (group.categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              group.categoryName!,
                              style:
                                  AppTypography.textTheme.labelSmall?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              group.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.warmWhite,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _Pill(
                                  icon: Icons.people_alt_rounded,
                                  label: '${group.memberCount} members',
                                ),
                                _Pill(
                                  icon: switch (group.meetingType) {
                                    GroupMeetingType.online =>
                                      Icons.videocam_outlined,
                                    GroupMeetingType.physical =>
                                      Icons.location_on_outlined,
                                    GroupMeetingType.hybrid =>
                                      Icons.public_rounded,
                                  },
                                  label: group.meetingType.label,
                                ),
                                if (group.privacy == GroupPrivacy.private)
                                  const _Pill(
                                    icon: Icons.lock_rounded,
                                    label: 'Private',
                                  ),
                              ],
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
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmWhite.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.warmWhite.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.warmWhite),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.warmWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

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
