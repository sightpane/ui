import 'package:flutter/widgets.dart' show Locale;
import 'package:sightpane_dashboard/core/format.dart';
import 'package:sightpane_dashboard/core/models.dart';
import 'package:sightpane_dashboard/l10n/gen/app_localizations.dart';
import 'package:sightpane_dashboard/features/sessions/sessions_page.dart'
    show platformLabel;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late Fmt tr, en;
  setUpAll(() async {
    for (final l in L.supportedLocales) {
      await initializeDateFormatting(l.languageCode);
    }
    tr = Fmt(await L.delegate.load(const Locale('tr')));
    en = Fmt(await L.delegate.load(const Locale('en')));
  });
  test('deviceLabel names the phone: maker once, then the model', () {
    Session phone(Map<String, Object?> device) => Session(
      id: 'p',
      projectId: 1,
      startedAt: DateTime(2026),
      lastSeenAt: DateTime(2026),
      device: device,
    );
    // The backend names an iPhone from its identifier.
    expect(
      phone({'manufacturer': 'Apple', 'model': 'iPhone17,3', 'model_name': 'iPhone 16'})
          .deviceLabel,
      'Apple iPhone 16',
    );
    // One it does not know yet stays an identifier.
    expect(
      phone({'manufacturer': 'Apple', 'model': 'iPhone99,1'}).deviceLabel,
      'Apple iPhone99,1',
    );
    // Android makers write themselves in lower case.
    expect(
      phone({'manufacturer': 'samsung', 'brand': 'samsung', 'model': 'SM-S918B'})
          .deviceLabel,
      'Samsung SM-S918B',
    );
    // A marketing name that already says the maker is not prefixed twice.
    expect(
      phone({'manufacturer': 'Xiaomi', 'model': '24072PX77G', 'model_name': 'Xiaomi 14T Pro'})
          .deviceLabel,
      'Xiaomi 14T Pro',
    );
    expect(phone({'os': 'Ubuntu'}).deviceLabel, '');
  });

  test('models parse backend json', () {
    final s = Session.fromJson({
      'id': 'abc',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:05:00Z',
      'ended_at': null,
      'user_id': 'u1',
      'user': {'id': 'u1', 'email': 'a@b.c'},
      'device': {'platform': 'web'},
      'platform': 'web',
      'release': '1.0',
      'error_count': 2,
      'event_count': 5,
      'frame_count': 9,
      'app_type': 'browser',
      'os': 'Linux',
      'os_version': '6.8.0',
    });
    expect(s.duration, const Duration(minutes: 5));
    expect(s.userLabel, 'a@b.c');
    expect(s.endedAt, isNull);
    expect(s.appType, 'browser');
    expect(s.os, 'Linux');
    expect(s.osVersion, '6.8.0');
    final d = SessionDetail.fromJson({
      'id': 'abc',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:05:00Z',
      'items': [
        {
          'id': 1,
          'ts': '2026-09-07T10:00:01Z',
          'type': 'error',
          'name': 'E',
          'body': {'exception': 'E', 'message': 'm'},
          'issue_id': 4,
        },
      ],
      'frames': [
        {
          'seq': 1,
          'ts': '2026-09-07T10:00:00Z',
          'width': 10,
          'height': 5,
          'taps': [
            {'x': 0.5, 'y': 0.25},
          ],
        },
      ],
    });
    expect(d.items.single.message, 'E: m');
    expect(d.isFlutter, isTrue);

    final dDom = SessionDetail.fromJson({
      'id': 'web-1',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:05:00Z',
      'sdk_name': '@sightpane/browser',
      'sdk_version': '0.1.0',
      'has_dom': true,
      'items': [
        {
          'id': 10,
          'ts': '2026-09-07T10:00:01Z',
          'type': 'dom',
          'name': 'snapshot',
          'body': {'kind': 'snapshot'},
        },
      ],
      'frames': [],
    });
    expect(dDom.session.sdkName, '@sightpane/browser');
    expect(dDom.session.sdkVersion, '0.1.0');
    expect(dDom.hasDom, isTrue);
    expect(dDom.isFlutter, isFalse);

    final sLinux = Session.fromJson({
      'id': 'sess-linux',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:05:00Z',
      'platform': 'linux',
      'device': {
        'platform_category': 'desktop',
        'os': 'Ubuntu',
        'os_version': '24.04',
        'kernel': 'Linux',
        'kernel_version': '6.8.0-40-generic',
        'arch': 'x86_64',
        'cpu_cores': 8,
        'screen': {'w': 1920, 'h': 1080, 'dpr': 1.5},
        'locale': 'tr-TR',
      },
    });
    expect(sLinux.platformCategory, 'Desktop');
    expect(sLinux.osName, 'Ubuntu');
    expect(sLinux.osVersion, '24.04');
    expect(sLinux.kernel, 'Linux');
    expect(sLinux.kernelVersion, '6.8.0-40-generic');
    expect(sLinux.arch, 'x86_64');
    expect(sLinux.cpuCores, 8);
    expect(sLinux.screenResolution, '1920×1080 (1.5x)');
    expect(sLinux.locale, 'tr-TR');
    expect(sLinux.isLinuxDesktop, isTrue);
    expect(sLinux.isWeb, isFalse);

    final sWeb = Session.fromJson({
      'id': 'sess-web',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:05:00Z',
      'platform': 'web',
      'device': {
        'platform_category': 'web',
        'os': 'Linux',
        'browser': 'Chrome',
        'browser_version': '128.0.6613.120',
        'arch': 'x86_64',
        'cpu_cores': 16,
      },
    });
    expect(sWeb.platformCategory, 'Web');
    expect(sWeb.osName, 'Linux');
    expect(sWeb.browserName, 'Chrome');
    expect(sWeb.browserVersion, '128.0.6613.120');
    expect(sWeb.isWeb, isTrue);
    expect(sWeb.isLinuxDesktop, isFalse);

    final dp = SessionDetail.fromJson({
      'id': 'x',
      'project_id': 1,
      'started_at': '2026-09-07T10:00:00Z',
      'last_seen_at': '2026-09-07T10:00:05Z',
      'items': [
        {
          'id': 2,
          'ts': '2026-09-07T10:00:01Z',
          'type': 'pointer',
          'name': 'pointer',
          'body': {
            'events': [
              {'t': 0, 'x': 0.1, 'y': 0.2, 'k': 'move'},
              {'t': 250, 'x': 0.5, 'y': 0.5, 'k': 'down'},
            ],
          },
        },
      ],
    });
    expect(dp.items, isEmpty); // pointer packets do not enter the timeline
    expect(dp.pointer.length, 2);
    expect(
      dp.pointer[1].ts.difference(dp.pointer[0].ts),
      const Duration(milliseconds: 250),
    );
    expect(dp.pointer[1].kind, 'down');
    expect(d.items.single.issueId, 4);
    expect(d.frames.single.taps.single.y, 0.25);
    final st = ProjectStats.fromJson({
      'days': 7,
      'sessions': 3,
      'crash_free': 0.5,
      'daily': [
        {'day': '2026-09-01', 'sessions': 1},
      ],
      'top_issues': [
        {'id': 1, 'title': 't', 'count': 2, 'resolved': false},
      ],
      'platforms': [
        {'name': 'web', 'count': 3},
      ],
      'app_types': [
        {'name': 'browser', 'count': 3},
      ],
      'operating_systems': [
        {'name': 'Linux', 'count': 2},
      ],
    });
    expect(st.daily.single.sessions, 1);
    expect(st.topIssues.single.title, 't');
    expect(st.platforms.single.count, 3);
    expect(st.appTypes.single.name, 'browser');
    expect(st.operatingSystems.single.name, 'Linux');
    expect(
      const SightpaneUser(id: 1, email: 'x@y.z', name: 'Ada Lovelace').initials,
      'AL',
    );
    expect(const SightpaneUser(id: 1, email: 'x@y.z', name: '').initials, 'X');
  });

  test('platform label shows the browser only when it adds information', () {
    expect(platformLabel('web', 'Chrome'), 'web · Chrome');
    expect(platformLabel('web', ''), 'web');
    expect(platformLabel('web', 'web'), 'web');
    expect(platformLabel('', ''), '—');
    expect(platformLabel('', '', empty: 'n/a'), 'n/a');

    // Multi-part platformLabel with appType, OS and version
    expect(
      platformLabel('web', 'Chrome', appType: 'browser', os: 'Windows', osVersion: '10'),
      'browser · Chrome · Windows 10',
    );
    expect(
      platformLabel('linux', '', appType: 'desktop', os: 'Ubuntu', osVersion: '24.04'),
      'desktop · Ubuntu 24.04',
    );
    expect(
      platformLabel('android', '', appType: 'mobile', os: 'Android', osVersion: '14'),
      'mobile · Android 14',
    );
    expect(
      platformLabel('linux', '', appType: 'desktop', os: 'Ubuntu'),
      'desktop · Ubuntu',
    );
    expect(
      platformLabel('web', 'Firefox', appType: 'browser'),
      'browser · Firefox',
    );
  });

  test('formatters follow the language', () {
    expect(tr.duration(const Duration(seconds: 42)), '42 sn');
    expect(tr.duration(const Duration(minutes: 7)), '7 dk');
    expect(tr.duration(const Duration(minutes: 90)), '1.5 sa');
    expect(tr.percent(0.75), '%75');
    expect(tr.percent(1), '%100');
    expect(tr.shortId('abcdefghijkl'), 'abcdefgh');
    // In Turkish the decimal separator is a comma; because the formatter depends
    // on the language, intl is used instead of `toStringAsFixed`.
    expect(tr.percent(0.996), '%99,6');
    expect(tr.percent(0.9234), '%92,3');
    expect(tr.integer(1234567), '1.234.567');

    // The same values in English: the percent sign trails, the separators swap.
    expect(en.duration(const Duration(seconds: 42)), '42s');
    expect(en.duration(const Duration(minutes: 90)), '1.5h');
    expect(en.percent(0.75), '75%');
    expect(en.percent(0.996), '99.6%');
    expect(en.integer(1234567), '1,234,567');

    // Relative time: in English the singular/plural split comes from the ICU
    // rule.
    final now = DateTime.now();
    expect(tr.relative(now.subtract(const Duration(seconds: 5))), 'az önce');
    expect(tr.relative(now.subtract(const Duration(minutes: 5))), '5 dk önce');
    expect(
      en.relative(now.subtract(const Duration(minutes: 1))),
      '1 minute ago',
    );
    expect(
      en.relative(now.subtract(const Duration(minutes: 5))),
      '5 minutes ago',
    );
    expect(tr.relative(null), '—');

    // The date pattern comes from the translations too (dd.MM.yyyy ↔
    // MMM d, yyyy).
    final t = DateTime(2026, 9, 7, 10, 5);
    expect(tr.dateTime(t), '07.09.2026 10:05');
    expect(en.dateTime(t), 'Sep 7, 2026 10:05');

    // Turkish upper case: an `i` in a table header has to become the dotted `İ`.
    expect(tr.upper('İstisna'), 'İSTİSNA');
    expect(en.upper('Exception'), 'EXCEPTION');
  });

  test('dashboard and insight models parse and serialize correctly', () {
    final dJson = {
      'id': 'dash-1',
      'project_id': 1,
      'name': 'Overview',
      'description': 'Main dashboard',
      'is_default': true,
      'layout': [
        {'insight_id': 'ins-1', 'col': 0, 'row': 0, 'w': 6, 'h': 4},
      ],
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-02T10:00:00Z',
    };
    final d = Dashboard.fromJson(dJson);
    expect(d.id, 'dash-1');
    expect(d.projectId, 1);
    expect(d.name, 'Overview');
    expect(d.description, 'Main dashboard');
    expect(d.isDefault, isTrue);
    expect(d.layout.length, 1);
    expect(d.layout.first.insightId, 'ins-1');
    expect(d.layout.first.col, 0);
    expect(d.layout.first.row, 0);
    expect(d.layout.first.w, 6);
    expect(d.layout.first.h, 4);

    final dOut = d.toJson();
    expect(dOut['id'], 'dash-1');
    expect(dOut['name'], 'Overview');
    expect(dOut['is_default'], isTrue);

    final insJson = {
      'id': 'ins-1',
      'project_id': 1,
      'dashboard_id': 'dash-1',
      'name': 'Pageviews',
      'chart_type': 'line',
      'query': {
        'date_range': '14d',
        'interval': 'day',
        'events': [
          {'name': 'pageview', 'math': 'count', 'property': ''},
        ],
        'breakdown': 'browser',
      },
      'created_at': '2026-09-01T10:00:00Z',
      'updated_at': '2026-09-02T10:00:00Z',
    };
    final ins = Insight.fromJson(insJson);
    expect(ins.id, 'ins-1');
    expect(ins.name, 'Pageviews');
    expect(ins.chartType, 'line');
    expect(ins.query.dateRange, '14d');
    expect(ins.query.interval, 'day');
    expect(ins.query.events.length, 1);
    expect(ins.query.events.first.name, 'pageview');
    expect(ins.query.events.first.math, 'count');
    expect(ins.query.breakdown, 'browser');

    final insOut = ins.toJson();
    expect(insOut['name'], 'Pageviews');
    expect(insOut['chart_type'], 'line');

    final qResJson = {
      'series': [
        {
          'label': 'Chrome',
          'aggregated_value': 265.5,
          'data': [
            {'time': '2026-09-01T00:00:00Z', 'value': 120.5},
            {'time': '2026-09-02T00:00:00Z', 'value': 145.0},
          ],
        },
      ],
      'cached': true,
      'executed_at': '2026-09-02T12:00:00Z',
    };
    final qRes = InsightQueryResult.fromJson(qResJson);
    expect(qRes.cached, isTrue);
    expect(qRes.series.length, 1);
    expect(qRes.series.first.label, 'Chrome');
    expect(qRes.series.first.aggregatedValue, 265.5);
    expect(qRes.series.first.data.length, 2);
    expect(qRes.series.first.data.first.value, 120.5);
  });
}
