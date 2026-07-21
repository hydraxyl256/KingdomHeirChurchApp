import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class ChallengeHubScreen extends StatelessWidget {
  const ChallengeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.ninetyDayChallenge),
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.navyAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    size: 64,
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '90-Day Discipleship Challenge',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '“Commit these things to faithful people who will be able to teach others also.” — 2 Timothy 2:2',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Select your path:',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'My Discipleship Journey',
              icon: Icons.person_rounded,
              onPressed: () {
                context.go(RouteNames.challengeParticipant);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Group Leader Report',
              icon: Icons.group_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: () {
                context.go(RouteNames.challengeReporting);
              },
            ),
          ],
        ),
      ),
    );
  }
}
