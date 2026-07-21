// Kingdom Heir — Chat Input Bar
//
// Pill-shaped text field with attach + send + scripture + prayer actions.
// Long-press on send opens the prayer composer. The scripture icon
// toggles a ScriptureChip above the bar (handled by the screen).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/responsive/insets.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/radius.dart';
import 'package:kingdom_heir/l10n/app_localizations.dart';

typedef ChatSendCallback = Future<void> Function(String text);

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSend,
    required this.onAttachTap,
    required this.onScriptureTap,
    required this.onLongPressSend,
    super.key,
    this.isSending = false,
    this.controller,
  });

  final ChatSendCallback onSend;
  final VoidCallback onAttachTap;
  final VoidCallback onScriptureTap;
  final VoidCallback onLongPressSend;
  final bool isSending;

  /// Optional external controller — if null, the bar owns the field.
  final TextEditingController? controller;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _owned =
      widget.controller ?? TextEditingController();
  late final FocusNode _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _owned.addListener(_onChanged);
  }

  @override
  void dispose() {
    _owned.removeListener(_onChanged);
    if (widget.controller == null) _owned.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    final next = _owned.text.trim().isNotEmpty;
    if (next != _hasText) setState(() => _hasText = next);
  }

  Future<void> _send() async {
    final text = _owned.text.trim();
    if (text.isEmpty || widget.isSending) return;
    unawaited(HapticFeedback.selectionClick());
    await widget.onSend(text);
    if (mounted) {
      _owned.clear();
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = Insets.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(insets.sm, insets.sm, insets.sm, insets.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.attach,
              onPressed: widget.onAttachTap,
              icon: Icon(
                Icons.attach_file_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.shareScripture,
              onPressed: widget.onScriptureTap,
              icon: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.goldDark,
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                  minHeight: 44,
                ),
                child: TextField(
                  controller: _owned,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeAMessage,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: insets.md,
                      vertical: insets.sm + 2,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.brFull,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.brFull,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.brFull,
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: _hasText ? 44 : 0,
              child: _hasText
                  ? IconButton(
                      tooltip: AppLocalizations.of(context)!.sendAsPrayer,
                      onLongPress: widget.onLongPressSend,
                      onPressed: _send,
                      icon: widget.isSending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.volunteer_activism_rounded,
                              color: theme.colorScheme.onPrimary,
                            ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.ink,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.brFull,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _hasText
                  ? IconButton(
                      key: const ValueKey('send'),
                      tooltip: AppLocalizations.of(context)!.send,
                      onPressed: widget.isSending ? null : _send,
                      icon: widget.isSending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: const CircleBorder(),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
