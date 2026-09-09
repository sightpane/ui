import 'package:sightpane_dashboard/core/api.dart';
import 'package:sightpane_dashboard/features/auth/auth_pages.dart';
import 'package:sightpane_dashboard/features/projects/projects_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'helpers/test_app.dart';

void main() {
  late FakeApi api;
  setUp(() async {
    api = FakeApi();
    await setUpLoggedOut();
  });

  Future<void> pump(WidgetTester tester) => pumpApp(tester, testContainer(api));

  testWidgets(
    'logged-out users land on login; a valid login opens the projects list',
    (tester) async {
      await pump(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      await tester.tap(find.text('Giriş yap').last);
      await settle(tester);
      expect(find.text('Geçerli bir e-posta girin'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'ayse@x.io');
      await tester.enterText(find.byType(TextField).at(1), 'secret1');
      await tester.tap(find.widgetWithText(PrimaryButton, 'Giriş yap'));
      await settle(tester);
      expect(api.calls, ['login ayse@x.io']);
      expect(find.byType(ProjectsPage), findsOneWidget);
      expect(find.text('Kasa App'), findsOneWidget);
    },
  );

  testWidgets('a rejected login shows a friendly error', (tester) async {
    api.loginError = const ApiException(401, 'invalid email or password');
    await pump(tester);
    await tester.enterText(find.byType(TextField).at(0), 'ayse@x.io');
    await tester.enterText(find.byType(TextField).at(1), 'bad');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Giriş yap'));
    await settle(tester);
    expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('register validates and creates the account', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Kayıt olun'));
    await settle(tester);
    expect(find.byType(RegisterPage), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Mert Kaya');
    await tester.enterText(find.byType(TextField).at(1), 'mert@x.io');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '654321');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Kayıt ol'));
    await settle(tester);
    expect(find.text('Şifreler eşleşmiyor'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Kayıt ol'));
    await settle(tester);
    expect(api.calls, ['register mert@x.io Mert Kaya']);
    expect(find.byType(ProjectsPage), findsOneWidget);
  });

  testWidgets('logout returns to login', (tester) async {
    await setUpLoggedIn();
    await pump(tester);
    expect(find.byType(ProjectsPage), findsOneWidget);
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.logOut));
    await settle(tester);
    expect(api.calls, ['logout']);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
