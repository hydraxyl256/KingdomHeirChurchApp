// Kingdom Heir — Global Search Screen
//
// Cross-feature search UI. The user types a query, debounces 250ms,
// and the result list populates with grouped cards (Sermons, Events,
// Devotionals, Prayer, News). Tapping a result deep-links into the
// corresponding feature.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/search/global_search_models.dart';
import 'package:kingdom_heir/core/search/global_search_provider.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/iconography.dart';
import 'package:kingdom_heir/core/utils/donation_launcher.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus on push so the keyboard comes up immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final titleColor = isDark ? AppColors.warmWhite : AppColors.navy;
    final muted = isDark
        ? AppColors.warmWhite.withValues(alpha: 0.6)
        : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;

    final async = ref.watch(globalSearchProvider);
    final query = ref.watch(globalSearchQueryProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SearchHeader(
              controller: _controller,
              focus: _focus,
              titleColor: titleColor,
              muted: muted,
              cardColor: cardColor,
              onChanged: (v) {
                ref.read(globalSearchQueryProvider.notifier).state = v;
                ref.read(globalSearchProvider.notifier).search(v);
              },
              onClear: () {
                _controller.clear();
                ref.read(globalSearchProvider.notifier).clear();
              },
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _SearchBody(
                async: async,
                query: query,
                cardColor: cardColor,
                titleColor: titleColor,
                muted: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focus,
    required this.titleColor,
    required this.muted,
    required this.cardColor,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final Color titleColor;
  final Color muted;
  final Color cardColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: titleColor,
              size: AppSpacing.iconSm,
            ),
            onPressed: onBack,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: AppSpacing.fieldHeight,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Iconography.search,
                    color: AppColors.goldDark,
                    size: AppSpacing.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focus,
                      textInputAction: TextInputAction.search,
                      onChanged: onChanged,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.searchTheKingdom,
                        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: muted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, value, __) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: muted,
                          size: AppSpacing.iconSm,
                        ),
                        onPressed: onClear,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — state machine: idle / loading / results / no results
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.async,
    required this.query,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });

  final AsyncValue<GlobalSearchResults> async;
  final String query;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return _IdleSearch(
          cardColor: cardColor, titleColor: titleColor, muted: muted,);
    }
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldDark,
          strokeWidth: 2.4,
        ),
      ),
      error: (err, _) => _ErrorState(
        message: err.toString(),
        cardColor: cardColor,
        titleColor: titleColor,
        muted: muted,
      ),
      data: (results) {
        if (results.isEmpty) {
          return _NoResults(query: query, titleColor: titleColor, muted: muted);
        }
        return _SearchResultsList(
          results: results,
          cardColor: cardColor,
          titleColor: titleColor,
          muted: muted,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle state — quick categories + recent (none in this case)
// ─────────────────────────────────────────────────────────────────────────────

class _IdleSearch extends StatelessWidget {
  const _IdleSearch({
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  static const _quickLinks = [
    _QuickLink(Iconography.bible, 'Bible Reader', RouteNames.bible),
    _QuickLink(Iconography.sermon, 'Sermons', RouteNames.sermons),
    _QuickLink(Iconography.devotional, 'Devotionals', RouteNames.devotionals),
    _QuickLink(Iconography.events, 'Events', RouteNames.events),
    _QuickLink(Iconography.prayer, 'Prayer Wall', RouteNames.prayerFeed),
    _QuickLink(
      Iconography.giving,
      'Giving',
      RouteNames.giving,
      opensDonationPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      children: [
        Text(
          'Browse',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: _quickLinks.length,
          itemBuilder: (_, i) {
            final link = _quickLinks[i];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                onTap: () {
                  if (link.opensDonationPage) {
                    openDonationPage(context);
                  } else {
                    context.push(link.route);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.goldContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Icon(
                          link.icon,
                          color: AppColors.goldDark,
                          size: AppSpacing.iconMd,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        link.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (40 * i).ms, duration: 240.ms).scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1, 1),
                );
          },
        ),
      ],
    );
  }
}

class _QuickLink {
  const _QuickLink(
    this.icon,
    this.label,
    this.route, {
    this.opensDonationPage = false,
  });
  final IconData icon;
  final String label;
  final String route;

  /// When true, tapping this quick link opens the hosted donation page
  /// in the device's external browser instead of pushing [route].
  final bool opensDonationPage;
}

// ─────────────────────────────────────────────────────────────────────────────
// Results — grouped list
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.results,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });

  final GlobalSearchResults results;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  static const _kindOrder = [
    SearchResultKind.sermon,
    SearchResultKind.event,
    SearchResultKind.devotional,
    SearchResultKind.prayer,
    SearchResultKind.news,
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = results.grouped();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.massive,
      ),
      itemCount: _kindOrder.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              '${results.total} result${results.total == 1 ? '' : 's'} for "${results.query}"',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          );
        }
        final kind = _kindOrder[i - 1];
        final items = grouped[kind];
        if (items == null || items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: _ResultGroup(
            kind: kind,
            items: items,
            cardColor: cardColor,
            titleColor: titleColor,
            muted: muted,
          ),
        );
      },
    );
  }
}

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({
    required this.kind,
    required this.items,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });
  final SearchResultKind kind;
  final List<SearchResultItem> items;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final meta = _meta(kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(meta.icon, color: meta.fg, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                meta.label,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '· ${items.length}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ResultCard(
              item: item,
              cardColor: cardColor,
              titleColor: titleColor,
              muted: muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.item,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });
  final SearchResultItem item;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        child: Image.network(
                          item.imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _meta(item.kind).icon,
                            color: AppColors.goldDark,
                          ),
                        ),
                      )
                    : Icon(
                        _meta(item.kind).icon,
                        color: AppColors.goldDark,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    switch (item.kind) {
      case SearchResultKind.sermon:
        context.push(RouteNames.sermonDetails.replaceAll(':id', item.id));
      case SearchResultKind.event:
        context.push(RouteNames.eventDetail.replaceAll(':id', item.id));
      case SearchResultKind.devotional:
        context.push('${RouteNames.devotionalReader}/${item.id}');
      case SearchResultKind.prayer:
        context.push(RouteNames.prayerFeed);
      case SearchResultKind.news:
        // The news_announcements screen uses `state.extra` — fall back to
        // pushing the listing screen for now.
        context.push(RouteNames.news);
      case SearchResultKind.member:
      case SearchResultKind.page:
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / error / loading helpers
// ─────────────────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.titleColor,
    required this.muted,
  });
  final String query;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.goldContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconography.search,
                color: AppColors.goldDark,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different keyword — search works across\nsermons, events, devotionals, prayer and news.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.cardColor,
    required this.titleColor,
    required this.muted,
  });
  final String message;
  final Color cardColor;
  final Color titleColor;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.goldDark,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Search unavailable',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We couldn’t reach the server. Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kind metadata
