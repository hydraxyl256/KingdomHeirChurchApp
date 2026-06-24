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

/// Empty state widget for lists / feeds with no content.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

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
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: actionLabel!,
                onPressed: action,
              ).animate().fadeIn(delay: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
