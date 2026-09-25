import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:sightpane_dashboard/features/sessions/replay_size.dart';

void main() {
  group('deviceFrameSize', () {
    const iphone = (w: 393.0, h: 852.0);

    test('is the screen the device reported, whatever the capture scale', () {
      // SightpaneReplay's default scale of 0.5 gives a 197×426 PNG.
      expect(deviceFrameSize(197, 426, iphone), const Size(393, 852));
      expect(deviceFrameSize(393, 852, iphone), const Size(393, 852));
    });

    test('turns with a device rotated after the session started', () {
      expect(deviceFrameSize(426, 197, iphone), const Size(852, 393));
    });

    test('falls back to the frame when the screen is unknown', () {
      expect(deviceFrameSize(160, 90, null), const Size(160, 90));
    });

    test('keeps the screen width when the window changed shape', () {
      expect(
        deviceFrameSize(100, 100, (w: 1920.0, h: 1080.0)),
        const Size(1920, 1920),
      );
    });
  });

  group('replayScale', () {
    const phone = Size(393, 852);
    const desktop = Size(1920, 1080);

    test('draws the device at its own size', () {
      expect(replayScale(phone, zoom: 1, maxWidth: 1100, maxHeight: 700), 1);
    });

    test('never wider than the panel', () {
      expect(
        replayScale(phone, zoom: 3, maxWidth: 1100, maxHeight: 700),
        1100 / 393,
      );
      expect(
        replayScale(desktop, zoom: 1, maxWidth: 1100, maxHeight: 700),
        1100 / 1920,
      );
    });

    test('fit is as large as fits on screen', () {
      expect(
        replayScale(phone, zoom: null, maxWidth: 1100, maxHeight: 700),
        700 / 852,
      );
      expect(
        replayScale(desktop, zoom: null, maxWidth: 1100, maxHeight: 700),
        1100 / 1920,
      );
    });
  });

  test('zoom steps move to the next step up or down', () {
    expect(nextZoomStep(1, up: true), 1.5);
    expect(nextZoomStep(1, up: false), 0.75);
    expect(nextZoomStep(3, up: true), isNull);
    expect(nextZoomStep(0.5, up: false), isNull);
    // From a fitted scale between steps.
    expect(nextZoomStep(0.82, up: true), 1);
    expect(nextZoomStep(0.82, up: false), 0.75);
  });
}
