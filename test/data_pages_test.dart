import 'package:sightpane_dashboard/features/events/events_page.dart';
import 'package:sightpane_dashboard/features/issues/issue_detail_page.dart';
import 'package:sightpane_dashboard/features/sessions/session_detail_page.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;
  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });
  Future<GoRouter> go(
    WidgetTester tester,
    String path, {
    Size size = desktopSize,
  }) => pumpApp(tester, testContainer(api), path: path, size: size);

  testWidgets('sessions list, error filter and row navigation', (tester) async {
    final r = await go(tester, '/projects/1/sessions');
    expect(find.text('ops@casino.local'), findsOneWidget);
    expect(find.text('10.1.2.3'), findsOneWidget);
    expect(find.text('anonim'), findsOneWidget);
    expect(find.text('açık'), findsOneWidget);
    expect(find.text('bitti'), findsOneWidget);
    await tester.tap(find.text('Yalnızca hatalı'));
    await settle(tester);
    expect(r.state.uri.toString(), '/projects/1/sessions?errors=1');
    expect(find.text('anonim'), findsNothing);
    await tester.tap(find.text('ops@casino.local'));
    await settle(tester);
    expect(find.byType(SessionDetailPage), findsOneWidget);
  });

  testWidgets(
    'session detail: player, timeline seek, error detail with breadcrumbs, issue link',
    (tester) async {
      await go(
        tester,
        '/projects/1/sessions/abcdef12-3456',
        size: tallDesktopSize,
      );
      expect(find.text('2 kare · 5 dk'), findsOneWidget);
      // Frames are buffered before playback; there is no network in the test
      // environment → both frames complete as "failed" and the player still
      // becomes ready.
      expect(find.textContaining('önbellek'), findsOneWidget);
      await settle(tester);
      expect(find.text('önbellek 0/2'), findsOneWidget);
      expect(find.textContaining('10.1.2.3'), findsOneWidget);
      expect(
        find.byType(TapMarker),
        findsOneWidget,
      ); // a tap on the first frame
      // Mouse trail: at 0.65 s the cursor sits on the click point and the trail
      // holds 3 moves.
      final page = tester.state(find.byType(SessionDetailPage)) as dynamic;
      final ReplayController rc = page.controllerForTest;
      rc.seek(const Duration(milliseconds: 650));
      await settle(tester);
      expect(rc.cursor?.x, 0.5);
      expect(rc.cursor?.kind, 'down');
      expect(rc.trail().length, 3);
      expect(find.byType(CustomPaint), findsWidgets);
      rc.seek(const Duration(seconds: 3));
      expect(rc.cursor, isNull); // a cursor older than 1.5 s is hidden
      rc.seek(Duration.zero);
      await settle(tester);
      expect(find.text('push /cashier'), findsOneWidget);
      expect(find.text('StateError: Bad state: boom'), findsOneWidget);
      await tester.tap(find.text('StateError: Bad state: boom'));
      await settle(tester);
      expect(find.textContaining('#0 main'), findsOneWidget);
      expect(find.text('tap "Kaydet"'), findsOneWidget);
      expect(find.text('Hata grubu #7'), findsOneWidget);
      // Jumping to the error moment (10:00:04) shows the second frame
      // (10:00:03).
      expect(find.textContaining('#2 · '), findsOneWidget);
      // Play / pause
      await tester.tap(find.byIcon(LucideIcons.play));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.byIcon(LucideIcons.pause));
      await settle(tester);
      // Fullscreen: the same controller, ESC closes it, the position is kept.
      final before = rc.position;
      await tester.tap(find.byIcon(LucideIcons.maximize2));
      await settle(tester);
      expect(find.byType(FullscreenReplayPage), findsOneWidget);
      expect(find.textContaining('ESC kapatır'), findsOneWidget);
      expect(find.byIcon(LucideIcons.minimize2), findsOneWidget);
      expect(find.byType(TimelineRow), findsNothing); // the player only
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.byType(FullscreenReplayPage), findsNothing);
      expect(rc.position, before);
      expect(find.byType(TimelineRow), findsWidgets);
      await tester.tap(find.text('Hata grubu #7'));
      await settle(tester);
      expect(find.byType(IssueDetailPage), findsOneWidget);
    },
  );

  testWidgets('issues list toggles resolved; detail resolves and reopens', (
    tester,
  ) async {
    final r = await go(tester, '/projects/1/issues');
    expect(find.text('StateError: Bad state: boom'), findsOneWidget);
    expect(find.text('Old'), findsNothing);
    await tester.tap(find.text('Çözülenleri göster'));
    await settle(tester);
    expect(r.state.uri.toString(), '/projects/1/issues?resolved=1');
    expect(find.text('Old'), findsOneWidget);
    await tester.tap(find.text('StateError: Bad state: boom'));
    await settle(tester);
    expect(find.byType(IssueDetailPage), findsOneWidget);
    expect(
      find.text('5 kez · ilk 01.09.2026 00:00 · son 07.09.2026 00:00'),
      findsOneWidget,
    );
    await tester.tap(find.text('Çözüldü'));
    await settle(tester);
    expect(api.calls, contains('resolve 7 undo=false'));
    expect(find.text('Yeniden aç'), findsOneWidget);
    await tester.tap(find.text('Yeniden aç'));
    await settle(tester);
    expect(api.calls, contains('resolve 7 undo=true'));
    await dismissToasts(tester);
  });

  testWidgets('events page aggregates per name with day columns', (
    tester,
  ) async {
    await go(tester, '/projects/1/events');
    expect(find.byType(EventsPage), findsOneWidget);
    expect(find.text('deposit'), findsOneWidget);
    expect(find.text('40'), findsOneWidget); // 30 + 10
    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('mobile layout shows the horizontal project nav', (tester) async {
    await go(tester, '/projects/1/issues', size: mobileSize);
    expect(find.text('Hatalar'), findsWidgets);
    expect(find.text('Oturumlar'), findsOneWidget);
  });
}
