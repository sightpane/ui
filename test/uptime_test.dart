// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/uptime/uptime_detail_page.dart';
import 'package:sightpane_dashboard/features/uptime/uptime_dialog.dart';
import 'package:sightpane_dashboard/features/uptime/uptime_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('uptime page renders monitor list, metrics, and opens create dialog', (tester) async {
    await go(tester, '/projects/1/uptime');
    await settle(tester);

    expect(find.byType(UptimePage), findsOneWidget);
    expect(find.text('Uptime & Sentetik İzleme'), findsWidgets);
    expect(find.text('Production API'), findsOneWidget);
    expect(find.text('https://api.sightpane.io/healthz'), findsOneWidget);
    expect(find.text('GET'), findsOneWidget);
    expect(find.text('Çalışıyor'), findsWidgets);
    expect(find.text('99.98%'), findsWidgets);

    // Open create dialog
    await tester.tap(find.text('Yeni İzleyici').first);
    await settle(tester);

    expect(find.byType(UptimeDialog), findsOneWidget);
    expect(find.text('Hedef URL'), findsOneWidget);
  });

  testWidgets('uptime detail page displays SLA, SSL, timeline, and checks table', (tester) async {
    await go(tester, '/projects/1/uptime/1');
    await settle(tester);

    expect(find.byType(UptimeDetailPage), findsOneWidget);
    expect(find.text('Production API'), findsWidgets);
    expect(find.text('https://api.sightpane.io/healthz'), findsOneWidget);
    expect(find.text('99.98%'), findsWidgets);
    expect(find.text('42ms'), findsWidgets);
    expect(find.text('90 Günlük Erişilebilirlik Geçmişi'), findsOneWidget);
    expect(find.text('Son Kontroller'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    // Trigger check now
    await tester.tap(find.text('Şimdi Kontrol Et'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);

    expect(api.calls, contains('triggerUptimeCheck 1 id=1'));
  });
}
