// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/traces/trace_detail_page.dart';
import 'package:sightpane_dashboard/features/traces/traces_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('traces page renders trace list with services, duration, and status', (tester) async {
    await go(tester, '/projects/1/traces');
    await settle(tester);

    expect(find.byType(TracesPage), findsOneWidget);
    expect(find.text('Dağıtık İzleme & Waterfall'), findsWidgets);
    expect(find.text('/api/v1/checkout'), findsOneWidget);
    expect(find.text('/api/v1/pay'), findsOneWidget);
    expect(find.text('backend-api'), findsOneWidget);
    expect(find.text('payment-service'), findsOneWidget);
    expect(find.text('OK'), findsWidgets);
    expect(find.text('ERR'), findsWidgets);
  });

  testWidgets('trace detail page renders breadcrumb, KPIs, suspect N+1 banner, and Gantt waterfall', (tester) async {
    await go(tester, '/projects/1/traces/trace-1234567890abcdef');
    await settle(tester);

    expect(find.byType(TraceDetailPage), findsOneWidget);
    expect(find.text('/api/v1/checkout'), findsWidgets);
    expect(find.text('Waterfall Gantt Timeline'), findsOneWidget);
    expect(find.text('Olası N+1 Sorgu Sorunu Tespit Edildi!'), findsOneWidget);
    expect(find.textContaining('Suspected N+1 query loop'), findsOneWidget);
    expect(find.text('SELECT users'), findsWidgets);

    // Tap on the SELECT users span to inspect SQL statement
    await tester.tap(find.text('SELECT users').first);
    await tester.pumpAndSettle();

    expect(find.text('SQL Sorgusu'), findsOneWidget);
    expect(find.textContaining('SELECT * FROM users'), findsWidgets);
  });
}
