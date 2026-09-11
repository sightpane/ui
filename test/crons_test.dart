// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/crons/cron_detail_page.dart';
import 'package:sightpane_dashboard/features/crons/cron_dialog.dart';
import 'package:sightpane_dashboard/features/crons/crons_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('crons page renders monitor list and opens create dialog', (tester) async {
    await go(tester, '/projects/1/crons');
    await settle(tester);

    expect(find.byType(CronsPage), findsOneWidget);
    expect(find.text('Cron İşleri & Heartbeat İzleme'), findsWidgets);
    expect(find.text('Daily Backup'), findsOneWidget);
    expect(find.text('daily-backup'), findsOneWidget);
    expect(find.text('0 2 * * *'), findsOneWidget);
    expect(find.text('Çalışıyor'), findsWidgets);

    // Open create dialog
    await tester.tap(find.text('Yeni Cron İzleyici'));
    await settle(tester);

    expect(find.byType(CronDialog), findsOneWidget);
    expect(find.text('Yeni Cron İzleyici'), findsWidgets);
  });

  testWidgets('cron detail page displays metadata, timeline, snippets, and checkin history', (tester) async {
    await go(tester, '/projects/1/crons/1');
    await settle(tester);

    expect(find.byType(CronDetailPage), findsOneWidget);
    expect(find.text('Daily Backup'), findsWidgets);
    expect(find.text('daily-backup'), findsOneWidget);
    expect(find.text('0 2 * * *'), findsOneWidget);
    expect(find.text('UTC'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('60 min'), findsOneWidget);

    // Snippets & Tabs
    expect(find.text('Entegrasyon Kodları'), findsOneWidget);
    expect(find.text('cURL / Bash'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('Flutter SDK'), findsOneWidget);
    expect(find.text('Node.js'), findsOneWidget);

    // History table
    expect(find.text('Backup completed cleanly'), findsOneWidget);
    expect(find.text('1.25s'), findsOneWidget);
  });
}
