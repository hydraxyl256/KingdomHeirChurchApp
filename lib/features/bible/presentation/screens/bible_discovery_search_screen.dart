import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_engagement_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Kingdom Heirs — Scripture Discovery / Search
///
/// Uses reference-based search via the YouVersion Platform API.
/// The idle state shows Recent Searches (from local cache) or quick-start
/// prompts — never fake/hardcoded scripture text.
class BibleDiscoverySearchScreen extends ConsumerStatefulWidget {
  const BibleDiscoverySearchScreen({super.key});

  @override
  ConsumerState<BibleDiscoverySearchScreen> createState() =>
      _BibleDiscoverySearchScreenState();
}

class _BibleDiscoverySearchScreenState
    extends ConsumerState<BibleDiscoverySearchScreen> {
  final _controller = TextEditingController();
  String _searchQuery = '';

  // Quick-start prompts shown when no recent searches exist.
  // These are reference labels only — no fake scripture text.
  static const _quickStart = [
    'John 3:16',
    'Romans 8',
    'Psalm 23',
    'Genesis 1',
    'Philippians 4:13',
    'Isaiah 40:31',
    'Matthew 5',
    'Revelation 1',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    final q = query.trim();
    setState(() => _searchQuery = q);
    if (q.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).add(q);
    }
  }

  void _selectPrompt(String prompt) {
    _controller.text = prompt;
    _search(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    final palette  = BibleReaderPalette.of(settings.theme);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              palette:    palette,
              controller: _controller,
              onChanged:  _search,
              onClear: () {
                _controller.clear();
                setState(() => _searchQuery = '');
              },
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(RouteNames.bible);
                }
              },
            ),
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _SearchResults(palette: palette, query: _searchQuery)
                  : _IdleView(
                      palette:        palette,
                      quickStart:     _quickStart,
                      onSelect:       _selectPrompt,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header with search field
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.controller,
    required this.onChanged,
    required this.onBack,
    required this.onClear,
  });

  final BibleReaderPalette    palette;
  final TextEditingController controller;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onBack;
  final VoidCallback          onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: palette.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width:  AppSpacing.iconLg + AppSpacing.sm,
                    height: AppSpacing.iconLg + AppSpacing.sm,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: palette.foreground,
                      size:  AppSpacing.iconSm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DISCOVERY',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color:        palette.accent,
                        letterSpacing: 2,
                        fontSize:      10,
                        fontWeight:    FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Search Scripture',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color:      palette.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color:        palette.surface,
              borderRadius: AppRadius.brLg,
              border:       Border.all(color: palette.divider),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical:   AppSpacing.xxs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: palette.foregroundMuted,
                  size:  AppSpacing.iconSm + 2,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus:  true,
                    onChanged:  onChanged,
                    onSubmitted: onChanged,
                    cursorColor: palette.accent,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: palette.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. John 3:16 · Romans 8 · Psalm 23',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color:      palette.foregroundMuted,
                        fontStyle:  FontStyle.italic,
                      ),
                      border:  InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear_rounded,
                      color: palette.foregroundMuted,
                      size:  AppSpacing.iconSm,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter a book name, chapter, or verse reference.',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: palette.foregroundMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle view — recent searches + quick-start prompts
// ─────────────────────────────────────────────────────────────────────────────

class _IdleView extends ConsumerWidget {
  const _IdleView({
    required this.palette,
    required this.quickStart,
    required this.onSelect,
  });

  final BibleReaderPalette palette;
  final List<String>       quickStart;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (recents.isNotEmpty) ...[
            _SectionHeader(palette: palette, label: 'RECENT SEARCHES'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: recents
                  .asMap()
                  .entries
                  .map((e) => _PromptChip(
                        palette:  palette,
                        label:    e.value,
                        icon:     Icons.history_rounded,
                        index:    e.key,
                        onTap:    () => onSelect(e.value),
                      ),)
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(palette: palette, label: 'QUICK START'),
                GestureDetector(
                  onTap: () =>
                      ref.read(recentSearchesProvider.notifier).clear(),
                  child: Text(
                    'Clear history',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: palette.foregroundMuted,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _SectionHeader(palette: palette, label: 'QUICK START'),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Tap a reference to open it instantly',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: palette.foregroundMuted,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: quickStart
                .asMap()
                .entries
                .map((e) => _PromptChip(
                      palette: palette,
                      label:   e.value,
                      icon:    Icons.menu_book_rounded,
                      index:   e.key,
                      onTap:   () => onSelect(e.value),
                    ),)
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.palette, required this.label});

  final BibleReaderPalette palette;
  final String             label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width:  6,
          height: 18,
          decoration: BoxDecoration(
            color:        palette.accent,
            borderRadius: AppRadius.brFull,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color:         palette.accent,
            letterSpacing: 2,
            fontSize:      10,
            fontWeight:    FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.palette,
    required this.label,
    required this.icon,
    required this.index,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final String             label;
  final IconData           icon;
  final int                index;
  final VoidCallback       onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:        palette.surface,
          borderRadius: AppRadius.brFull,
          border:       Border.all(color: palette.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.accent, size: 14),
            const SizedBox(width: AppSpacing.xxs + 2),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color:      palette.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay:    Duration(milliseconds: 40 * index),
          duration: AppMotion.standard,
        )
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Results — live YouVersion API results
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.palette, required this.query});

  final BibleReaderPalette palette;
  final String             query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(bibleSearchProvider(query));
    return searchAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: palette.accent),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: palette.foregroundMuted,
                size:  40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Could not load results',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color:      palette.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                err.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: palette.foregroundMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () => ref.invalidate(bibleSearchProvider(query)),
                icon:  Icon(Icons.refresh_rounded, color: palette.accent),
                label: Text(
                  'Retry',
                  style: TextStyle(color: palette.accent),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: palette.foregroundMuted,
                    size:  40,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No results for "$query"',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color:      palette.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Try a book + chapter reference.\nExamples: "John 3", "Romans 8", "Psalm 23:1"',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: palette.foregroundMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          itemCount:        results.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final r = results[i];
            return _ResultCard(
              palette:  palette,
              result:   r,
              index:    i,
              onTap: () {
                // Navigate to the chapter in the reader
                ref
                    .read(bibleNavigationProvider.notifier)
                    .navigateToChapter(r.chapterId);
                context.go(RouteNames.bible);
              },
            );
          },
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.palette,
    required this.result,
    required this.index,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final BibleSearchResult  result;
  final int                index;
  final VoidCallback       onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:        palette.surface,
          borderRadius: AppRadius.brLg,
          border:       Border.all(color: palette.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width:  6,
                  height: 16,
                  decoration: BoxDecoration(
                    color:        palette.accent,
                    borderRadius: AppRadius.brFull,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    result.ref.toUpperCase(),
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color:         palette.accent,
                      fontWeight:    FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.foregroundMuted,
                  size:  12,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Html(
              data: result.text,
              style: {
                'body': Style(
                  color:       palette.foreground,
                  fontSize:    FontSize(15),
                  lineHeight:  const LineHeight(1.6),
                  margin:      Margins.zero,
                ),
              },
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            delay:    Duration(milliseconds: 50 * index),
            duration: AppMotion.standard,
          )
          .slideY(
            begin: 0.06,
            end:   0,
            curve: AppMotion.decelerate,
          ),
    );
  }
}
