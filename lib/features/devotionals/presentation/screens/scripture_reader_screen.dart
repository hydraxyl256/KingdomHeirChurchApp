// Kingdom Heir — Devotional Journey: Screen 2 — Scripture Reader
//
// Distraction-free, large-typography scripture reading experience.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_typography.dart';
import 'package:kingdom_heir/core/theme/motion.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotional_journey_provider.dart';
import 'package:kingdom_heir/features/devotionals/presentation/providers/devotionals_provider.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class ScriptureReaderScreen extends ConsumerStatefulWidget {
  const ScriptureReaderScreen({required this.devotionalId, super.key});
  final String devotionalId;

  @override
  ConsumerState<ScriptureReaderScreen> createState() =>
      _ScriptureReaderScreenState();
}

class _ScriptureReaderScreenState extends ConsumerState<ScriptureReaderScreen>
    with SingleTickerProviderStateMixin {
  bool _isDark = false;
  bool _showFontPanel = false;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    // Ensure progress started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(journeyProgressProvider(widget.devotionalId).notifier)
          .ensureStarted();
    });
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devotionalAsync = ref.watch(dailyDevotionalProvider);
    final fontSize = ref.watch(devotionalFontSizeProvider);
    final bookmarked = ref.watch(
      scriptureBookmarkedProvider(widget.devotionalId),
    );

    final bg = _isDark ? AppColors.navy : AppColors.warmWhite;
    final textColor = _isDark ? Colors.white : AppColors.navy;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textColor),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Scripture',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // Bookmark
            IconButton(
              icon: Icon(
                bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                color: bookmarked ? AppColors.goldDark : textColor,
              ),
              onPressed: () {
                ref
                    .read(
                      scriptureBookmarkedProvider(widget.devotionalId).notifier,
                    )
                    .state = !bookmarked;
              },
            ),
            // Font size
            IconButton(
              icon: Icon(Icons.format_size_rounded, color: textColor),
              onPressed: () => setState(() => _showFontPanel = !_showFontPanel),
            ),
            // Dark mode
            IconButton(
              icon: Icon(
                _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textColor,
              ),
              onPressed: () => setState(() => _isDark = !_isDark),
            ),
          ],
        ),
        body: devotionalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (devotional) {
            if (devotional == null || devotional.id != widget.devotionalId) {
              // Try to find in previous list (simplified — use daily for now)
              return Center(
                  child:
                      Text(AppLocalizations.of(context)!.devotionalNotFound),);
            }

            return Column(
              children: [
                // Font size panel
                AnimatedSize(
                  duration: AppMotion.standard,
                  child: _showFontPanel
                      ? _FontSizePanel(
                          fontSize: fontSize,
                          onChanged: (v) => ref
                              .read(devotionalFontSizeProvider.notifier)
                              .state = v,
                          isDark: _isDark,
                        )
                      : const SizedBox.shrink(),
                ),

                // Reading progress (top bar)
                LinearProgressIndicator(
                  value: 0,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldDark.withValues(alpha: 0.4),
                  ),
                ),

                // Scripture content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reference label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldDark.withValues(alpha: 0.12),
                            borderRadius: AppRadius.brFull,
                          ),
                          child: Text(
                            devotional.scriptureRef,
                            style: AppTypography.scriptureRef.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ).animate().fadeIn(duration: AppMotion.standard),

                        const SizedBox(height: AppSpacing.xl),

                        // Decorative quote mark
                        Text(
                          '"',
                          style: TextStyle(
                            fontSize: 72,
                            height: 0.5,
                            color: AppColors.goldDark.withValues(alpha: 0.2),
                            fontFamily: 'Georgia',
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Scripture text — large, readable
                        SelectableText(
                          devotional.scriptureText,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                            height: 1.8,
                            letterSpacing: 0.2,
                            fontFamily: 'Georgia',
                          ),
                        ).animate().fadeIn(
                              delay: 200.ms,
                              duration: AppMotion.emphasized,
                            ),

                        const SizedBox(height: AppSpacing.xl),

                        // Reference (end)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '— ${devotional.scriptureRef}',
                            style: AppTypography.scriptureRef.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: 400.ms,
                              duration: AppMotion.standard,
                            ),

                        const SizedBox(height: AppSpacing.massive),

                        // Action row
                        _ActionRow(
                          onCopy: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '"${devotional.scriptureText}" — ${devotional.scriptureRef}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              _snack('Copied to clipboard'),
                            );
                          },
                          onShare: () {
                            Share.share(
                              '"${devotional.scriptureText}"\n— ${devotional.scriptureRef}\n\nRead via Kingdom Heirs Church App',
                            );
                          },
                          isDark: _isDark,
                        ).animate().fadeIn(
                              delay: 500.ms,
                              duration: AppMotion.standard,
                            ),
                      ],
                    ),
                  ),
                ),

                // Continue button
                _ContinueBar(
                  label: 'Read Devotional',
                  onContinue: () async {
                    await ref
                        .read(
                          journeyProgressProvider(widget.devotionalId).notifier,
                        )
                        .markScriptureRead();
                    if (context.mounted) {
                      unawaited(
                        context.push(
                          '/home/devotionals/${widget.devotionalId}/content',
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SnackBar _snack(String msg) => SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brFull),
        content: Text(msg, style: const TextStyle(color: AppColors.warmWhite)),
        duration: const Duration(milliseconds: 1600),
      );
}

class _FontSizePanel extends StatelessWidget {
  const _FontSizePanel({
    required this.fontSize,
    required this.onChanged,
    required this.isDark,
  });
  final double fontSize;
  final ValueChanged<double> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      color: isDark ? AppColors.navyMid : AppColors.surfaceContainerLight,
      child: Row(
        children: [
          Icon(
            Icons.text_fields_rounded,
            size: 16,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
          Expanded(
            child: Slider(
              value: fontSize,
              min: 14,
              max: 28,
              divisions: 7,
              activeColor: AppColors.goldDark,
              onChanged: onChanged,
            ),
          ),
          Icon(
            Icons.text_fields_rounded,
            size: 22,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onCopy,
    required this.onShare,
    required this.isDark,
  });
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white70 : AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionBtn(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: onCopy,
            color: color,),
        const SizedBox(width: AppSpacing.xl),
        _ActionBtn(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: onShare,
            color: color,),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconMd),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Continue Bar ───────────────────────────────────────────────────────

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.label, required this.onContinue});
  final String label;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        safeBottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: const Border(
          top: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onContinue,
        child: Container(
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.gold],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.ink,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
