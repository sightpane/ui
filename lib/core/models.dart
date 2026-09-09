/// Backend JSON models.
library;

int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
String _s(Object? v) => v?.toString() ?? '';
DateTime? _t(Object? v) =>
    v == null ? null : DateTime.tryParse('$v')?.toLocal();
Map<String, Object?> _m(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};

class SightpaneUser {
  const SightpaneUser({
    required this.id,
    required this.email,
    required this.name,
    this.locale = '',
  });
  final int id;
  final String email, name;

  /// The account's dashboard language; when empty the user has made no choice
  /// and the dashboard falls back to the browser language (see
  /// `core/locale.dart`).
  final String locale;
  factory SightpaneUser.fromJson(Map<String, Object?> j) => SightpaneUser(
    id: _i(j['id']),
    email: _s(j['email']),
    name: _s(j['name']),
    locale: _s(j['locale']),
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'locale': locale,
  };
  String get displayName => name.isEmpty ? email : name;
  String get initials {
    final src = name.isEmpty ? email : name;
    final parts = src
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final SightpaneUser user;
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.apiKey,
    this.platform = 'flutter',
    this.role = '',
    this.createdAt,
    this.sessions24h = 0,
    this.errors24h = 0,
    this.openIssues = 0,
  });
  final int id;
  final String name, apiKey, platform, role;
  final DateTime? createdAt;
  final int sessions24h, errors24h, openIssues;
  bool get isOwner => role == 'owner';
  factory Project.fromJson(Map<String, Object?> j) => Project(
    id: _i(j['id']),
    name: _s(j['name']),
    apiKey: _s(j['api_key']),
    platform: _s(j['platform']),
    role: _s(j['role']),
    createdAt: _t(j['created_at']),
    sessions24h: _i(j['sessions_24h']),
    errors24h: _i(j['errors_24h']),
    openIssues: _i(j['open_issues']),
  );
}

class Member {
  const Member({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });
  final int userId;
  final String email, name, role;
  factory Member.fromJson(Map<String, Object?> j) => Member(
    userId: _i(j['user_id']),
    email: _s(j['email']),
    name: _s(j['name']),
    role: _s(j['role']),
  );
}

class DayStat {
  const DayStat({
    required this.day,
    this.sessions = 0,
    this.users = 0,
    this.errors = 0,
    this.events = 0,
  });
  final String day;
  final int sessions, users, errors, events;
  factory DayStat.fromJson(Map<String, Object?> j) => DayStat(
    day: _s(j['day']),
    sessions: _i(j['sessions']),
    users: _i(j['users']),
    errors: _i(j['errors']),
    events: _i(j['events']),
  );
}

class NameCount {
  const NameCount(this.name, this.count);
  final String name;
  final int count;
  factory NameCount.fromJson(Map<String, Object?> j) =>
      NameCount(_s(j['name']), _i(j['count']));
}

class ProjectStats {
  const ProjectStats({
    required this.days,
    this.sessions = 0,
    this.users = 0,
    this.errors = 0,
    this.events = 0,
    this.frames = 0,
    this.openIssues = 0,
    this.crashFree = 1,
    this.daily = const [],
    this.platforms = const [],
    this.releases = const [],
    this.topIssues = const [],
    this.topEvents = const [],
  });
  final int days, sessions, users, errors, events, frames, openIssues;
  final double crashFree;
  final List<DayStat> daily;
  final List<NameCount> platforms, releases, topEvents;
  final List<Issue> topIssues;
  factory ProjectStats.fromJson(Map<String, Object?> j) => ProjectStats(
    days: _i(j['days']),
    sessions: _i(j['sessions']),
    users: _i(j['users']),
    errors: _i(j['errors']),
    events: _i(j['events']),
    frames: _i(j['frames']),
    openIssues: _i(j['open_issues']),
    crashFree: _d(j['crash_free']),
    daily: [
      for (final d in (j['daily'] as List? ?? const []))
        DayStat.fromJson(_m(d)),
    ],
    platforms: [
      for (final d in (j['platforms'] as List? ?? const []))
        NameCount.fromJson(_m(d)),
    ],
    releases: [
      for (final d in (j['releases'] as List? ?? const []))
        NameCount.fromJson(_m(d)),
    ],
    topEvents: [
      for (final d in (j['top_events'] as List? ?? const []))
        NameCount.fromJson(_m(d)),
    ],
    topIssues: [
      for (final d in (j['top_issues'] as List? ?? const []))
        Issue.fromJson(_m(d)),
    ],
  );
}

