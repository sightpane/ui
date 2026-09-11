// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sightpane_dashboard/features/paths/paths_page.dart';
import 'package:sightpane_dashboard/features/paths/widgets/sankey_diagram.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('paths page renders sankey diagram and transition flows', (tester) async {
    await go(tester, '/projects/1/paths');
    await settle(tester);

    expect(find.byType(PathsPage), findsOneWidget);
    expect(find.byType(SankeyDiagram), findsOneWidget);
    expect(find.text('Kullanıcı Yolculuk Akışları'), findsOneWidget);

    // Verify step nodes exist in the Sankey diagram
    expect(find.text('route:/home'), findsOneWidget);
    expect(find.text('route:/products'), findsOneWidget);
    expect(find.text('route:/login'), findsOneWidget);
    expect(find.text('add_to_cart'), findsOneWidget);
    expect(find.text('Terk (Exit)'), findsOneWidget);

    // Verify filters exist
    expect(find.text('İleri (Başlangıçtan)'), findsOneWidget);
    expect(find.text('Geriye Doğru (Hedefe)'), findsOneWidget);
    expect(find.text('14d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);
  });

  testWidgets('clicking a path node opens sample sessions modal', (tester) async {
    await go(tester, '/projects/1/paths');
    await settle(tester);

    // Tap on a step node
    await tester.tap(find.text('route:/products'));
    await settle(tester);

    // Modal should show sample sessions
    expect(find.text('Yolculuk Oturum Kayıtları'), findsOneWidget);
    expect(find.text('sess-p1'), findsOneWidget);
    expect(find.text('sess-p2'), findsOneWidget);
  });
}
