import 'dart:convert';

import 'package:sightpane_dashboard/app/router.dart';
import 'package:sightpane_dashboard/app/theme/app_theme.dart';
import 'package:sightpane_dashboard/app/theme/shadcn_localizations_fallback.dart';
import 'package:sightpane_dashboard/core/api.dart';
import 'package:sightpane_dashboard/core/locale.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/l10n/gen/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const desktopSize = Size(1440, 900);
const tallDesktopSize = Size(1440, 2400);
const mobileSize = Size(390, 844);
final testTheme = AppTheme.dark(platform: TargetPlatform.linux);

const testUser = SightpaneUser(id: 1, email: 'ayse@x.io', name: 'Ayşe Yılmaz');

/// The tests run in Turkish; the language is pinned through
/// [initialLocaleProvider] so it does not shift with the host machine's
/// locale.
const testLocale = Locale('tr');

/// Start signed in: the token + the user are already in SharedPreferences.
Future<void> setUpLoggedIn() async {
  await _initFormats();
  SharedPreferences.setMockInitialValues({
    TokenStore.tokenKey: 'tok',
    TokenStore.userKey: jsonEncode(testUser.toJson()),
  });
}

Future<void> setUpLoggedOut() async {
  await _initFormats();
  SharedPreferences.setMockInitialValues({});
}

Future<void> _initFormats() async {
  for (final l in L.supportedLocales) {
    await initializeDateFormatting(l.languageCode);
  }
}

Future<void> settle(WidgetTester tester, {int frames = 4}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> dismissToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 12));
  await tester.pump(const Duration(seconds: 1));
}

Finder inDialog(Finder f) =>
    find.descendant(of: find.byType(AlertDialog), matching: f);

/// Opens the app with the given container; the router is read from that same
/// container so the auth redirect sees the same state.
Future<GoRouter> pumpApp(
  WidgetTester tester,
  ProviderContainer container, {
  String? path,
  Size size = desktopSize,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = container.read(routerProvider);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const _TestApp()),
  );
  await settle(tester);
  if (path != null) {
    router.go(path);
    await settle(tester);
  }
  return router;
}