class Session {
  const Session({
    required this.id,
    required this.projectId,
    required this.startedAt,
    required this.lastSeenAt,
    this.endedAt,
    this.userId = '',
    this.user = const {},
    this.device = const {},
    this.props = const {},
    this.platform = '',
    this.release = '',
    this.errorCount = 0,
    this.eventCount = 0,
    this.frameCount = 0,
    this.ip = '',
    this.browser = '',
    this.currentRoute = '',
  });
  final String id;
  final int projectId;
  final DateTime startedAt, lastSeenAt;
  final DateTime? endedAt;
  final String userId, platform, release, ip, browser, currentRoute;
  final Map<String, Object?> user, device, props;
  final int errorCount, eventCount, frameCount;
  Duration get duration => (endedAt ?? lastSeenAt).difference(startedAt);

  /// The user name to show; returns empty when there is none — the wording for
  /// "anonymous" comes from the translations, so the model keeps no text.
  String get userLabel => _s(user['email']).isNotEmpty
      ? _s(user['email'])
      : (_s(user['name']).isNotEmpty ? _s(user['name']) : userId);
  factory Session.fromJson(Map<String, Object?> j) => Session(
    id: _s(j['id']),
    projectId: _i(j['project_id']),
    startedAt: _t(j['started_at']) ?? DateTime.now(),
    lastSeenAt: _t(j['last_seen_at']) ?? DateTime.now(),
    endedAt: _t(j['ended_at']),
    userId: _s(j['user_id']),
    user: _m(j['user']),
    device: _m(j['device']),
    props: _m(j['props']),
    platform: _s(j['platform']),
    release: _s(j['release']),
    errorCount: _i(j['error_count']),
    eventCount: _i(j['event_count']),
    frameCount: _i(j['frame_count']),
    ip: _s(j['ip']),
    browser: _s(j['browser']),
    currentRoute: _s(j['current_route']),
  );
}

/// A timeline item: breadcrumb | event | error.
class TimelineItem {
  const TimelineItem({
    required this.id,
    required this.ts,
    required this.type,
    required this.name,
    required this.body,
    this.issueId,
    this.sessionId = '',
  });
  final int id;
  final DateTime ts;
  final String type, name, sessionId;
  final Map<String, Object?> body;
  final int? issueId;
  String get message => switch (type) {
    'error' => '${_s(body['exception'])}: ${_s(body['message'])}',
    'event' =>
      _s(body['name']) + (body['props'] is Map ? ' ${body['props']}' : ''),
    _ => _s(body['message']),
  };
  String get category => type == 'breadcrumb' ? name : type;
  factory TimelineItem.fromJson(Map<String, Object?> j) => TimelineItem(
    id: _i(j['id']),
    ts: _t(j['ts']) ?? DateTime.now(),
    type: _s(j['type']),
    name: _s(j['name']),
    body: _m(j['body']),
    issueId: j['issue_id'] == null ? null : _i(j['issue_id']),
    sessionId: _s(j['session_id']),
  );
}

class Tap {
  const Tap(this.x, this.y);
  final double x, y;
}

/// A mouse / touch sample (absolute time, normalized coordinates).
class PointerSample {
  const PointerSample({
    required this.ts,
    required this.x,
    required this.y,
    required this.kind,
  });
  final DateTime ts;
  final double x, y;

  /// move | down | up | scroll
  final String kind;
}

class Frame {
  const Frame({
    required this.seq,
    required this.ts,
    required this.width,
    required this.height,
    this.taps = const [],
  });
  final int seq;
  final DateTime ts;
  final int width, height;
  final List<Tap> taps;
  factory Frame.fromJson(Map<String, Object?> j) => Frame(
    seq: _i(j['seq']),
    ts: _t(j['ts']) ?? DateTime.now(),
    width: _i(j['width']),
    height: _i(j['height']),
    taps: [
      for (final t in (j['taps'] as List? ?? const []))
        Tap(_d(_m(t)['x']), _d(_m(t)['y'])),
    ],
  );
}

