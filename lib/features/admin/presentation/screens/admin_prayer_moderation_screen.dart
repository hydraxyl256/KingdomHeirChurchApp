// Kingdom Heir — Admin Prayer Moderation screen
//
// Three tabs: Pending review (default), Approved, Not published.
// Each tab shows a list of prayer requests with their status chip and
// moderation actions. Pending rows expose Approve and Do not publish
// buttons, each guarded by a confirmation dialog that lets the admin
// add an optional note for the member. Approved rows expose Unpublish;
// Not published rows expose Restore to pending review.
//
// All three moderation actions are server-side RPCs (approve / reject /
// set_prayer_request_pending) — the client never writes to the
// `prayer_requests` table directly. RLS + SECURITY DEFINER re-check
// `is_admin_db()` on the database, so even a tampered client is locked
// out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/app_text_field.dart';
import 'package:kingdom_heir/features/auth/presentation/providers/auth_provider.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/providers/prayer_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminPrayerModerationScreen extends ConsumerStatefulWidget {
  const AdminPrayerModerationScreen({super.key});

  @override
  ConsumerState<AdminPrayerModerationScreen> createState() =>
      _AdminPrayerModerationScreenState();
}

class _AdminPrayerModerationScreenState
    extends ConsumerState<AdminPrayerModerationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isAdmin = ref.watch(currentUserIsAdminProvider);

    // Client-side admin guard. DB RLS is the final authority.
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'You do not have admin permissions to view this page.',),
              backgroundColor: scheme.error,
            ),
          );
        }
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer Moderation')),
        body: const Center(
          child: Text('Redirecting…'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prayer Moderation'),
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: 'Pending review'),
              Tab(text: 'Approved'),
              Tab(text: 'Not published'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: const [
            _PendingTab(),
            _ApprovedTab(),
            _RejectedTab(),
          ],
        ),
      ),
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(pendingPrayersForAdminProvider);
    return _PrayerList(
      asyncData: asyncData,
      emptyIcon: Icons.schedule_rounded,
      emptyTitle: 'No pending requests',
      emptyDescription:
          'New prayer requests will appear here for moderation. Take a moment to pray for each one before deciding.',
      onRefresh: () async => ref.invalidate(pendingPrayersForAdminProvider),
      buildCard: (req) => _PrayerModerationCard(
        request: req,
        actions: [
          _ActionSpec(
            label: 'Do not publish',
            icon: Icons.do_not_disturb_alt_rounded,
            isPrimary: false,
            destructive: true,
            dialogTitle: 'Do not publish this prayer request?',
            dialogBody:
                'This request will be removed from the moderation queue and the member will be notified.',
            confirmLabel: 'Confirm',
            onConfirm: (note) => ref
                .read(adminPrayerModerationProvider)
                .reject(req.id, adminNote: note),
            successMessage: 'Prayer request marked as not published.',
          ),
          _ActionSpec(
            label: 'Approve for Prayer Wall',
            icon: Icons.check_rounded,
            isPrimary: true,
            dialogTitle: 'Approve this prayer request?',
            dialogBody:
                'This request will become visible on the Prayer Wall after approval.',
            confirmLabel: 'Approve',
            onConfirm: (note) => ref
                .read(adminPrayerModerationProvider)
                .approve(req.id, adminNote: note),
            successMessage: 'Prayer request approved for the Prayer Wall.',
          ),
        ],
      ),
    );
  }
}

class _ApprovedTab extends ConsumerWidget {
  const _ApprovedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(approvedPrayersForAdminProvider);
    return _PrayerList(
      asyncData: asyncData,
      emptyIcon: Icons.check_circle_outline_rounded,
      emptyTitle: 'No approved requests yet',
      emptyDescription:
          'Approved prayer requests will appear here. You can return any to the pending queue if circumstances change.',
      onRefresh: () async => ref.invalidate(approvedPrayersForAdminProvider),
      buildCard: (req) => _PrayerModerationCard(
        request: req,
        actions: [
          _ActionSpec(
            label: 'Return to pending',
            icon: Icons.undo_rounded,
            isPrimary: false,
            dialogTitle: 'Move this request back to pending review?',
            dialogBody:
                'This will hide the request from the Prayer Wall again until it is re-approved.',
            confirmLabel: 'Move to pending',
            onConfirm: (_) => ref
                .read(adminPrayerModerationProvider)
                .returnToPending(req.id),
            successMessage: 'Prayer request moved back to the pending queue.',
          ),
        ],
      ),
    );
  }
}

