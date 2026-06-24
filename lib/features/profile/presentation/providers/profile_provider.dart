import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/features/profile/data/repositories/profile_repository.dart';
import 'package:kingdom_heir/features/profile/domain/entities/profile.dart';

final currentProfileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<Profile>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});

class ProfileNotifier extends StateNotifier<AsyncValue<Profile>> {
  ProfileNotifier(this._repo) : super(const AsyncLoading()) {
    _fetch();
  }

  final ProfileRepository _repo;

  Future<void> _fetch() async {
    state = const AsyncLoading();
    final result = await _repo.getCurrentProfile();
    state = result.fold(
      (err) => AsyncError(err, StackTrace.current),
      AsyncData.new,
    );
  }

  Future<String?> updateProfileInfo(
      {required String fullName, String? phone,}) async {
    final updates = {
      'full_name': fullName,
      if (phone != null) 'phone': phone,
    };
    final result = await _repo.updateProfile(updates);
    return result.fold(
      (err) => err,
      (profile) {
        state = AsyncData(profile);
        return null;
      },
    );
  }

  Future<String?> uploadAndUpdateAvatar(File imageFile) async {
    // 1. Upload the image
    final uploadResult = await _repo.uploadAvatar(imageFile);
    return uploadResult.fold(
      (err) => err,
      (publicUrl) async {
        // 2. Update the profile with the new URL
        final updateResult =
            await _repo.updateProfile({'avatar_url': publicUrl});
        return updateResult.fold(
          (err) => err,
          (profile) {
            state = AsyncData(profile);
            return null; // Success
          },
        );
      },
    );
  }
}
