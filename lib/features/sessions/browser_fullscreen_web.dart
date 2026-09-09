import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Takes the browser window into fullscreen too (must be called from inside a
/// user gesture).
Future<void> enterBrowserFullscreen() async {
  try {
    await web.document.documentElement?.requestFullscreen().toDart;
  } catch (_) {
    // If the browser refuses, in-app fullscreen still works.
  }
}

Future<void> exitBrowserFullscreen() async {
  try {
    if (web.document.fullscreenElement != null) {
      await web.document.exitFullscreen().toDart;
    }
  } catch (_) {}
}
