import 'dart:convert';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleLocalCache {
  BibleLocalCache(this._prefs);
  final SharedPreferences _prefs;

  static const _booksKey = 'bible_books';
  static const _chaptersKeyPrefix = 'bible_chapters_';
  static const _contentKeyPrefix = 'bible_content_';

  // Books
  Future<void> cacheBooks(String bibleId, List<BibleBook> books) async {
    final jsonList = books
        .map(
          (b) => {
            'id': b.id,
            'bibleId': b.bibleId,
            'abbreviation': b.abbreviation,
            'name': b.name,
            'nameLong': b.nameLong,
          },
        )
        .toList();
    await _prefs.setString('${_booksKey}_$bibleId', jsonEncode(jsonList));
  }

  List<BibleBook>? getCachedBooks(String bibleId) {
    final str = _prefs.getString('${_booksKey}_$bibleId');
    if (str == null) return null;
    final list = jsonDecode(str) as List<dynamic>;
    return list
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Chapters
  Future<void> cacheChapters(
      String bibleId, String bookId, List<BibleChapter> chapters,) async {
    final jsonList = chapters
        .map(
          (c) => {
            'id': c.id,
            'bibleId': c.bibleId,
            'bookId': c.bookId,
            'number': c.number,
            'reference': c.reference,
          },
        )
        .toList();
    await _prefs.setString(
        '$_chaptersKeyPrefix${bibleId}_$bookId', jsonEncode(jsonList),);
  }

  List<BibleChapter>? getCachedChapters(String bibleId, String bookId) {
    final str = _prefs.getString('$_chaptersKeyPrefix${bibleId}_$bookId');
    if (str == null) return null;
    final list = jsonDecode(str) as List<dynamic>;
    return list
        .map((e) => BibleChapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Content
  Future<void> cacheContent(
      String bibleId, String chapterId, BibleChapterContent content,) async {
    final map = {
      'id': content.id,
      'bibleId': content.bibleId,
      'number': content.number,
      'bookId': content.bookId,
      'reference': content.reference,
      'content': content.content,
    };
    await _prefs.setString(
        '$_contentKeyPrefix${bibleId}_$chapterId', jsonEncode(map),);
  }

  BibleChapterContent? getCachedContent(String bibleId, String chapterId) {
    final str = _prefs.getString('$_contentKeyPrefix${bibleId}_$chapterId');
    if (str == null) return null;
    final map = jsonDecode(str) as Map<String, dynamic>;
    return BibleChapterContent.fromJson(map);
  }
}
