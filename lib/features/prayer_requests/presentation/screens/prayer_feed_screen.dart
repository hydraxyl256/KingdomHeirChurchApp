import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/widgets/app_avatar.dart';
import 'package:kingdom_heir/core/widgets/app_empty_state.dart';
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

    final feedAsync = ref.watch(prayerFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Wall'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'My Prayers',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _MyPrayersSheet(),
            ),
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
            child: AppLoadingIndicator(label: 'Loading prayers...'),),
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
            onRefresh: () async => ref.invalidate(prayerFeedProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ── Stats bar ───────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.navy,
                              if (isDark)
                                AppColors.navyMid
                              else
                                AppColors.navyAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                                value: '${requests.length}', label: 'Requests',),
                            _Divider(),
                            _StatItem(
                              value:
                                  '${requests.fold<int>(0, (s, r) => s + r.prayerCount)}',
                              label: 'Prayers Said',
                            ),
                            _Divider(),
                            _StatItem(
                              value:
                                  '${requests.where((r) => r.status == PrayerStatus.answered).length}',
                              label: 'Answered',
                            ),
                          ],
                        ),
                      ),

                      // ── Category filters ─────────────────────────────────────────
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (_, i) => FilterChip(
                            label: Text(_categories[i]),
                            selected: _selectedCategory == i,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = i),
                            selectedColor:
                                AppColors.gold.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.goldDark,
                            labelStyle:
                                AppTypography.textTheme.labelSmall?.copyWith(
                              color: _selectedCategory == i
                                  ? AppColors.goldDark
                                  : theme.colorScheme.onSurface,
                              fontWeight: _selectedCategory == i
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            side: BorderSide(
                              color: _selectedCategory == i
                                  ? AppColors.gold
                                  : theme.dividerColor,
                            ),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Request list ─────────────────────────────────────────────
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

/// Two flavors of empty state:
/// - When the DB is genuinely empty (no requests at all), invite the user
///   to submit the first prayer request with a CTA.
/// - When the user has filtered down to a category that has no matches,
///   encourage them to broaden the filter or pray for others.
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
    final isAnswered = item.status == PrayerStatus.answered;

    final displayName =
        item.isAnonymous ? 'Anonymous' : (item.authorName ?? 'Member');
    final timeAgo = timeago.format(item.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AppAvatar(
                    name: displayName,
                    imageUrl: item.authorAvatarUrl,
                    size: AppSpacing.avatarSm,),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? AppColors.successContainer
                        : AppColors.goldContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    isAnswered ? 'Answered' : item.category,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color:
                          isAnswered ? AppColors.success : AppColors.goldDark,
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
              style: AppTypography.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Content
            Text(
              item.content,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),

            // Actions
            Row(
              children: [
                // Pray button
                GestureDetector(
                  onTap: isAnswered
                      ? null
                      : () => ref
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
                          : AppColors.gold.withValues(alpha: 0.08),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                const Spacer(),

                // Share / comment
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  onPressed: () {},
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18),
                  onPressed: () {},
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white24,
    );
  }
}

// ─── My Prayers History Sheet ─────────────────────────────────────────────────

class _MyPrayersSheet extends ConsumerWidget {
  const _MyPrayersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final myAsync = ref.watch(myPrayersProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.self_improvement_rounded,
                        color: AppColors.gold, size: 20,),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'My Prayer Requests',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: cs.onSurface, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: myAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Could not load your prayers.\n$err',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  data: (requests) {
                    if (requests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 48, color: cs.outlineVariant,),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              "You haven't submitted any prayer requests yet.",
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, i) {
                        final r = requests[i];
                        final isAnswered = r.status == PrayerStatus.answered;
                        final isPrivate = !r.isPublic;
                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.title,
                                        style: AppTypography.textTheme
                                            .labelMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAnswered
                                            ? AppColors.successContainer
                                            : isPrivate
                                                ? cs.secondaryContainer
                                                : AppColors.goldContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        isAnswered
                                            ? '✅ Answered'
                                            : isPrivate
                                                ? '🔒 Private'
                                                : r.category,
                                        style: AppTypography.textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: isAnswered
                                              ? AppColors.success
                                              : isPrivate
                                                  ? cs.onSecondaryContainer
                                                  : AppColors.goldDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.content,
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.65),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeago.format(r.createdAt),
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                                if (r.prayerCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '🙏 ${r.prayerCount} praying',
                                    style: AppTypography.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
