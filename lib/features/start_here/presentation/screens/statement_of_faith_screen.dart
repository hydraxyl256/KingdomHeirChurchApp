// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/start_here_provider.dart';

class StatementOfFaithScreen extends ConsumerWidget {
  const StatementOfFaithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync =
        ref.watch(startHereContentProvider('statement_of_faith'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement of Faith'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (content) {
          final paragraphs = content.body.split('\n');
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'The Kingdom Heirs Foundation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Statement of Faith',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ...paragraphs.asMap().entries.map((entry) {
                final text = entry.value;
                if (text.trim().isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    '• $text',
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.black87,),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required String references,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            references,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.dividerLight),
        ],
      ),
    );
  }
}