class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.items,
    required this.frames,
  }) : pointer = const [];
  final Session session;

  /// The timeline items; pointer packets are not here but in [pointer].
  final List<TimelineItem> items;
  final List<Frame> frames;
  final List<PointerSample> pointer;

  const SessionDetail.withPointer({
    required this.session,
    required this.items,
    required this.frames,
    required this.pointer,
  });

  factory SessionDetail.fromJson(Map<String, Object?> j) {
    final items = <TimelineItem>[];
    final pointer = <PointerSample>[];
    for (final raw in (j['items'] as List? ?? const [])) {
      final it = TimelineItem.fromJson(_m(raw));
      if (it.type != 'pointer') {
        items.add(it);
        continue;
      }
      for (final e in (it.body['events'] as List? ?? const [])) {
        final m = _m(e);
        pointer.add(
          PointerSample(
            ts: it.ts.add(Duration(milliseconds: _i(m['t']))),
            x: _d(m['x']),
            y: _d(m['y']),
            kind: _s(m['k']),
          ),
        );
      }
    }
    pointer.sort((a, b) => a.ts.compareTo(b.ts));
    return SessionDetail.withPointer(
      session: Session.fromJson(j),
      items: items,
      frames: [
        for (final f in (j['frames'] as List? ?? const []))
          Frame.fromJson(_m(f)),
      ],
      pointer: pointer,
    );
  }
}

class Issue {
  const Issue({
    required this.id,
    required this.title,
    this.exception = '',
    this.firstSeen,
    this.lastSeen,
    this.count = 0,
    this.resolved = false,
  });
  final int id;
  final String title, exception;
  final DateTime? firstSeen, lastSeen;
  final int count;
  final bool resolved;
  factory Issue.fromJson(Map<String, Object?> j) => Issue(
    id: _i(j['id']),
    title: _s(j['title']),
    exception: _s(j['exception']),
    firstSeen: _t(j['first_seen']),
    lastSeen: _t(j['last_seen']),
    count: _i(j['count']),
    resolved: j['resolved'] == true || j['resolved'] == 1,
  );
}

class IssueDetail {
  const IssueDetail({required this.issue, required this.occurrences});
  final Issue issue;
  final List<TimelineItem> occurrences;
  factory IssueDetail.fromJson(Map<String, Object?> j) => IssueDetail(
    issue: Issue.fromJson(j),
    occurrences: [
      for (final o in (j['occurrences'] as List? ?? const []))
        TimelineItem.fromJson(_m(o)),
    ],
  );
}

class EventCount {
  const EventCount({
    required this.name,
    required this.day,
    required this.count,
    required this.users,
  });
  final String name, day;
  final int count, users;
  factory EventCount.fromJson(Map<String, Object?> j) => EventCount(
    name: _s(j['name']),
    day: _s(j['day']),
    count: _i(j['count']),
    users: _i(j['users']),
  );
}

/// A session that is open right now (the live view).
class LiveViewer {
  const LiveViewer({
    required this.sessionId,
    required this.userLabel,
    required this.ip,
    required this.browser,
    required this.platform,
    required this.route,
    required this.lastSeen,
    required this.startedAt,
  });
  final String sessionId, userLabel, ip, browser, platform, route;
  final DateTime lastSeen, startedAt;
  factory LiveViewer.fromJson(Map<String, Object?> j) => LiveViewer(
    sessionId: _s(j['session_id']),
    userLabel: _s(j['user_label']),
    ip: _s(j['ip']),
    browser: _s(j['browser']),
    platform: _s(j['platform']),
    route: _s(j['route']),
    lastSeen: _t(j['last_seen']) ?? DateTime.now(),
    startedAt: _t(j['started_at']) ?? DateTime.now(),
  );
}

class LiveStatus {
  const LiveStatus({
    this.windowSeconds = 60,
    this.count = 0,
    this.visitors = 0,
    this.routes = const [],
    this.viewers = const [],
  });
  final int windowSeconds, count, visitors;
  final List<NameCount> routes;
  final List<LiveViewer> viewers;
  factory LiveStatus.fromJson(Map<String, Object?> j) => LiveStatus(
    windowSeconds: _i(j['window_seconds']),
    count: _i(j['count']),
    visitors: _i(j['visitors']),
    routes: [
      for (final r in (j['routes'] as List? ?? const []))
        NameCount.fromJson(_m(r)),
    ],
    viewers: [
      for (final v in (j['viewers'] as List? ?? const []))
        LiveViewer.fromJson(_m(v)),
    ],
  );
}
