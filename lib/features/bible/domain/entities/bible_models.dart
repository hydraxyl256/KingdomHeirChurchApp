import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bible Version (YouVersion /bibles response)
// ─────────────────────────────────────────────────────────────────────────────

class BibleVersion extends Equatable {
  const BibleVersion({
    required this.id,
    required this.title,
    required this.abbreviation,
    required this.language,
    this.audioBibles = const [],
  });

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id:           json['id'] as int,
      title:        json['local_title'] as String? ??
                    json['title'] as String? ?? '',
      abbreviation: json['local_abbreviation'] as String? ??
                    json['abbreviation'] as String? ?? '',
      language:     json['language'] as String? ?? 'eng',
    );
  }

  final int    id;
  final String title;
  final String abbreviation;
  final String language;
  final List<String> audioBibles;

  @override
  List<Object?> get props => [id, abbreviation, language];
}

// ─────────────────────────────────────────────────────────────────────────────
// Bible Book
// ─────────────────────────────────────────────────────────────────────────────

class BibleBook extends Equatable {
  const BibleBook({
    required this.id,
    required this.bibleId,
    required this.abbreviation,
    required this.name,
    required this.nameLong,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    // YouVersion response uses 'usfm' as the book ID and 'human' or 'name' for the name
    final usfm = json['usfm'] as String? ?? json['id'] as String? ?? '';
    final name = json['human'] as String? ??
                 json['name'] as String? ??
                 json['local_abbreviation'] as String? ?? usfm;
    return BibleBook(
      id:           usfm,
      bibleId:      (json['version_id'] ?? json['bibleId'] ?? '').toString(),
      abbreviation: json['local_abbreviation'] as String? ??
                    json['abbreviation'] as String? ?? usfm,
      name:         name,
      nameLong:     json['human_long'] as String? ??
                    json['nameLong'] as String? ?? name,
    );
  }

  final String id;
  final String bibleId;
  final String abbreviation;
  final String name;
  final String nameLong;

  @override
  List<Object?> get props => [id, bibleId, abbreviation, name, nameLong];
}

// ─────────────────────────────────────────────────────────────────────────────
// Bible Chapter (metadata — used for the chapter picker)
// ─────────────────────────────────────────────────────────────────────────────

class BibleChapter extends Equatable {
  const BibleChapter({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.number,
    required this.reference,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    // YouVersion: chapter list entry looks like {"usfm":"GEN.1","human":"Genesis 1","version_id":1}
    final usfm = json['usfm'] as String? ?? json['id'] as String? ?? '';
    final parts = usfm.split('.');
    final number = parts.length >= 2 ? parts[1] : usfm;
    return BibleChapter(
      id:        usfm,
      bibleId:   (json['version_id'] ?? json['bibleId'] ?? '').toString(),
      bookId:    parts.isNotEmpty ? parts[0] : usfm,
      number:    number,
      reference: json['human'] as String? ??
                 json['reference'] as String? ?? usfm,
    );
  }

  final String id;
  final String bibleId;
  final String bookId;
  final String number;
  final String reference;

  @override
  List<Object?> get props => [id, bibleId, bookId, number, reference];
}

// ─────────────────────────────────────────────────────────────────────────────
// Bible Chapter Content (HTML returned by YouVersion passages endpoint)
// ─────────────────────────────────────────────────────────────────────────────

class BibleChapterContent extends Equatable {
  const BibleChapterContent({
    required this.id,
    required this.bibleId,
    required this.number,
    required this.bookId,
    required this.reference,
    required this.content,
    this.nextChapterId,
    this.previousChapterId,
  });

