// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/features/alerts/metric_alert_rule_form_page.dart';
import 'package:sightpane_dashboard/features/alerts/metric_alerts_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('metric alerts page renders rules and incidents tabs', (tester) async {
    await go(tester, '/projects/1/alerts');
    await settle(tester);

    expect(find.byType(MetricAlertsPage), findsOneWidget);
    expect(find.text('Metrik Uyarıları & Anomali Tespiti'), findsOneWidget);
    expect(find.text('High Error Rate in Checkout'), findsOneWidget);
    expect(find.text('Sudden Crash Spike'), findsOneWidget);
    expect(find.text('Normal'), findsWidgets);
    expect(find.text('Tetiklendi'), findsWidgets);

    // Switch to incidents tab
    await tester.tap(find.text('Olay Geçmişi'));
    await settle(tester);

    expect(find.text('TETIKLENDI'), findsWidgets);
    expect(find.text('ÇÖZÜLDÜ'), findsWidgets);
    expect(find.textContaining('Current crashes (18.00)'), findsOneWidget);
  });

  testWidgets('metric alert rule form page renders form and preview chart, and saves rule', (tester) async {
    await go(tester, '/projects/1/alerts/rules/new');
    await settle(tester);

    expect(find.byType(MetricAlertRuleFormPage), findsOneWidget);
    expect(find.text('Yeni Kural'), findsWidgets);
    expect(find.text('Geçmiş Metrik & Eşik Önizlemesi (Son 7 Gün)'), findsOneWidget);
    expect(find.text('Kural Adı'), findsOneWidget);

    // Fill rule name
    await tester.enterText(find.byType(TextField).first, 'API Latency Rule');
    await tester.pump();

    // Save rule
    await tester.tap(find.text('Kuralı Kaydet'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);

    expect(api.calls, contains('createMetricAlertRule 1 name=API Latency Rule'));
  });
}
