import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/more_section_theme.dart';

/// Kingdom Heir — Production Material 3 Theme
///
/// Exports [AppTheme.light] and [AppTheme.dark].
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
      extensions: <ThemeExtension<dynamic>>[
        isDark ? MoreSectionTheme.dark : MoreSectionTheme.light,
      ],

      // ── App Bar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        foregroundColor: isDark ? AppColors.warmWhite : AppColors.navy,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
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
        elevation: AppSpacing.elevation1,
        color: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
          elevation: AppSpacing.elevation1,
          shadowColor: AppColors.gold.withValues(alpha: 0.4),
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
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
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      // ── FilledButton ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(64, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
        elevation: AppSpacing.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.45),
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
        floatingLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
        labelStyle: AppTypography.textTheme.labelMedium,
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        checkmarkColor: AppColors.goldDark,
        elevation: 0,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.navBarHeight,
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.navy.withValues(alpha: 0.1),
        elevation: AppSpacing.elevation2,
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
          (states) => AppTypography.textTheme.labelSmall?.copyWith(
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
        selectedLabelTextStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.gold,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.55),
        ),
        elevation: AppSpacing.elevation0,
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
        labelStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.textTheme.labelLarge,
        splashFactory: InkRipple.splashFactory,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: AppSpacing.elevation5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor:
            isDark ? AppColors.dividerDark : AppColors.dividerLight,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.navyMid : AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: AppSpacing.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
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
        titleTextStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
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
            AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.ink),
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
        contentTextStyle: AppTypography.textTheme.bodyMedium
            ?.copyWith(color: AppColors.warmWhite),
        actionTextColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.elevation3,
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.warmWhite,
        ),
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
        elevation: AppSpacing.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        textStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      // ── Page Transitions ──────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
