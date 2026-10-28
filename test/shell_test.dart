import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:sightpane_dashboard/features/issues/issues_page.dart';
import 'package:sightpane_dashboard/features/projects/projects_page.dart';
import 'package:sightpane_dashboard/features/surveys/surveys_page.dart';
import 'package:sightpane_dashboard/shell/app_shell.dart';

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

  testWidgets('a project on desktop gets the grouped sidebar, no top bar', (
    tester,
  ) async {
    await go(tester, '/projects/1/releases');
    expect(find.byType(ProjectSidebar), findsOneWidget);
    expect(find.byType(TopBar), findsNothing);
    // Group labels use the Turkish dotted capital İ.
    expect(find.text('İZLEME'), findsOneWidget);
    expect(find.text('ÜRÜN ANALİTİĞİ'), findsOneWidget);
    expect(find.text('YAYIN'), findsOneWidget);
    expect(find.text('GÜVENİLİRLİK'), findsOneWidget);
    // The account and the AGPL source address moved into the sidebar foot.
    expect(find.text('AGPL-3.0'), findsOneWidget);
    expect(find.byIcon(LucideIcons.logOut), findsOneWidget);
    // The open-issue count of the project sits next to "Hatalar".
    expect(
      find.descendant(
        of: find.widgetWithText(GhostButton, 'Hatalar'),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(GhostButton, 'Hatalar'));
    await settle(tester);
    expect(find.byType(IssuesPage), findsOneWidget);
  });

  testWidgets('the project switcher lists projects and the way back', (
    tester,
  ) async {
    await go(tester, '/projects/1/releases');
    await tester.tap(find.byIcon(LucideIcons.chevronsUpDown));
    await settle(tester);
    expect(find.text('Proje değiştir'), findsOneWidget);
    await tester.tap(find.text('Tüm projeler'));
    await settle(tester);
    expect(find.byType(ProjectsPage), findsOneWidget);
  });

  testWidgets('⌘K / Ctrl+K opens a page search that jumps to the hit', (
    tester,
  ) async {
    await go(tester, '/projects/1/releases');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'anket');
    await settle(tester);
    expect(find.text('Hatalar'), findsOneWidget); // only the sidebar's
    await tester.tap(
      find.descendant(
        of: find.byType(CommandItem),
        matching: find.text('Anketler & Geri Bildirim'),
      ),
    );
    await settle(tester);
    expect(find.byType(SurveysPage), findsOneWidget);
  });

  testWidgets('on a phone the top bar and the horizontal menu stay', (
    tester,
  ) async {
    await go(tester, '/projects/1/releases', size: mobileSize);
    expect(find.byType(TopBar), findsOneWidget);
    expect(find.byType(ProjectNav), findsOneWidget);
    expect(find.byType(ProjectSidebar), findsNothing);
  });

  testWidgets('the project list keeps the top bar', (tester) async {
    await go(tester, '/projects');
    expect(find.byType(TopBar), findsOneWidget);
    expect(find.byType(ProjectSidebar), findsNothing);
  });
}