// ─────────────────────────────────────────────────────────────────────────────

class _KindMeta {
  const _KindMeta(this.icon, this.bg, this.fg, this.label);
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
}

_KindMeta _meta(SearchResultKind kind) {
  switch (kind) {
    case SearchResultKind.sermon:
      return const _KindMeta(
        Iconography.sermon,
        Color(0xFFEDE9FE),
        Color(0xFF6D28D9),
        'Sermons',
      );
    case SearchResultKind.event:
      return const _KindMeta(
        Iconography.calendar,
        AppColors.goldContainer,
        AppColors.goldDark,
        'Events',
      );
    case SearchResultKind.devotional:
      return const _KindMeta(
        Iconography.devotional,
        Color(0xFFFEF3C7),
        Color(0xFFB45309),
        'Devotionals',
      );
    case SearchResultKind.prayer:
      return const _KindMeta(
        Iconography.prayer,
        Color(0xFFE0F2FE),
        Color(0xFF0369A1),
        'Prayer',
      );
    case SearchResultKind.news:
      return const _KindMeta(
        Iconography.announcement,
        Color(0xFFDCFCE7),
        Color(0xFF166534),
        'News',
      );
    case SearchResultKind.member:
      return const _KindMeta(
        Iconography.userAvatar,
        Color(0xFFF1F5F9),
        AppColors.navy,
        'Members',
      );
    case SearchResultKind.page:
      return const _KindMeta(
        Iconography.favorite,
        Color(0xFFF1F5F9),
        AppColors.navy,
        'Pages',
      );
  }
}
