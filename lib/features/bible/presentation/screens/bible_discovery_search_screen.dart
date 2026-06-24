import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_engagement_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Kingdom Heirs — Scripture Discovery / Search
///
/// Theme-aware search screen. Uses the same palette as the reader so a
/// Royal Dark / Sepia / Royal Light / Midnight theme is honoured here too.
/// Renders search results as gold-accent cards.
class BibleDiscoverySearchScreen extends ConsumerStatefulWidget {
  const BibleDiscoverySearchScreen({super.key});

  @override
  ConsumerState<BibleDiscoverySearchScreen> createState() =>
      _BibleDiscoverySearchScreenState();
}

class _BibleDiscoverySearchScreenState
    extends ConsumerState<BibleDiscoverySearchScreen> {
  final _controller = SearchController();
  String _searchQuery = '';

  final _popular = const [
    {'ref': 'John 3:16', 'text': 'For God so loved the world…'},
    {'ref': 'Philippians 4:13', 'text': 'I can do all things through Christ…'},
    {'ref': 'Jeremiah 29:11', 'text': 'For I know the plans I have for you…'},
    {'ref': 'Psalm 23:1', 'text': 'The Lord is my shepherd…'},
    {'ref': 'Romans 8:28', 'text': 'And we know that in all things God works…'},
  ];

  void _search(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    final palette = BibleReaderPalette.of(settings.theme);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              palette: palette,
              controller: _controller,
              onChanged: _search,
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
                  ? _SearchResults(
                      palette: palette,
                      query: _searchQuery,
                    )
                  : _PopularVerses(
                      palette: palette,
                      verses: _popular,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.controller,
    required this.onChanged,
    required this.onBack,
  });

  final BibleReaderPalette palette;
  final SearchController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

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
                    width: AppSpacing.iconLg + AppSpacing.sm,
                    height: AppSpacing.iconLg + AppSpacing.sm,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: palette.foreground,
                      size: AppSpacing.iconSm,
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
                        color: palette.accent,
                        letterSpacing: 2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Search Scripture',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: palette.foreground,
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
              color: palette.surface,
              borderRadius: AppRadius.brLg,
              border: Border.all(color: palette.divider),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: palette.foregroundMuted,
                  size: AppSpacing.iconSm + 2,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: onChanged,
                    cursorColor: palette.accent,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: palette.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Word, phrase or reference',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: palette.foregroundMuted,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.palette, required this.query});

  final BibleReaderPalette palette;
  final String query;

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
          child: Text(
            'Error: $err',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: palette.foregroundMuted,
            ),
          ),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: palette.foregroundMuted,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No results for "$query"',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Try a different word or a full reference like "John 3".',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: palette.foregroundMuted,
                  ),
                ),
              ],
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
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final r = results[i];
            return _ResultCard(
              palette: palette,
              ref: r['ref'] ?? '',
              html: r['text'] ?? '',
              index: i,
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
    required this.ref,
    required this.html,
    required this.index,
  });

  final BibleReaderPalette palette;
  final String ref;
  final String html;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 16,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: AppRadius.brFull,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                ref.toUpperCase(),
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: palette.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Html(
            data: html,
            style: {
              'body': Style(
                color: palette.foreground,
                fontSize: FontSize(15),
                lineHeight: const LineHeight(1.6),
              ),
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: AppMotion.standard,
        )
        .slideY(
          begin: 0.06,
          end: 0,
          curve: AppMotion.decelerate,
        );
  }
}

class _PopularVerses extends StatelessWidget {
  const _PopularVerses({required this.palette, required this.verses});

  final BibleReaderPalette palette;
  final List<Map<String, String>> verses;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: AppRadius.brFull,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'INSPIRATION',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: palette.accent,
                  letterSpacing: 2,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Popular verses',
            style: GoogleFonts.playfairDisplay(
              color: palette.foreground,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...verses.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: AppRadius.brLg,
                  border: Border.all(color: palette.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: palette.accentSoft,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Text(
                        v['ref']!,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: palette.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        v['text']!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: palette.foreground,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: palette.foregroundMuted,
                      size: 12,
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 80 * i),
                  duration: AppMotion.standard,
                )
                .slideY(
                  begin: 0.04,
                  end: 0,
                  curve: AppMotion.decelerate,
                );
          }),
        ],
      ),
    );
  }
}
