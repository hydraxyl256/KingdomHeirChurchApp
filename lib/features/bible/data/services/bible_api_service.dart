import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kingdom_heir/core/config/env.dart';
import 'package:kingdom_heir/features/bible/domain/entities/bible_models.dart';

class BibleApiService {
  BibleApiService() : _apiKey = Env.apiBibleKey;

  final String _apiKey;
  static const _baseUrl = 'https://api.scripture.api.bible/v1';

  Map<String, String> get _headers => {
        'api-key': _apiKey,
        'Accept': 'application/json',
      };

  Future<List<BibleBook>> getBooks(String bibleId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/books'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to load books');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BibleChapter>> getChapters(String bibleId, String bookId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/books/$bookId/chapters'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to load chapters');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    // The API usually returns an intro chapter (number 'intro'). We might want to filter it out or keep it.
    return data
        .map((e) => BibleChapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BibleChapterContent> getChapterContent(
      String bibleId, String chapterId,) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/bibles/$bibleId/chapters/$chapterId?content-type=html',),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load chapter content');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return BibleChapterContent.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, String>>> search(String bibleId, String query) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/bibles/$bibleId/search?query=${Uri.encodeComponent(query)}',),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Search failed');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final root = json['data'] as Map<String, dynamic>;
    final data = root['verses'] as List<dynamic>;
    return data.map((e) {
      final map = e as Map<String, dynamic>;
      return {
        'ref': map['reference'] as String,
        'text': map['text'] as String,
        'id': map['id'] as String,
      };
    }).toList();
  }
}
