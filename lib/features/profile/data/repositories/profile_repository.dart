import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kingdom_heir/features/profile/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(supabase.Supabase.instance.client);
});

abstract class ProfileRepository {
  Future<Either<String, Profile>> getCurrentProfile();
  Future<Either<String, Profile>> updateProfile(Map<String, dynamic> updates);
  Future<Either<String, String>> uploadAvatar(File imageFile);
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);
  final supabase.SupabaseClient _client;

  @override
  Future<Either<String, Profile>> getCurrentProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      final response =
          await _client.from('profiles').select().eq('id', user.id).single();

      return right(_mapToProfile(response));
    } catch (e) {
      return left('Failed to load profile: $e');
    }
  }

  @override
  Future<Either<String, Profile>> updateProfile(
      Map<String, dynamic> updates,) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return right(_mapToProfile(response));
    } catch (e) {
      return left('Failed to update profile: $e');
    }
  }

  @override
  Future<Either<String, String>> uploadAvatar(File imageFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return left('Not authenticated.');

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      await _client.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const supabase.FileOptions(upsert: true),
          );

      final imageUrlResponse =
          _client.storage.from('avatars').getPublicUrl(filePath);

      return right(imageUrlResponse);
    } catch (e) {
      return left('Failed to upload avatar: $e');
    }
  }

  Profile _mapToProfile(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String,
      phone: data['phone'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      role: data['role'] as String? ?? 'member',
      isActive: data['is_active'] as bool? ?? true,
    );
  }
}
