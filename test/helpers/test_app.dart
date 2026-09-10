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
}

List<dynamic> overridesFor(FakeApi api) => [apiProvider.overrideWithValue(api)];
