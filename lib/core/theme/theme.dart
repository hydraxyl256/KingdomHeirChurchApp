/// Kingdom Heir — Theme Entry Point
///
/// Luxury Christian mobile experience.
/// Aggregates the entire design system: color tokens, typography, spacing,
/// radius, elevation, and motion. Bind to MaterialApp via [AppTheme.light]
/// and [AppTheme.dark].
///
/// Follows Material 3 and Apple Human Interface Guidelines.
library kingdom_heir.theme;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/elevation.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/core/theme/spacing.dart';

// Re-export public surface so screens/widgets import a single file.
export 'app_colors.dart' show AppColors;
export 'app_typography.dart' show AppTypography;
export 'elevation.dart' show AppElevation;
export 'motion.dart' show AppMotion;
export 'radius.dart' show AppRadius;
export 'spacing.dart' show AppSpacing;

/// Kingdom Heir — Production Material 3 Theme
///
/// Exports [AppTheme.light] and [AppTheme.dark]. The aggregated theme wires:
///   • Material 3 ColorScheme (gold primary, deep navy secondary)
///   • Inter (UI) + Playfair Display (display) typography
///   • 8-pt spacing grid, semantic radius scale, tiered elevation
///   • Apple-style spring curves for motion
abstract final class AppTheme {
  // ─────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData get light => _build(
        scheme: AppColors.lightScheme,
        brightness: Brightness.light,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData get dark => _build(
        scheme: AppColors.darkScheme,
        brightness: Brightness.dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Builder
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData _build({
    required ColorScheme scheme,
    required Brightness brightness,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      // ── App Bar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: AppElevation.level0,
        scrolledUnderElevation: AppElevation.level1,
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        foregroundColor: isDark ? AppColors.warmWhite : AppColors.navy,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.warmWhite : AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.warmWhite : AppColors.navy,
          size: AppSpacing.iconMd,
        ),
        systemOverlayStyle: systemOverlayStyle,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppElevation.level1,
        color: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.38),
          disabledForegroundColor: AppColors.ink.withValues(alpha: 0.38),
          elevation: AppElevation.level1,
          shadowColor: AppColors.gold.withValues(alpha: 0.4),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          disabledForegroundColor: AppColors.gold.withValues(alpha: 0.38),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      // ── FilledButton ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),

      // ── Input / Text Field ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.navyLight.withValues(alpha: 0.3)
            : AppColors.surfaceContainerLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.45),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? AppColors.gold
              : scheme.onSurface.withValues(alpha: 0.5),
        ),
        suffixIconColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? AppColors.gold
              : scheme.onSurface.withValues(alpha: 0.5),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.navyLight.withValues(alpha: 0.4)
            : AppColors.surfaceContainerLight,
        selectedColor: AppColors.gold.withValues(alpha: 0.15),
        disabledColor: scheme.onSurface.withValues(alpha: 0.12),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        checkmarkColor: AppColors.goldDark,
        elevation: AppElevation.level0,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.navBarHeight,
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.navy.withValues(alpha: 0.1),
        elevation: AppElevation.level2,
        indicatorColor: AppColors.gold.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSpacing.iconMd,
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : scheme.onSurface.withValues(alpha: 0.55),
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),

      // ── Navigation Rail ───────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        indicatorColor: AppColors.gold.withValues(alpha: 0.15),
        selectedIconTheme: const IconThemeData(
          color: AppColors.gold,
          size: AppSpacing.iconMd,
        ),
        unselectedIconTheme: IconThemeData(
          color: scheme.onSurface.withValues(alpha: 0.55),
          size: AppSpacing.iconMd,
        ),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.55),
        ),
        elevation: AppElevation.level0,
        minWidth: 72,
        minExtendedWidth: 200,
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.gold,
        unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.55),
        indicatorColor: AppColors.gold,
        dividerColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelLarge,
        splashFactory: InkRipple.splashFactory,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.level5,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        showDragHandle: true,
        dragHandleColor:
            isDark ? AppColors.dividerDark : AppColors.dividerLight,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.level4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        thickness: 0.5,
        space: 0,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxs,
        ),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minLeadingWidth: 0,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.ink
              : scheme.onSurface.withValues(alpha: 0.6),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : scheme.onSurface.withValues(alpha: 0.2),
        ),
      ),

      // ── Checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(AppColors.ink),
        side: const BorderSide(color: AppColors.gold, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      // ── Radio ─────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : scheme.onSurface.withValues(alpha: 0.5),
        ),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.gold.withValues(alpha: 0.25),
        thumbColor: AppColors.gold,
        overlayColor: AppColors.gold.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.goldDark,
        valueIndicatorTextStyle:
            textTheme.labelSmall?.copyWith(color: AppColors.ink),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.goldContainer,
        circularTrackColor: AppColors.goldContainer,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.navyLight : AppColors.navy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.warmWhite,
        ),
        actionTextColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.level3,
      ),

      // ── Badge ─────────────────────────────────────────────────────────────
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.gold,
        textColor: AppColors.ink,
        smallSize: 8,
        largeSize: 20,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyLight : AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.warmWhite),
        preferBelow: false,
      ),

      // ── Icon Button ───────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          highlightColor: AppColors.gold.withValues(alpha: 0.1),
          focusColor: AppColors.gold.withValues(alpha: 0.08),
        ),
      ),

      // ── Popup Menu ────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),

      // ── Page Transitions (Apple HIG on iOS, predictive back on Android) ───
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ── Splash & Highlight (Apple HIG tactile feedback) ───────────────────
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
  }
}
