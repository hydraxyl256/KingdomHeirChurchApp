// Kingdom Heir — Group Leader Screen
//
// Leader-only dashboard for a single group. Layout:
//
//   • SliverAppBar with group name
//   • Quick stats row (pending / active / engagement / attendance)
//   • Pending requests list (if any)
//   • Engagement chart (last 8 weeks)
//   • Members list
//   • Announcement composer (pinned toggle + post)
//
// Reads:
//   • groupPendingRequestsProvider
//   • groupMembersProvider
//   • groupWeeklyEngagementProvider
//   • groupAvgAttendanceProvider
//   • groupDetailProvider (for the group name)
//
// Mutations (approve / deny / postAnnouncement) go through
// `groupMutationsProvider`.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/responsive_section_header.dart';
import 'package:kingdom_heir/features/groups/presentation/providers/group_detail_provider.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/leader/engagement_chart.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/leader/member_row.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/leader/pending_request_card.dart';
import 'package:kingdom_heir/features/groups/presentation/widgets/leader/quick_stat_tile.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GroupLeaderScreen extends ConsumerWidget {
  const GroupLeaderScreen({required this.groupId, super.key});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(groupSectionsProvider(groupId));
    final insets = Insets.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          sections.detail.valueOrNull?.group.name ?? 'Leader dashboard',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: sections.detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AppErrorWidget(
          message: AppLocalizations.of(context)!.couldntLoadLeaderDashboard,
          onRetry: () => ref.invalidate(groupSectionsProvider(groupId)),
        ),
        data: (_) {
          final pending = sections.pendingRequests.valueOrNull ?? [];
          final members = sections.members.valueOrNull ?? [];
          final engagement = sections.weeklyEngagement.valueOrNull ?? 0;
          final avgAttend = sections.avgAttendance.valueOrNull ?? 0.0;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  insets.lg,
                  insets.md,
                  insets.lg,
                  0,
                ),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: insets.sm,
                  crossAxisSpacing: insets.sm,
                  childAspectRatio: 1.6,
                  children: [
                    QuickStatTile(
                      label: 'Pending requests',
                      value: '${pending.length}',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      delta: pending.isEmpty ? 'All clear' : 'Action needed',
                    ),
                    QuickStatTile(
                      label: 'Active members',
                      value:
                          '${members.where((m) => m.role.name != 'pending').length}',
                      icon: Icons.people_alt_rounded,
                      delta: '+${(members.length / 10).round()} this month',
                    ),
                    QuickStatTile(
                      label: 'Weekly engagement',
                      value: '$engagement%',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.goldDark,
                      delta: '+4% from last week',
                    ),
                    QuickStatTile(
                      label: 'Avg. attendance',
                      value: '${(avgAttend * 100).round()}%',
                      icon: Icons.event_available_rounded,
                      color: AppColors.success,
                      delta: 'Last 4 meetings',
                    ),
                  ],
                ),
              ),
              if (pending.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: ResponsiveSectionHeader(
                    title: 'Pending requests',
                    subtitle: 'Approve or deny new joiners',
                    icon: Icons.hourglass_top_rounded,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    0,
                    insets.lg,
                    insets.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: pending.length,
                    separatorBuilder: (_, __) => SizedBox(height: insets.sm),
                    itemBuilder: (_, i) => PendingRequestCard(
                      request: pending[i],
                      groupId: groupId,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 50 * i),
                          duration: 300.ms,
                        ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    insets.xl,
                    insets.lg,
                    insets.sm,
                  ),
                  child: EngagementChart(
                    weeklyActive: _mockWeekly(engagement),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ResponsiveSectionHeader(
                  title: 'Members',
                  subtitle: '${members.length} total',
                  icon: Icons.people_alt_rounded,
                  actionLabel: 'Manage',
                  onAction: () {},
                ),
              ),
              if (members.isEmpty)
                const SliverToBoxAdapter(
                  child: AppEmptyState(
                    icon: Icons.person_off_outlined,
                    title: 'No members yet',
                    description: 'Once people join they’ll appear here.',
                    isCompact: true,
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    0,
                    insets.lg,
                    insets.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, __) => SizedBox(height: insets.xs),
                    itemBuilder: (_, i) => MemberRow(
                      member: members[i],
                      onPromote: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .promoteFeatureComingSoon,),
                          ),
                        );
                      },
                      onRemove: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .removeFeatureComingSoon,),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: ResponsiveSectionHeader(
                  title: 'Post announcement',
                  subtitle: 'Pin a message to the top of the group',
                  icon: Icons.campaign_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    insets.lg,
                    0,
                    insets.lg,
                    insets.xxl,
                  ),
                  child: _AnnouncementComposer(groupId: groupId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Stub weekly series. Replace with
  /// `repo.getWeeklyEngagementSeries(groupId)` when the backend exposes it.
  List<int> _mockWeekly(int currentPct) {
    final base = currentPct == 0 ? 60 : currentPct;
    const scale = 6; // turn 0–100 pct into a chart-friendly 0–600 range
    return List<int>.generate(8, (i) {
      final v = (base + (i - 4) * 3 + (i.isEven ? 2 : -2)).clamp(20, 100);
      return v * scale;
    });
  }
}

class _AnnouncementComposer extends ConsumerStatefulWidget {
  const _AnnouncementComposer({required this.groupId});
  final String groupId;

  @override
  ConsumerState<_AnnouncementComposer> createState() =>
      _AnnouncementComposerState();
}

class _AnnouncementComposerState extends ConsumerState<_AnnouncementComposer> {
  final _controller = TextEditingController();
  bool _pinned = false;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(groupMutationsProvider).postAnnouncement(
            groupId: widget.groupId,
            body: body,
            pinned: _pinned,
          );
      if (mounted) {
        _controller.clear();
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.announcementPosted),),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(insets.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.shareAnUpdateWithTheGroup,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: AppRadius.brMd,
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.brMd,
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.brMd,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.4,
                ),
              ),
              contentPadding: EdgeInsets.all(insets.sm),
            ),
          ),
          SizedBox(height: insets.sm),
          Row(
            children: [
              Switch(
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
                activeThumbColor: AppColors.gold,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.push_pin_rounded,
                size: 14,
                color: AppColors.goldDark,
              ),
              const SizedBox(width: 4),
              Text(
                'Pin to top',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 14),
                label: Text(AppLocalizations.of(context)!.post),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                  padding: EdgeInsets.symmetric(
                    horizontal: insets.md,
                    vertical: 8,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brMd,
                  ),
                  textStyle: AppTypography.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
