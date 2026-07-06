// Kingdom Heir — Public Prayer Wall
//
// Lists the approved prayer requests, ordered by approval time
// (newest approval first). The repository targets the
// `prayer_requests_approved` view, so only approved + public-or-leader
// rows are ever read by the public wall — pending and rejected rows
// stay invisible. Anonymous approved rows display "Anonymous" as the
// requester name; no user ID or profile metadata is exposed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
import 'package:kingdom_heir/core/widgets/app_error_widget.dart';
import 'package:kingdom_heir/core/widgets/app_loading_indicator.dart';
import 'package:kingdom_heir/features/prayer_requests/domain/entities/prayer_request.dart';
import 'package:kingdom_heir/features/prayer_requests/presentation/providers/prayer_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

const _categories = [
  'All',
  'General',
  'Healing',
  'Provision',
  'Salvation',
  'Relationships',
  'Deliverance',
  'Thanksgiving',
];

class PrayerFeedScreen extends ConsumerStatefulWidget {
  const PrayerFeedScreen({super.key});

  @override
  ConsumerState<PrayerFeedScreen> createState() => _PrayerFeedScreenState();
}

class _PrayerFeedScreenState extends ConsumerState<PrayerFeedScreen> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final feedAsync = ref.watch(prayerFeedProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Prayer Wall'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'My Prayer Requests',
            onPressed: () => context.go(RouteNames.myPrayers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.submitPrayer),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Request Prayer'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
      ),
      body: feedAsync.when(
        loading: () => const Center(
          child: AppLoadingIndicator(label: 'Loading prayers...'),
        ),
        error: (err, stack) => AppErrorWidget(
          message: 'We could not load prayer requests right now. Please try again.',
          onRetry: () => ref.invalidate(prayerFeedProvider),
        ),
        data: (requests) {
          final filtered = _selectedCategory == 0
              ? requests
              : requests
                  .where((r) => r.category == _categories[_selectedCategory])
                  .toList();

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => ref.invalidate(prayerFeedProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ── Stats bar ──────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.navyMid, AppColors.navyLight]
                                : [AppColors.navy, AppColors.navyAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              value: '${requests.length}',
                              label: 'Requests',
                            ),
                            const _VertDivider(),
                            _StatItem(
                              value:
                                  '${requests.fold<int>(0, (s, r) => s + r.prayerCount)}',
                              label: 'Prayers Said',
                            ),
                          ],
                        ),
                      ),

                      // ── Category filters ────────────────────────────────────
                      Container(
                        height: 60,
                        color: isDark ? AppColors.surfaceDark : cs.surface,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (_, i) => FilterChip(
                            label: Text(_categories[i]),
                            selected: _selectedCategory == i,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = i),
                            backgroundColor: isDark
                                ? AppColors.surfaceContainerDark
                                : cs.surfaceContainerLow,
                            selectedColor: AppColors.gold.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.gold,
                            labelStyle:
                                AppTypography.textTheme.labelSmall?.copyWith(
                              color: _selectedCategory == i
                                  ? AppColors.gold
                                  : cs.onSurface.withValues(alpha: 0.75),
                              fontWeight: _selectedCategory == i
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            side: BorderSide(
                              color: _selectedCategory == i
                                  ? AppColors.gold
                                  : isDark
                                      ? AppColors.dividerDark
                                      : AppColors.dividerLight,
                            ),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Request list ─────────────────────────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _PrayerEmptyState(
                      isFiltered: requests.isNotEmpty &&
                          _selectedCategory != 0,
                      onSubmit: () => context.go(RouteNames.submitPrayer),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.massive,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _PrayerCard(item: filtered[i]),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _PrayerEmptyState extends StatelessWidget {
  const _PrayerEmptyState({
    required this.isFiltered,
    required this.onSubmit,
  });

  final bool isFiltered;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (isFiltered) {
      return const AppEmptyState(
        icon: Icons.filter_alt_off_rounded,
        title: 'No requests in this category',
        description:
            'Try a different filter — or be the first to ask for prayer here.',
      );
    }
    return AppEmptyState(
      icon: Icons.self_improvement_rounded,
      title: 'No prayer requests yet',
      description:
          'Be the first to share a prayer request. Our community is here to stand with you in prayer.',
      actionLabel: 'Request Prayer',
      onAction: onSubmit,
    );
  }
}

// ─── Prayer Card ─────────────────────────────────────────────────────────────

class _PrayerCard extends ConsumerWidget {
  const _PrayerCard({required this.item});

  final PrayerRequest item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    // displayName is always populated by the public view — it is the
    // requester's full name for non-anonymous rows and the literal
    // "Anonymous" for anonymous rows.
    final displayName = item.displayName ?? 'Member';
    final timeAgo = timeago.format(item.createdAt);

    final categoryBg = isDark
        ? AppColors.gold.withValues(alpha: 0.15)
        : AppColors.goldContainer;
    final categoryText = isDark ? AppColors.goldLight : AppColors.goldDark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isDark ? AppColors.surfaceDark : cs.surface,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                AppAvatar(
                  name: displayName,
                  imageUrl: item.isAnonymous ? null : item.authorAvatarUrl,
                  size: AppSpacing.avatarSm,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    item.category,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: categoryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              item.title,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Content
            Text(
              item.content,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                height: 1.6,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              height: 1,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Actions row
            Row(
              children: [
                // Pray button
                GestureDetector(
                  onTap: () => ref
                      .read(prayerFeedProvider.notifier)
                      .togglePray(item.id, currentlyPraying: item.hasPrayed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: item.hasPrayed
                          ? AppColors.gold.withValues(alpha: 0.15)
                          : AppColors.gold.withValues(alpha: 0.07),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: item.hasPrayed
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.3),
                        width: item.hasPrayed ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.hasPrayed
                              ? Icons.self_improvement_rounded
                              : Icons.self_improvement_outlined,
                          size: AppSpacing.iconSm,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.hasPrayed ? 'Praying' : 'Pray',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Prayer count
                Text(
                  '${item.prayerCount} praying',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                const Spacer(),

                // Share / comment icons
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  onPressed: () {},
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  onPressed: () {},
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.statNumber.copyWith(
            color: AppColors.gold,
            fontSize: 26,
          ),
        ),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white24,
    );
  }
}
