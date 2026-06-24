import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kingdom Heir — Typography System
///
/// Uses **Inter** (body/UI) + **Playfair Display** (display headings)
/// Scale follows Material 3 type roles exactly.
abstract final class AppTypography {
  // ─────────────────────────────────────────────────────────────────────────
  // Font Families
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary UI font — Inter
  static TextStyle get _inter => GoogleFonts.inter();

  /// Display / brand headings — Playfair Display
  static TextStyle get _playfair => GoogleFonts.playfairDisplay();

  // ─────────────────────────────────────────────────────────────────────────
  // Material 3 Text Theme
  // ─────────────────────────────────────────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
        // ── Display ──────────────────────────────────────────────────────
        displayLarge: _playfair.copyWith(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: _playfair.copyWith(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: _playfair.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
        ),

        // ── Headline ─────────────────────────────────────────────────────
        headlineLarge: _playfair.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: _inter.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: _inter.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.33,
        ),

        // ── Title ─────────────────────────────────────────────────────────
        titleLarge: _inter.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: _inter.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: _inter.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),

        // ── Body ─────────────────────────────────────────────────────────
        bodyLarge: _inter.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
        ),
        bodyMedium: _inter.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: _inter.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),

        // ── Label ─────────────────────────────────────────────────────────
        labelLarge: _inter.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: _inter.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: _inter.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience Styles (non-Material role)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sermon / devotional quote body — Playfair italic
  static TextStyle get quote => _playfair.copyWith(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.2,
      );

  /// Scripture reference — uppercase small caps style
  static TextStyle get scriptureRef => _inter.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      );

  /// Code / ticket reference monospace
  static TextStyle get ticketCode => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
      );

  /// Countdown / stat number — large bold
  static TextStyle get statNumber => _inter.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );
}
