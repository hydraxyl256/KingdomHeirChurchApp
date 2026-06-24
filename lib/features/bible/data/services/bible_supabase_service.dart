import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class BibleSupabaseService {
  BibleSupabaseService(this._client);
  final supabase.SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  // Bookmarks
  Future<Either<String, List<BibleBookmark>>> getBookmarks(
      String versionId,) async {
    try {
      final data = await _client
          .from('bible_bookmarks')
          .select()
          .eq('bible_version_id', versionId)
          .order('created_at', ascending: false);
      return right((data as List<dynamic>)
          .map((e) => BibleBookmark.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> addBookmark(BibleBookmark bookmark) async {
    try {
      await _client.from('bible_bookmarks').insert({
        'user_id': _userId,
        'bible_version_id': bookmark.bibleVersionId,
        'book_id': bookmark.bookId,
        'chapter_id': bookmark.chapterId,
        'verse_id': bookmark.verseId,
        'reference_text': bookmark.referenceText,
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> removeBookmark(String bookmarkId) async {
    try {
      await _client.from('bible_bookmarks').delete().eq('id', bookmarkId);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  // Highlights
  Future<Either<String, List<BibleHighlight>>> getHighlights(
      String versionId,) async {
    try {
      final data = await _client
          .from('bible_highlights')
          .select()
          .eq('bible_version_id', versionId);
      return right((data as List<dynamic>)
          .map((e) => BibleHighlight.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> addHighlight(BibleHighlight highlight) async {
    try {
      await _client.from('bible_highlights').upsert({
        'user_id': _userId,
        'bible_version_id': highlight.bibleVersionId,
        'verse_id': highlight.verseId,
        'color_hex': highlight.colorHex,
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, void>> removeHighlight(String highlightId) async {
    try {
      await _client.from('bible_highlights').delete().eq('id', highlightId);
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }

  // Reading History
  Future<Either<String, void>> updateReadingHistory(
      String versionId, String chapterId, int progressPercent,) async {
    try {
      await _client.from('bible_reading_history').upsert({
        'user_id': _userId,
        'bible_version_id': versionId,
        'chapter_id': chapterId,
        'progress_percent': progressPercent,
        'last_read_at': DateTime.now().toIso8601String(),
      });
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
