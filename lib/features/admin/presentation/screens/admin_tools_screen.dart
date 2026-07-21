// Kingdom Heir — Admin Tools Screen
//
// Temporary internal utility for administrators to manually trigger
// YouTube content synchronisation before the full Admin CMS is ready.
//
// Access: admin, super_admin, pastor only (enforced by router guard).
// Route: /admin/tools
//
// This screen intentionally uses no print() statements — all logging
// goes through dart:developer which is stripped in release builds.

import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _lastSyncRunProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('media_sync_runs')
      .select()
      .order('started_at', ascending: false)
      .limit(1)
      .maybeSingle();
  return data;
});

final _mediaStatsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final rows = await client.from('media_content').select('status');
  final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();

  final total = list.length;
  var pendingReview = 0;
  var published = 0;
  var rejected = 0;

  for (final row in list) {
    final status = row['status'] as String? ?? '';
    if (status == 'pending_review') pendingReview++;
    if (status == 'published') published++;
    if (status == 'rejected') rejected++;
  }

  return {
    'total': total,
    'pending_review': pendingReview,
    'published': published,
    'rejected': rejected,
  };
});

/// Holds the result of the last sync invocation during this session.
final _syncResultProvider = StateProvider<_SyncResult?>((ref) => null);

/// Whether a sync is currently in-flight.
final _isSyncingProvider = StateProvider<bool>((ref) => false);

// ─── Data Classes ─────────────────────────────────────────────────────────────

class _SyncResult {
  const _SyncResult({
    required this.success,
    required this.status,
    required this.videosFound,
    required this.videosCreated,
    required this.videosUpdated,
    required this.durationMs,
    this.errorMessage,
  });

  factory _SyncResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? json;
    return _SyncResult(
      success: json['success'] as bool? ?? false,
      status: summary['status'] as String? ?? 'unknown',
      videosFound: summary['videosFound'] as int? ?? 0,
      videosCreated: summary['videosCreated'] as int? ?? 0,
      videosUpdated: summary['videosUpdated'] as int? ?? 0,
      durationMs: summary['durationMs'] as int? ?? 0,
      errorMessage: summary['errorMessage'] as String?,
    );
  }

  final bool success;
  final String status;
  final int videosFound;
  final int videosCreated;
  final int videosUpdated;
  final int durationMs;
  final String? errorMessage;

  double get durationSeconds => durationMs / 1000;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminToolsScreen extends ConsumerWidget {
  const AdminToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.navy : AppColors.warmWhite;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.navyMid : null,
        title: Text(
          'Admin Tools',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.of(context)!.refresh,
            color: AppColors.gold,
            onPressed: () {
              ref
                ..invalidate(_lastSyncRunProvider)
                ..invalidate(_mediaStatsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _YouTubeSyncCard(),
          SizedBox(height: AppSpacing.md),
          _LastSyncCard(),
          SizedBox(height: AppSpacing.md),
          _MediaStatsCard(),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── YouTube Sync Card ────────────────────────────────────────────────────────

class _YouTubeSyncCard extends ConsumerWidget {
  const _YouTubeSyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(_isSyncingProvider);
    final syncResult = ref.watch(_syncResultProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.smart_display_rounded,
                  color: Color(0xFFFF0000),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YouTube Synchronization',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.warmWhite : AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Synchronize the latest sermons, podcasts and live videos\n'
                      'from the official Kingdom Heirs YouTube channel.',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.warmWhite.withValues(alpha: 0.6)
                            : AppColors.navyLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Sync Button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: isSyncing ? null : () => _triggerSync(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSyncing ? AppColors.navyLight : AppColors.gold,
                  disabledBackgroundColor: AppColors.navyLight,
                  foregroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: isSyncing ? 0 : 3,
                ),
                icon: isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.gold),
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 20),
                label: Text(
                  isSyncing ? 'Syncing…' : 'Sync YouTube',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSyncing ? AppColors.gold : AppColors.navy,
                  ),
                ),
              ),
            ),
          ),

          // ── Result Panel ───────────────────────────────────────────
          if (syncResult != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _SyncResultPanel(result: syncResult),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms);
  }

  Future<void> _triggerSync(BuildContext context, WidgetRef ref) async {
    dev.log('[AdminTools] Sync YouTube started', name: 'AdminTools');
    final startTime = DateTime.now();

    ref.read(_isSyncingProvider.notifier).state = true;
    ref.read(_syncResultProvider.notifier).state = null;

    try {
      final client = ref.read(supabaseClientProvider);

      // Supabase.functions automatically adds Authorization: Bearer <token>
      // from the current session — no manual token handling needed.
      final response = await client.functions.invoke(
        'sync-youtube-content',
      );

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;

      dev.log(
        '[AdminTools] Sync response received in ${durationMs}ms',
        name: 'AdminTools',
      );

      if (response.data == null) {
        throw Exception('Edge Function returned no data.');
      }

      final result = _SyncResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      dev.log(
        '[AdminTools] Sync finished — status: ${result.status}, '
        'found: ${result.videosFound}, created: ${result.videosCreated}, '
        'updated: ${result.videosUpdated}',
        name: 'AdminTools',
      );

      ref.read(_syncResultProvider.notifier).state = result;

      // Auto-refresh Last Sync and Media Stats.
      ref
        ..invalidate(_lastSyncRunProvider)
        ..invalidate(_mediaStatsProvider);
    } catch (e) {
      dev.log('[AdminTools] Sync error: $e', name: 'AdminTools');
      ref.read(_syncResultProvider.notifier).state = const _SyncResult(
        success: false,
        status: 'failed',
        videosFound: 0,
        videosCreated: 0,
        videosUpdated: 0,
        durationMs: 0,
        errorMessage: 'Synchronization failed. Please try again.',
      );
    } finally {
      ref.read(_isSyncingProvider.notifier).state = false;
    }
  }
}

