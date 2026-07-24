import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:kingdom_heir/features/bible/presentation/providers/bible_provider.dart';
import 'package:kingdom_heir/features/bible/presentation/theme/bible_reader_palette.dart';

/// Draggable bottom sheet that lets the user pick a book and a chapter.
///
/// Designed for the reader — fully responsive:
///   • 320–599 px: two-tab book grid (OT/NT), chapter grid below.
///   • ≥ 600 px: side-by-side book list + chapter grid.
///
/// On the caller's side:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   useSafeArea: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => BibleChapterPickerSheet(
///     palette: palette,
///     currentBookId: ...,
///     currentChapter: ...,
///     onPicked: (bookId, chapterNumber) { ... },
///   ),
/// );
/// ```
class BibleChapterPickerSheet extends ConsumerStatefulWidget {
  const BibleChapterPickerSheet({
    required this.palette,
    required this.currentBookId,
    required this.currentChapter,
    required this.onPicked,
    super.key,
  });

  final BibleReaderPalette palette;
  final String currentBookId;
  final int currentChapter;
  final void Function(String bookId, int chapterNumber) onPicked;

  static Future<void> show({
    required BuildContext context,
    required BibleReaderPalette palette,
    required String currentBookId,
    required int currentChapter,
    required void Function(String bookId, int chapterNumber) onPicked,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BibleChapterPickerSheet(
        palette: palette,
        currentBookId: currentBookId,
        currentChapter: currentChapter,
        onPicked: onPicked,
      ),
    );
  }

  @override
  ConsumerState<BibleChapterPickerSheet> createState() =>
      _BibleChapterPickerSheetState();
}

class _BibleChapterPickerSheetState
    extends ConsumerState<BibleChapterPickerSheet> {
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    _selectedBookId = widget.currentBookId;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 600;
    final booksAsync = ref.watch(bibleBooksProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return AnimatedPadding(
          duration: AppMotion.standard,
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: widget.palette.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
              border: Border(
                top: BorderSide(color: widget.palette.accentSoft),
              ),
            ),
            child: Column(
              children: [
                _SheetHandle(palette: widget.palette),
                _Header(
                  palette: widget.palette,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: booksAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: widget.palette.accent,
                      ),
                    ),
                    error: (e, _) => _Error(
                      palette: widget.palette,
                      message: bibleFriendlyErrorMessage(e),
                    ),
                    data: (books) {
                      final selected = books.firstWhere(
                        (b) => b.id == _selectedBookId,
                        orElse: () => books.first,
                      );
                      return isWide
                          ? _WideLayout(
                              palette: widget.palette,
                              books: books,
                              selected: selected,
                              currentChapter: widget.currentChapter,
                              scrollController: scrollController,
                              onBookPicked: (b) =>
                                  setState(() => _selectedBookId = b.id),
                              onChapterPicked: (c) {
                                widget.onPicked(selected.id, c);
                                Navigator.of(context).pop();
                              },
                            )
                          : _NarrowLayout(
                              palette: widget.palette,
                              books: books,
                              selected: selected,
                              currentChapter: widget.currentChapter,
                              scrollController: scrollController,
                              onBookPicked: (b) =>
                                  setState(() => _selectedBookId = b.id),
                              onChapterPicked: (c) {
                                widget.onPicked(selected.id, c);
                                Navigator.of(context).pop();
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.palette});

  final BibleReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      width: AppSpacing.sheetHandleWidth,
      height: AppSpacing.sheetHandleHeight,
      decoration: BoxDecoration(
        color: palette.divider,
        borderRadius: AppRadius.brFull,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.onClose});

  final BibleReaderPalette palette;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: AppRadius.brFull,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASSAGE LIBRARY',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: palette.accent,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose book & chapter',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: palette.foregroundMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.palette, required this.message});

  final BibleReaderPalette palette;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: palette.foregroundMuted,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
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
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.palette,
    required this.books,
    required this.selected,
    required this.currentChapter,
    required this.scrollController,
    required this.onBookPicked,
    required this.onChapterPicked,
  });

  final BibleReaderPalette palette;
  final List<BibleBook> books;
  final BibleBook selected;
  final int currentChapter;
  final ScrollController scrollController;
  final ValueChanged<BibleBook> onBookPicked;
  final ValueChanged<int> onChapterPicked;

  @override
  Widget build(BuildContext context) {
    // Better UX on narrow screens: Book list on top half, Chapters on bottom half
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _BookList(
            palette: palette,
            books: books,
            selected: selected,
            onPicked: onBookPicked,
          ),
        ),
        Divider(height: 1, thickness: 1, color: palette.divider),
        Expanded(
          flex: 6,
          child: _ChapterGrid(
            palette: palette,
            book: selected,
            currentChapter: currentChapter,
            onPicked: onChapterPicked,
            controller: scrollController,
          ),
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.palette,
    required this.books,
    required this.selected,
    required this.currentChapter,
    required this.scrollController,
    required this.onBookPicked,
    required this.onChapterPicked,
  });

  final BibleReaderPalette palette;
  final List<BibleBook> books;
  final BibleBook selected;
  final int currentChapter;
  final ScrollController scrollController;
  final ValueChanged<BibleBook> onBookPicked;
  final ValueChanged<int> onChapterPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: _BookList(
            palette: palette,
            books: books,
            selected: selected,
            onPicked: onBookPicked,
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: palette.divider,
        ),
        Expanded(
          child: _ChapterGrid(
            palette: palette,
            book: selected,
            currentChapter: currentChapter,
            onPicked: onChapterPicked,
            controller: scrollController,
          ),
        ),
      ],
    );
  }
}


