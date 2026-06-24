import 'package:flutter/material.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Avatar component used throughout Kingdom Heir.
///
/// Shows [imageUrl] if provided, otherwise renders initials
/// from [name] with a gold-tinted background.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.borderColor,
    this.borderWidth = 0,
    this.isOnline = false,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  /// Shows a green online dot if true.
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final hasBorder = borderWidth > 0 && borderColor != null;

    Widget avatar = ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialsAvatar(
                initials: initials,
                size: size,
              ),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _ShimmerAvatar(size: size),
            )
          : _InitialsAvatar(initials: initials, size: size),
    );

    if (hasBorder) {
      avatar = Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor!,
            width: borderWidth,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: avatar,
        ),
      );
    }

    if (isOnline) {
      return Stack(
        children: [
          avatar,
          Positioned(
            right: hasBorder ? borderWidth : 1,
            bottom: hasBorder ? borderWidth : 1,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.size});

  final String initials;
  final double size;

  // Deterministic color from initials
  Color _bgColor() {
    const colors = [
      Color(0xFFFDF3C0), // light gold
      Color(0xFFDBEAFE), // light navy
      Color(0xFFE0F2FE), // sky blue
      Color(0xFFDCFCE7), // mint
      Color(0xFFFEF3C7), // amber
    ];
    final idx = (initials.isEmpty ? 0 : initials.codeUnitAt(0)) % colors.length;
    return colors[idx];
  }

  Color _fgColor() {
    const colors = [
      AppColors.goldDark,
      AppColors.navyAccent,
      Color(0xFF0369A1),
      AppColors.success,
      Color(0xFFD97706),
    ];
    final idx = (initials.isEmpty ? 0 : initials.codeUnitAt(0)) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: _fgColor(),
            fontWeight: FontWeight.w700,
            fontSize: size * 0.33,
          ),
        ),
      ),
    );
  }
}

class _ShimmerAvatar extends StatelessWidget {
  const _ShimmerAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.goldContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Stacked avatar group — e.g. "3 members joined"
class AppAvatarGroup extends StatelessWidget {
  const AppAvatarGroup({
    required this.names,
    super.key,
    this.imageUrls,
    this.size = AppSpacing.avatarSm,
    this.overlap = 12,
    this.maxVisible = 4,
    this.suffixLabel,
  });

  final List<String> names;
  final List<String>? imageUrls;
  final double size;
  final double overlap;
  final int maxVisible;
  final String? suffixLabel;

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final overflow = names.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: visible.length * (size - overlap) +
              overlap +
              (overflow > 0 ? size : 0),
          child: Stack(
            children: [
              ...visible.asMap().entries.map(
                    (e) => Positioned(
                      left: e.key * (size - overlap),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: AppAvatar(
                          name: e.value,
                          imageUrl: imageUrls?.elementAtOrNull(e.key),
                          size: size,
                        ),
                      ),
                    ),
                  ),
              if (overflow > 0)
                Positioned(
                  left: visible.length * (size - overlap),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: AppColors.goldContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '+$overflow',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w700,
                          fontSize: size * 0.28,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (suffixLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            suffixLabel!,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
