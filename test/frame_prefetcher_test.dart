import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sightpane_dashboard/features/sessions/frame_prefetcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buffers the first 10 frames one by one, then slides one frame per cursor step', () async {
    final pending = <Completer<void>>[];
    final requested = <String>[];
    final p = FramePrefetcher(
      urls: [for (var i = 0; i < 25; i++) 'f$i'],
      load: (provider) {
        requested.add((provider as NetworkImage).url);
        final c = Completer<void>();
        pending.add(c);
        return c.future;
      },
    );
    var notifications = 0;
    p.addListener(() => notifications++);
    p.start();
    await Future<void>.delayed(Duration.zero);
    expect(requested, [
      'f0',
    ]); // one at a time: the second request waits for the first
    expect(p.initialReady, isFalse);
    for (var i = 0; i < 10; i++) {
      pending[i].complete();
      await Future<void>.delayed(Duration.zero);
    }
    expect(requested, [for (var i = 0; i < 10; i++) 'f$i']);
    expect(p.initialReady, isTrue);
    expect(p.initialDone, 10);
    expect(p.loadedCount, 10);
    expect(notifications, 10);
    // Cursor 1 → window 1..10: one more frame.
    p.setCursor(1);
    await Future<void>.delayed(Duration.zero);
    expect(requested.last, 'f10');
    pending.last.complete();
    await Future<void>.delayed(Duration.zero);
    expect(requested.length, 11);
    // Cursor 2 → f11. The same cursor again: no new request.
    p.setCursor(2);
    await Future<void>.delayed(Duration.zero);
    pending.last.complete();
    await Future<void>.delayed(Duration.zero);
    p.setCursor(2);
    await Future<void>.delayed(Duration.zero);
    expect(requested.last, 'f11');
    expect(requested.length, 12);
    // Jumping: cursor 20 → 20..24 in order (already requested ones are skipped).
    p.setCursor(20);
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
      pending.last.complete();
    }
    await Future<void>.delayed(Duration.zero);
    expect(requested.sublist(12), ['f20', 'f21', 'f22', 'f23', 'f24']);
    expect(p.isLoaded(24), isTrue);
    expect(p.isLoaded(15), isFalse);
    p.dispose();
  });

  test('failed loads count towards readiness but not towards loaded', () async {
    final p = FramePrefetcher(
      urls: const ['a', 'b', 'c'],
      load: (prov) async {
        if ((prov as NetworkImage).url == 'b') throw Exception('404');
      },
    );
    p.start();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(p.initialTarget, 3);
    expect(p.initialReady, isTrue);
    expect(p.loadedCount, 2);
    expect(p.failedCount, 1);
    expect(p.isLoaded(1), isFalse);
  });

  test('empty session is immediately ready', () {
    final p = FramePrefetcher(urls: const [], load: (_) async {});
    expect(p.initialReady, isTrue);
    expect(p.initialTarget, 0);
  });
}
