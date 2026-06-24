// ignore_for_file: one_member_abstracts

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final startHereRepositoryProvider = Provider<StartHereRepository>((ref) {
  return SupabaseStartHereRepository(supabase.Supabase.instance.client);
});

class StartHereContent {
  const StartHereContent({
    required this.key,
    required this.title,
    required this.body,
  });

  factory StartHereContent.fromJson(Map<String, dynamic> json) {
    return StartHereContent(
      key: json['content_key'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  final String key;
  final String title;
  final String body;
}

abstract class StartHereRepository {
  Future<Either<String, StartHereContent>> getContent(String key);
}

class SupabaseStartHereRepository implements StartHereRepository {
  SupabaseStartHereRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, StartHereContent>> getContent(String key) async {
    try {
      final response = await _client
          .from('start_here_content')
          .select()
          .eq('content_key', key)
          .single();
      return right(StartHereContent.fromJson(response));
    } catch (e) {
      return left('Failed to load content: $e');
    }
  }
}
