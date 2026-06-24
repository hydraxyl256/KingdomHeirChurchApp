import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/start_here_provider.dart';

class KingdomHeirsStoryScreen extends ConsumerWidget {
  const KingdomHeirsStoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(startHereContentProvider('story'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact & Story'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (content) {
          final jsonMap = jsonDecode(content.body) as Map<String, dynamic>;
          final intro = jsonMap['intro'] as String;
          final highlights = jsonMap['highlights'] as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'IMPACT AND STORY',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Behind every number is a life restored.',
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                intro,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const Text(
                'Highlight Stories',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,),
              ),
              const Divider(),
              ...highlights.map((h) {
                final map = h as Map<String, dynamic>;
                return _buildHighlightCard(
                  title: map['title'] as String,
                  date: map['date'] as String,
                  bullets: (map['bullets'] as List<dynamic>).cast<String>(),
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
              const Text(
                'Church Unity & Collaboration',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'One Church, One Kingdom\n\nWe have discovered that the greatest miracle is not just a healing or a crowd—it is when pastors and churches of different backgrounds come together as one.\n\nKingdom Heirs Foundation serves as a bridge, helping churches: Pray together, Plan together, and Reach their cities together.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const Text(
                'Ways to Partner',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,),
              ),
              const Divider(),
              _buildPartnerSection('1. Pray',
                  'Commit to praying for our team, our partners, and the communities we serve.',),
              _buildPartnerSection('2. Give',
                  'Your financial support helps provide food, water, shelter, outreach crusades, and leadership training through Vessel Bible College.',),
              _buildPartnerSection('3. Church Partnerships',
                  'We collaborate with local churches to host city-wide evangelistic crusades, regional unity gatherings, and training days for evangelism and outreach.',),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 18, color: AppColors.primary),),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 16, height: 1.4),),),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
      {required String title,
      required String date,
      required List<String> bullets,}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,),),
            const SizedBox(height: AppSpacing.sm),
            ...bullets.map(_buildBulletPoint),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}
