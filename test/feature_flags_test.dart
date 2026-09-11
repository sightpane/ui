// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/flags/feature_flag_dialog.dart';
import 'package:sightpane_dashboard/features/flags/feature_flags_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('feature flags page renders flag list with toggles and rollout badges', (tester) async {
    await go(tester, '/projects/1/feature-flags');
    await settle(tester);

    expect(find.byType(FeatureFlagsPage), findsOneWidget);
    expect(find.text('Özellik Bayrakları & Uzaktan Yapılandırma'), findsOneWidget);
    expect(find.text('New Checkout Flow'), findsOneWidget);
    expect(find.text('new_checkout_flow'), findsOneWidget);
    expect(find.text('Beta Dashboard v2'), findsOneWidget);
    expect(find.text('Pricing Tier Experiment'), findsOneWidget);

    // Verify rollout and variant badges
    expect(find.text('100% rollout'), findsNWidgets(2));
    expect(find.text('50% rollout'), findsOneWidget);
    expect(find.text('1 rules'), findsOneWidget);
    expect(find.text('2 variants'), findsOneWidget);

    // Open create dialog
    await tester.tap(find.text('Yeni Bayrak'));
    await settle(tester);

    expect(find.byType(FeatureFlagDialog), findsOneWidget);
  });

  testWidgets('dialog runs live preview test for user', (tester) async {
    await go(tester, '/projects/1/feature-flags');
    await settle(tester);

    await tester.tap(find.text('Yeni Bayrak'));
    await settle(tester);

    expect(find.byType(FeatureFlagDialog), findsOneWidget);

    // Tap test button
    await tester.tap(find.text('Test'));
    await settle(tester);

    // Should display preview result
    expect(find.textContaining('Preview:'), findsOneWidget);
  });
}
