// Kingdom Heir — Donation Launcher
//
// Single funnel for every donation / giving entry point in the app.
//
// Contract:
//   • Opens the hosted payment page at https://pay.kingdomheirsfoundation.com
//     in the device's external browser (not an in-app WebView, not a
//     platform sheet).
//   • Idempotent under rapid taps: a process-wide `_inFlight` guard plus
//     a 1.5 s cooldown ensures double- and triple-taps open at most one
//     browser tab.
//   • Never exposes raw exceptions, URLs, or stack traces to the user.
//     A floating SnackBar with friendly copy is the only failure surface.
//   • Theme-aware — uses `Theme.of(context).colorScheme` tokens for the
//     snackbar so it looks correct in both light and dark modes.
//
// Usage:
//   `await openDonationPage(context);`
//
// The Stripe SDK, mobile money, card form, and any other payment surface
// are intentionally NOT used here. Payment happens entirely on the
// hosted page.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hosted donation / payment page.
const String kDonationPageUrl = 'https://pay.kingdomheirsfoundation.com';

/// Friendly error copy shown when the page cannot be opened.
const String _kDonationErrorMessage =
    'We could not open the donation page. Please try again.';

/// Friendly info copy shown in the retry SnackBar.
const String _kDonationRetryLabel = 'Retry';

/// Cooldown after a launch attempt, during which subsequent calls are
/// ignored. Chosen to be long enough to swallow accidental double-taps
/// and short enough that a deliberate retry feels responsive.
const Duration _kCooldown = Duration(milliseconds: 1500);

/// Process-wide guard so concurrent callers cannot open multiple browser
/// tabs. Stays `true` for the duration of the launch attempt + the
/// cooldown window, then resets.
bool _inFlight = false;

/// Opens the hosted donation page in the device's external browser.
///
/// Safe to call from any button's `onPressed`. Returns `Future<void>`
/// because callers may want to disable their button until the launch
/// resolves (the function does not provide that signal itself, so
/// callers should set local state in their own `StatefulWidget`).
///
/// Always returns normally — failures surface via a SnackBar, never via
/// thrown exceptions.
Future<void> openDonationPage(BuildContext context) async {
  if (_inFlight) return;
  _inFlight = true;

  // Capture the messenger and the theme synchronously so we don't touch
  // `context` after an async gap.
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;

  try {
    final uri = Uri.parse(kDonationPageUrl);

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      _showErrorSnackbar(messenger, scheme);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showErrorSnackbar(messenger, scheme);
    }
  } catch (_) {
    // Swallow every error. We never want a payment-launch attempt to
    // crash the calling screen.
    _showErrorSnackbar(messenger, scheme);
  } finally {
    await Future<void>.delayed(_kCooldown);
    _inFlight = false;
  }
}

void _showErrorSnackbar(ScaffoldMessengerState messenger, ColorScheme scheme) {
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: const Text(_kDonationErrorMessage),
        backgroundColor: scheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: _kDonationRetryLabel,
          textColor: scheme.onError,
          // The messenger's BuildContext is still valid here — the
          // SnackBar itself owns the lifetime. We avoid touching the
          // caller's context across the async gap.
          onPressed: () => openDonationPage(messenger.context),
        ),
      ),
    );
}
