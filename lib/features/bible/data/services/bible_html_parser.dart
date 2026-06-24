import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_local_state.dart';

/// Pure-Dart parser that converts the API's chapter HTML into a list of
/// [BibleVerse] entries. The API's HTML uses `<span class="v">N</span>` for
/// verse numbers and surrounding text for the verse body.
class BibleHtmlParser {
  const BibleHtmlParser._();

  /// Parse the API chapter HTML into verses.
  ///
  /// [chapterId] looks like `JHN.3` and is combined with the verse number
  /// to populate [BibleVerse.verseId] (e.g. `JHN.3.16`).
  static List<BibleVerse> parse({
    required String html,
    required String chapterId,
  }) {
    if (html.trim().isEmpty) return const [];

    // Tokenise the HTML into tag / text tokens.
    final tokens = <_Token>[];
    final tagRe = RegExp('<[^>]+>');
    var cursor = 0;
    for (final m in tagRe.allMatches(html)) {
      if (m.start > cursor) {
        tokens.add(_Token(text: html.substring(cursor, m.start), isTag: false));
      }
      tokens.add(_Token(text: m.group(0)!, isTag: true));
      cursor = m.end;
    }
    if (cursor < html.length) {
      tokens.add(_Token(text: html.substring(cursor), isTag: false));
    }

    // Walk tokens. When we see <span class="v">, start a new verse. Read
    // the digits inside the span, then continue collecting text until the
    // next verse-number span (or end of document).
    final out = <BibleVerse>[];
    String? currentNumber;
    final buffer = StringBuffer();

    void flush() {
      if (currentNumber == null) return;
      final cleaned = _clean(buffer.toString());
      if (cleaned.isEmpty) return;
      out.add(
        BibleVerse(
          number: currentNumber,
          text: cleaned,
          verseId: '$chapterId.$currentNumber',
        ),
      );
    }

    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (t.isTag &&
          t.text.toLowerCase().startsWith('<span') &&
          t.text.toLowerCase().contains('class="v"')) {
        // Closing of previous verse (if any).
        flush();
        buffer.clear();
        currentNumber = null;

        // Read inner digits up to the matching </span>.
        var depth = 1;
        final numBuf = StringBuffer();
        i++;
        while (i < tokens.length && depth > 0) {
          final inner = tokens[i];
          if (inner.isTag) {
            final lower = inner.text.toLowerCase();
            if (lower.startsWith('<span')) {
              depth++;
            } else if (lower.startsWith('</span>')) {
              depth--;
              if (depth == 0) {
                i++;
                break;
              }
            }
          } else {
            numBuf.write(inner.text);
          }
          i++;
        }
        currentNumber = numBuf.toString().trim();
      } else if (!t.isTag && currentNumber != null) {
        buffer.write(_decode(t.text));
      }
    }
    flush();

    return out;
  }

  static String _decode(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  static String _clean(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _Token {
  const _Token({required this.text, required this.isTag});

  final String text;
  final bool isTag;
}

/// Strips HTML tags from a snippet and returns plain text. Used when a
/// caller has a partial HTML string (e.g. from search results) and needs
/// to render it inline.
String stripBibleHtml(String html) {
  final noTags = html.replaceAll(RegExp('<[^>]+>'), ' ');
  return noTags
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Adapter: wraps flutter_html so callers can render a parsed snippet
/// without repeating style boilerplate.
Widget renderBibleHtml(
  String html, {
  TextStyle? baseStyle,
  TextStyle? verseNumberStyle,
}) {
  return Html(
    data: html,
    style: {
      'body': Style(
        fontSize: baseStyle?.fontSize != null
            ? FontSize(baseStyle!.fontSize!)
            : FontSize(16),
        color: baseStyle?.color,
        lineHeight: baseStyle?.height != null
            ? LineHeight.number(baseStyle!.height!)
            : const LineHeight(1.7),
      ),
      '.v': Style(
        fontSize: verseNumberStyle?.fontSize != null
            ? FontSize(verseNumberStyle!.fontSize! * 0.7)
            : FontSize(11),
        color: verseNumberStyle?.color,
        fontWeight: FontWeight.w700,
        verticalAlign: VerticalAlign.sup,
      ),
      'p': Style(margin: Margins.only(bottom: 12)),
    },
  );
}
