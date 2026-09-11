// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/surveys/survey_detail_page.dart';
import 'package:sightpane_dashboard/features/surveys/survey_dialog.dart';
import 'package:sightpane_dashboard/features/surveys/surveys_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('surveys page renders survey list and opens create dialog', (tester) async {
    await go(tester, '/projects/1/surveys');
    await settle(tester);

    expect(find.byType(SurveysPage), findsOneWidget);
    expect(find.text('Anketler & Geri Bildirim'), findsWidgets);
    expect(find.text('Quarterly NPS'), findsOneWidget);
    expect(find.text('How likely are you to recommend Sightpane?'), findsOneWidget);
    expect(find.text('NPS'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);

    // Open create dialog
    await tester.tap(find.text('Yeni Anket'));
    await settle(tester);

    expect(find.byType(SurveyDialog), findsOneWidget);
    expect(find.text('Create New Survey'), findsOneWidget);
  });

  testWidgets('survey detail page displays NPS metrics, distribution and response replay link', (tester) async {
    await go(tester, '/projects/1/surveys/1');
    await settle(tester);

    expect(find.byType(SurveyDetailPage), findsOneWidget);
    expect(find.text('Quarterly NPS'), findsWidgets);
    expect(find.text('100.0'), findsOneWidget); // NPS score
    expect(find.text('100.0%'), findsOneWidget); // Promoters %

    // Responses table
    expect(find.text('usr_alice'), findsOneWidget);
    expect(find.text('Score: 10'), findsOneWidget);
    expect(find.text('Best tool ever!'), findsOneWidget);

    // Watch replay button
    expect(find.text('Oturumu İzle'), findsOneWidget);
  });
}
