// Kingdom Heir — Scripture Chip
//
// A pill that appears in the chat composer when a scripture reference is
// attached. Tap the close icon to detach. Shown above the input bar.

import 'package:flutter/material.dart';

import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/radius.dart';

class ScriptureChip extends StatelessWidget {
  const ScriptureChip({
    required this.reference,
    required this.onClose,
    super.key,
  });

  final String reference;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(insets.sm, 6, 6, 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.55,
            ),
            child: Text(
              reference,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.warmWhite,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
