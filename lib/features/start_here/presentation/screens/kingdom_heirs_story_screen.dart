import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/start_here_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class KingdomHeirsStoryScreen extends ConsumerWidget {
  const KingdomHeirsStoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.gold : AppColors.primary;
    final titleColor = isDark ? AppColors.warmWhite : AppColors.primaryDark;
    final bodyColor = isDark
        ? AppColors.warmWhite.withValues(alpha: 0.85)
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.warmWhite.withValues(alpha: 0.6)
        : AppColors.textSecondary;

    final contentAsync = ref.watch(startHereContentProvider('story'));
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.impactStory),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: isDark ? AppColors.warmWhite : Colors.white,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
            child: Text('Error: $err', style: TextStyle(color: titleColor)),),
        data: (content) {
          final jsonMap = jsonDecode(content.body) as Map<String, dynamic>;
          final intro = jsonMap['intro'] as String;
          final highlights = jsonMap['highlights'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                'IMPACT AND STORY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Behind every number is a life restored.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                intro,
                style: TextStyle(fontSize: 16, height: 1.5, color: bodyColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Highlight Stories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Divider(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,),
              ...highlights.map((h) {
                final map = h as Map<String, dynamic>;
                return _buildHighlightCard(
                  title: map['title'] as String,
                  date: map['date'] as String,
                  bullets: (map['bullets'] as List<dynamic>).cast<String>(),
                  isDark: isDark,
                  primaryColor: primaryColor,
                  titleColor: titleColor,
                  bodyColor: bodyColor,
                  secondaryColor: secondaryColor,
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Church Unity & Collaboration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'One Church, One Kingdom\n\nWe have discovered that the greatest miracle is not just a healing or a crowd—it is when pastors and churches of different backgrounds come together as one.\n\nKingdom Heirs Foundation serves as a bridge, helping churches: Pray together, Plan together, and Reach their cities together.',
                style: TextStyle(fontSize: 16, height: 1.5, color: bodyColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'Ways to Partner',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Divider(
                  color:
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,),
              _buildPartnerSection(
                '1. Pray',
                'Commit to praying for our team, our partners, and the communities we serve.',
                titleColor,
                bodyColor,
              ),
              _buildPartnerSection(
                '2. Give',
                'Your financial support helps provide food, water, shelter, outreach crusades, and leadership training through Vessel Bible College.',
                titleColor,
                bodyColor,
              ),
              _buildPartnerSection(
                '3. Church Partnerships',
                'We collaborate with local churches to host city-wide evangelistic crusades, regional unity gatherings, and training days for evangelism and outreach.',
                titleColor,
                bodyColor,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required String date,
    required List<String> bullets,
    required bool isDark,
    required Color primaryColor,
    required Color titleColor,
    required Color bodyColor,
    required Color secondaryColor,
  }) {
    return Card(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                            fontSize: 15, height: 1.4, color: bodyColor,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSection(
      String title, String desc, Color titleColor, Color bodyColor,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            desc,
            style: TextStyle(fontSize: 16, height: 1.4, color: bodyColor),
          ),
        ],
      ),
    );
  }
}
