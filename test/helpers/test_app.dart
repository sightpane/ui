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

/// Pumps a single widget with the delegates the app uses, for a test about a
/// widget rather than a page. Anything with a route goes through pumpApp.
Future<void> pumpWidgetWithL10n(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ShadcnApp(
      theme: testTheme,
      locale: testLocale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [
        L.delegate,
        FallbackShadcnLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(child: SingleChildScrollView(child: child)),
    ),
  );
  await settle(tester);
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
      orgId: 1,
    ),
    const Project(id: 2, name: 'Müfettiş', apiKey: 'k2', role: 'member', orgId: 1),
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
      device: const {
        'platform_category': 'web',
        'browser': 'Chrome',
        'browser_version': '128.0.6613.120',
        'os': 'macOS',
        'os_version': '14.5',
        'arch': 'arm64',
        'cpu_cores': 8,
        'locale': 'tr-TR',
        'screen': {'w': 1920, 'h': 1080, 'dpr': 2.0},
      },
    ),
    Session(
      id: 'ffff0000-1111',
      projectId: 1,
      startedAt: DateTime(2026, 9, 7, 11),
      lastSeenAt: DateTime(2026, 9, 7, 11, 1),
      endedAt: DateTime(2026, 9, 7, 11, 1),
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

  SessionDetail detailFor(String id) {
    if (id == 'dom-session') {
      return SessionDetail.withPointer(
        pointer: const [],
        hasDom: true,
        session: Session(
          id: 'dom-session',
          projectId: 1,
          startedAt: DateTime(2026, 9, 7, 10, 0, 0),
          lastSeenAt: DateTime(2026, 9, 7, 10, 0, 10),
          sdkName: '@sightpane/browser',
          sdkVersion: '0.1.0',
          platform: 'web',
          currentRoute: 'https://app.local/shop',
          device: const {
            'platform_category': 'web',
            'browser': 'Chrome',
            'browser_version': '128.0.0.0',
            'os': 'macOS',
            'os_version': '14.5',
          },
        ),
        items: [
          TimelineItem(
            id: 101,
            ts: DateTime(2026, 9, 7, 10, 0, 1),
            type: 'dom',
            name: 'snapshot',
            body: const {'kind': 'snapshot', 'tree': '<div>Hello</div>'},
          ),
          TimelineItem(
            id: 102,
            ts: DateTime(2026, 9, 7, 10, 0, 3),
            type: 'dom',
            name: 'mutation',
            body: const {'kind': 'mutation', 'changes': 2},
          ),
        ],
        frames: const [],
      );
    }
    return SessionDetail.withPointer(
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
        sessionId: id,
        platform: 'web',
        browser: 'Chrome',
        device: const {
          'platform_category': 'web',
          'browser': 'Chrome',
          'browser_version': '128.0.6613.120',
          'os': 'macOS',
          'os_version': '14.5',
        },
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
  }

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
    int? retentionDays,
    int? quotaItemsPerMinute,
    String? storeIp,
    String? scrubRulesJson,
  }) async {
    calls.add('update $id $name');
    return projectList.first;
  }

  @override
  Future<void> deleteUserData(int projectId, String userId) async =>
      calls.add('deleteUserData $projectId $userId');

  @override
  String userExportUrl(int projectId, String userId) =>
      '/api/v1/projects/$projectId/users/$userId/export';

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
    String query = '',
    int limit = 100,
  }) async {
    calls.add('sessions $projectId errors=$onlyErrors user=$user query=$query');
    return onlyErrors
        ? sessionList.where((s) => s.errorCount > 0).toList()
        : sessionList;
  }

  var usersValue = ProjectUsersData(
    totalUsers: 2,
    activeUsers: 2,
    avgDurationSec: 150.0,
    sessionsPerUser: 1.5,
    errorUserCount: 1,
    daily: [
      const UserDailyStat(
        day: '2026-09-07',
        activeUsers: 2,
        errorUsers: 1,
        avgDurationSec: 150.0,
      ),
    ],
    users: [
      UserSummary(
        userId: 'u1',
        email: 'ops@casino.local',
        name: 'Ops User',
        sessionCount: 2,
        totalDurationSec: 300.0,
        avgDurationSec: 150.0,
        errorCount: 1,
        errorSessionCount: 1,
        firstSeen: DateTime(2026, 9, 1),
        lastSeen: DateTime(2026, 9, 7),
        lastPlatform: 'web',
        lastBrowser: 'Chrome',
        lastIP: '10.1.2.3',
        user: const {'email': 'ops@casino.local', 'role': 'admin'},
      ),
      UserSummary(
        userId: 'u2',
        sessionCount: 1,
        totalDurationSec: 60.0,
        avgDurationSec: 60.0,
        errorCount: 0,
        errorSessionCount: 0,
        firstSeen: DateTime(2026, 9, 6),
        lastSeen: DateTime(2026, 9, 7),
        lastPlatform: 'linux',
        lastIP: '10.1.2.4',
      ),
    ],
  );

  @override
  Future<ProjectUsersData> users(
    int projectId, {
    int days = 14,
    String query = '',
  }) async {
    calls.add('users $projectId days=$days query=$query');
    return usersValue;
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
    String query = '',
  }) async {
    calls.add('issues $projectId resolved=$includeResolved query=$query');
    return includeResolved
      ? issueList
      : issueList.where((i) => !i.resolved).toList();
  }
  @override
  Future<IssueDetail> issue(int id) async => IssueDetail(
    issue: issueList.firstWhere((i) => i.id == id),
    occurrences: [detailFor('abcdef12-3456').items.last],
    latestSession: sessionList.firstWhere((s) => s.id == 'abcdef12-3456'),
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

  var commentsList = <IssueComment>[
    IssueComment(
      id: 1,
      issueId: 7,
      userId: 1,
      userEmail: 'owner@casino.local',
      userName: 'Owner',
      body: 'Looking into this crash',
      createdAt: DateTime(2026, 9, 7, 10, 30),
    ),
  ];
  var rulesList = <FingerprintRule>[];

  @override
  Future<void> assignIssue(int id, int? userId) async {
    calls.add('assignIssue $id $userId');
    issueList = [
      for (final i in issueList)
        i.id == id
            ? Issue(
                id: i.id,
                title: i.title,
                exception: i.exception,
                count: i.count,
                resolved: i.resolved,
                status: i.status,
                assigneeUserId: userId,
                assigneeEmail: userId == 1 ? 'owner@casino.local' : 'dev@casino.local',
              )
            : i,
    ];
  }

  @override
  Future<void> setIssueStatus(int id, String status) async {
    calls.add('setIssueStatus $id $status');
    issueList = [
      for (final i in issueList)
        i.id == id
            ? Issue(
                id: i.id,
                title: i.title,
                exception: i.exception,
                count: i.count,
                resolved: status == 'resolved',
                status: status,
              )
            : i,
    ];
  }

  @override
  Future<void> snoozeIssue(int id, {DateTime? until, int countThreshold = 0}) async {
    calls.add('snoozeIssue $id until=$until threshold=$countThreshold');
    issueList = [
      for (final i in issueList)
        i.id == id
            ? Issue(
                id: i.id,
                title: i.title,
                exception: i.exception,
                count: i.count,
                resolved: false,
                status: 'snoozed',
                snoozeUntil: until,
                snoozeCountThreshold: countThreshold,
              )
            : i,
    ];
  }

  @override
  Future<void> mergeIssue(int sourceId, int targetId) async {
    calls.add('mergeIssue $sourceId -> $targetId');
    issueList = issueList.where((i) => i.id != sourceId).toList();
  }

  @override
  Future<List<IssueComment>> issueComments(int issueId) async {
    calls.add('issueComments $issueId');
    return commentsList.where((c) => c.issueId == issueId).toList();
  }

  @override
  Future<IssueComment> addIssueComment(int issueId, String body) async {
    calls.add('addIssueComment $issueId $body');
    final c = IssueComment(
      id: commentsList.length + 1,
      issueId: issueId,
      userId: 1,
      userEmail: 'owner@casino.local',
      userName: 'Owner',
      body: body,
      createdAt: DateTime.now(),
    );
    commentsList = [...commentsList, c];
    return c;
  }

  @override
  Future<List<FingerprintRule>> fingerprintRules(int projectId) async {
    calls.add('fingerprintRules $projectId');
    return rulesList.where((r) => r.projectId == projectId).toList();
  }

  @override
  Future<FingerprintRule> createFingerprintRule(
    int projectId, {
    String exceptionMatch = '',
    String messageGlob = '',
    String stackContains = '',
    required String action,
    String groupFingerprint = '',
    int priority = 0,
  }) async {
    calls.add('createFingerprintRule $projectId $action');
    final r = FingerprintRule(
      id: rulesList.length + 1,
      projectId: projectId,
      exceptionMatch: exceptionMatch,
      messageGlob: messageGlob,
      stackContains: stackContains,
      action: action,
      groupFingerprint: groupFingerprint,
      priority: priority,
      createdAt: DateTime.now(),
    );
    rulesList = [...rulesList, r];
    return r;
  }

  @override
  Future<void> deleteFingerprintRule(int projectId, int ruleId) async {
    calls.add('deleteFingerprintRule $projectId $ruleId');
    rulesList = rulesList.where((r) => r.id != ruleId).toList();
  }

  @override
  Future<List<EventCount>> eventSummary(int projectId, {int days = 30}) async =>
      const [
        EventCount(name: 'deposit', day: '2026-09-07', count: 30, users: 3),
        EventCount(name: 'deposit', day: '2026-09-06', count: 10, users: 2),
        EventCount(name: 'login', day: '2026-09-07', count: 5, users: 5),
      ];

  var releaseHealthList = <ReleaseHealth>[
    ReleaseHealth(
      version: '1.0.0',
      firstSeen: DateTime(2026, 9, 1),
      lastSeen: DateTime(2026, 9, 7),
      sessionCount: 20,
      errorSessionCount: 2,
      errorCount: 3,
      userCount: 15,
      crashFreeRate: 90.0,
      adoptionRate: 80.0,
    ),
    ReleaseHealth(
      version: '0.9.0',
      firstSeen: DateTime(2026, 8, 15),
      lastSeen: DateTime(2026, 8, 31),
      sessionCount: 5,
      errorSessionCount: 0,
      errorCount: 0,
      userCount: 4,
      crashFreeRate: 100.0,
      adoptionRate: 20.0,
    ),
  ];

  @override
  Future<List<ReleaseHealth>> releases(int projectId) async {
    calls.add('releases $projectId');
    return releaseHealthList;
  }

  @override
  Future<ReleaseHealth> releaseHealth(int projectId, String version) async {
    calls.add('releaseHealth $projectId $version');
    return releaseHealthList.firstWhere(
      (r) => r.version == version,
      orElse: () => ReleaseHealth(
        version: version,
        firstSeen: DateTime.now(),
        lastSeen: DateTime.now(),
        sessionCount: 0,
        errorSessionCount: 0,
        errorCount: 0,
        userCount: 0,
        crashFreeRate: 100.0,
        adoptionRate: 0.0,
      ),
    );
  }


  var alertChannelList = <AlertChannel>[
    const AlertChannel(
      id: 1,
      projectId: 1,
      name: 'Ops Slack',
      kind: 'slack',
      target: 'https://hooks.slack.com/services/xxx',
    ),
  ];
  var alertRuleList = <AlertRule>[
    const AlertRule(
      id: 1,
      projectId: 1,
      name: 'New Issues',
      kind: 'new_issue',
      channelIds: [1],
      enabled: true,
    ),
  ];

  @override
  Future<List<AlertChannel>> alertChannels(int projectId) async {
    calls.add('alertChannels $projectId');
    return alertChannelList.where((c) => c.projectId == projectId).toList();
  }

  @override
  Future<AlertChannel> createAlertChannel(
    int projectId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  }) async {
    calls.add('createAlertChannel $projectId $name $kind $target');
    final ch = AlertChannel(
      id: alertChannelList.length + 1,
      projectId: projectId,
      name: name,
      kind: kind,
      target: target,
      secret: secret,
      createdAt: DateTime.now(),
    );
    alertChannelList = [...alertChannelList, ch];
    return ch;
  }

  @override
  Future<AlertChannel> updateAlertChannel(
    int projectId,
    int channelId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  }) async {
    calls.add('updateAlertChannel $projectId $channelId $name');
    final ch = AlertChannel(
      id: channelId,
      projectId: projectId,
      name: name,
      kind: kind,
      target: target,
      secret: secret,
    );
    alertChannelList = [
      for (final c in alertChannelList) c.id == channelId ? ch : c,
    ];
    return ch;
  }

  @override
  Future<void> deleteAlertChannel(int projectId, int channelId) async {
    calls.add('deleteAlertChannel $projectId $channelId');
    alertChannelList =
        alertChannelList.where((c) => c.id != channelId).toList();
    alertRuleList = [
      for (final r in alertRuleList)
        AlertRule(
          id: r.id,
          projectId: r.projectId,
          name: r.name,
          kind: r.kind,
          params: r.params,
          channelIds: r.channelIds.where((id) => id != channelId).toList(),
          enabled: r.enabled,
          createdAt: r.createdAt,
        ),
    ];
  }

  @override
  Future<void> testAlertChannel(int projectId, int channelId) async {
    calls.add('testAlertChannel $projectId $channelId');
  }

  @override
  Future<List<AlertRule>> alertRules(int projectId) async {
    calls.add('alertRules $projectId');
    return alertRuleList.where((r) => r.projectId == projectId).toList();
  }

  @override
  Future<AlertRule> createAlertRule(
    int projectId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    bool enabled = true,
  }) async {
    calls.add('createAlertRule $projectId $name $kind');
    final r = AlertRule(
      id: alertRuleList.length + 1,
      projectId: projectId,
      name: name,
      kind: kind,
      params: params,
      channelIds: channelIds,
      enabled: enabled,
      createdAt: DateTime.now(),
    );
    alertRuleList = [...alertRuleList, r];
    return r;
  }

  @override
  Future<AlertRule> updateAlertRule(
    int projectId,
    int ruleId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    required bool enabled,
  }) async {
    calls.add('updateAlertRule $projectId $ruleId enabled=$enabled');
    final r = AlertRule(
      id: ruleId,
      projectId: projectId,
      name: name,
      kind: kind,
      params: params,
      channelIds: channelIds,
      enabled: enabled,
    );
    alertRuleList = [
      for (final existing in alertRuleList)
        existing.id == ruleId ? r : existing,
    ];
    return r;
  }

  @override
  Future<void> deleteAlertRule(int projectId, int ruleId) async {
    calls.add('deleteAlertRule $projectId $ruleId');
    alertRuleList = alertRuleList.where((r) => r.id != ruleId).toList();
  }

  var performanceSummaryList = <PerformanceSummaryItem>[
    const PerformanceSummaryItem(
      op: 'navigation',
      name: 'route:/dashboard',
      count: 450,
      p50: 120.0,
      p95: 280.0,
      avgDuration: 135.0,
      errorCount: 0,
      errorRate: 0.0,
    ),
    const PerformanceSummaryItem(
      op: 'http.client',
      name: 'GET /api/v1/sessions',
      count: 1200,
      p50: 85.0,
      p95: 350.0,
      avgDuration: 95.0,
      errorCount: 12,
      errorRate: 0.01,
    ),
  ];
  var performanceOpsList = <String>['navigation', 'http.client'];

  @override
  Future<PerformanceResponse> performance(
    int projectId, {
    int days = 14,
    String op = '',
  }) async {
    calls.add('performance $projectId days=$days op=$op');
    final filtered = op.isEmpty
        ? performanceSummaryList
        : performanceSummaryList.where((s) => s.op == op).toList();
    return PerformanceResponse(
      summary: filtered,
      ops: performanceOpsList,
    );
  }

  @override
  Future<TransactionDetailResponse> transactionDetail(
    int projectId, {
    required String name,
    String op = '',
    int days = 14,
  }) async {
    calls.add('transactionDetail $projectId name=$name op=$op days=$days');
    return TransactionDetailResponse(
      op: op.isNotEmpty ? op : 'navigation',
      name: name,
      count: 100,
      p50: 110.0,
      p95: 250.0,
      avgDuration: 125.0,
      errorCount: 2,
      errorRate: 0.02,
      daily: [
        const DailyPerformancePoint(
          date: '2026-09-08',
          count: 50,
          p50: 105.0,
          p95: 240.0,
          avgDuration: 120.0,
        ),
        const DailyPerformancePoint(
          date: '2026-09-09',
          count: 50,
          p50: 115.0,
          p95: 260.0,
          avgDuration: 130.0,
        ),
      ],
      samples: [
        SpanSample(
          id: 1,
          sessionId: 'abcdef12-3456',
          ts: DateTime(2026, 9, 9, 12, 0),
          durationMs: 450.0,
          status: 'ok',
        ),
      ],
    );
  }

  var orgList = <Org>[
    const Org(id: 1, name: 'Default Org', slug: 'default-org', role: 'owner'),
  ];
  var orgMemberList = <OrgMember>[
    const OrgMember(userId: 1, email: 'ayse@x.io', name: 'Ayşe Yılmaz', role: 'owner'),
  ];
  var auditLogList = <AuditLogEntry>[
    AuditLogEntry(
      id: 1,
      orgId: 1,
      action: 'key.rotate',
      targetType: 'project',
      targetId: '1',
      ip: '127.0.0.1',
      createdAt: DateTime(2026, 9, 10, 10, 0),
    ),
  ];
  var apiTokenList = <ApiToken>[
    ApiToken(
      id: 1,
      orgId: 1,
      name: 'CI Token',
      scopes: ['sourcemaps:write'],
      createdBy: 1,
      createdAt: DateTime(2026, 9, 10, 10, 0),
    ),
  ];

  @override
  Future<List<Org>> orgs() async {
    calls.add('orgs');
    return orgList;
  }

  @override
  Future<Org> createOrg(String name) async {
    calls.add('createOrg $name');
    final o = Org(id: orgList.length + 1, name: name, slug: name.toLowerCase(), role: 'owner');
    orgList.add(o);
    return o;
  }

  @override
  Future<Org> org(int id) async {
    calls.add('org $id');
    return orgList.firstWhere(
      (o) => o.id == id,
      orElse: () => Org(id: id, name: 'Org $id', slug: 'org-$id', role: 'owner'),
    );
  }

  @override
  Future<List<OrgMember>> orgMembers(int orgId) async {
    calls.add('orgMembers $orgId');
    return orgMemberList;
  }

  @override
  Future<List<OrgMember>> addOrgMember(int orgId, String email, {String role = 'member'}) async {
    calls.add('addOrgMember $orgId email=$email role=$role');
    final m = OrgMember(userId: orgMemberList.length + 1, email: email, name: email.split('@').first, role: role);
    orgMemberList.add(m);
    return orgMemberList;
  }

  @override
  Future<void> updateOrgMemberRole(int orgId, int userId, String role) async {
    calls.add('updateOrgMemberRole $orgId userId=$userId role=$role');
  }

  @override
  Future<void> removeOrgMember(int orgId, int userId) async {
    calls.add('removeOrgMember $orgId userId=$userId');
    orgMemberList.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<List<AuditLogEntry>> auditLogs(int orgId, {int? projectId, int limit = 100}) async {
    calls.add('auditLogs $orgId projectId=$projectId limit=$limit');
    return auditLogList;
  }

  @override
  Future<List<ApiToken>> apiTokens(int orgId) async {
    calls.add('apiTokens $orgId');
    return apiTokenList;
  }

  @override
  Future<ApiToken> createApiToken(int orgId, {required String name, required List<String> scopes, DateTime? expiresAt}) async {
    calls.add('createApiToken $orgId name=$name scopes=$scopes');
    final t = ApiToken(
      id: apiTokenList.length + 1,
      orgId: orgId,
      name: name,
      scopes: scopes,
      createdBy: 1,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      secret: 'sp_fake_secret_token_123',
    );
    apiTokenList.add(t);
    return t;
  }

  @override
  Future<void> deleteApiToken(int orgId, int tokenId) async {
    calls.add('deleteApiToken $orgId tokenId=$tokenId');
    apiTokenList.removeWhere((t) => t.id == tokenId);
  }

  var funnelList = <Funnel>[
    Funnel(
      id: 1,
      projectId: 1,
      name: 'Onboarding Funnel',
      description: 'Sign-up flow to first payment',
      steps: const [
        FunnelStep(name: 'page_view'),
        FunnelStep(name: 'signup_submit'),
        FunnelStep(name: 'checkout_success'),
      ],
      conversionWindowSeconds: 86400,
      createdAt: DateTime(2026, 9, 1),
    ),
  ];

  var funnelResultValue = const FunnelResult(
    funnelId: 1,
    periodDays: 7,
    totalSessions: 100,
    completedSessions: 42,
    overallConversionRate: 0.42,
    medianConversionSeconds: 185.0,
    steps: [
      FunnelStepResult(
        stepIndex: 0,
        name: 'page_view',
        count: 100,
        conversionRate: 1.0,
        dropOffCount: 30,
        dropOffRate: 0.30,
      ),
      FunnelStepResult(
        stepIndex: 1,
        name: 'signup_submit',
        count: 70,
        conversionRate: 0.70,
        dropOffCount: 28,
        dropOffRate: 0.40,
      ),
      FunnelStepResult(
        stepIndex: 2,
        name: 'checkout_success',
        count: 42,
        conversionRate: 0.42,
        dropOffCount: 0,
        dropOffRate: 0.0,
      ),
    ],
  );

  @override
  Future<List<Funnel>> funnels(int projectId) async {
    calls.add('funnels $projectId');
    return funnelList.where((f) => f.projectId == projectId).toList();
  }

  @override
  Future<Funnel> createFunnel(
    int projectId, {
    required String name,
    String description = '',
    required List<FunnelStep> steps,
    int conversionWindowSeconds = 86400,
  }) async {
    calls.add('createFunnel $projectId name=$name');
    final f = Funnel(
      id: funnelList.length + 1,
      projectId: projectId,
      name: name,
      description: description,
      steps: steps,
      conversionWindowSeconds: conversionWindowSeconds,
      createdAt: DateTime.now(),
    );
    funnelList.add(f);
    return f;
  }

  @override
  Future<Funnel> funnel(int projectId, int funnelId) async {
    calls.add('funnel $projectId $funnelId');
    return funnelList.firstWhere((f) => f.id == funnelId);
  }

  @override
  Future<Funnel> updateFunnel(
    int projectId,
    int funnelId, {
    String? name,
    String? description,
    List<FunnelStep>? steps,
    int? conversionWindowSeconds,
  }) async {
    calls.add('updateFunnel $projectId $funnelId');
    final idx = funnelList.indexWhere((f) => f.id == funnelId);
    final cur = funnelList[idx];
    final updated = Funnel(
      id: cur.id,
      projectId: cur.projectId,
      name: name ?? cur.name,
      description: description ?? cur.description,
      steps: steps ?? cur.steps,
      conversionWindowSeconds: conversionWindowSeconds ?? cur.conversionWindowSeconds,
      createdAt: cur.createdAt,
      updatedAt: DateTime.now(),
    );
    funnelList[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteFunnel(int projectId, int funnelId) async {
    calls.add('deleteFunnel $projectId $funnelId');
    funnelList.removeWhere((f) => f.id == funnelId);
  }

  @override
  Future<FunnelResult> funnelResults(
    int projectId,
    int funnelId, {
    int days = 7,
  }) async {
    calls.add('funnelResults $projectId $funnelId days=$days');
    return funnelResultValue;
  }

  @override
  Future<List<String>> funnelDropoffs(
    int projectId,
    int funnelId, {
    required int step,
    int days = 7,
    int limit = 50,
  }) async {
    calls.add('funnelDropoffs $projectId $funnelId step=$step');
    return ['abcdef12-3456'];
  }

  var cohortList = <Cohort>[
    Cohort(
      id: 1,
      projectId: 1,
      name: 'Power Users',
      description: 'Users with at least 5 visits',
      isDynamic: true,
      rules: const [
        CohortRule(type: 'event', eventName: 'page_view', operator: 'gte', value: '5'),
      ],
      memberCount: 42,
      createdAt: DateTime(2026, 9, 1),
    ),
  ];

  var retentionResultValue = const RetentionResult(
    periodUnit: 'day',
    targetEvent: 'session_start',
    returnEvent: 'page_view',
    totalBuckets: 3,
    buckets: [
      RetentionCohortBucket(
        bucketStart: '2026-09-01',
        totalUsers: 100,
        periods: [
          RetentionPeriodActivity(periodIndex: 0, activeUsers: 100, percentage: 100.0),
          RetentionPeriodActivity(periodIndex: 1, activeUsers: 40, percentage: 40.0),
          RetentionPeriodActivity(periodIndex: 2, activeUsers: 25, percentage: 25.0),
        ],
      ),
      RetentionCohortBucket(
        bucketStart: '2026-09-02',
        totalUsers: 80,
        periods: [
          RetentionPeriodActivity(periodIndex: 0, activeUsers: 80, percentage: 100.0),
          RetentionPeriodActivity(periodIndex: 1, activeUsers: 32, percentage: 40.0),
        ],
      ),
    ],
  );

  @override
  Future<List<Cohort>> cohorts(int projectId) async {
    calls.add('cohorts $projectId');
    return cohortList.where((c) => c.projectId == projectId).toList();
  }

  @override
  Future<Cohort> createCohort(
    int projectId, {
    required String name,
    String description = '',
    bool isDynamic = true,
    List<CohortRule> rules = const [],
  }) async {
    calls.add('createCohort $projectId name=$name');
    final c = Cohort(
      id: cohortList.length + 1,
      projectId: projectId,
      name: name,
      description: description,
      isDynamic: isDynamic,
      rules: rules,
      memberCount: 1,
      createdAt: DateTime.now(),
    );
    cohortList.add(c);
    return c;
  }

  @override
  Future<Cohort> cohort(int projectId, int id) async {
    calls.add('cohort $projectId $id');
    return cohortList.firstWhere((c) => c.id == id);
  }

  @override
  Future<Cohort> updateCohort(
    int projectId,
    int id, {
    String? name,
    String? description,
    bool? isDynamic,
    List<CohortRule>? rules,
  }) async {
    calls.add('updateCohort $projectId $id');
    final idx = cohortList.indexWhere((c) => c.id == id);
    final cur = cohortList[idx];
    final updated = Cohort(
      id: cur.id,
      projectId: cur.projectId,
      name: name ?? cur.name,
      description: description ?? cur.description,
      isDynamic: isDynamic ?? cur.isDynamic,
      rules: rules ?? cur.rules,
      memberCount: cur.memberCount,
      createdAt: cur.createdAt,
      updatedAt: DateTime.now(),
    );
    cohortList[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCohort(int projectId, int id) async {
    calls.add('deleteCohort $projectId $id');
    cohortList.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<String>> cohortMembers(
    int projectId,
    int id, {
    int limit = 50,
    int offset = 0,
  }) async {
    calls.add('cohortMembers $projectId $id');
    return ['user-101', 'user-102'];
  }

  @override
  Future<Map<String, Object?>> refreshCohort(int projectId, int id) async {
    calls.add('refreshCohort $projectId $id');
    return {'member_count': 42};
  }

  @override
  Future<RetentionResult> retention(
    int projectId, {
    int days = 30,
    String period = 'day',
    String targetEvent = '',
    String returnEvent = '',
    int? cohortId,
  }) async {
    calls.add('retention $projectId days=$days period=$period');
    return retentionResultValue;
  }

  var pathResultValue = const PathResult(
    rootEvent: 'route:/home',
    direction: 'forward',
    stepLimit: 3,
    nodes: [
      PathNode(id: '0:route:/home', name: 'route:/home', step: 0, count: 100),
      PathNode(id: '1:route:/products', name: 'route:/products', step: 1, count: 70),
      PathNode(id: '1:route:/login', name: 'route:/login', step: 1, count: 30),
      PathNode(id: '2:add_to_cart', name: 'add_to_cart', step: 2, count: 50),
      PathNode(id: '2:Exit', name: 'Exit', step: 2, count: 20),
    ],
    links: [
      PathLink(source: '0:route:/home', target: '1:route:/products', count: 70),
      PathLink(source: '0:route:/home', target: '1:route:/login', count: 30),
      PathLink(source: '1:route:/products', target: '2:add_to_cart', count: 50),
      PathLink(source: '1:route:/products', target: '2:Exit', count: 20),
    ],
  );

  @override
  Future<PathResult> paths(
    int projectId, {
    String rootEvent = '',
    String direction = 'forward',
    int stepLimit = 4,
    int days = 14,
    List<String> exclude = const [],
    double threshold = 1.0,
  }) async {
    calls.add('paths $projectId root=$rootEvent dir=$direction');
    return pathResultValue;
  }

  @override
  Future<List<String>> pathSessions(
    int projectId, {
    required String source,
    required String target,
    int days = 14,
    int limit = 50,
  }) async {
    calls.add('pathSessions $projectId src=$source tgt=$target');
    return ['sess-p1', 'sess-p2'];
  }

  var featureFlagsValue = <FeatureFlag>[
    const FeatureFlag(
      id: 1,
      projectId: 1,
      key: 'new_checkout_flow',
      name: 'New Checkout Flow',
      description: 'Streamlined multi-step checkout',
      enabled: true,
      rolloutPercentage: 100,
      filters: [],
      variants: [],
    ),
    const FeatureFlag(
      id: 2,
      projectId: 1,
      key: 'beta_dashboard_v2',
      name: 'Beta Dashboard v2',
      description: 'Admin and power user interface',
      enabled: true,
      rolloutPercentage: 50,
      filters: [
        FlagFilter(property: 'role', operator: 'exact', value: 'admin'),
      ],
      variants: [],
    ),
    const FeatureFlag(
      id: 3,
      projectId: 1,
      key: 'pricing_experiment',
      name: 'Pricing Tier Experiment',
      description: 'Test monthly vs yearly emphasis',
      enabled: true,
      rolloutPercentage: 100,
      variants: [
        FlagVariant(key: 'control', rollout: 50),
        FlagVariant(key: 'treatment_yearly', rollout: 50),
      ],
    ),
  ];

  @override
  Future<List<FeatureFlag>> featureFlags(int projectId) async {
    calls.add('featureFlags $projectId');
    return featureFlagsValue;
  }

  @override
  Future<FeatureFlag> createFeatureFlag(
    int projectId, {
    required String key,
    required String name,
    String description = '',
    bool enabled = true,
    int rolloutPercentage = 100,
    List<FlagFilter> filters = const [],
    List<FlagVariant> variants = const [],
  }) async {
    calls.add('createFeatureFlag $projectId key=$key');
    final f = FeatureFlag(
      id: featureFlagsValue.length + 1,
      projectId: projectId,
      key: key,
      name: name,
      description: description,
      enabled: enabled,
      rolloutPercentage: rolloutPercentage,
      filters: filters,
      variants: variants,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    featureFlagsValue.add(f);
    return f;
  }

  @override
  Future<FeatureFlag> updateFeatureFlag(
    int projectId,
    int flagId, {
    required String name,
    String description = '',
    bool enabled = true,
    int rolloutPercentage = 100,
    List<FlagFilter> filters = const [],
    List<FlagVariant> variants = const [],
  }) async {
    calls.add('updateFeatureFlag $projectId id=$flagId');
    final idx = featureFlagsValue.indexWhere((f) => f.id == flagId);
    if (idx != -1) {
      final old = featureFlagsValue[idx];
      final updated = FeatureFlag(
        id: old.id,
        projectId: old.projectId,
        key: old.key,
        name: name,
        description: description,
        enabled: enabled,
        rolloutPercentage: rolloutPercentage,
        filters: filters,
        variants: variants,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      featureFlagsValue[idx] = updated;
      return updated;
    }
    throw Exception('Flag not found');
  }

  @override
  Future<void> deleteFeatureFlag(int projectId, int flagId) async {
    calls.add('deleteFeatureFlag $projectId id=$flagId');
    featureFlagsValue.removeWhere((f) => f.id == flagId);
  }

  @override
  Future<Map<String, dynamic>> testFeatureFlag(
    int projectId,
    int flagId, {
    required String distinctId,
    Map<String, dynamic> properties = const {},
  }) async {
    calls.add('testFeatureFlag $projectId id=$flagId user=$distinctId');
    return {
      'key': 'test_flag',
      'value': true,
      'active': true,
      'enabled': true,
    };
  }

  var experimentsValue = <Experiment>[
    const Experiment(
      id: 1,
      projectId: 1,
      name: 'CTA Button Color Test',
      description: 'Test blue vs green CTA button on landing page',
      featureFlagKey: 'cta_button_color',
      status: 'running',
      primaryMetricEvent: 'signup_completed',
      variants: [
        ExperimentVariant(key: 'control', name: 'Control (Blue)'),
        ExperimentVariant(key: 'treatment', name: 'Treatment (Green)'),
      ],
      minimumSampleSize: 500,
    ),
  ];

  @override
  Future<List<Experiment>> experiments(int projectId) async {
    calls.add('experiments $projectId');
    return experimentsValue;
  }

  @override
  Future<Experiment> experiment(int projectId, int expId) async {
    calls.add('experiment $projectId id=$expId');
    final exp = experimentsValue.firstWhere(
      (e) => e.id == expId,
      orElse: () => experimentsValue.first,
    );
    return exp;
  }

  @override
  Future<Experiment> createExperiment(
    int projectId, {
    required String name,
    String description = '',
    required String featureFlagKey,
    required String primaryMetricEvent,
    List<ExperimentVariant> variants = const [],
    int minimumSampleSize = 100,
  }) async {
    calls.add('createExperiment $projectId name=$name');
    final exp = Experiment(
      id: experimentsValue.length + 1,
      projectId: projectId,
      name: name,
      description: description,
      featureFlagKey: featureFlagKey,
      status: 'draft',
      primaryMetricEvent: primaryMetricEvent,
      variants: variants,
      minimumSampleSize: minimumSampleSize,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    experimentsValue.add(exp);
    return exp;
  }

  @override
  Future<Experiment> updateExperiment(
    int projectId,
    int expId, {
    required String name,
    String description = '',
    String status = 'draft',
    int minimumSampleSize = 100,
  }) async {
    calls.add('updateExperiment $projectId id=$expId status=$status');
    final idx = experimentsValue.indexWhere((e) => e.id == expId);
    if (idx != -1) {
      final old = experimentsValue[idx];
      final updated = Experiment(
        id: old.id,
        projectId: old.projectId,
        name: name,
        description: description,
        featureFlagKey: old.featureFlagKey,
        status: status,
        primaryMetricEvent: old.primaryMetricEvent,
        variants: old.variants,
        minimumSampleSize: minimumSampleSize,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      experimentsValue[idx] = updated;
      return updated;
    }
    throw Exception('Experiment not found');
  }

  @override
  Future<void> deleteExperiment(int projectId, int expId) async {
    calls.add('deleteExperiment $projectId id=$expId');
    experimentsValue.removeWhere((e) => e.id == expId);
  }

  @override
  Future<ExperimentResults> experimentResults(
    int projectId,
    int expId, {
    int days = 14,
  }) async {
    calls.add('experimentResults $projectId id=$expId days=$days');
    return const ExperimentResults(
      experimentId: 1,
      status: 'running',
      totalParticipants: 1200,
      statisticalSignificance: 0.982,
      isSignificant: true,
      recommendedAction: 'treatment_winning',
      variants: [
        VariantResult(
          key: 'control',
          name: 'Control (Blue)',
          participants: 600,
          conversions: 60,
          conversionRate: 0.10,
          confidenceInterval: [0.08, 0.12],
          relativeLift: 0.0,
          chanceToWin: 0.018,
          pValue: 0.018,
        ),
        VariantResult(
          key: 'treatment',
          name: 'Treatment (Green)',
          participants: 600,
          conversions: 90,
          conversionRate: 0.15,
          confidenceInterval: [0.125, 0.175],
          relativeLift: 0.50,
          chanceToWin: 0.982,
          pValue: 0.018,
        ),
      ],
    );
  }

  @override
  Future<Experiment> declareExperimentWinner(
    int projectId,
    int expId, {
    required String winnerVariant,
  }) async {
    calls.add('declareExperimentWinner $projectId id=$expId winner=$winnerVariant');
    final idx = experimentsValue.indexWhere((e) => e.id == expId);
    if (idx != -1) {
      final old = experimentsValue[idx];
      final concluded = Experiment(
        id: old.id,
        projectId: old.projectId,
        name: old.name,
        description: old.description,
        featureFlagKey: old.featureFlagKey,
        status: 'concluded',
        primaryMetricEvent: old.primaryMetricEvent,
        variants: old.variants,
        minimumSampleSize: old.minimumSampleSize,
        winnerVariant: winnerVariant,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        concludedAt: DateTime.now(),
      );
      experimentsValue[idx] = concluded;
      return concluded;
    }
    throw Exception('Experiment not found');
  }

  var surveysValue = <Survey>[
    Survey(
      id: 1,
      projectId: 1,
      name: 'Quarterly NPS',
      type: 'nps',
      question: 'How likely are you to recommend Sightpane?',
      description: 'NPS survey 0 to 10',
      targeting: const SurveyTargeting(urlPattern: '/dashboard/*'),
      active: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  var surveyResponsesValue = <SurveyResponse>[
    SurveyResponse(
      id: 1,
      surveyId: 1,
      projectId: 1,
      sessionId: 'sess_abc123',
      userId: 'usr_alice',
      score: 10,
      responseText: 'Best tool ever!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Survey>> surveys(int projectId) async {
    calls.add('surveys $projectId');
    return surveysValue;
  }

  @override
  Future<Survey> survey(int projectId, int surveyId) async {
    calls.add('survey $projectId id=$surveyId');
    final s = surveysValue.firstWhere(
      (e) => e.id == surveyId,
      orElse: () => surveysValue.first,
    );
    return s;
  }

  @override
  Future<Survey> createSurvey(
    int projectId, {
    required String name,
    required String type,
    required String question,
    String description = '',
    List<String> choices = const [],
    SurveyTargeting targeting = const SurveyTargeting(),
    bool active = true,
  }) async {
    calls.add('createSurvey $projectId name=$name');
    final s = Survey(
      id: surveysValue.length + 1,
      projectId: projectId,
      name: name,
      type: type,
      question: question,
      description: description,
      choices: choices,
      targeting: targeting,
      active: active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    surveysValue.add(s);
    return s;
  }

  @override
  Future<Survey> updateSurvey(
    int projectId,
    int surveyId, {
    String? name,
    String? type,
    String? question,
    String? description,
    List<String>? choices,
    SurveyTargeting? targeting,
    bool? active,
  }) async {
    calls.add('updateSurvey $projectId id=$surveyId');
    final idx = surveysValue.indexWhere((e) => e.id == surveyId);
    if (idx != -1) {
      final old = surveysValue[idx];
      final updated = Survey(
        id: old.id,
        projectId: old.projectId,
        name: name ?? old.name,
        type: type ?? old.type,
        question: question ?? old.question,
        description: description ?? old.description,
        choices: choices ?? old.choices,
        targeting: targeting ?? old.targeting,
        active: active ?? old.active,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      surveysValue[idx] = updated;
      return updated;
    }
    throw Exception('Survey not found');
  }

  @override
  Future<void> deleteSurvey(int projectId, int surveyId) async {
    calls.add('deleteSurvey $projectId id=$surveyId');
    surveysValue.removeWhere((e) => e.id == surveyId);
  }

  @override
  Future<SurveyResults> surveyResults(int projectId, int surveyId) async {
    calls.add('surveyResults $projectId id=$surveyId');
    return SurveyResults(
      surveyId: surveyId,
      type: 'nps',
      totalResponses: 1,
      npsScore: 100.0,
      promotersCount: 1,
      passivesCount: 0,
      detractorsCount: 0,
      distribution: [
        for (int i = 0; i <= 10; i++)
          ScoreBucket(score: i, count: i == 10 ? 1 : 0),
      ],
    );
  }

  @override
  Future<List<SurveyResponse>> surveyResponses(
    int projectId,
    int surveyId, {
    int limit = 100,
  }) async {
    calls.add('surveyResponses $projectId id=$surveyId');
    return surveyResponsesValue;
  }

  var cronMonitorsValue = <CronMonitor>[
    CronMonitor(
      id: 1,
      projectId: 1,
      name: 'Daily Backup',
      slug: 'daily-backup',
      schedule: '0 2 * * *',
      timezone: 'UTC',
      gracePeriodMinutes: 15,
      maxRuntimeMinutes: 60,
      status: 'ok',
      lastCheckinAt: DateTime.now().subtract(const Duration(hours: 2)),
      nextExpectedAt: DateTime.now().add(const Duration(hours: 22)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  var cronStatsValue = const CronStats(
    totalMonitors: 1,
    okCount: 1,
    inProgressCount: 0,
    missedCount: 0,
    errorCount: 0,
  );

  var cronCheckinsValue = <CronCheckin>[
    CronCheckin(
      id: 1,
      monitorId: 1,
      projectId: 1,
      status: 'ok',
      durationMs: 1250,
      message: 'Backup completed cleanly',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<List<CronMonitor>> cronMonitors(int projectId) async {
    calls.add('cronMonitors $projectId');
    return cronMonitorsValue;
  }

  @override
  Future<CronStats> cronStats(int projectId) async {
    calls.add('cronStats $projectId');
    return cronStatsValue;
  }

  @override
  Future<CronMonitor> cronMonitor(int projectId, int monitorId) async {
    calls.add('cronMonitor $projectId id=$monitorId');
    return cronMonitorsValue.firstWhere(
      (m) => m.id == monitorId,
      orElse: () => cronMonitorsValue.first,
    );
  }

  @override
  Future<CronMonitor> createCronMonitor(
    int projectId, {
    required String name,
    required String slug,
    required String schedule,
    String timezone = 'UTC',
    int gracePeriodMinutes = 15,
    int maxRuntimeMinutes = 60,
  }) async {
    calls.add('createCronMonitor $projectId name=$name slug=$slug');
    final m = CronMonitor(
      id: cronMonitorsValue.length + 1,
      projectId: projectId,
      name: name,
      slug: slug,
      schedule: schedule,
      timezone: timezone,
      gracePeriodMinutes: gracePeriodMinutes,
      maxRuntimeMinutes: maxRuntimeMinutes,
      status: 'ok',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    cronMonitorsValue.add(m);
    return m;
  }

  @override
  Future<CronMonitor> updateCronMonitor(
    int projectId,
    int monitorId, {
    String? name,
    String? schedule,
    String? timezone,
    int? gracePeriodMinutes,
    int? maxRuntimeMinutes,
  }) async {
    calls.add('updateCronMonitor $projectId id=$monitorId');
    final idx = cronMonitorsValue.indexWhere((m) => m.id == monitorId);
    if (idx != -1) {
      final old = cronMonitorsValue[idx];
      final updated = CronMonitor(
        id: old.id,
        projectId: old.projectId,
        name: name ?? old.name,
        slug: old.slug,
        schedule: schedule ?? old.schedule,
        timezone: timezone ?? old.timezone,
        gracePeriodMinutes: gracePeriodMinutes ?? old.gracePeriodMinutes,
        maxRuntimeMinutes: maxRuntimeMinutes ?? old.maxRuntimeMinutes,
        status: old.status,
        lastCheckinAt: old.lastCheckinAt,
        nextExpectedAt: old.nextExpectedAt,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      cronMonitorsValue[idx] = updated;
      return updated;
    }
    throw Exception('Cron monitor not found');
  }

  @override
  Future<void> deleteCronMonitor(int projectId, int monitorId) async {
    calls.add('deleteCronMonitor $projectId id=$monitorId');
    cronMonitorsValue.removeWhere((m) => m.id == monitorId);
  }

  @override
  Future<List<CronCheckin>> cronCheckins(
    int projectId,
    int monitorId, {
    int limit = 50,
  }) async {
    calls.add('cronCheckins $projectId id=$monitorId');
    return cronCheckinsValue;
  }

  var uptimeMonitorsValue = <UptimeMonitor>[
    UptimeMonitor(
      id: 1,
      projectId: 1,
      name: 'Production API',
      url: 'https://api.sightpane.io/healthz',
      method: 'GET',
      headers: const {},
      expectedStatusCode: 200,
      intervalSeconds: 60,
      timeoutSeconds: 10,
      status: 'up',
      sslCheckEnabled: true,
      sslIssuer: "Let's Encrypt",
      sslExpiresAt: DateTime.now().add(const Duration(days: 85)),
      lastCheckedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      uptimePercentage: 99.98,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
  ];

  var uptimeStatsValue = const UptimeStats(
    totalMonitors: 1,
    upCount: 1,
    degradedCount: 0,
    downCount: 0,
    avgUptimePct: 99.98,
  );

  var uptimeHistoryDetailValue = UptimeHistoryDetail(
    monitor: UptimeMonitor(
      id: 1,
      projectId: 1,
      name: 'Production API',
      url: 'https://api.sightpane.io/healthz',
      method: 'GET',
      headers: const {},
      expectedStatusCode: 200,
      intervalSeconds: 60,
      timeoutSeconds: 10,
      status: 'up',
      sslCheckEnabled: true,
      sslIssuer: "Let's Encrypt",
      sslExpiresAt: DateTime.now().add(const Duration(days: 85)),
      lastCheckedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      uptimePercentage: 99.98,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    status: 'up',
    uptimePercentage: 99.98,
    currentResponseTimeMs: 42,
    ssl: UptimeSSLInfo(
      valid: true,
      expiresAt: DateTime.now().add(const Duration(days: 85)),
      daysRemaining: 85,
      issuer: "Let's Encrypt",
    ),
    history90d: [
      for (int i = 89; i >= 0; i--)
        UptimeDaySummary(
          date: '2026-09-${(i % 28 + 1).toString().padLeft(2, '0')}',
          status: 'up',
          avgMs: 40 + (i % 10),
          uptimePct: 100.0,
        ),
    ],
    recentChecks: [
      UptimeCheck(
        id: 101,
        monitorId: 1,
        projectId: 1,
        checkedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        statusCode: 200,
        responseTimeMs: 42,
        isUp: true,
        errorMessage: '',
      ),
    ],
  );

  @override
  Future<List<UptimeMonitor>> uptimeMonitors(int projectId) async {
    calls.add('uptimeMonitors $projectId');
    return uptimeMonitorsValue;
  }

  @override
  Future<UptimeStats> uptimeStats(int projectId) async {
    calls.add('uptimeStats $projectId');
    return uptimeStatsValue;
  }

  @override
  Future<UptimeHistoryDetail> uptimeMonitor(int projectId, int monitorId, {int days = 90}) async {
    calls.add('uptimeMonitor $projectId id=$monitorId days=$days');
    return uptimeHistoryDetailValue;
  }

  @override
  Future<UptimeMonitor> createUptimeMonitor(
    int projectId, {
    required String name,
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    int expectedStatusCode = 200,
    int intervalSeconds = 60,
    int timeoutSeconds = 10,
    bool sslCheckEnabled = true,
  }) async {
    calls.add('createUptimeMonitor $projectId name=$name');
    final m = UptimeMonitor(
      id: uptimeMonitorsValue.length + 1,
      projectId: projectId,
      name: name,
      url: url,
      method: method,
      headers: headers ?? const {},
      expectedStatusCode: expectedStatusCode,
      intervalSeconds: intervalSeconds,
      timeoutSeconds: timeoutSeconds,
      status: 'up',
      sslCheckEnabled: sslCheckEnabled,
      sslIssuer: sslCheckEnabled ? "Let's Encrypt" : null,
      sslExpiresAt: sslCheckEnabled ? DateTime.now().add(const Duration(days: 90)) : null,
      lastCheckedAt: DateTime.now(),
      uptimePercentage: 100.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    uptimeMonitorsValue.add(m);
    return m;
  }

  @override
  Future<UptimeMonitor> updateUptimeMonitor(
    int projectId,
    int monitorId, {
    String? name,
    String? url,
    String? method,
    Map<String, String>? headers,
    int? expectedStatusCode,
    int? intervalSeconds,
    int? timeoutSeconds,
    bool? sslCheckEnabled,
  }) async {
    calls.add('updateUptimeMonitor $projectId id=$monitorId');
    final idx = uptimeMonitorsValue.indexWhere((m) => m.id == monitorId);
    if (idx != -1) {
      final old = uptimeMonitorsValue[idx];
      final updated = UptimeMonitor(
        id: old.id,
        projectId: old.projectId,
        name: name ?? old.name,
        url: url ?? old.url,
        method: method ?? old.method,
        headers: headers ?? old.headers,
        expectedStatusCode: expectedStatusCode ?? old.expectedStatusCode,
        intervalSeconds: intervalSeconds ?? old.intervalSeconds,
        timeoutSeconds: timeoutSeconds ?? old.timeoutSeconds,
        status: old.status,
        sslCheckEnabled: sslCheckEnabled ?? old.sslCheckEnabled,
        sslIssuer: old.sslIssuer,
        sslExpiresAt: old.sslExpiresAt,
        lastCheckedAt: old.lastCheckedAt,
        uptimePercentage: old.uptimePercentage,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      uptimeMonitorsValue[idx] = updated;
      return updated;
    }
    throw Exception('Uptime monitor not found');
  }

  @override
  Future<void> deleteUptimeMonitor(int projectId, int monitorId) async {
    calls.add('deleteUptimeMonitor $projectId id=$monitorId');
    uptimeMonitorsValue.removeWhere((m) => m.id == monitorId);
  }

  @override
  Future<Map<String, Object?>> triggerUptimeCheck(int projectId, int monitorId) async {
    calls.add('triggerUptimeCheck $projectId id=$monitorId');
    return {'is_up': true, 'response_time_ms': 42, 'status_code': 200};
  }

  var metricAlertRulesValue = <MetricAlertRule>[
    MetricAlertRule(
      id: 1,
      projectId: 1,
      name: 'High Error Rate in Checkout',
      metricType: 'error_rate',
      targetFilter: 'route:/checkout',
      comparisonOperator: 'gt',
      criticalThreshold: 5.0,
      warningThreshold: 2.5,
      windowMinutes: 5,
      channelIds: const [1],
      isActive: true,
      currentStatus: 'ok',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    MetricAlertRule(
      id: 2,
      projectId: 1,
      name: 'Sudden Crash Spike',
      metricType: 'unhandled_crash_count',
      targetFilter: '',
      comparisonOperator: 'spike_multiplier',
      criticalThreshold: 3.0,
      windowMinutes: 10,
      channelIds: const [],
      isActive: true,
      currentStatus: 'firing',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  var metricAlertIncidentsValue = <MetricAlertIncident>[
    MetricAlertIncident(
      id: 1,
      ruleId: 2,
      projectId: 1,
      status: 'firing',
      triggeredAt: DateTime.now().subtract(const Duration(minutes: 15)),
      peakValue: 18.0,
      summary: 'Current crashes (18.00) is 4.5x higher than historical baseline (4.00)',
      ruleName: 'Sudden Crash Spike',
    ),
    MetricAlertIncident(
      id: 2,
      ruleId: 1,
      projectId: 1,
      status: 'resolved',
      triggeredAt: DateTime.now().subtract(const Duration(hours: 4)),
      resolvedAt: DateTime.now().subtract(const Duration(hours: 3)),
      peakValue: 8.2,
      summary: 'Error rate peaked at 8.2% in checkout',
      ruleName: 'High Error Rate in Checkout',
    ),
  ];

  var metricHistoryPreviewValue = <MetricHistoryPoint>[
    for (var i = 0; i < 24; i++)
      MetricHistoryPoint(
        timestamp: DateTime.now().subtract(Duration(hours: 24 - i)),
        value: (i % 5 == 0) ? 12.0 : (i % 3 == 0 ? 6.0 : 2.0),
      ),
  ];

  @override
  Future<List<MetricAlertRule>> metricAlertRules(int projectId) async {
    calls.add('metricAlertRules $projectId');
    return metricAlertRulesValue;
  }

  @override
  Future<MetricAlertRule> metricAlertRule(int projectId, int ruleId) async {
    calls.add('metricAlertRule $projectId id=$ruleId');
    return metricAlertRulesValue.firstWhere((r) => r.id == ruleId);
  }

  @override
  Future<MetricAlertRule> createMetricAlertRule(
    int projectId, {
    required String name,
    required String metricType,
    String targetFilter = '',
    required String comparisonOperator,
    required double criticalThreshold,
    double? warningThreshold,
    int windowMinutes = 5,
    List<int> channelIds = const [],
    bool isActive = true,
  }) async {
    calls.add('createMetricAlertRule $projectId name=$name');
    final rule = MetricAlertRule(
      id: metricAlertRulesValue.length + 1,
      projectId: projectId,
      name: name,
      metricType: metricType,
      targetFilter: targetFilter,
      comparisonOperator: comparisonOperator,
      criticalThreshold: criticalThreshold,
      warningThreshold: warningThreshold,
      windowMinutes: windowMinutes,
      channelIds: channelIds,
      isActive: isActive,
      currentStatus: 'ok',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    metricAlertRulesValue.add(rule);
    return rule;
  }

  @override
  Future<MetricAlertRule> updateMetricAlertRule(
    int projectId,
    int ruleId, {
    String? name,
    String? metricType,
    String? targetFilter,
    String? comparisonOperator,
    double? criticalThreshold,
    double? warningThreshold,
    int? windowMinutes,
    List<int>? channelIds,
    bool? isActive,
  }) async {
    calls.add('updateMetricAlertRule $projectId id=$ruleId');
    final idx = metricAlertRulesValue.indexWhere((r) => r.id == ruleId);
    if (idx != -1) {
      final old = metricAlertRulesValue[idx];
      final updated = MetricAlertRule(
        id: old.id,
        projectId: old.projectId,
        name: name ?? old.name,
        metricType: metricType ?? old.metricType,
        targetFilter: targetFilter ?? old.targetFilter,
        comparisonOperator: comparisonOperator ?? old.comparisonOperator,
        criticalThreshold: criticalThreshold ?? old.criticalThreshold,
        warningThreshold: warningThreshold ?? old.warningThreshold,
        windowMinutes: windowMinutes ?? old.windowMinutes,
        channelIds: channelIds ?? old.channelIds,
        isActive: isActive ?? old.isActive,
        currentStatus: old.currentStatus,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      metricAlertRulesValue[idx] = updated;
      return updated;
    }
    throw Exception('Metric alert rule not found');
  }

  @override
  Future<void> deleteMetricAlertRule(int projectId, int ruleId) async {
    calls.add('deleteMetricAlertRule $projectId id=$ruleId');
    metricAlertRulesValue.removeWhere((r) => r.id == ruleId);
  }

  @override
  Future<List<MetricAlertIncident>> metricAlertIncidents(int projectId, {int? ruleId, int limit = 50}) async {
    calls.add('metricAlertIncidents $projectId');
    if (ruleId != null) {
      return metricAlertIncidentsValue.where((i) => i.ruleId == ruleId).toList();
    }
    return metricAlertIncidentsValue;
  }

  @override
  Future<Map<String, Object?>> metricAlertRulePreview(int projectId, int ruleId, {int days = 7}) async {
    calls.add('metricAlertRulePreview $projectId id=$ruleId');
    final rule = metricAlertRulesValue.firstWhere((r) => r.id == ruleId);
    return {
      'rule': rule,
      'points': [
        for (final p in metricHistoryPreviewValue)
          {'timestamp': p.timestamp.toIso8601String(), 'value': p.value},
      ],
    };
  }

  @override
  Future<List<MetricHistoryPoint>> metricAlertPreview(
    int projectId, {
    required String metricType,
    String? targetFilter,
    int windowMinutes = 5,
    int days = 7,
  }) async {
    calls.add('metricAlertPreview $projectId type=$metricType');
    return metricHistoryPreviewValue;
  }

  @override
  Future<Map<String, Object?>> testMetricAlertRule(int projectId, int ruleId) async {
    calls.add('testMetricAlertRule $projectId id=$ruleId');
    return {
      'rule_id': ruleId,
      'current_value': 7.5,
      'event_count': 15,
      'is_firing': true,
      'summary': 'Metric threshold exceeded (current: 7.50)',
    };
  }

  var tracesValue = <TraceSummary>[
    TraceSummary(
      traceId: 'trace-1234567890abcdef',
      rootOp: 'http.server',
      rootName: '/api/v1/checkout',
      serviceName: 'backend-api',
      startTime: DateTime.now().subtract(const Duration(minutes: 5)),
      durationMs: 245.5,
      status: 'ok',
      spanCount: 4,
      serviceCount: 2,
      services: ['backend-api', 'auth-service'],
      hasErrors: false,
    ),
    TraceSummary(
      traceId: 'trace-error-987654321',
      rootOp: 'http.server',
      rootName: '/api/v1/pay',
      serviceName: 'payment-service',
      startTime: DateTime.now().subtract(const Duration(minutes: 15)),
      durationMs: 850.0,
      status: 'error',
      spanCount: 6,
      serviceCount: 2,
      services: ['payment-service', 'postgres'],
      hasErrors: true,
    ),
  ];

  var traceDetailsValue = <String, TraceDetail>{
    'trace-1234567890abcdef': TraceDetail(
      traceId: 'trace-1234567890abcdef',
      rootSpanId: 'span-root-1',
      rootName: '/api/v1/checkout',
      rootOp: 'http.server',
      startTime: DateTime.now().subtract(const Duration(minutes: 5)),
      totalDurationMs: 245.5,
      status: 'ok',
      serviceCount: 2,
      spanCount: 4,
      services: ['backend-api', 'auth-service'],
      spans: [
        TraceSpan(
          spanId: 'span-root-1',
          parentSpanId: '',
          op: 'http.server',
          name: '/api/v1/checkout',
          serviceName: 'backend-api',
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          startOffsetMs: 0.0,
          durationMs: 245.5,
          status: 'ok',
          depth: 0,
          data: {'http.method': 'POST', 'http.status_code': 200},
        ),
        TraceSpan(
          spanId: 'span-auth-2',
          parentSpanId: 'span-root-1',
          op: 'http.client',
          name: 'POST /verify-token',
          serviceName: 'auth-service',
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          startOffsetMs: 15.0,
          durationMs: 50.0,
          status: 'ok',
          depth: 1,
          data: {'http.method': 'POST', 'url': 'http://auth/verify-token'},
        ),
        TraceSpan(
          spanId: 'span-db-3',
          parentSpanId: 'span-root-1',
          op: 'db.query',
          name: 'SELECT users',
          serviceName: 'backend-api',
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          startOffsetMs: 70.0,
          durationMs: 35.0,
          status: 'ok',
          depth: 1,
          isSuspectNPlusOne: true,
          data: {'db.statement': 'SELECT * FROM users WHERE id = \$1', 'db.system': 'postgresql'},
        ),
        TraceSpan(
          spanId: 'span-db-4',
          parentSpanId: 'span-root-1',
          op: 'db.query',
          name: 'SELECT users',
          serviceName: 'backend-api',
          startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          startOffsetMs: 110.0,
          durationMs: 30.0,
          status: 'ok',
          depth: 1,
          isSuspectNPlusOne: true,
          data: {'db.statement': 'SELECT * FROM users WHERE id = \$1', 'db.system': 'postgresql'},
        ),
      ],
      suspectIssues: [
        SuspectIssue(
          type: 'n_plus_one_query',
          message: 'Suspected N+1 query loop: 2 consecutive db.query calls with identical query',
          spanIds: ['span-db-3', 'span-db-4'],
        ),
      ],
    ),
  };

  @override
  Future<List<TraceSummary>> traces(
    int projectId, {
    int days = 14,
    String? service,
    String? status,
    double? minDurationMs,
    String? query,
    int limit = 50,
  }) async {
    calls.add('traces $projectId');
    return tracesValue.where((t) {
      if (service != null && service.isNotEmpty && t.serviceName != service) return false;
      if (status != null && status.isNotEmpty) {
        if (status == 'error' && !t.hasErrors) return false;
        if (status == 'ok' && t.hasErrors) return false;
      }
      if (minDurationMs != null && t.durationMs < minDurationMs) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!t.traceId.toLowerCase().contains(q) &&
            !t.rootName.toLowerCase().contains(q) &&
            !t.rootOp.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<TraceDetail> trace(int projectId, String traceId) async {
    calls.add('trace $projectId id=$traceId');
    if (traceDetailsValue.containsKey(traceId)) {
      return traceDetailsValue[traceId]!;
    }
    return TraceDetail(
      traceId: traceId,
      rootSpanId: 'root',
      rootName: 'fallback-trace',
      rootOp: 'http.server',
      startTime: DateTime.now(),
      totalDurationMs: 100.0,
      status: 'ok',
      serviceCount: 1,
      spanCount: 1,
      services: ['fallback-service'],
      spans: [
        TraceSpan(
          spanId: 'root',
          op: 'http.server',
          name: 'fallback-trace',
          serviceName: 'fallback-service',
          startTime: DateTime.now(),
          startOffsetMs: 0.0,
          durationMs: 100.0,
          status: 'ok',
        ),
      ],
    );
  }

  var profilesValue = <ProfileSummary>[
    ProfileSummary(
      id: 'prof-1',
      transactionName: 'route:/feed',
      sessionId: 'sess-1',
      traceId: 'trace-1',
      durationMs: 450.0,
      cpuTimeMs: 380.0,
      threadName: 'main',
      platform: 'flutter',
      createdAt: DateTime(2026, 9, 11, 10),
    ),
  ];
  var profileDetailsValue = <String, ProfileDetail>{
    'prof-1': ProfileDetail(
      id: 'prof-1',
      projectId: 1,
      transactionName: 'route:/feed',
      sessionId: 'sess-1',
      traceId: 'trace-1',
      durationMs: 450.0,
      cpuTimeMs: 380.0,
      threadName: 'main',
      platform: 'flutter',
      callTree: ProfileCallTree(
        frames: [
          ProfileFrame(name: 'root', file: 'main.dart', line: 10),
          ProfileFrame(name: 'loadFeed', file: 'feed.dart', line: 45),
          ProfileFrame(name: 'parseJSON', file: 'parser.dart', line: 80),
        ],
        samples: [
          ProfileSample(elapsedMs: 10.0, stackId: [0, 1]),
          ProfileSample(elapsedMs: 20.0, stackId: [0, 1, 2]),
        ],
      ),
      createdAt: DateTime(2026, 9, 11, 10),
    ),
  };
  var topSlowFunctionsValue = <SlowFunction>[
    SlowFunction(
      name: 'parseJSON',
      file: 'parser.dart',
      totalTimeMs: 120.0,
      selfTimeMs: 85.0,
      callCount: 15,
    ),
  ];

  @override
  Future<List<ProfileSummary>> profiles(
    int projectId, {
    int days = 14,
    String? transaction,
    int limit = 50,
  }) async {
    calls.add('profiles $projectId');
    return profilesValue.where((p) {
      if (transaction != null && transaction.isNotEmpty && p.transactionName != transaction) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<ProfileDetail> profile(int projectId, String profileId) async {
    calls.add('profile $projectId id=$profileId');
    if (profileDetailsValue.containsKey(profileId)) {
      return profileDetailsValue[profileId]!;
    }
    return ProfileDetail(
      id: profileId,
      projectId: projectId,
      transactionName: 'fallback-tx',
      sessionId: 'sess-fallback',
      traceId: 'trace-fallback',
      durationMs: 100.0,
      cpuTimeMs: 80.0,
      threadName: 'main',
      platform: 'flutter',
      callTree: const ProfileCallTree(frames: [], samples: []),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<SlowFunction>> topSlowFunctions(
    int projectId, {
    int days = 14,
    String? transaction,
    int limit = 20,
  }) async {
    calls.add('topSlowFunctions $projectId');
    return topSlowFunctionsValue;
  }

  var dashboardsValue = <Dashboard>[
    Dashboard(
      id: 'dash-1',
      projectId: 1,
      name: 'Executive Overview',
      description: 'Key business metrics and engagement',
      isDefault: true,
      layout: const [
        DashboardTile(insightId: 'ins-1', col: 0, row: 0, w: 6, h: 4),
        DashboardTile(insightId: 'ins-2', col: 6, row: 0, w: 6, h: 4),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  var insightsValue = <Insight>[
    Insight(
      id: 'ins-1',
      projectId: 1,
      dashboardId: 'dash-1',
      name: 'Weekly Purchases',
      chartType: 'bar',
      query: const InsightQuery(
        dateRange: '7d',
        interval: 'day',
        events: [InsightEvent(name: 'purchase', math: 'count')],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
    Insight(
      id: 'ins-2',
      projectId: 1,
      dashboardId: 'dash-1',
      name: 'Active Users by Platform',
      chartType: 'donut',
      query: const InsightQuery(
        dateRange: '7d',
        interval: 'day',
        events: [InsightEvent(name: 'pageview', math: 'unique_users')],
        breakdown: 'platform',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Dashboard>> dashboards(int projectId) async {
    calls.add('dashboards $projectId');
    return dashboardsValue.where((d) => d.projectId == projectId).toList();
  }

  @override
  Future<Dashboard> dashboard(int projectId, String dashboardId) async {
    calls.add('dashboard $projectId id=$dashboardId');
    return dashboardsValue.firstWhere((d) => d.id == dashboardId);
  }

  @override
  Future<Dashboard> createDashboard(
    int projectId, {
    required String name,
    String description = '',
    bool isDefault = false,
    List<DashboardTile> layout = const [],
  }) async {
    calls.add('createDashboard $projectId name=$name');
    final d = Dashboard(
      id: 'dash-${dashboardsValue.length + 1}',
      projectId: projectId,
      name: name,
      description: description,
      isDefault: isDefault,
      layout: layout,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    dashboardsValue.add(d);
    return d;
  }

  @override
  Future<Dashboard> updateDashboard(
    int projectId,
    String dashboardId, {
    required String name,
    String description = '',
    bool isDefault = false,
    List<DashboardTile> layout = const [],
  }) async {
    calls.add('updateDashboard $projectId id=$dashboardId');
    final idx = dashboardsValue.indexWhere((d) => d.id == dashboardId);
    if (idx != -1) {
      final old = dashboardsValue[idx];
      final updated = Dashboard(
        id: old.id,
        projectId: old.projectId,
        name: name,
        description: description,
        isDefault: isDefault,
        layout: layout,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      dashboardsValue[idx] = updated;
      return updated;
    }
    throw Exception('Dashboard not found');
  }

  @override
  Future<void> deleteDashboard(int projectId, String dashboardId) async {
    calls.add('deleteDashboard $projectId id=$dashboardId');
    dashboardsValue.removeWhere((d) => d.id == dashboardId);
  }

  @override
  Future<void> setDefaultDashboard(int projectId, String dashboardId) async {
    calls.add('setDefaultDashboard $projectId id=$dashboardId');
    for (int i = 0; i < dashboardsValue.length; i++) {
      dashboardsValue[i] = Dashboard(
        id: dashboardsValue[i].id,
        projectId: dashboardsValue[i].projectId,
        name: dashboardsValue[i].name,
        description: dashboardsValue[i].description,
        isDefault: dashboardsValue[i].id == dashboardId,
        layout: dashboardsValue[i].layout,
        createdAt: dashboardsValue[i].createdAt,
        updatedAt: dashboardsValue[i].updatedAt,
      );
    }
  }

  @override
  Future<List<Insight>> insights(int projectId, {String? dashboardId}) async {
    calls.add('insights $projectId dashboardId=$dashboardId');
    return insightsValue.where((i) {
      if (i.projectId != projectId) return false;
      if (dashboardId != null && dashboardId.isNotEmpty && i.dashboardId != dashboardId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Insight> insight(int projectId, String insightId) async {
    calls.add('insight $projectId id=$insightId');
    return insightsValue.firstWhere((i) => i.id == insightId);
  }

  @override
  Future<Insight> createInsight(
    int projectId, {
    String? dashboardId,
    required String name,
    String chartType = 'line',
    required InsightQuery query,
  }) async {
    calls.add('createInsight $projectId name=$name');
    final ins = Insight(
      id: 'ins-${insightsValue.length + 1}',
      projectId: projectId,
      dashboardId: dashboardId,
      name: name,
      chartType: chartType,
      query: query,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    insightsValue.add(ins);
    return ins;
  }

  @override
  Future<Insight> updateInsight(
    int projectId,
    String insightId, {
    String? dashboardId,
    required String name,
    String chartType = 'line',
    required InsightQuery query,
  }) async {
    calls.add('updateInsight $projectId id=$insightId');
    final idx = insightsValue.indexWhere((i) => i.id == insightId);
    if (idx != -1) {
      final old = insightsValue[idx];
      final updated = Insight(
        id: old.id,
        projectId: old.projectId,
        dashboardId: dashboardId ?? old.dashboardId,
        name: name,
        chartType: chartType,
        query: query,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      insightsValue[idx] = updated;
      return updated;
    }
    throw Exception('Insight not found');
  }

  @override
  Future<void> deleteInsight(int projectId, String insightId) async {
    calls.add('deleteInsight $projectId id=$insightId');
    insightsValue.removeWhere((i) => i.id == insightId);
  }

  @override
  Future<InsightQueryResult> queryInsight(int projectId, InsightQuery query) async {
    calls.add('queryInsight $projectId');
    return InsightQueryResult(
      series: [
        InsightSeries(
          label: query.events.isNotEmpty ? query.events.first.name : 'Event',
          data: [
            const InsightDataPoint(time: '2026-09-01', value: 12),
            const InsightDataPoint(time: '2026-09-02', value: 24),
            const InsightDataPoint(time: '2026-09-03', value: 18),
            const InsightDataPoint(time: '2026-09-04', value: 32),
            const InsightDataPoint(time: '2026-09-05', value: 45),
          ],
          aggregatedValue: 131,
        ),
      ],
      cached: false,
      executedAt: DateTime.now(),
    );
  }

  @override
  Future<InsightQueryResult> insightResults(int projectId, String insightId) async {
    calls.add('insightResults $projectId id=$insightId');
    return InsightQueryResult(
      series: [
        const InsightSeries(
          label: 'Data',
          data: [
            InsightDataPoint(time: '2026-09-01', value: 10),
            InsightDataPoint(time: '2026-09-02', value: 25),
            InsightDataPoint(time: '2026-09-03', value: 40),
          ],
          aggregatedValue: 75,
        ),
      ],
      cached: false,
      executedAt: DateTime.now(),
    );
  }
}


List<dynamic> overridesFor(FakeApi api) => [apiProvider.overrideWithValue(api)];

