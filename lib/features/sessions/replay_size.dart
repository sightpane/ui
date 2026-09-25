// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'dart:ui' show Size;

/// The size the recorded screen had on the device, in logical pixels: what the
/// user actually saw. A frame's own pixel size says little — the SDK captures at
/// a fraction of the screen (`SightpaneReplay`'s `scale`) — while the session's
/// `device.screen` says it exactly. The screen is reported once, when the session
/// starts, so a device turned sideways afterwards draws it the other way round.
Size deviceFrameSize(
  int frameWidth,
  int frameHeight,
  ({double w, double h})? screen,
) {
  if (frameWidth <= 0 || frameHeight <= 0) return const Size(16, 9);
  final aspect = frameWidth / frameHeight;
  if (screen == null || screen.w <= 0 || screen.h <= 0) {
    return Size(frameWidth.toDouble(), frameHeight.toDouble());
  }
  bool near(double a) => (a - aspect).abs() <= aspect * 0.05;
  if (near(screen.w / screen.h)) return Size(screen.w, screen.h);
  if (near(screen.h / screen.w)) return Size(screen.h, screen.w);
  // A browser window resized mid-session: the reported width is still the
  // best guess at the scale.
  return Size(screen.w, screen.w / aspect);
}

/// Zoom levels, relative to the device's own size.
const replayZoomSteps = [0.5, 0.75, 1.0, 1.5, 2.0, 3.0];

/// How much a frame of [natural] size is scaled when drawn: [zoom] times the
/// device size, or with no zoom as large as fits in [maxWidth] × [maxHeight].
/// Never wider than [maxWidth], so the page does not scroll sideways.
double replayScale(
  Size natural, {
  required double? zoom,
  required double maxWidth,
  required double maxHeight,
}) {
  final widthCap = maxWidth / natural.width;
  if (zoom == null) return math.min(widthCap, maxHeight / natural.height);
  return math.min(zoom, widthCap);
}

/// The zoom step after [scale] in the direction asked, or null past the end.
/// [scale] may sit between steps after "fit".
double? nextZoomStep(double scale, {required bool up}) {
  const eps = 1e-6;
  if (up) {
    for (final s in replayZoomSteps) {
      if (s > scale + eps) return s;
    }
  } else {
    for (final s in replayZoomSteps.reversed) {
      if (s < scale - eps) return s;
    }
  }
  return null;
}
