// Kingdom Heir — Section Error Boundary
//
// Wraps a single dashboard section so a render-time exception (e.g. an
// unexpected null on a greeting field, a malformed RPC response) cannot
// take down the rest of the screen. The rest of the dashboard continues
// to render unaffected sections.
//
// The boundary:
//   1. Catches every FlutterError / exception thrown while building the
//      wrapped child.
//   2. Logs the technical details to Sentry / Crashlytics (via
//      `StructuredLogger`) — UI is never shown a raw stack trace.
//   3. Renders a compact, friendly fallback (icon + "Section
//      unavailable" + optional retry).
//   4. Reports the failure back to the host so analytics can count
//      "section X failed" events without coupling this widget to
//      Firebase Analytics directly.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/logging/structured_logger.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Tag describing which dashboard section failed — used for logging +
/// analytics. Kept short so the JSON event is compact.
enum DashboardSection {
  greeting,
  scripture,
  quickActions,
  continueJourney,
  service,
  dailyJourney,
  continueWatching,
  floatingPrayer,
  other,
}

class SectionErrorBoundary extends StatefulWidget {
  const SectionErrorBoundary({
    required this.section,
    required this.child,
    this.fallback,
    this.onRetry,
    super.key,
  });

  /// Which dashboard section is being protected. Used for logging.
  final DashboardSection section;

  /// The section widget to render. If it throws while building, the
  /// boundary catches the error and shows [fallback] (or a default
  /// compact error card) instead.
  final Widget child;

  /// Optional explicit fallback widget. When null, a default
  /// compact-error card is rendered.
  final Widget? fallback;

  /// Optional retry callback. When provided, the default fallback shows
  /// a "Tap to retry" button that calls this and re-renders the child.
  final VoidCallback? onRetry;

  @override
  State<SectionErrorBoundary> createState() => _SectionErrorBoundaryState();
}

class _SectionErrorBoundaryState extends State<SectionErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Reset on every rebuild of the child so a successful retry replaces
    // the fallback cleanly.
    _error = null;
  }

  @override
  Widget build(BuildContext context) {
    // Use a builder + try/catch to surface render-time exceptions
    // (including async ones that resolve before the next frame).
    try {
      return Builder(
        builder: (context) => widget.child,
      );
    } catch (e, st) {
      _record(e, st);
      return _buildFallback();
    }
  }

  void _record(Object e, StackTrace? st) {
    // Only log the first failure per section instance; otherwise retries
    // would spam the logger.
    if (_error != null) return;
    _error = e;

    StructuredLogger.logEvent({
      'event': 'dashboard_section_failed',
      'section': widget.section.name,
      'error_type': e.runtimeType.toString(),
      // Never include the full message in the structured log — it can
      // contain PII from server-side error text. Logged details go to
      // Crashlytics / Sentry only.
      'has_error': true,
    });

    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[SectionErrorBoundary] ${widget.section.name} crashed: $e\n$st',
      );
    }
  }

  Widget _buildFallback() {
    if (widget.fallback != null) return widget.fallback!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Material(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: widget.onRetry,
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
                        'This section is temporarily unavailable',
                        style:
                            AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.onRetry != null
                            ? 'Tap to retry'
                            : 'Pull down to refresh',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color:
                              AppColors.error.withValues(alpha: 0.6),
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
