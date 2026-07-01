// Kingdom Heir — Phosphor Iconography Registry
//
// Single source of truth for every Phosphor icon used across the app.
// All dashboard / home widgets MUST import this file instead of using
// `PhosphorIcons.<glyph>(...)` directly, so the icon family can be
// swapped in one place if we ever migrate to HugeIcons or Cupertino.
//
// Weight convention:
//   * `regular` (default) — outlined, 1.5pt, premium feel. Used in
//     navigation chrome, secondary actions, small labels.
//   * `bold` (2.0pt) — used for primary CTAs and section headers to
//     anchor the visual hierarchy.
//
// Why not `PhosphorIcons.bookOpen()` (the method)? Because the public
// `PhosphorIcons.<glyph>` accessors are runtime switch expressions and
// can't be used in `const` contexts. We reference the style-specific
// static const fields directly (e.g. `PhosphorIconsRegular.bookOpen`)
// which compile down to the same `IconData` tree.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Semantic, role-based icon lookups. Every dashboard widget pulls from
/// this registry — never from `PhosphorIcons.*` directly.
abstract final class Iconography {
  // ── Section headers ────────────────────────────────────────────────────
  static const IconData streak = PhosphorIconsBold.flame;
  static const IconData bookmark = PhosphorIconsRegular.bookmarkSimple;
  static const IconData share = PhosphorIconsRegular.shareNetwork;
  static const IconData audio = PhosphorIconsRegular.speakerHigh;
  static const IconData reflect = PhosphorIconsRegular.notePencil;
  static const IconData favorite = PhosphorIconsRegular.heart;

  // ── Header chrome ──────────────────────────────────────────────────────
  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData notifications = PhosphorIconsRegular.bellRinging;
  static const IconData weather = PhosphorIconsRegular.cloudSun;
  static const IconData calendar = PhosphorIconsRegular.calendarPlus;
  static const IconData reminder = PhosphorIconsRegular.bell;
  static const IconData directions = PhosphorIconsRegular.mapTrifold;

  // ── Service / Live / Reminder ──────────────────────────────────────────
  static const IconData live = PhosphorIconsBold.broadcast;

  // ── Quick action rail (8 tiles) ────────────────────────────────────────
  static const IconData bible = PhosphorIconsRegular.bookOpen;
  static const IconData prayer = PhosphorIconsRegular.handsPraying;
  static const IconData devotional = PhosphorIconsRegular.bookmarks;
  static const IconData groups = PhosphorIconsRegular.usersThree;
  static const IconData giving = PhosphorIconsRegular.handHeart;
  static const IconData events = PhosphorIconsRegular.calendarDots;
  static const IconData journal = PhosphorIconsRegular.notebook;
  static const IconData sermon = PhosphorIconsBold.playCircle;

  // ── Daily Journey timeline (kind → icon) ───────────────────────────────
  static const IconData taskPrayer = PhosphorIconsBold.handsPraying;
  static const IconData taskReading = PhosphorIconsBold.bookOpen;
  static const IconData taskReflection = PhosphorIconsBold.lightbulb;
  static const IconData taskDevotional = PhosphorIconsBold.sun;
  static const IconData taskWorship = PhosphorIconsBold.musicNote;
  static const IconData taskJournal = PhosphorIconsBold.notebook;

  // ── Community tile grid ───────────────────────────────────────────────
  static const IconData community = PhosphorIconsRegular.chatsCircle;
  static const IconData birthday = PhosphorIconsRegular.cake;
  static const IconData meeting = PhosphorIconsRegular.usersThree;
  static const IconData announcement = PhosphorIconsRegular.megaphone;

  // ── Continue Watching ──────────────────────────────────────────────────
  static const IconData download = PhosphorIconsRegular.downloadSimple;

  // ── Fallback avatar ────────────────────────────────────────────────────
  static const IconData userAvatar = PhosphorIconsRegular.userCircle;

  // ── Admin / system icons ───────────────────────────────────────────────
  static const IconData adminDownload = PhosphorIconsRegular.downloadSimple;
  static const IconData adminRefresh = PhosphorIconsRegular.arrowsClockwise;
  static const IconData adminOnline = PhosphorIconsRegular.wifiHigh;
  static const IconData adminDaily = PhosphorIconsRegular.calendar;
  static const IconData adminWeekly = PhosphorIconsRegular.calendarDots;
  static const IconData adminMonthly = PhosphorIconsRegular.calendarBlank;
  static const IconData adminUsers = PhosphorIconsRegular.users;
  static const IconData adminPayments = PhosphorIconsRegular.currencyDollar;
  static const IconData adminBalance = PhosphorIconsRegular.bank;
  static const IconData adminChart = PhosphorIconsRegular.trendUp;
  static const IconData adminStar = PhosphorIconsRegular.star;
}
