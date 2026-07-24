// Kingdom Heir — YouTube ID Normalizer + Embed Fallback Launcher
//
// Single source of truth for converting any YouTube reference into a
// canonical 11-character video ID, plus the external-launch fallback
// used when a video cannot be embedded in our WebView.
//
// Why this exists:
//   The sermon + live players used to assume `sermon.youtubeId` was
//   already a bare `dQw4w9WgXcQ`-style ID. In practice, that field can
//   be:
//     • the bare 11-char ID (the happy case)
//     • a full https://www.youtube.com/watch?v=… URL
//     • a https://youtu.be/… short URL
//     • a https://www.youtube.com/embed/… embed URL
//     • a https://www.youtube.com/live/… live URL
//     • a https://m.youtube.com/… mobile URL
//     • a https://music.youtube.com/… music URL
//     • a playlist URL (https://www.youtube.com/playlist?list=… or
//       https://www.youtube.com/watch?v=…&list=…)
//
//   Passing any of these URL forms straight into
//   `YoutubePlayerController.fromVideoId` results in the WebView
//   showing "Video unavailable — error 152-4" because the value is
//   not a valid video ID. The fix is to normalise once, at the
//   boundary between data and player.
//
//   Some videos are not embeddable at all (the owner disabled
//   embedding, the video is private, the video is age-restricted, or
//   the content owner revoked embed rights). When that happens the
//   YouTube IFrame API returns error code 101 / 150 / 152 and shows
//   "Video unavailable". The fix is to detect that state and
//   gracefully launch the official YouTube app / browser so the
//   user is never stranded on a broken player.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Length of a canonical YouTube video ID. YouTube guarantees 11
/// characters; anything else is not a video ID.
const int kYouTubeVideoIdLength = 11;

/// Allowed characters in a YouTube video ID. Anything outside
/// `[A-Za-z0-9_-]` is invalid.
final RegExp _kValidVideoIdChars = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Why a YouTube reference could not be normalised into a video ID.
/// `null` is the success case.
enum YouTubeIdError {
  /// Input was empty.
  empty,

  /// Input looked like a URL but was not a recognised YouTube
  /// shape (e.g. random `https://example.com/foo`).
  notYouTube,

  /// Input was a YouTube URL but only carried a playlist ID —
  /// `?list=…` without a paired `?v=…`.
  playlistOnly,

  /// Input was a recognised YouTube ID/url but the extracted
  /// candidate is not 11 chars of `[A-Za-z0-9_-]`.
  invalid,
}

/// Result of normalising a YouTube reference.
class YouTubeIdResult {
  const YouTubeIdResult.ok(this.videoId)
      : error = null,
        rawPlaylistId = null;
  const YouTubeIdResult.playlistOnly({this.rawPlaylistId})
      : videoId = null,
        error = YouTubeIdError.playlistOnly;
  const YouTubeIdResult.error(this.error) : videoId = null, rawPlaylistId = null;

  /// The canonical 11-char video ID. `null` on error.
  final String? videoId;

  /// Why normalisation failed. `null` on success.
  final YouTubeIdError? error;

  /// When [error] is `playlistOnly`, the raw `list=…` value the URL
  /// carried — used by callers to surface a helpful message.
  final String? rawPlaylistId;

  bool get isValid => videoId != null && videoId!.length == kYouTubeVideoIdLength;
  bool get isPlaylistOnly => error == YouTubeIdError.playlistOnly;

  @override
  String toString() => isValid
      ? 'YouTubeIdResult.ok($videoId)'
      : 'YouTubeIdResult.error($error)';
}

/// Pure function — converts any reasonable YouTube reference into a
/// canonical 11-char video ID.
///
/// Accepts:
///   • a bare 11-char ID
///   • `https://www.youtube.com/watch?v=ID` (with or without `list=`)
///   • `https://youtu.be/ID`
///   • `https://www.youtube.com/embed/ID`
///   • `https://www.youtube.com/live/ID`
///   • `https://m.youtube.com/...`, `https://music.youtube.com/...`
///
/// Rejects (with a typed [YouTubeIdError]):
///   • empty / whitespace
///   • non-YouTube URLs
///   • playlist-only URLs (no `?v=`)
///   • 11-char candidate that doesn't match the charset
YouTubeIdResult normaliseYouTubeId(String? raw) {
  if (raw == null) return const YouTubeIdResult.error(YouTubeIdError.empty);
  final input = raw.trim();
  if (input.isEmpty) return const YouTubeIdResult.error(YouTubeIdError.empty);

  // Already a bare ID?
  if (_kValidVideoIdChars.hasMatch(input)) {
    return YouTubeIdResult.ok(input);
  }

  // Not a URL? Then it's malformed.
  final uri = Uri.tryParse(input);
  if (uri == null || !uri.hasScheme) {
    // Last-ditch: maybe the user pasted just `youtube.com/watch?v=ID`
    // without the scheme. Try as a path-style.
    if (input.contains('youtube.com') || input.contains('youtu.be')) {
      return _fromUri(Uri.parse('https://$input'));
    }
    // Could be a 12+ char "ID" — call it invalid.
    return const YouTubeIdResult.error(YouTubeIdError.invalid);
  }
  return _fromUri(uri);
}

