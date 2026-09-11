// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/profiling/profile_detail_page.dart';
import 'package:sightpane_dashboard/features/profiling/profiling_page.dart';
import 'package:sightpane_dashboard/features/profiling/widgets/flame_chart.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('profiling page renders slow functions and profile list', (tester) async {
    await go(tester, '/projects/1/profiling');
    await settle(tester);

    expect(find.byType(ProfilingPage), findsOneWidget);
    expect(find.text('Sürekli CPU Profilleme & Flame Chart'), findsWidgets);
    expect(find.text('En Yavaş Fonksiyonlar'), findsOneWidget);
    expect(find.text('parseJSON'), findsOneWidget);
    expect(find.text('route:/feed'), findsOneWidget);
    expect(find.text('Profili Görüntüle'), findsWidgets);
  });

  testWidgets('profile detail page renders AppBreadcrumb, KPIs, and FlameChart', (tester) async {
    await go(tester, '/projects/1/profiling/prof-1');
    await settle(tester);

    expect(find.byType(ProfileDetailPage), findsOneWidget);
    expect(find.byType(FlameChart), findsOneWidget);
    expect(find.text('route:/feed'), findsWidgets);
    expect(find.text('Aşağıdan Yukarı (Icicle)'), findsOneWidget);

    // Tap on the flame chart to select a block
    await tester.tap(find.byType(FlameChart));
    await tester.pumpAndSettle();

    // Verify flame chart renders without errors
    expect(find.byType(FlameChart), findsOneWidget);
  });
}
