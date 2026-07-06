import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/widgets/app_button.dart';

/// Displays an error state with icon, message, and optional retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
    this.title,
  });

  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;
  final String? title;

  String get _title => title ?? 'Something went wrong';

  String get _message {
    if (message != null) return message!;
    if (failure == null) return 'An unexpected error occurred.';
    return switch (failure!) {
      NetworkFailure() =>
        'No internet connection. Please check your network and try again.',
      AuthFailure() => 'You need to log in to continue.',
      ServerFailure(message: final m) => m,
      ValidationFailure(message: final m) => m,
      CacheFailure() => 'Could not load data from cache.',
      UnknownFailure(message: final m) => m,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Try Again',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ).animate().fadeIn(delay: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
