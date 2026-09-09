import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Caches the frame images one after another, before playback starts and while
/// it runs.
///
/// The first [window] frames (10 by default) are loaded up front; as the cursor
/// advances the window slides along and one more frame is requested at every
/// step. Requests go out one at a time; a frame that fails does not count as
/// "loaded" but does not block either.
class FramePrefetcher extends ChangeNotifier {
  FramePrefetcher({required this.urls, required this.load, this.window = 10})
    : providers = [for (final u in urls) NetworkImage(u)];

  final List<String> urls;
  final List<ImageProvider> providers;
  final int window;

  /// The loader that caches a single frame (in production [precacheLoader]).
  final Future<void> Function(ImageProvider) load;
  final Set<int> _requested = {}, _loaded = {}, _failed = {};
  int _cursor = 0;
  bool _running = false;
  bool _disposed = false;

  int get cursor => _cursor;
  int get loadedCount => _loaded.length;
  int get failedCount => _failed.length;
  bool isLoaded(int i) => _loaded.contains(i);
  bool isRequested(int i) => _requested.contains(i);

  /// The initial buffer: the first [window] frames (all of them when there are
  /// fewer).
  int get initialTarget => math.min(window, urls.length);

  /// Whether the initial buffer is full (loaded + failed).
  bool get initialReady =>
      Iterable<int>.generate(initialTarget)
          .every((i) => _loaded.contains(i) || _failed.contains(i));

  /// How many frames of the initial buffer are done (for the status readout).
  int get initialDone =>
      Iterable<int>.generate(initialTarget)
          .where((i) => _loaded.contains(i) || _failed.contains(i))
          .length;

  /// Playback reached frame [i]; the window runs [window] frames on from here.
  void setCursor(int i) {
    final c = i.clamp(0, math.max(0, urls.length - 1)).toInt();
    if (c == _cursor && _running) return;
    _cursor = c;
    start();
  }

  void start() => unawaited(_pump());

  int? _next() {
    final end = math.min(_cursor + window, urls.length);
    for (var i = _cursor; i < end; i++) {
      if (!_requested.contains(i)) return i;
    }
    return null;
  }

  Future<void> _pump() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      while (!_disposed) {
        final i = _next();
        if (i == null) break;
        _requested.add(i);
        try {
          await load(providers[i]);
          _loaded.add(i);
        } catch (_) {
          _failed.add(i);
        }
        if (!_disposed) notifyListeners();
      }
    } finally {
      _running = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// The [precacheImage]-based loader; an error comes back as a load failure.
  static Future<void> Function(ImageProvider) precacheLoader(
    BuildContext context,
  ) => (provider) async {
    Object? failure;
    await precacheImage(provider, context, onError: (e, _) => failure = e);
    if (failure != null) throw failure!;
  };
}
