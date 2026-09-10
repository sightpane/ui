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
    });
    expect(s.duration, const Duration(minutes: 5));
    expect(s.userLabel, 'a@b.c');
    expect(s.endedAt, isNull);
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
    });
    expect(st.daily.single.sessions, 1);
    expect(st.topIssues.single.title, 't');
    expect(st.platforms.single.count, 3);
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
}
