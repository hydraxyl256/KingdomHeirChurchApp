// Kingdom Heir — Group Avatar
//
// Square / rounded-square group avatar with a category badge fallback.
// Falls back to a gold gradient + first-letter monogram when no
// `imageUrl` is supplied.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    required this.name,
    super.key,
    this.imageUrl,
    this.size = 56,
    this.borderRadius,
    this.categoryBadge,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final String? categoryBadge;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg);
    final fallback = _initials(name);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: radius,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Fallback(
                      initials: fallback,
                      size: size,
                    ),
                  )
                : _Fallback(initials: fallback, size: size),
          ),
          if (categoryBadge != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.warmWhite, width: 1.5),
                ),
                child: Text(
                  categoryBadge!,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final cleaned = name.trim();
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.initials, required this.size});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.goldDark, AppColors.gold, AppColors.goldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
