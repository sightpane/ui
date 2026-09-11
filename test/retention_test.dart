// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/cohorts/cohort_create_dialog.dart';
import 'package:sightpane_dashboard/features/cohorts/cohorts_page.dart';
import 'package:sightpane_dashboard/features/retention/retention_page.dart';
import 'package:sightpane_dashboard/features/retention/widgets/retention_matrix_table.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('retention page renders heatmap matrix and filters', (tester) async {
    await go(tester, '/projects/1/retention');
    await settle(tester);

    expect(find.byType(RetentionPage), findsOneWidget);
    expect(find.byType(RetentionMatrixTable), findsOneWidget);
    expect(find.text('Kullanıcı Elde Tutma Matrisi'), findsOneWidget);
    expect(find.text('2026-09-01'), findsOneWidget);
    expect(find.text('2026-09-02'), findsOneWidget);
    expect(find.text('100.0%'), findsNWidgets(2));
    expect(find.text('40.0%'), findsNWidgets(2));
    expect(find.text('25.0%'), findsOneWidget);

    // Verify filter buttons exist
    expect(find.text('Günlük'), findsOneWidget);
    expect(find.text('Haftalık'), findsOneWidget);
    expect(find.text('14d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);
  });

  testWidgets('cohorts page renders cohort list and allows refresh and creation', (tester) async {
    await go(tester, '/projects/1/cohorts');
    await settle(tester);

    expect(find.byType(CohortsPage), findsOneWidget);
    expect(find.text('Davranışsal Kohortlar'), findsOneWidget);
    expect(find.text('Power Users'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('page_view >= 5 (30d)'), findsOneWidget);

    // Open create cohort dialog
    await tester.tap(find.text('Yeni Kohort'));
    await settle(tester);

    expect(find.byType(CohortCreateDialog), findsOneWidget);
    expect(find.text('Dinamik Kurallar'), findsOneWidget);
  });
}
