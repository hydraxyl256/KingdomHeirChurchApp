// Kingdom Heirs — Vision & Mission provider.
//
// Wraps the curated [VisionMissionContent] in a [FutureProvider] so the
// screen can demonstrate its full loading / data / error triad even though
// the source today is local. When a remote source is wired up, only this
// provider changes — the screen stays the same.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kingdom_heir/features/start_here/data/vision_mission_content.dart';

/// Resolves the Vision & Mission content. Today this is local (immediate),
/// but it's exposed as an [AsyncValue] so the screen renders real loading
/// and error states instead of mocking them in the widget tree.
final visionMissionContentProvider =
    FutureProvider<VisionMissionContent>((ref) async {
  // Simulate a one-frame async hop so the skeleton loader is visible —
  // removes any "screen flash" and matches what a network fetch would do.
  await Future<void>.delayed(const Duration(milliseconds: 60));
  return VisionMissionContent.defaults;
});
