import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/features/start_here/presentation/providers/start_here_provider.dart';

class FounderLetterScreen extends ConsumerWidget {
  const FounderLetterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentAsync = ref.watch(startHereContentProvider('founder_letter'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Letter from our Founder'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: isDark ? AppColors.warmWhite : Colors.white,
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: isDark ? AppColors.warmWhite : AppColors.textPrimary))),
        data: (content) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                'Welcome to Kingdom Heirs Foundation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.warmWhite : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                content.body,
                style: TextStyle(
                    fontSize: 16, height: 1.6, color: isDark ? AppColors.warmWhite.withValues(alpha: 0.85) : AppColors.textPrimary,),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Rev. James Maddalone',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.gold : AppColors.primary,),
              ),
              Text(
                'Founder, Kingdom Heirs Foundation',
                style: TextStyle(fontSize: 14, color: isDark ? AppColors.warmWhite.withValues(alpha: 0.6) : AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }
}
