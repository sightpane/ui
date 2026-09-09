import 'package:sightpane_dashboard/features/projects/overview_page.dart';
import 'package:sightpane_dashboard/features/projects/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;
  setUp(() async {
    api = FakeApi();
    await setUpLoggedIn();
  });
  Future<void> go(
    WidgetTester tester,
    String path, {
    Size size = desktopSize,
  }) => pumpApp(tester, testContainer(api), path: path, size: size);

  testWidgets(
    'projects list shows cards with counters; create dialog returns the key and snippet',
    (tester) async {
      await go(tester, '/projects');
      expect(find.text('Kasa App'), findsOneWidget);
      expect(find.text('Müfettiş'), findsOneWidget);
      expect(find.text('sahip'), findsOneWidget);
      await tester.tap(find.text('Yeni proje'));
      await settle(tester);
      await tester.tap(inDialog(find.text('Oluştur')));
      await settle(tester);
      expect(find.text('Proje adı gerekli'), findsOneWidget);
      await tester.enterText(inDialog(find.byType(TextField)), 'Garson');
      await tester.tap(inDialog(find.text('web')));
      await tester.tap(inDialog(find.text('Oluştur')));
      await settle(tester);
      expect(api.calls, ['create Garson web']);
      expect(find.text('Garson oluşturuldu'), findsOneWidget);
      expect(find.text('newkey1234567890'), findsOneWidget);
      expect(find.textContaining("apiKey: 'newkey1234567890'"), findsOneWidget);
      await tester.tap(find.text('Projeye git'));
      await settle(tester);
      expect(find.byType(OverviewPage), findsOneWidget);
    },
  );

  testWidgets(
    'overview renders KPIs, charts, top issues and the day range switch',
    (tester) async {
      await go(tester, '/projects/1', size: tallDesktopSize);
      expect(find.byType(OverviewPage), findsOneWidget);
      expect(find.text('12'), findsOneWidget); // sessions
      expect(find.text('%75'), findsOneWidget); // crash-free sessions
      expect(
        find.text('4 ziyaretçi (kullanıcı + IP + tarayıcı)'),
        findsOneWidget,
      );
      // Live panel: the head count, the pages and the viewers; it refreshes once
      // a second.
      expect(
        find.text('2 kişi şu anda çevrimiçi · 2 ziyaretçi'),
        findsOneWidget,
      );
      expect(find.text('/cashier'), findsWidgets);
      expect(find.text('Chrome · 10.1.2.3'), findsOneWidget);
      final liveCalls = api.calls.where((c) => c.startsWith('live')).length;
      await tester.pump(const Duration(seconds: 2));
      await settle(tester);
      expect(
        api.calls.where((c) => c.startsWith('live')).length,
        greaterThan(liveCalls),
      );
      expect(find.text('StateError: Bad state: boom'), findsOneWidget);
      expect(find.text('web'), findsOneWidget);
      expect(api.calls.where((c) => c.startsWith('stats')).first, 'stats 1 14');
      await tester.tap(find.text('30 g'));
      await settle(tester);
      expect(api.calls.where((c) => c.startsWith('stats')).last, 'stats 1 30');
      await tester.tap(find.text('StateError: Bad state: boom'));
      await settle(tester);
      expect(find.text('Oluşumlar'), findsOneWidget);
    },
  );

  testWidgets(
    'settings: rename, rotate key with confirmation, add member, delete',
    (tester) async {
      await go(tester, '/projects/1/settings', size: tallDesktopSize);
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('abcdef1234567890'), findsWidgets);
      expect(find.text('Can · can@x.io'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Kasa App v2');
      await tester.tap(find.text('Kaydet'));
      await settle(tester);
      expect(api.calls, contains('update 1 Kasa App v2'));
      await tester.tap(find.text('Döndür'));
      await settle(tester);
      expect(find.text('Anahtarı döndür'), findsOneWidget);
      await tester.tap(inDialog(find.text('Döndür')));
      await settle(tester);
      expect(api.calls, contains('rotate 1'));
      await tester.enterText(find.byType(TextField).last, 'yeni@x.io');
      await tester.tap(find.text('Üye ekle'));
      await settle(tester);
      expect(api.calls, contains('addMember yeni@x.io'));
      await tester.tap(find.byIcon(LucideIcons.x));
      await settle(tester);
      expect(api.calls, contains('removeMember 2'));
      await tester.tap(find.text('Projeyi sil'));
      await settle(tester);
      await tester.tap(inDialog(find.text('Sil')));
      await settle(tester);
      expect(api.calls, contains('delete 1'));
      expect(find.text('Projeler'), findsOneWidget);
      await dismissToasts(tester);
    },
  );

  testWidgets('member (non-owner) sees settings read-only', (tester) async {
    await go(tester, '/projects/2/settings', size: tallDesktopSize);
    expect(find.text('Projeyi sil'), findsNothing);
    expect(find.text('Üye ekle'), findsNothing);
    expect(find.textContaining('yalnızca görüntüleme'), findsOneWidget);
  });
}
