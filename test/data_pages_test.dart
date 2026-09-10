import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/events/events_page.dart';
import 'package:sightpane_dashboard/features/issues/issue_detail_page.dart';
import 'package:sightpane_dashboard/features/sessions/session_detail_page.dart';
import 'package:sightpane_dashboard/features/users/users_page.dart';
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

  testWidgets('sessions search query and filter chips', (tester) async {
    final r = await go(tester, '/projects/1/sessions');
    expect(find.text('Hızlı Filtreler'), findsOneWidget);
    await tester.tap(find.text('browser:Chrome'));
    await settle(tester);
    expect(r.state.uri.toString(), contains('q=browser%3AChrome'));
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
      expect(find.text('İstemci ve Ortam Bilgileri'), findsOneWidget);
      expect(find.text('Web'), findsWidgets);
      expect(find.text('macOS'), findsWidgets);
      expect(find.text('14.5'), findsOneWidget);
      expect(find.text('Chrome'), findsWidgets);
      expect(find.text('128.0.6613.120'), findsOneWidget);
      expect(find.text('arm64'), findsOneWidget);
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

  testWidgets(
    'session detail: dom replay player is picked for dom sessions',
    (tester) async {
      await go(
        tester,
        '/projects/1/sessions/dom-session',
        size: tallDesktopSize,
      );
      expect(find.byType(DomReplayPlayer), findsOneWidget);
      expect(find.text('DOM Replay'), findsOneWidget);
      expect(find.text('DOM Kaydı (2 olay)'), findsOneWidget);
      expect(find.text('SNAPSHOT'), findsOneWidget);
      expect(find.text('https://app.local/shop'), findsOneWidget);
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

  testWidgets('issue detail assignment, snooze, ignore and comments workflow', (
    tester,
  ) async {
    await go(tester, '/projects/1/issues/7');
    expect(find.byType(IssueDetailPage), findsOneWidget);

    // 1. Comments
    expect(find.text('Looking into this crash'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Fix in progress');
    await tester.tap(find.text('Gönder'));
    await settle(tester);
    expect(api.calls, contains('addIssueComment 7 Fix in progress'));
    expect(find.text('Fix in progress'), findsOneWidget);

    // 2. Assignment
    expect(find.text('Atanmamış'), findsOneWidget);
    await tester.tap(find.text('Atanmamış'));
    await settle(tester);
    expect(find.text('Ayşe Yılmaz (ayse@x.io)'), findsOneWidget);
    await tester.tap(find.text('Ayşe Yılmaz (ayse@x.io)'));
    await settle(tester);
    expect(api.calls, contains('assignIssue 7 1'));

    // 3. Snooze
    expect(find.text('Ertele'), findsOneWidget);
    await tester.tap(find.text('Ertele'));
    await settle(tester);
    expect(find.text('24 saat'), findsOneWidget);
    await tester.tap(find.text('24 saat'));
    await settle(tester);
    expect(api.calls, anyElement(contains('snoozeIssue 7')));
    await dismissToasts(tester);

    // 4. Reopen and Ignore
    expect(find.text('Yeniden aç'), findsOneWidget);
    await tester.tap(find.text('Yeniden aç'));
    await settle(tester);
    expect(find.text('Göz ardı et'), findsOneWidget);
    await tester.tap(find.text('Göz ardı et'));
    await settle(tester);
    expect(api.calls, contains('setIssueStatus 7 ignored'));
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

  testWidgets('releases page renders release health table with crash-free rate', (
    tester,
  ) async {
    await go(tester, '/projects/1/releases');
    expect(find.text('Sürümler'), findsWidgets);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('90.0%'), findsOneWidget);
    expect(find.text('0.9.0'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
    expect(api.calls, contains('releases 1'));
  });

  testWidgets('performance page renders transactions, filter and detail modal with slowest samples', (tester) async {
    await go(tester, '/projects/1/performance');
    expect(find.text('Performans'), findsWidgets);
    expect(find.text('route:/dashboard'), findsOneWidget);
    expect(find.text('GET /api/v1/sessions'), findsOneWidget);
    expect(api.calls, contains('performance 1 days=14 op='));

    // Tap on transaction to open detail dialog
    await tester.tap(find.text('route:/dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('En Yavaş Örnekler'), findsOneWidget);
    expect(find.text('Kaydı Aç'), findsOneWidget);
    expect(api.calls, contains('transactionDetail 1 name=route:/dashboard op=navigation days=14'));

    // Tap "Kaydı Aç" to navigate to session
    await tester.tap(find.text('Kaydı Aç'));
    await tester.pumpAndSettle();
    expect(find.byType(SessionDetailPage), findsOneWidget);
  });

  testWidgets('mobile layout shows the horizontal project nav', (tester) async {
    await go(tester, '/projects/1/issues', size: mobileSize);
    expect(find.text('Hatalar'), findsWidgets);
    expect(find.text('Oturumlar'), findsOneWidget);
  });

  testWidgets(
    'client environment card renders linux desktop kernel and cpu details',
    (tester) async {
      final session = Session(
        id: 'ffff0000-1111',
        projectId: 1,
        startedAt: DateTime(2026, 9, 7, 11),
        lastSeenAt: DateTime(2026, 9, 7, 11, 1),
        platform: 'linux',
        device: const {
          'platform_category': 'desktop',
          'os': 'Ubuntu',
          'os_version': '24.04',
          'kernel': 'Linux',
          'kernel_version': '6.8.0-40-generic',
          'arch': 'x86_64',
          'cpu_cores': 16,
        },
      );
      await pumpWidgetWithL10n(tester, ClientEnvironmentCard(session: session));
      expect(find.text('İstemci ve Ortam Bilgileri'), findsOneWidget);
      expect(find.text('Masaüstü (Desktop)'), findsOneWidget);
      expect(find.text('Ubuntu'), findsOneWidget);
      expect(find.text('24.04'), findsOneWidget);
      expect(find.text('Linux'), findsOneWidget);
      expect(find.text('6.8.0-40-generic'), findsOneWidget);
      expect(find.text('x86_64'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
    },
  );

  testWidgets('users page renders KPIs, DAU chart, users table and navigates', (tester) async {
    final r = await go(tester, '/projects/1/users');
    expect(find.byType(UsersPage), findsOneWidget);
    expect(find.text('Kullanıcılar'), findsWidgets);
    expect(find.text('Toplam Kullanıcı'), findsOneWidget);
    expect(find.text('Aktif Kullanıcı (Dönem)'), findsOneWidget);
    expect(find.text('Ortalama Süre'), findsOneWidget);
    expect(find.text('Kullanıcı Başı Oturum'), findsOneWidget);
    expect(find.text('Günlük Aktif Kullanıcılar (DAU)'), findsOneWidget);
    expect(find.text('Ops User'), findsOneWidget);
    expect(find.text('ops@casino.local'), findsOneWidget);
    expect(find.text('u2'), findsOneWidget);
    expect(find.text('web'), findsOneWidget);
    expect(find.text('Chrome'), findsOneWidget);

    // Click on user to open detail dialog
    await tester.tap(find.text('Ops User'));
    await settle(tester);
    expect(find.text('Kullanıcı Detayları'), findsNothing); // title has initials + display name
    expect(find.text('IP: 10.1.2.3'), findsOneWidget);
    expect(find.text('Özel Nitelikler'), findsOneWidget);
    expect(find.text('role: admin'), findsOneWidget);
    expect(find.text('Oturumları Gör'), findsOneWidget);
    expect(find.text('Veriyi İndir (JSON)'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Kapat'));
    await settle(tester);

    // Sidebar navigation check
    await tester.tap(find.text('Oturumlar'));
    await settle(tester);
    expect(r.state.uri.toString(), '/projects/1/sessions');

    await tester.tap(find.text('Kullanıcılar'));
    await settle(tester);
    expect(r.state.uri.toString(), '/projects/1/users');
  });
}