YouTubeIdResult _fromUri(Uri uri) {
  final host = uri.host.toLowerCase();
  final isYouTubeHost = host == 'youtube.com' ||
      host == 'www.youtube.com' ||
      host == 'm.youtube.com' ||
      host == 'music.youtube.com' ||
      host == 'youtu.be';
  if (!isYouTubeHost) {
    return const YouTubeIdResult.error(YouTubeIdError.notYouTube);
  }

  // Path-based: /watch, /embed/, /live/, /shorts/, youtu.be/<id>
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isNotEmpty) {
    if (host == 'youtu.be') {
      // youtu.be/<id>
      final candidate = segments.first;
      if (_kValidVideoIdChars.hasMatch(candidate)) {
        return YouTubeIdResult.ok(candidate);
      }
    }
    if (segments.length >= 2 &&
        (segments.first == 'embed' ||
            segments.first == 'live' ||
            segments.first == 'shorts' ||
            segments.first == 'v')) {
      final candidate = segments[1];
      if (_kValidVideoIdChars.hasMatch(candidate)) {
        return YouTubeIdResult.ok(candidate);
      }
    }
  }

  // Query-based: ?v=ID (and optionally ?list=PLAYLIST)
  final v = uri.queryParameters['v'];
  if (v != null && _kValidVideoIdChars.hasMatch(v)) {
    return YouTubeIdResult.ok(v);
  }

  final list = uri.queryParameters['list'];
  if (list != null && list.isNotEmpty) {
    return YouTubeIdResult.playlistOnly(rawPlaylistId: list);
  }

  return const YouTubeIdResult.error(YouTubeIdError.invalid);
}

// ─────────────────────────────────────────────────────────────────────────────
//  External-launch fallback
// ─────────────────────────────────────────────────────────────────────────────

/// Canonical watch URL for a video ID.
Uri youTubeWatchUri(String videoId) => Uri.parse('https://www.youtube.com/watch?v=$videoId');

/// Canonical mobile / YouTube-app URL for a video ID. The platform
/// `url_launcher` will route this to the YouTube app when installed,
/// and to the browser otherwise.
Uri youTubeAppUri(String videoId) => Uri.parse('https://youtu.be/$videoId');

/// Process-wide guard so a panic-tap on "Open in YouTube" can never
/// open two browser tabs at once. Stays `true` for the duration of
/// the launch attempt + a short cooldown, then resets.
bool _launchInFlight = false;

const Duration _kLaunchCooldown = Duration(milliseconds: 1500);

/// Best-effort friendly message used in the fallback UI when the
/// app cannot determine *why* embedding failed. The player surfaces
/// the raw YouTube error code (e.g. "152-4") in development logs but
/// never in production UI.
const String _kFallbackMessage =
    'This video cannot be played in the app. Open it in YouTube instead?';

const String _kFallbackCta = 'Open in YouTube';
const String _kFallbackCancel = 'Not now';
const String _kFallbackFailed =
    'We could not open YouTube. Please try again.';

/// Launches the official YouTube app (or the system browser) for the
/// given video. Returns `true` if a launch was attempted; `false` if
/// the call was suppressed by the in-flight guard.
///
/// The function never throws. A failure surfaces as a [SnackBar]
/// presented to the supplied [ScaffoldMessenger] (which is captured
/// synchronously to avoid using `BuildContext` across the async
/// gap).
Future<bool> openYouTubeVideo(
  BuildContext context, {
  required String videoId,
}) async {
  if (_launchInFlight) return false;
  _launchInFlight = true;

  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;
  Uri? uri;
  try {
    // Prefer the youtu.be short-link: Android + iOS both route that
    // to the YouTube app when installed and to the browser otherwise.
    // Fall back to the watch URL if needed.
    uri = youTubeAppUri(videoId);

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      uri = youTubeWatchUri(videoId);
    }
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showFallbackError(messenger, scheme);
    }
    return launched;
  } catch (_) {
    _showFallbackError(messenger, scheme);
    return false;
  } finally {
    await Future<void>.delayed(_kLaunchCooldown);
    _launchInFlight = false;
  }
}

/// Shows a modal sheet offering to open the YouTube app / browser.
/// Used by the player when the YouTube IFrame reports an
/// embed-restriction error (101 / 150 / 152) or when the video ID
/// resolves to a playlist-only URL.
Future<bool> showYouTubeFallbackSheet(
  BuildContext context, {
  required String videoId,
  String? reason,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.play_circle_outline_rounded, size: 48),
              const SizedBox(height: 12),
              Text(
                'Watch in YouTube',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                reason ?? _kFallbackMessage,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop(true);
                  await openYouTubeVideo(context, videoId: videoId);
                },
                child: const Text(_kFallbackCta),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: const Text(_kFallbackCancel),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

void _showFallbackError(ScaffoldMessengerState messenger, ColorScheme scheme) {
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: const Text(_kFallbackFailed),
        backgroundColor: scheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
