import 'package:kingdom_heir/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data model wrapping Supabase user data. Maps to/from [AppUser].
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.phone,
    this.bio,
    this.createdAt,
  });

  factory UserModel.fromSupabaseUser(
    User user, [
    Map<String, dynamic>? profile,
  ]) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      role: _parseRole(profile?['role'] as String?),
      phone: profile?['phone'] as String?,
      bio: profile?['bio'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        role: _parseRole(json['role'] as String?),
        phone: json['phone'] as String?,
        bio: json['bio'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole? role;
  final String? phone;
  final String? bio;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role?.name,
        'phone': phone,
        'bio': bio,
      };

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        role: role,
        phone: phone,
        bio: bio,
        createdAt: createdAt,
      );

  static UserRole? _parseRole(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.member,
    );
  }
}
