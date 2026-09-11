// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/dashboards/dashboards_page.dart';
import 'package:sightpane_dashboard/features/dashboards/dashboard_view_page.dart';
import 'package:sightpane_dashboard/features/dashboards/widgets/dashboard_tile_card.dart';
import 'package:sightpane_dashboard/features/insights/insight_builder_page.dart';
import 'package:sightpane_dashboard/features/insights/widgets/insight_chart.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('dashboards page renders dashboard list and default badge', (tester) async {
    await go(tester, '/projects/1/dashboards');
    await settle(tester);

    expect(find.byType(DashboardsPage), findsOneWidget);
    expect(find.text('Executive Overview'), findsOneWidget);
    expect(find.text('Key business metrics and engagement'), findsOneWidget);
    expect(find.text('Varsayılan Pano'), findsWidgets); // TR default badge

    // Open create dashboard dialog
    expect(find.text('Yeni Pano'), findsOneWidget);
    await tester.tap(find.text('Yeni Pano'));
    await settle(tester);

    expect(find.text('Pano Adı'), findsOneWidget);
  });

  testWidgets('dashboard view page renders dashboard with tiles and controls', (tester) async {
    await go(tester, '/projects/1/dashboards/dash-1');
    await settle(tester);

    expect(find.byType(DashboardViewPage), findsOneWidget);
    expect(find.text('Executive Overview'), findsWidgets);
    expect(find.byType(DashboardTileCard), findsNWidgets(2));
    expect(find.text('Weekly Purchases'), findsOneWidget);
    expect(find.text('Active Users by Platform'), findsOneWidget);

    // Refresh controls
    expect(find.text('Kapalı'), findsOneWidget);
    expect(find.text('10s'), findsOneWidget);
    expect(find.text('30s'), findsOneWidget);
    expect(find.text('1m'), findsOneWidget);

    // Layout save and add tile buttons
    expect(find.text('Düzeni Kaydet'), findsOneWidget);
    expect(find.text('Görü Ekle'), findsOneWidget);
  });

  testWidgets('insight builder page renders form controls and preview', (tester) async {
    await go(tester, '/projects/1/insights');
    await settle(tester);

    expect(find.byType(InsightBuilderPage), findsOneWidget);
    expect(find.text('Grafik Türü'), findsOneWidget);
    expect(find.text('Çizgi'), findsOneWidget);
    expect(find.text('Çubuk'), findsOneWidget);
    expect(find.text('Alan'), findsOneWidget);
    expect(find.text('Sayısal (KPI)'), findsOneWidget);
    expect(find.text('Halka (Donut)'), findsOneWidget);
    expect(find.text('Tablo'), findsOneWidget);

    // Date range & interval
    expect(find.text('24h'), findsOneWidget);
    expect(find.text('7d'), findsOneWidget);
    expect(find.text('14d'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);

    // Events and Breakdown
    expect(find.text('Olay Ekle'), findsOneWidget);
    expect(find.text('Gruplama (Breakdown)'), findsOneWidget);
    expect(find.text('Sorguyu Çalıştır'), findsOneWidget);
    expect(find.text('Görüyü Kaydet'), findsOneWidget);
  });

  testWidgets('insight chart widget renders number, table and series results', (tester) async {
    final result = InsightQueryResult(
      series: [
        InsightSeries(
          label: 'Chrome',
          aggregatedValue: 300,
          data: const [
            InsightDataPoint(time: '2026-09-01', value: 120),
            InsightDataPoint(time: '2026-09-02', value: 180),
          ],
        ),
      ],
      cached: false,
    );

    // Number chart test
    await pumpWidgetWithL10n(
      tester,
      InsightChart(
        chartType: 'number',
        result: result,
      ),
    );
    await settle(tester);
    expect(find.text('300'), findsOneWidget);

    // Table chart test
    await pumpWidgetWithL10n(
      tester,
      InsightChart(
        chartType: 'table',
        result: result,
      ),
    );
    await settle(tester);
    expect(find.text('Chrome'), findsOneWidget);
  });
}
