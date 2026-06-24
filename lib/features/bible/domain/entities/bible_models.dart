import 'package:equatable/equatable.dart';

class BibleBook extends Equatable {
  const BibleBook({
    required this.id,
    required this.bibleId,
    required this.abbreviation,
    required this.name,
    required this.nameLong,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'] as String,
      bibleId: json['bibleId'] as String,
      abbreviation: json['abbreviation'] as String,
      name: json['name'] as String,
      nameLong: json['nameLong'] as String,
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

class BibleChapter extends Equatable {
  const BibleChapter({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.number,
    required this.reference,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      id: json['id'] as String,
      bibleId: json['bibleId'] as String,
      bookId: json['bookId'] as String,
      number: json['number'] as String,
      reference: json['reference'] as String,
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

class BibleChapterContent extends Equatable {
  const BibleChapterContent({
    required this.id,
    required this.bibleId,
    required this.number,
    required this.bookId,
    required this.reference,
    required this.content,
  }); // HTML content from API

  factory BibleChapterContent.fromJson(Map<String, dynamic> json) {
    return BibleChapterContent(
      id: json['id'] as String,
      bibleId: json['bibleId'] as String,
      number: json['number'] as String,
      bookId: json['bookId'] as String,
      reference: json['reference'] as String,
      content: json['content'] as String,
    );
  }

  final String id;
  final String bibleId;
  final String number;
  final String bookId;
  final String reference;
  final String content;

  @override
  List<Object?> get props => [id, bibleId, number, bookId, reference, content];
}

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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bibleVersionId: json['bible_version_id'] as String,
      bookId: json['book_id'] as String,
      chapterId: json['chapter_id'] as String,
      verseId: json['verse_id'] as String,
      referenceText: json['reference_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String bibleVersionId;
  final String bookId;
  final String chapterId;
  final String verseId;
  final String referenceText;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        bibleVersionId,
        bookId,
        chapterId,
        verseId,
        referenceText,
        createdAt,
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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bibleVersionId: json['bible_version_id'] as String,
      verseId: json['verse_id'] as String,
      colorHex: json['color_hex'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String bibleVersionId;
  final String verseId;
  final String colorHex;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, userId, bibleVersionId, verseId, colorHex, createdAt];
}