class _BookList extends StatelessWidget {
  const _BookList({
    required this.palette,
    required this.books,
    required this.selected,
    required this.onPicked,
  });

  final BibleReaderPalette palette;
  final List<BibleBook> books;
  final BibleBook selected;
  final ValueChanged<BibleBook> onPicked;

  @override
  Widget build(BuildContext context) {
    final otBooks = books.take(39).toList();
    final ntBooks = books.skip(39).toList();

    return CustomScrollView(
      slivers: [
        _buildSectionHeader(context, 'Old Testament'),
        _buildBookList(otBooks),
        _buildSectionHeader(context, 'New Testament'),
        _buildBookList(ntBooks),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
        child: Text(
          title.toUpperCase(),
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: palette.accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(List<BibleBook> sectionBooks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final book = sectionBooks[i];
          final isSel = book.id == selected.id;
          return Material(
            color: Colors.transparent,
          child: InkWell(
            onTap: () => onPicked(book),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSel ? palette.accentSoft : null,
                border: Border(
                  left: BorderSide(
                    color: isSel ? palette.accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    book.abbreviation,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isSel ? palette.accent : palette.foregroundMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      book.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: isSel
                            ? palette.foreground
                            : palette.foregroundMuted,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        },
        childCount: sectionBooks.length,
      ),
    );
  }
}


class _ChapterGrid extends ConsumerWidget {
  const _ChapterGrid({
    required this.palette,
    required this.book,
    required this.currentChapter,
    required this.onPicked,
    required this.controller,
  });

  final BibleReaderPalette palette;
  final BibleBook book;
  final int currentChapter;
  final ValueChanged<int> onPicked;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(bibleChaptersProvider(book.id));

    return chaptersAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: palette.accent),
      ),
      error: (e, _) => Center(
        child: Text(
          bibleFriendlyErrorMessage(e),
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.foregroundMuted),
        ),
      ),
      data: (chapters) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    book.nameLong.toUpperCase(),
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: palette.accent,
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${chapters.length} chapters',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: palette.foregroundMuted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 56,
                  mainAxisSpacing: AppSpacing.xs,
                  crossAxisSpacing: AppSpacing.xs,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, i) {
                  final n = int.tryParse(chapters[i].number) ?? (i + 1);
                  final isCurrent = n == currentChapter;
                  return _ChapterTile(
                    palette: palette,
                    number: n,
                    isCurrent: isCurrent,
                    onTap: () => onPicked(n),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.palette,
    required this.number,
    required this.isCurrent,
    required this.onTap,
  });

  final BibleReaderPalette palette;
  final int number;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isCurrent,
      label: 'Chapter $number',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brMd,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.decelerate,
            decoration: BoxDecoration(
              color: isCurrent ? palette.accent : palette.surfaceMuted,
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: isCurrent ? palette.accent : palette.divider,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: isCurrent ? AppColors.ink : palette.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