class _RejectedTab extends ConsumerWidget {
  const _RejectedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(rejectedPrayersForAdminProvider);
    return _PrayerList(
      asyncData: asyncData,
      emptyIcon: Icons.do_not_disturb_on_outlined,
      emptyTitle: 'No "not published" requests',
      emptyDescription:
          'Requests that were decided to remain off the Prayer Wall will appear here. You can return any to the pending queue.',
      onRefresh: () async => ref.invalidate(rejectedPrayersForAdminProvider),
      buildCard: (req) => _PrayerModerationCard(
        request: req,
        actions: [
          _ActionSpec(
            label: 'Restore to pending',
            icon: Icons.restore_rounded,
            isPrimary: false,
            dialogTitle: 'Restore this request to pending review?',
            dialogBody:
                'This will move the request back into the pending queue so it can be reviewed again.',
            confirmLabel: 'Restore',
            onConfirm: (_) => ref
                .read(adminPrayerModerationProvider)
                .returnToPending(req.id),
            successMessage: 'Prayer request restored to pending review.',
          ),
        ],
      ),
    );
  }
}

// ─── Generic list wrapper ────────────────────────────────────────────────

class _PrayerList extends StatelessWidget {
  const _PrayerList({
    required this.asyncData,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onRefresh,
    required this.buildCard,
  });

  final AsyncValue<List<PrayerRequest>> asyncData;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final Future<void> Function() onRefresh;
  final Widget Function(PrayerRequest request) buildCard;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: asyncData.when(
        loading: () => const AppLoadingIndicator(
          label: 'Loading prayer requests...',
        ),
        error: (err, _) => AppErrorWidget(
          message:
              'We could not load the moderation queue. Please try again.',
          onRetry: onRefresh,
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: AppEmptyState(
                    icon: emptyIcon,
                    title: emptyTitle,
                    description: emptyDescription,
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => buildCard(requests[i]),
          );
        },
      ),
    );
  }
}

// ─── Card ───────────────────────────────────────────────────────────────

class _PrayerModerationCard extends ConsumerWidget {
  const _PrayerModerationCard({
    required this.request,
    required this.actions,
  });

  final PrayerRequest request;
  final List<_ActionSpec> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final inFlight = ref.watch(moderationInFlightProvider).contains(request.id);
    final displayName = request.displayName ?? 'Member';
    final showSubmittedBy = request.isAnonymous;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.category} • ${timeago.format(request.createdAt)}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (request.isAnonymous)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off_rounded,
                        size: 12,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Anonymous',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Content
          Text(
            request.content,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.55,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // Admin-only "submitted by" line — even for anonymous
          // requests, the admin sees the requester name.
          if (showSubmittedBy)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 14,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Submitted by: $displayName',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          if (request.adminNote?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your previous note to the member:',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.adminNote!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Actions
          if (inFlight)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            )
          else
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final action in actions)
                  _ActionButton(action: action, request: request),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.action, required this.request});
  final _ActionSpec action;
  final PrayerRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Future<void> onPressed() async {
      final note = await showDialog<String?>(
        context: context,
        builder: (_) => _AdminActionDialog(
          title: action.dialogTitle,
          body: action.dialogBody,
          confirmLabel: action.confirmLabel,
          destructive: action.destructive,
        ),
      );
      // Note: null could be either "no note" or "cancelled" — we
      // distinguish by the sentinel. Returning a sentinel value is the
      // only reliable way to tell them apart in a single-channel
      // dialog. The dialog returns `''` for "no note entered" and
      // `null` for cancellation.
      if (note == null) return;
      final error = await action.onConfirm(note.isEmpty ? null : note);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? action.successMessage,
          ),
          backgroundColor: error == null ? AppColors.success : scheme.error,
        ),
      );
    }

    if (action.isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(action.icon, size: 18),
        label: Text(action.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        action.icon,
        size: 18,
        color: action.destructive
            ? scheme.error
            : scheme.onSurface.withValues(alpha: 0.75),
      ),
      label: Text(
        action.label,
        style: TextStyle(
          color: action.destructive
              ? scheme.error
              : scheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: action.destructive
              ? scheme.error.withValues(alpha: 0.5)
              : scheme.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}

class _ActionSpec {
  _ActionSpec({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.dialogTitle,
    required this.dialogBody,
    required this.confirmLabel,
    required this.onConfirm,
    required this.successMessage,
    this.destructive = false,
  });
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool destructive;
  final String dialogTitle;
  final String dialogBody;
  final String confirmLabel;
  final Future<String?> Function(String? note) onConfirm;
  final String successMessage;
}

class _AdminActionDialog extends StatefulWidget {
  const _AdminActionDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.destructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final bool destructive;

  @override
  State<_AdminActionDialog> createState() => _AdminActionDialogState();
}

class _AdminActionDialogState extends State<_AdminActionDialog> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      backgroundColor: theme.cardColor,
      title: Text(
        widget.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _noteController,
            label: 'Note for the member (optional)',
            hint: 'A short, pastoral word…',
            maxLines: 3,
            minLines: 2,
            maxLength: 280,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_noteController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.destructive ? scheme.error : AppColors.gold,
            foregroundColor:
                widget.destructive ? scheme.onError : AppColors.ink,
            elevation: 0,
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
