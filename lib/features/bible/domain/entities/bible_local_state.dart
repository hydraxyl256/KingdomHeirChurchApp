import 'package:equatable/equatable.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart'
    show BibleBookmark;

/// Local-only Bible engagement state (notes, highlights, bookmarks, plans,
/// settings). These live in SharedPreferences — they don't depend on
/// network calls.

/// Single highlight on a verse (verseId is `bookId.chapter.verse`).
class BibleHighlightLocal extends Equatable {
  const BibleHighlightLocal({
    required this.id,
    required this.verseId,
    required this.colorHex,
    required this.createdAt,
  });

  factory BibleHighlightLocal.fromJson(Map<String, dynamic> json) =>
      BibleHighlightLocal(
        id: json['id'] as String,
        verseId: json['verseId'] as String,
        colorHex: json['colorHex'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String verseId;
  final String colorHex;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseId': verseId,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, verseId, colorHex, createdAt];
}

/// Note attached to a verse or chapter reference.
class BibleNoteLocal extends Equatable {
  const BibleNoteLocal({
    required this.id,
    required this.reference,
    required this.verseId,
    required this.body,
    required this.updatedAt,
  });

  factory BibleNoteLocal.fromJson(Map<String, dynamic> json) => BibleNoteLocal(
        id: json['id'] as String,
        reference: json['reference'] as String,
        verseId: (json['verseId'] as String?) ?? '',
        body: json['body'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  final String id;

  /// e.g. "John 3:16"
  final String reference;

  /// e.g. "JHN.3.16" — may be empty for chapter notes
  final String verseId;
  final String body;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'verseId': verseId,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, reference, verseId, body, updatedAt];
}

/// A locally-stored bookmark (mirrors [BibleBookmark] but lives offline).
class BibleBookmarkLocal extends Equatable {
  const BibleBookmarkLocal({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.reference,
    required this.createdAt,
  });

  factory BibleBookmarkLocal.fromJson(Map<String, dynamic> json) =>
      BibleBookmarkLocal(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        chapterId: json['chapterId'] as String,
        reference: json['reference'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String bookId;
  final String chapterId;
  final String reference;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'chapterId': chapterId,
        'reference': reference,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, bookId, chapterId, reference, createdAt];
}

/// A reading plan — curated catalogue lives in code; progress is local.
class BibleReadingPlan extends Equatable {
  const BibleReadingPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.durationDays,
    required this.icon,
    required this.accentHex,
    required this.coverEmoji,
    required this.chapters,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int durationDays;
  final String icon;
  final String accentHex;
  final String coverEmoji;

  /// Ordered list of `bookId.chapter` references.
  final List<String> chapters;

  @override
  List<Object?> get props => [id];
}

/// Per-plan progress (which day and chapter is the user on).
class BiblePlanProgress extends Equatable {
  const BiblePlanProgress({
    required this.planId,
    required this.currentIndex,
    required this.startedAt,
    this.completedAt,
  });

  factory BiblePlanProgress.fromJson(Map<String, dynamic> json) =>
      BiblePlanProgress(
        planId: json['planId'] as String,
        currentIndex: json['currentIndex'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
      );

  final String planId;
  final int currentIndex;
  final DateTime startedAt;
  final DateTime? completedAt;

  double get progress {
    // Will be computed against the plan length by the UI.
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'currentIndex': currentIndex,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  BiblePlanProgress copyWith({
    int? currentIndex,
    DateTime? completedAt,
  }) =>
      BiblePlanProgress(
        planId: planId,
        currentIndex: currentIndex ?? this.currentIndex,
        startedAt: startedAt,
        completedAt: completedAt ?? this.completedAt,
      );

  @override
  List<Object?> get props => [planId, currentIndex, startedAt, completedAt];
}

/// Reader appearance settings (font size, theme, line height, family).
class BibleReaderSettings extends Equatable {
  const BibleReaderSettings({
    this.fontScale = 1.0,
    this.lineHeight = 1.7,
    this.fontFamily = ReaderFontFamily.inter,
    this.theme = ReaderTheme.royalDark,
    this.verseNumbers = true,
    this.redLetter = true,
    this.justify = false,
  });

  factory BibleReaderSettings.fromJson(Map<String, dynamic> json) =>
      BibleReaderSettings(
        fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.7,
        fontFamily: ReaderFontFamily.values.firstWhere(
          (f) => f.name == json['fontFamily'],
          orElse: () => ReaderFontFamily.inter,
        ),
        theme: ReaderTheme.values.firstWhere(
          (t) => t.name == json['theme'],
          orElse: () => ReaderTheme.royalDark,
        ),
        verseNumbers: json['verseNumbers'] as bool? ?? true,
        redLetter: json['redLetter'] as bool? ?? true,
        justify: json['justify'] as bool? ?? false,
      );

  /// 0.85 .. 1.6
  final double fontScale;

  /// 1.4 .. 2.0
  final double lineHeight;
  final ReaderFontFamily fontFamily;
  final ReaderTheme theme;
  final bool verseNumbers;
  final bool redLetter;
  final bool justify;

  BibleReaderSettings copyWith({
    double? fontScale,
    double? lineHeight,
    ReaderFontFamily? fontFamily,
    ReaderTheme? theme,
    bool? verseNumbers,
    bool? redLetter,
    bool? justify,
  }) =>
      BibleReaderSettings(
        fontScale: fontScale ?? this.fontScale,
        lineHeight: lineHeight ?? this.lineHeight,
        fontFamily: fontFamily ?? this.fontFamily,
        theme: theme ?? this.theme,
        verseNumbers: verseNumbers ?? this.verseNumbers,
        redLetter: redLetter ?? this.redLetter,
        justify: justify ?? this.justify,
      );

  Map<String, dynamic> toJson() => {
        'fontScale': fontScale,
        'lineHeight': lineHeight,
        'fontFamily': fontFamily.name,
        'theme': theme.name,
        'verseNumbers': verseNumbers,
        'redLetter': redLetter,
        'justify': justify,
      };

  @override
  List<Object?> get props => [
        fontScale,
        lineHeight,
        fontFamily,
        theme,
        verseNumbers,
        redLetter,
        justify,
      ];
}

enum ReaderFontFamily {
  inter('Inter', 'Clean and modern'),
  playfair('Playfair Display', 'Reverent serif'),
  merriweather('Merriweather', 'Traditional reading'),
  lora('Lora', 'Warm serif');

  const ReaderFontFamily(this.label, this.description);
  final String label;
  final String description;
}

enum ReaderTheme {
  royalDark('Royal Dark', 'Deep navy'),
  royalLight('Royal Light', 'Warm white'),
  sepia('Sepia', 'Aged parchment'),
  midnight('Midnight', 'Pure ink');

  const ReaderTheme(this.label, this.description);
  final String label;
  final String description;
}

/// A single parsed verse (extracted from API HTML).
class BibleVerse extends Equatable {
  const BibleVerse({
    required this.number,
    required this.text,
    this.verseId = '',
  });

  final String number;
  final String text;

  /// e.g. "JHN.3.16" — set by parser when book/chapter are known.
  final String verseId;

  @override
  List<Object?> get props => [number, text, verseId];
}

/// Curated highlight palette (YouVersion-inspired).
class BibleHighlightPalette {
  const BibleHighlightPalette._();

  static const String gold = '#FFD166';
  static const String rose = '#FF6B8A';
  static const String mint = '#7CE3B5';
  static const String sky = '#9CC4FF';

  static const List<HighlightSwatch> all = [
    HighlightSwatch(name: 'Gold', hex: gold, label: 'Joy'),
    HighlightSwatch(name: 'Rose', hex: rose, label: 'Love'),
    HighlightSwatch(name: 'Mint', hex: mint, label: 'Growth'),
    HighlightSwatch(name: 'Sky', hex: sky, label: 'Peace'),
  ];
}

class HighlightSwatch {
  const HighlightSwatch({
    required this.name,
    required this.hex,
    required this.label,
  });

  final String name;
  final String hex;
  final String label;
}
