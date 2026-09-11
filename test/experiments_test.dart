// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/experiments/experiment_detail_page.dart';
import 'package:sightpane_dashboard/features/experiments/experiment_dialog.dart';
import 'package:sightpane_dashboard/features/experiments/experiments_page.dart';
import 'package:sightpane_dashboard/features/experiments/widgets/significance_badge.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('experiments page renders experiment list and opens create dialog', (tester) async {
    await go(tester, '/projects/1/experiments');
    await settle(tester);

    expect(find.byType(ExperimentsPage), findsOneWidget);
    expect(find.text('Deneyler (A/B Testi)'), findsWidgets);
    expect(find.text('CTA Button Color Test'), findsOneWidget);
    expect(find.text('cta_button_color'), findsOneWidget);
    expect(find.text('signup_completed'), findsOneWidget);

    // Open create dialog
    await tester.tap(find.text('Yeni Deney'));
    await settle(tester);

    expect(find.byType(ExperimentDialog), findsOneWidget);
    expect(find.text('Create New Experiment'), findsOneWidget);
  });

  testWidgets('experiment detail page displays results, significance badge and variant cards', (tester) async {
    await go(tester, '/projects/1/experiments/1');
    await settle(tester);

    expect(find.byType(ExperimentDetailPage), findsOneWidget);
    expect(find.text('CTA Button Color Test'), findsWidgets);
    expect(find.byType(SignificanceBadge), findsOneWidget);
    expect(find.textContaining('Statistically Significant'), findsOneWidget);

    // Variant cards
    expect(find.text('Control (Blue)'), findsOneWidget);
    expect(find.text('Treatment (Green)'), findsOneWidget);
    expect(find.text('10.00%'), findsOneWidget);
    expect(find.text('15.00%'), findsOneWidget);
    expect(find.text('+50.0%'), findsOneWidget);

    // Declare winner button
    expect(find.text('Declare Winner'), findsNWidgets(2));
  });
}
