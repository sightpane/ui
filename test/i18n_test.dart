import 'package:sightpane_dashboard/core/api.dart';
import 'package:sightpane_dashboard/core/auth.dart';
import 'package:sightpane_dashboard/core/locale.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/features/auth/auth_pages.dart';
import 'package:sightpane_dashboard/l10n/gen/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_app.dart';

void main() {
  late L tr, en;
  setUpAll(() async {
    tr = await L.delegate.load(const Locale('tr'));
    en = await L.delegate.load(const Locale('en'));
  });

  group('locale selection order', () {
    // The order is a contract: a shared link (?lang=) outranks even the user's
    // own choice, because whoever opens the link wants to see that language;
    // the account language only kicks in when no choice was made in this
    // browser.
    test('?lang= comes before everything else', () {
      expect(
        resolveStartupLocale(
          stored: 'tr',
          platform: const Locale('tr'),
          url: Uri.parse('https://hog.local/projects?lang=en'),
        ),
        const Locale('en'),
      );
    });
    test('the choice made in this browser beats the browser language', () {
      expect(
        resolveStartupLocale(
          stored: 'en',
          platform: const Locale('tr'),
          url: Uri.parse('https://hog.local/'),
        ),
        const Locale('en'),
      );
    });
    test('with no choice, the browser language is used', () {
      expect(
        resolveStartupLocale(
          platform: const Locale('en', 'US'),
          url: Uri.parse('https://hog.local/'),
        ),
        const Locale('en'),
      );
    });
    test('an unsupported language is ignored and Turkish is used', () {
      expect(
        resolveStartupLocale(
          stored: 'de',
          platform: const Locale('fr'),
          url: Uri.parse('https://hog.local/?lang=es'),
        ),
        const Locale('tr'),
      );
    });
  });

  group('describeError', () {
    // REGRESSION: the dashboard used to tell 401s apart with
    // `message.contains('password')`, so fixing the backend wording broke the
    // dashboard. The criterion is now `code`.
    test('translates by code even when the server text changes', () {
      const e = ApiException(
        401,
        'these credentials do not match our records',
        code: 'auth.invalid_credentials',
      );
      expect(describeError(tr, e), 'E-posta veya şifre hatalı.');
      expect(describeError(en, e), 'Wrong email or password.');
    });
    test('the same status code with two meanings is told apart', () {
      expect(
        describeError(
          tr,
          const ApiException(401, 'x', code: 'auth.invalid_token'),
        ),
        'Oturum geçersiz; yeniden giriş yapın.',
      );
    });
    test('a network error shows the server address', () {
      const e = ApiException(
        0,
        'cannot reach http://localhost:8790: SocketException',
        code: ApiException.codeNetwork,
        detail: 'http://localhost:8790',
      );
      expect(describeError(en, e), contains('http://localhost:8790'));
      expect(describeError(en, e), startsWith('Cannot reach the server'));
    });
    test(
      'an older backend without codes keeps working off the status code',
      () {
        expect(
          describeError(tr, const ApiException(403, 'owner role required')),
          'Bu işlem için proje sahibi olmalısınız.',
        );
      },
    );
    test('an unrecognised code shows the server text as it is', () {
      expect(
        describeError(
          tr,
          const ApiException(418, 'i am a teapot', code: 'x.y'),
        ),
        'i am a teapot',
      );
    });
  });

  group('language switch', () {
    late FakeApi api;
    setUp(() async {
      api = FakeApi();
      await setUpLoggedIn();
    });

    testWidgets('the top bar switches to English and the choice sticks', (
      tester,
    ) async {
      await pumpApp(tester, testContainer(api), path: '/projects');
      expect(find.text('Projeler'), findsOneWidget);
      expect(find.text('Yeni proje'), findsOneWidget);

      await tester.tap(find.widgetWithText(GhostButton, 'English'));
      await settle(tester);

      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('New project'), findsOneWidget);
      expect(find.text('Projeler'), findsNothing);
      // The left menu, the KPIs and the table headers have to turn over too, not
      // just the title.
      expect(find.text('Sessions 24h'), findsWidgets);

      // The choice is stored both in the browser and on the account, so the same
      // language comes back when signing in from another device.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(localeStorageKey), 'en');
      expect(api.calls, contains('updateMe locale=en'));
    });

    testWidgets('the language can be changed on the login page too', (
      tester,
    ) async {
      await setUpLoggedOut();
      await pumpApp(tester, testContainer(api));
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Giriş yap'), findsWidgets);

      await tester.tap(find.widgetWithText(GhostButton, 'English'));
      await settle(tester);

      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Giriş yap'), findsNothing);
      // Nothing is written to the server while signed out; it is kept in the
      // browser only.
      expect(api.calls, isNot(contains('updateMe locale=en')));
    });

    testWidgets('starting in English, numbers and dates are English too', (
      tester,
    ) async {
      await pumpApp(
        tester,
        testContainer(api, locale: const Locale('en')),
        path: '/projects/1/issues',
        size: tallDesktopSize,
      );
      expect(find.text('Issues'), findsWidgets);
      expect(find.text('Show resolved'), findsOneWidget);
      // Table headers are upper-cased; in English that is a dotless I.
      expect(find.text('EXCEPTION'), findsOneWidget);

      await tester.tap(find.text('StateError: Bad state: boom'));
      await settle(tester);
      expect(
        find.text('5 times · first Sep 1, 2026 00:00 · last Sep 7, 2026 00:00'),
        findsOneWidget,
      );
      await dismissToasts(tester);
    });

    testWidgets(
      'the account language applies when this browser has no choice',
      (tester) async {
        api.meUser = const SightpaneUser(
          id: 1,
          email: 'ayse@x.io',
          name: 'Ayşe Yılmaz',
          locale: 'en',
        );
        api.loginUser = api.meUser;
        await setUpLoggedOut();
        await pumpApp(tester, testContainer(api));
        expect(find.text('Giriş yap'), findsWidgets);
        await tester.enterText(find.byType(TextField).at(0), 'ayse@x.io');
        await tester.enterText(find.byType(TextField).at(1), 'secret1');
        await tester.tap(find.widgetWithText(PrimaryButton, 'Giriş yap'));
        await settle(tester);
        expect(find.text('Projects'), findsOneWidget);
      },
    );
  });
}