// ─── Sync Result Panel ────────────────────────────────────────────────────────

class _SyncResultPanel extends StatelessWidget {
  const _SyncResultPanel({required this.result});

  final _SyncResult result;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!result.success || result.status == 'failed') {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Synchronization Failed',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (result.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      result.errorMessage!,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.error.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    // ── Success panel ───────────────────────────────────────────────
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Synchronization Complete',
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ResultRow(
            label: 'Videos Found',
            value: '${result.videosFound}',
            color: isDark ? AppColors.warmWhite : AppColors.navy,
          ),
          const SizedBox(height: 6),
          _ResultRow(
            label: 'New Videos Imported',
            value: '${result.videosCreated}',
            color: AppColors.success,
          ),
          const SizedBox(height: 6),
          _ResultRow(
            label: 'Existing Videos Updated',
            value: '${result.videosUpdated}',
            color: AppColors.gold,
          ),
          const SizedBox(height: 6),
          _ResultRow(
            label: 'Duration',
            value: '${result.durationSeconds.toStringAsFixed(1)} seconds',
            color: isDark
                ? AppColors.warmWhite.withValues(alpha: 0.6)
                : AppColors.navyLight,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms);
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.warmWhite.withValues(alpha: 0.5)
                : AppColors.navyLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Last Sync Card ───────────────────────────────────────────────────────────

class _LastSyncCard extends ConsumerWidget {
  const _LastSyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSync = ref.watch(_lastSyncRunProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Last Sync',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.warmWhite : AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          asyncSync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.gold),
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => _InfoRow(
              label: 'Status',
              value: 'Unavailable',
              isDark: isDark,
            ),
            data: (run) {
              if (run == null) {
                return Text(
                  'No synchronization runs recorded yet.',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.warmWhite.withValues(alpha: 0.5)
                        : AppColors.navyLight,
                  ),
                );
              }

              final status = run['status'] as String? ?? 'unknown';
              final startedAt = run['started_at'] != null
                  ? DateTime.tryParse(run['started_at'] as String)
                  : null;
              final durationMs = run['duration_ms'] as int?;
              final videosCreated = run['videos_created'] as int? ?? 0;
              final errorMsg = run['error_message'] as String?;

              Color statusColor;
              IconData statusIcon;
              switch (status) {
                case 'completed':
                  statusColor = AppColors.success;
                  statusIcon = Icons.check_circle_rounded;
                case 'failed':
                  statusColor = AppColors.error;
                  statusIcon = Icons.cancel_rounded;
                case 'running':
                  statusColor = AppColors.warning;
                  statusIcon = Icons.pending_rounded;
                default:
                  statusColor = isDark
                      ? AppColors.warmWhite.withValues(alpha: 0.4)
                      : AppColors.navyLight;
                  statusIcon = Icons.help_outline_rounded;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  if (startedAt != null)
                    _InfoRow(
                      label: 'Date',
                      value: _formatDate(startedAt),
                      isDark: isDark,
                    ),
                  if (durationMs != null) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Duration',
                      value: '${(durationMs / 1000).toStringAsFixed(1)}s',
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'Videos Imported',
                    value: '$videosCreated',
                    isDark: isDark,
                  ),

                  if (status == 'failed' && errorMsg != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        errorMsg,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.error.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(
          begin: 0.05,
          duration: 400.ms,
          delay: 100.ms,
        );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year} at $h:$m';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.warmWhite.withValues(alpha: 0.5)
                : AppColors.navyLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.warmWhite : AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Media Statistics Card ────────────────────────────────────────────────────

class _MediaStatsCard extends ConsumerWidget {
  const _MediaStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(_mediaStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.navyAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.video_library_rounded,
                  color: isDark ? AppColors.goldLight : AppColors.navyAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Media Library',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.warmWhite : AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          asyncStats.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.gold),
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, __) => Text(
              'Unable to load media statistics.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
            data: (stats) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.2,
              children: [
                _StatTile(
                  label: 'Total Videos',
                  value: '${stats['total'] ?? 0}',
                  color: isDark ? AppColors.gold : AppColors.navy,
                  bgColor: AppColors.gold.withValues(alpha: 0.08),
                ),
                _StatTile(
                  label: 'Pending Review',
                  value: '${stats['pending_review'] ?? 0}',
                  color: AppColors.warning,
                  bgColor: AppColors.warning.withValues(alpha: 0.08),
                ),
                _StatTile(
                  label: 'Published',
                  value: '${stats['published'] ?? 0}',
                  color: AppColors.success,
                  bgColor: AppColors.success.withValues(alpha: 0.08),
                ),
                _StatTile(
                  label: 'Rejected',
                  value: '${stats['rejected'] ?? 0}',
                  color: AppColors.error,
                  bgColor: AppColors.error.withValues(alpha: 0.08),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
          begin: 0.05,
          duration: 400.ms,
          delay: 200.ms,
        );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Premium Card Wrapper ─────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyMid : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.navyLight.withValues(alpha: 0.4)
              : AppColors.gold.withValues(alpha: 0.15),
        ),
        boxShadow: AppElevation.shadowFor(AppElevation.level2),
      ),
      child: child,
    );
  }
}