  factory BibleChapterContent.fromJson(Map<String, dynamic> json) {
    // YouVersion passage response:
    // { "data": { "reference": {"usfm":"GEN.1","human":"Genesis 1","version_id":1},
    //             "content": "<div>...</div>",
    //             "next":     {"usfm":"GEN.2","human":"Genesis 2"},
    //             "previous": {"usfm":"...","human":"..."} } }
    final ref  = json['reference'] as Map<String, dynamic>? ?? json;
    final usfm = ref['usfm'] as String? ?? json['id'] as String? ?? '';
    final parts = usfm.split('.');
    final bookId = parts.isNotEmpty ? parts[0] : '';
    final number = parts.length >= 2 ? parts[1] : usfm;

    final nextMap = json['next'] as Map<String, dynamic>?;
    final prevMap = json['previous'] as Map<String, dynamic>?;

    return BibleChapterContent(
      id:                usfm,
      bibleId:           (ref['version_id'] ?? json['bibleId'] ?? '').toString(),
      number:            number,
      bookId:            bookId,
      reference:         ref['human'] as String? ??
                         json['reference'] as String? ?? usfm,
      content:           json['content'] as String? ?? '',
      nextChapterId:     nextMap?['usfm'] as String?,
      previousChapterId: prevMap?['usfm'] as String?,
    );
  }

  final String  id;
  final String  bibleId;
  final String  number;
  final String  bookId;
  final String  reference;
  final String  content;
  // Navigation hints from YouVersion — used for Prev/Next chapter buttons
  final String? nextChapterId;
  final String? previousChapterId;

  @override
  List<Object?> get props =>
      [id, bibleId, number, bookId, reference, content];
}

// ─────────────────────────────────────────────────────────────────────────────
// Bible Search Result (reference-based, since YouVersion has no keyword search)
// ─────────────────────────────────────────────────────────────────────────────

class BibleSearchResult extends Equatable {
  const BibleSearchResult({
    required this.ref,
    required this.text,
    required this.chapterId,
  });

  final String ref;
  final String text;
  final String chapterId;

  @override
  List<Object?> get props => [ref, chapterId];
}

// ─────────────────────────────────────────────────────────────────────────────
// User data — Bookmarks & Highlights (Supabase-backed)
// ─────────────────────────────────────────────────────────────────────────────

class BibleBookmark extends Equatable {
  const BibleBookmark({
    required this.id,
    required this.userId,
    required this.bibleVersionId,
    required this.bookId,
    required this.chapterId,
    required this.verseId,
    required this.referenceText,
    required this.createdAt,
  });

  factory BibleBookmark.fromJson(Map<String, dynamic> json) {
    return BibleBookmark(
      id:             json['id'] as String,
      userId:         json['user_id'] as String,
      bibleVersionId: json['bible_version_id'] as String,
      bookId:         json['book_id'] as String,
      chapterId:      json['chapter_id'] as String,
      verseId:        json['verse_id'] as String,
      referenceText:  json['reference_text'] as String,
      createdAt:      DateTime.parse(json['created_at'] as String),
    );
  }

  final String   id;
  final String   userId;
  final String   bibleVersionId;
  final String   bookId;
  final String   chapterId;
  final String   verseId;
  final String   referenceText;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id, userId, bibleVersionId, bookId,
        chapterId, verseId, referenceText, createdAt,
      ];
}

class BibleHighlight extends Equatable {
  const BibleHighlight({
    required this.id,
    required this.userId,
    required this.bibleVersionId,
    required this.verseId,
    required this.colorHex,
    required this.createdAt,
  });

  factory BibleHighlight.fromJson(Map<String, dynamic> json) {
    return BibleHighlight(
      id:             json['id'] as String,
      userId:         json['user_id'] as String,
      bibleVersionId: json['bible_version_id'] as String,
      verseId:        json['verse_id'] as String,
      colorHex:       json['color_hex'] as String,
      createdAt:      DateTime.parse(json['created_at'] as String),
    );
  }

  final String   id;
  final String   userId;
  final String   bibleVersionId;
  final String   verseId;
  final String   colorHex;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, userId, bibleVersionId, verseId, colorHex, createdAt];
}
