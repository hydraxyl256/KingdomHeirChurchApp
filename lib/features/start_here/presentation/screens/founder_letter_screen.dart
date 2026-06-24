import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/start_here_provider.dart';

class FounderLetterScreen extends ConsumerWidget {
  const FounderLetterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(startHereContentProvider('founder_letter'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Letter from our Founder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (content) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'Welcome to Kingdom Heirs Foundation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                content.body,
                style: const TextStyle(
                    fontSize: 16, height: 1.6, color: AppColors.textPrimary,),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Rev. James Maddalone',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,),
              ),
              const Text(
                'Founder, Kingdom Heirs Foundation',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }
}
