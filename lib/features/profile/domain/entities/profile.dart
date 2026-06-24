import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final bool isActive;

  Profile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return Profile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, fullName, phone, avatarUrl, role, isActive];
}
