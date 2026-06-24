// Kingdom Heir — Sermon Resource
//
// Companion asset for a sermon — study guides, scripture sheets,
// audio clips, etc.

import 'package:equatable/equatable.dart';

enum SermonResourceKind { pdf, link, audio, video }

extension SermonResourceKindX on SermonResourceKind {
  String get label => switch (this) {
        SermonResourceKind.pdf => 'PDF',
        SermonResourceKind.link => 'Link',
        SermonResourceKind.audio => 'Audio',
        SermonResourceKind.video => 'Video',
      };
}

class SermonResource extends Equatable {
  const SermonResource({
    required this.id,
    required this.title,
    required this.kind,
    required this.url,
    this.sizeBytes,
  });

  final String id;
  final String title;
  final SermonResourceKind kind;
  final String url;
  final int? sizeBytes;

  String get humanSize {
    final b = sizeBytes ?? 0;
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [id, title, kind, url, sizeBytes];
}
