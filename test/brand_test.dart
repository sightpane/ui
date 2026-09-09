// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sightpane_dashboard/shared/brand.dart';

Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: Center(child: child)),
);

void main() {
  // The wordmark is two spans of different weight, not one string. It still has
  // to answer to find.text('sightpane'): the sign-in page and the top bar are
  // where AGPL §13 attribution sits, and the tests that check those screens
  // look the name up by text.
  testWidgets('the wordmark still reads as one word', (tester) async {
    await pump(tester, const SightpaneLockup());
    expect(find.text('sightpane'), findsOneWidget);
  });

  // Below 20 logical pixels the 4-unit stroke is down to a single pixel and the
  // horizontal mullion runs into the corner radius, so it is dropped. The top
  // bar sits at 18 and depends on this happening by itself.
  test('the mark simplifies itself when it gets small', () {
    expect(const SightpaneMark(size: 18).isSimplified, isTrue);
    expect(const SightpaneMark(size: 20).isSimplified, isFalse);
    expect(const SightpaneMark(size: 64).isSimplified, isFalse);
    // An explicit choice still wins, for the places that want the full mark
    // small or the simplified one large.
    expect(const SightpaneMark(size: 64, simplified: true).isSimplified, isTrue);
  });
}
