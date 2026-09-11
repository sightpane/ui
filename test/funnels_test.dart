// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/features/funnels/funnel_create_dialog.dart';
import 'package:sightpane_dashboard/features/funnels/funnel_detail_page.dart';
import 'package:sightpane_dashboard/features/funnels/funnels_page.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;

  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });

  Future<GoRouter> go(WidgetTester tester, String path) =>
      pumpApp(tester, testContainer(api), path: path);

  testWidgets('funnels page renders funnels and navigates to detail', (tester) async {
    final r = await go(tester, '/projects/1/funnels');
    await settle(tester);

    expect(find.byType(FunnelsPage), findsOneWidget);
    expect(find.text('Dönüşüm Hunileri'), findsOneWidget);
    expect(find.text('Onboarding Funnel'), findsOneWidget);
    expect(find.text('page_view  →  signup_submit  →  checkout_success'), findsOneWidget);

    // Tap the funnel row to navigate to detail
    await tester.tap(find.text('Onboarding Funnel'));
    await settle(tester);

    expect(r.state.uri.toString(), '/projects/1/funnels/1');
    expect(find.byType(FunnelDetailPage), findsOneWidget);
    expect(find.text('Genel Dönüşüm Oranı'), findsOneWidget);
    expect(find.text('42.0%'), findsNWidgets(2));
    expect(find.text('Tamamlayan Oturum'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Başlayan Oturum'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('funnel detail page shows steps and opens dropoff replay dialog', (tester) async {
    await go(tester, '/projects/1/funnels/1');
    await settle(tester);

    expect(find.byType(FunnelDetailPage), findsOneWidget);
    expect(find.text('page_view'), findsOneWidget);
    expect(find.text('signup_submit'), findsOneWidget);
    expect(find.text('checkout_success'), findsOneWidget);

    // Find the watch replays button for step with dropoffs
    final replayBtn = find.text('Terk Eden Kayıtları İzle (30)');
    expect(replayBtn, findsOneWidget);

    await tester.tap(replayBtn);
    await settle(tester);

    // Checks that funnelDropoffs was called on api
    expect(api.calls.any((c) => c.startsWith('funnelDropoffs')), isTrue);
  });

  testWidgets('funnels page empty state and create funnel dialog', (tester) async {
    api.funnelList = [];
    await go(tester, '/projects/1/funnels');
    await settle(tester);

    expect(find.text('Henüz tanımlanmış bir huni yok.'), findsOneWidget);

    // Tap create funnel button
    await tester.tap(find.widgetWithText(PrimaryButton, 'Huni Oluştur').first);
    await settle(tester);

    expect(find.byType(FunnelCreateDialog), findsOneWidget);
  });
}
