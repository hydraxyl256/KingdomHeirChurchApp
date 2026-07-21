import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/router/route_names.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_engagement_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Premium bookmarks list with filter chips, swipe-to-delete, and
/// segmented tabs (Bookmarks / Highlights / Notes).
class BibleBookmarksScreen extends ConsumerStatefulWidget {
  const BibleBookmarksScreen({super.key});

  @override
  ConsumerState<BibleBookmarksScreen> createState() =>
      _BibleBookmarksScreenState();
}

class _BibleBookmarksScreenState extends ConsumerState<BibleBookmarksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ReaderTheme _activeTheme = ReaderTheme.royalDark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    _activeTheme = settings.theme;
    final palette = BibleReaderPalette.of(_activeTheme);
    final booksAsync = ref.watch(bibleBooksProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              palette: palette,
              onBack: () => Navigator.of(context).pop(),
            ),
            _Tabs(
              palette: palette,
              controller: _tabController,
              tabs: const ['Bookmarks', 'Highlights', 'Notes'],
              counts: [
                ref.watch(bookmarksProvider).length,
                ref.watch(highlightsProvider).length,
                ref.watch(notesProvider).length,
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookmarksTab(palette: palette, booksAsync: booksAsync),
                  _HighlightsTab(palette: palette),
                  _NotesTab(palette: palette),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.onBack});

  final BibleReaderPalette palette;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _HeaderButton(
            palette: palette,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR TREASURY',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.accent,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bookmarks · Highlights · Notes',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
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

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.palette,
    required this.icon,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppSpacing.iconLg + AppSpacing.sm,
          height: AppSpacing.iconLg + AppSpacing.sm,
          child: Icon(icon, color: palette.foreground, size: AppSpacing.iconSm),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.palette,
    required this.controller,
    required this.tabs,
    required this.counts,
  });

  final BibleReaderPalette palette;
  final TabController controller;
  final List<String> tabs;
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.brFull,
        border: Border.all(color: palette.divider),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: palette.accent,
          borderRadius: AppRadius.brFull,
          boxShadow: AppElevation.shadowFor(AppElevation.level1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: AppColors.ink,
        unselectedLabelColor: palette.foregroundMuted,
        labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: List.generate(tabs.length, (i) {
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    tabs[i],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (counts[i] > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: controller.index == i
                          ? AppColors.ink.withValues(alpha: 0.18)
                          : palette.divider,
                      borderRadius: AppRadius.brFull,
                    ),
                    child: Text(
                      '${counts[i]}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: controller.index == i
                            ? AppColors.ink
                            : palette.foregroundMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab({required this.palette, required this.booksAsync});

  final BibleReaderPalette palette;
  final AsyncValue<dynamic> booksAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    if (bookmarks.isEmpty) {
      return _EmptyState(
        palette: palette,
        icon: Icons.bookmark_outline_rounded,
        title: 'No bookmarks yet',
        body: 'Tap the bookmark icon in the reader to save a passage '
            'for later.',
      );
    }
    final sorted = [...bookmarks]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final b = sorted[i];
        return Dismissible(
          key: ValueKey(b.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(bookmarksProvider.notifier).remove(b.id);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.error,
              borderRadius: AppRadius.brLg,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: AppSpacing.iconMd,
            ),
          ),
          child: _BookmarkCard(
            palette: palette,
            bookmark: b,
            onTap: () {
              ref.read(bibleNavigationProvider.notifier).navigate(
                    bookId: b.bookId,
                    chapterId: b.chapterId,
                  );
              context.go(RouteNames.bible);
            },
          ).animate().fadeIn(
                delay: Duration(milliseconds: 60 * i),
                duration: AppMotion.standard,
              ),
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.palette,
    required this.bookmark,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final BibleBookmarkLocal bookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: AppRadius.brLg,
            border: Border.all(color: palette.divider),
            boxShadow: AppElevation.shadowFor(AppElevation.level1),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.avatarSm,
                height: AppSpacing.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.accentSoft,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: palette.accent,
                  size: AppSpacing.iconSm,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.reference,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _format(bookmark.createdAt),
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: palette.foregroundMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: palette.foregroundMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 30) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}'
          '-${dt.day.toString().padLeft(2, '0')}';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _HighlightsTab extends ConsumerWidget {
  const _HighlightsTab({required this.palette});

  final BibleReaderPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightsProvider);
    if (highlights.isEmpty) {
      return _EmptyState(
        palette: palette,
        icon: Icons.brush_outlined,
        title: 'No highlights yet',
        body: 'Select a verse in the reader and choose a color '
            'to highlight it.',
      );
    }
    final sorted = [...highlights]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final h = sorted[i];
        return _HighlightCard(palette: palette, highlight: h).animate().fadeIn(
              delay: Duration(milliseconds: 60 * i),
              duration: AppMotion.standard,
            );
      },
    );
  }
}

class _HighlightCard extends ConsumerWidget {
  const _HighlightCard({required this.palette, required this.highlight});

  final BibleReaderPalette palette;
  final BibleHighlightLocal highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _hex(highlight.colorHex);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: palette.divider),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.brFull,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.verseId.replaceAll('.', ' ').toUpperCase(),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.accent,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Highlighted in '
                  '${_swatchName(highlight.colorHex)}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: palette.foregroundMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(highlightsProvider.notifier).remove(highlight.verseId),
            icon: Icon(
              Icons.close_rounded,
              color: palette.foregroundMuted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  static Color _hex(String s) {
    final clean = s.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  static String _swatchName(String hex) {
    for (final s in BibleHighlightPalette.all) {
      if (s.hex.toUpperCase() == hex.toUpperCase()) return s.label;
    }
    return 'Custom';
  }
}

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.palette});

  final BibleReaderPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    if (notes.isEmpty) {
      return _EmptyState(
        palette: palette,
        icon: Icons.edit_note_rounded,
        title: 'No notes yet',
        body: 'Tap a verse in the reader to write a private reflection.',
      );
    }
    final sorted = [...notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final n = sorted[i];
        return _NoteCard(palette: palette, note: n).animate().fadeIn(
              delay: Duration(milliseconds: 60 * i),
              duration: AppMotion.standard,
            );
      },
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.palette, required this.note});

  final BibleReaderPalette palette;
  final BibleNoteLocal note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: palette.divider),
        boxShadow: AppElevation.shadowFor(AppElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                note.reference,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: palette.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    ref.read(notesProvider.notifier).remove(note.id),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: palette.foregroundMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            note.body,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: palette.foreground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.palette,
    required this.icon,
    required this.title,
    required this.body,
  });

  final BibleReaderPalette palette;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: palette.accent,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: palette.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: palette.foregroundMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