/// The test counterpart of the app root: the same router, the same locale
/// provider, the same localization delegates — only the theme is pinned.
/// It builds the same tree as `SightpaneApp` so language switching can be tested too.
class _TestApp extends ConsumerWidget {
  const _TestApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ShadcnApp.router(
    theme: testTheme,
    routerConfig: ref.watch(routerProvider),
    locale: ref.watch(localeProvider),
    supportedLocales: L.supportedLocales,
    localizationsDelegates: const [
      L.delegate,
      // shadcn_flutter only ships `en`; the same fallback as in the app.
      FallbackShadcnLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

ProviderContainer testContainer(FakeApi api, {Locale locale = testLocale}) {
  final c = ProviderContainer(
    overrides: [
      ...overridesFor(api),
      initialLocaleProvider.overrideWithValue(locale),
    ].cast(),
    retry: (_, _) => null,
  );
  addTearDown(c.dispose);
  return c;
}

/// An in-memory backend; it records the calls made to it.
class FakeApi implements SightpaneApi {
  FakeApi();
  final calls = <String>[];
  Object? loginError;

  /// The user returned on sign-in; changed when the account language is under
  /// test.
  SightpaneUser loginUser = testUser;
  var projectList = <Project>[
    const Project(
      id: 1,
      name: 'Kasa App',
      apiKey: 'abcdef1234567890',
      role: 'owner',
      sessions24h: 3,
      errors24h: 1,
      openIssues: 2,
    ),
    const Project(id: 2, name: 'Müfettiş', apiKey: 'k2', role: 'member'),
  ];
  var statsValue = ProjectStats(
    days: 7,
    sessions: 12,
    users: 4,
    errors: 3,
    events: 40,
    frames: 200,
    openIssues: 2,
    crashFree: 0.75,
    daily: [
      for (var i = 1; i <= 7; i++)
        DayStat(
          day: '2026-09-0$i',
          sessions: i,
          errors: i % 3,
          events: i * 2,
          users: 1,
        ),
    ],
    platforms: const [NameCount('web', 8), NameCount('linux', 4)],
    releases: const [NameCount('1.0', 12)],
    topIssues: const [
      Issue(
        id: 7,
        title: 'StateError: Bad state: boom',
        exception: 'StateError',
        count: 5,
      ),
    ],
    topEvents: const [NameCount('deposit', 30)],
  );
  var sessionList = <Session>[
    Session(
      id: 'abcdef12-3456',
      projectId: 1,
      startedAt: DateTime(2026, 9, 7, 10),
      lastSeenAt: DateTime(2026, 9, 7, 10, 5),
      userId: 'u1',
      user: const {'email': 'ops@casino.local'},
      platform: 'web',
      release: '1.0',
      errorCount: 1,
      eventCount: 3,
      frameCount: 2,
      ip: '10.1.2.3',
    ),
    Session(
      id: 'ffff0000-1111',
      projectId: 1,
      startedAt: DateTime(2026, 9, 7, 11),
      lastSeenAt: DateTime(2026, 9, 7, 11, 1),
      endedAt: DateTime(2026, 9, 7, 11, 1),
      platform: 'linux',
    ),
  ];
  var issueList = <Issue>[
    Issue(
      id: 7,
      title: 'StateError: Bad state: boom',
      exception: 'StateError',
      count: 5,
      firstSeen: DateTime(2026, 9, 1),
      lastSeen: DateTime(2026, 9, 7),
    ),
    const Issue(id: 8, title: 'Old', exception: 'E', count: 1, resolved: true),
  ];
  var memberList = <Member>[
    const Member(
      userId: 1,
      email: 'ayse@x.io',
      name: 'Ayşe Yılmaz',
      role: 'owner',
    ),
    const Member(userId: 2, email: 'can@x.io', name: 'Can', role: 'member'),
  ];

  SessionDetail detailFor(String id) => SessionDetail.withPointer(
    pointer: [
      PointerSample(
        ts: DateTime(2026, 9, 7, 10, 0, 0, 200),
        x: 0.1,
        y: 0.1,
        kind: 'move',
      ),
      PointerSample(
        ts: DateTime(2026, 9, 7, 10, 0, 0, 400),
        x: 0.3,
        y: 0.2,
        kind: 'move',
      ),
      PointerSample(
        ts: DateTime(2026, 9, 7, 10, 0, 0, 600),
        x: 0.5,
        y: 0.5,
        kind: 'down',
      ),
      PointerSample(
        ts: DateTime(2026, 9, 7, 10, 0, 0, 700),
        x: 0.5,
        y: 0.5,
        kind: 'up',
      ),
    ],
    session: sessionList.firstWhere(
      (s) => s.id == id,
      orElse: () => sessionList.first,
    ),
    items: [
      TimelineItem(
        id: 1,
        ts: DateTime(2026, 9, 7, 10, 0, 1),
        type: 'breadcrumb',
        name: 'navigation',
        body: const {'message': 'push /cashier'},
      ),
      TimelineItem(
        id: 2,
        ts: DateTime(2026, 9, 7, 10, 0, 2),
        type: 'event',
        name: 'deposit',
        body: const {
          'name': 'deposit',
          'props': {'amount': 50},
        },
      ),
      TimelineItem(
        id: 3,
        ts: DateTime(2026, 9, 7, 10, 0, 4),
        type: 'error',
        name: 'StateError: Bad state: boom',
        issueId: 7,
        body: const {
          'exception': 'StateError',
          'message': 'Bad state: boom',
          'stack': '#0 main (package:app/main.dart:1:1)',
          'route': '/cashier',
          'breadcrumbs': [
            {'category': 'ui.click', 'message': 'tap "Kaydet"'},
          ],
        },
      ),
    ],
    frames: [
      Frame(
        seq: 1,
        ts: DateTime(2026, 9, 7, 10, 0, 0),
        width: 160,
        height: 90,
        taps: const [Tap(0.5, 0.5)],
      ),
      Frame(seq: 2, ts: DateTime(2026, 9, 7, 10, 0, 3), width: 160, height: 90),
    ],
  );

  @override
  Future<AuthSession> login(String email, String password) async {
    calls.add('login $email');
    if (loginError != null) throw loginError!;
    return AuthSession(token: 'tok', user: loginUser);
  }

  @override
  Future<AuthSession> register(
    String email,
    String name,
    String password,
  ) async {
    calls.add('register $email $name');
    if (loginError != null) throw loginError!;
    return AuthSession(
      token: 'tok',
      user: SightpaneUser(id: 9, email: email, name: name),
    );
  }

  @override
  Future<void> logout() async => calls.add('logout');
  SightpaneUser meUser = testUser;
  @override
  Future<SightpaneUser> me() async => meUser;
  @override
  Future<SightpaneUser> updateMe({String? locale}) async {
    calls.add('updateMe locale=$locale');
    meUser = SightpaneUser(
      id: meUser.id,
      email: meUser.email,
      name: meUser.name,
      locale: locale ?? meUser.locale,
    );
    return meUser;
  }

  @override
  Future<List<Project>> projects() async => projectList;
  @override
  Future<Project> project(int id) async => projectList.firstWhere(
    (p) => p.id == id,
    orElse: () => throw const ApiException(404, 'project not found'),
  );
  @override
  Future<Project> createProject(
    String name, {
    String platform = 'flutter',
  }) async {
    calls.add('create $name $platform');
    final p = Project(
      id: 3,
      name: name,
      apiKey: 'newkey1234567890',
      platform: platform,
      role: 'owner',
    );
    projectList = [...projectList, p];
    return p;
  }

  @override
  Future<Project> updateProject(
    int id, {
    required String name,
    String platform = 'flutter',
  }) async {
    calls.add('update $id $name');
    return projectList.first;
  }

  @override
  Future<void> deleteProject(int id) async => calls.add('delete $id');
  @override
  Future<String> rotateKey(int id) async {
    calls.add('rotate $id');
    return 'rotated';
  }

  @override
  Future<List<Member>> members(int id) async => memberList;
  @override
  Future<List<Member>> addMember(
    int id,
    String email, {
    String role = 'member',
  }) async {
    calls.add('addMember $email');
    return memberList;
  }

  @override
  Future<List<Member>> removeMember(int id, int userId) async {
    calls.add('removeMember $userId');
    return memberList;
  }

  var liveValue = LiveStatus(
    count: 2,
    visitors: 2,
    routes: const [NameCount('/cashier', 1), NameCount('/tables', 1)],
    viewers: [
      LiveViewer(
        sessionId: 'abcdef12-3456',
        userLabel: 'ops@casino.local',
        ip: '10.1.2.3',
        browser: 'Chrome',
        platform: 'web',
        route: '/cashier',
        lastSeen: DateTime.now(),
        startedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      LiveViewer(
        sessionId: 'ffff0000-1111',
        userLabel: 'anonim',
        ip: '10.1.2.9',
        browser: 'Firefox',
        platform: 'web',
        route: '/tables',
        lastSeen: DateTime.now(),
        startedAt: DateTime.now(),
      ),
    ],
  );

  @override
  Future<LiveStatus> live(int id, {int windowSeconds = 60}) async {
    calls.add('live $id');
    return liveValue;
  }

  @override
  Future<ProjectStats> stats(int id, {int days = 14}) async {
    calls.add('stats $id $days');
    return statsValue;
  }

  @override
  Future<List<Session>> sessions(
    int projectId, {
    bool onlyErrors = false,
    String user = '',
    int limit = 100,
  }) async {
    calls.add('sessions $projectId errors=$onlyErrors user=$user');
    return onlyErrors
        ? sessionList.where((s) => s.errorCount > 0).toList()
        : sessionList;
  }

  @override
  Future<SessionDetail> session(String id) async => detailFor(id);
  @override
  String frameUrl(String sessionId, int seq) =>
      'http://127.0.0.1:1/f/$sessionId/$seq.png';
  @override
  Future<List<Issue>> issues(
    int projectId, {
    bool includeResolved = false,
  }) async => includeResolved
      ? issueList
      : issueList.where((i) => !i.resolved).toList();
  @override
  Future<IssueDetail> issue(int id) async => IssueDetail(
    issue: issueList.firstWhere((i) => i.id == id),
    occurrences: [detailFor('abcdef12-3456').items.last],
  );
  @override
  Future<void> resolveIssue(int id, {bool undo = false}) async {
    calls.add('resolve $id undo=$undo');
    issueList = [
      for (final i in issueList)
        i.id == id
            ? Issue(
                id: i.id,
                title: i.title,
                exception: i.exception,
                count: i.count,
                resolved: !undo,
              )
            : i,
    ];
  }

  @override
  Future<List<EventCount>> eventSummary(int projectId, {int days = 30}) async =>
      const [
        EventCount(name: 'deposit', day: '2026-09-07', count: 30, users: 3),
        EventCount(name: 'deposit', day: '2026-09-06', count: 10, users: 2),
        EventCount(name: 'login', day: '2026-09-07', count: 5, users: 5),
      ];
}

List<dynamic> overridesFor(FakeApi api) => [apiProvider.overrideWithValue(api)];
