// Kingdom Heir — Dashboard Section View
//
// Wraps an `AsyncValue<T>` so a single dashboard section shows its own
// skeleton, data, error, or offline state without affecting the other
// sections on the screen.
//
// Contract:
//   • `data: ...`          → renders `data(data)`, or `empty()` if
//                            `isEmpty(data)` returns true
//   • `loading: ...`       → renders `loading()` (a per-section
//                            skeleton; the full `DashboardSkeleton` is
//                            used by the screen on cold start before
//                            any data has arrived)
//   • `error: (e, _) => …` → renders the friendly `_SectionErrorCard`
//                            with `onRetry` wired to the right
//                            provider's `invalidate` — never the raw
//                            exception text
//
// The error message is piped through a single shared helper so the raw
// `PostgrestException` text never reaches the user.

import 'dart:io' show SocketException;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/error/failure.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Curated, user-safe error string for a dashboard section failure.
///
/// Never returns the raw `Object.toString()` of the exception — that
/// could leak a `PostgrestException` class name, the underlying SQL
/// table name, or a status code (e.g. `42501`).
String dashboardFriendlyErrorMessage(Object e) {
  if (e is Failure) return e.toString();
  if (e is SocketException) {
    return 'You appear to be offline. Check your connection and try again.';
  }
  return 'This section is temporarily unavailable. '
      'Tap to retry, or pull down to refresh.';
}

/// One slot of the dashboard. The body takes a fresh
/// `AsyncValue<T>` and renders whichever phase the section is in.
///
/// `isEmpty` lets the data branch signal "the server returned
/// successfully, but the list is empty" — the section then renders
/// `empty()` instead of `data(data)`.
class DashboardSectionView<T> extends StatelessWidget {
  const DashboardSectionView({
    required this.asyncValue,
    required this.data,
    required this.loading,
    required this.onRetry,
    this.empty,
    this.isEmpty,
    super.key,
  });

  final AsyncValue<T> asyncValue;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final VoidCallback onRetry;
  final Widget Function()? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (value) {
        if (isEmpty != null && isEmpty!(value) && empty != null) {
          return empty!();
        }
        return data(value);
      },
      loading: loading,
      error: (e, _) => _SectionErrorCard(
        message: dashboardFriendlyErrorMessage(e),
        onRetry: onRetry,
      ),
    );
  }
}

/// Compact, friendly error card. Used when a section's provider is
/// in an `AsyncError` state. Mirrors the visual language of
/// `SectionErrorBoundary`'s default fallback.
class _SectionErrorCard extends StatelessWidget {
  const _SectionErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Material(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.error.withValues(alpha: 0.7),
                  size: 22,
                  semanticLabel: 'Section unavailable',
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to retry',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.error.withValues(alpha: 0.6),
                        ),
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
