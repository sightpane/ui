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
    this.retentionDays = 30,
    this.quotaItemsPerMinute = 0,
    this.storeIp = 'full',
    this.scrubRulesJson = '[]',
    this.sessions24h = 0,
    this.errors24h = 0,
    this.openIssues = 0,
    this.orgId,
  });
  final int id;
  final String name, apiKey, platform, role;
  final DateTime? createdAt;
  final int retentionDays, quotaItemsPerMinute;
  final String storeIp, scrubRulesJson;
  final int sessions24h, errors24h, openIssues;
  final int? orgId;
  bool get isOwner => role == 'owner';
  factory Project.fromJson(Map<String, Object?> j) => Project(
    id: _i(j['id']),
    name: _s(j['name']),
    apiKey: _s(j['api_key']),
    platform: _s(j['platform']),
    role: _s(j['role']),
    createdAt: _t(j['created_at']),
    retentionDays: j.containsKey('retention_days') ? _i(j['retention_days']) : 30,
    quotaItemsPerMinute: _i(j['quota_items_per_minute']),
    storeIp: _s(j['store_ip']).isEmpty ? 'full' : _s(j['store_ip']),
    scrubRulesJson: _s(j['scrub_rules_json']).isEmpty ? '[]' : _s(j['scrub_rules_json']),
    sessions24h: _i(j['sessions_24h']),
    errors24h: _i(j['errors_24h']),
    openIssues: _i(j['open_issues']),
    orgId: j['org_id'] != null ? _i(j['org_id']) : null,
  );
}

class Org {
  const Org({
    required this.id,
    required this.name,
    required this.slug,
    this.role = '',
    this.createdAt,
  });
  final int id;
  final String name, slug, role;
  final DateTime? createdAt;

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';

  factory Org.fromJson(Map<String, Object?> j) => Org(
    id: _i(j['id']),
    name: _s(j['name']),
    slug: _s(j['slug']),
    role: _s(j['role']),
    createdAt: _t(j['created_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'role': role,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class OrgMember {
  const OrgMember({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });
  final int userId;
  final String email, name, role;

  factory OrgMember.fromJson(Map<String, Object?> j) => OrgMember(
    userId: _i(j['user_id']),
    email: _s(j['email']),
    name: _s(j['name']),
    role: _s(j['role']),
  );
}

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.orgId,
    this.projectId,
    this.userId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.meta = const {},
    this.ip = '',
    this.createdAt,
  });
  final int id, orgId;
  final int? projectId, userId;
  final String action, targetType, targetId, ip;
  final Map<String, Object?> meta;
  final DateTime? createdAt;

  factory AuditLogEntry.fromJson(Map<String, Object?> j) => AuditLogEntry(
    id: _i(j['id']),
    orgId: _i(j['org_id']),
    projectId: j['project_id'] != null ? _i(j['project_id']) : null,
    userId: j['user_id'] != null ? _i(j['user_id']) : null,
    action: _s(j['action']),
    targetType: _s(j['target_type']),
    targetId: _s(j['target_id']),
    meta: _m(j['meta']),
    ip: _s(j['ip']),
    createdAt: _t(j['created_at']),
  );
}

class ApiToken {
  const ApiToken({
    required this.id,
    required this.orgId,
    required this.name,
    this.scopes = const [],
    this.createdBy = 0,
    this.createdAt,
    this.expiresAt,
    this.secret,
  });
  final int id, orgId, createdBy;
  final String name;
  final List<String> scopes;
  final DateTime? createdAt, expiresAt;
  final String? secret;

  factory ApiToken.fromJson(Map<String, Object?> j) => ApiToken(
    id: _i(j['id']),
    orgId: _i(j['org_id']),
    name: _s(j['name']),
    scopes: (j['scopes'] as List?)?.map((e) => '$e').toList() ?? const [],
    createdBy: _i(j['created_by']),
    createdAt: _t(j['created_at']),
    expiresAt: _t(j['expires_at']),
    secret: j['secret'] != null ? _s(j['secret']) : null,
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
    this.dropped = 0,
    this.crashFree = 1,
    this.daily = const [],
    this.platforms = const [],
    this.releases = const [],
    this.topIssues = const [],
    this.topEvents = const [],
  });
  final int days, sessions, users, errors, events, frames, openIssues, dropped;
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
    dropped: _i(j['dropped']),
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
    this.sdkName = '',
    this.sdkVersion = '',
  });
  final String id;
  final int projectId;
  final DateTime startedAt, lastSeenAt;
  final DateTime? endedAt;
  final String userId, platform, release, ip, browser, currentRoute, sdkName, sdkVersion;
  final Map<String, Object?> user, device, props;
  final int errorCount, eventCount, frameCount;
  Duration get duration => (endedAt ?? lastSeenAt).difference(startedAt);

  /// Form factor category: 'Desktop', 'Web', 'Mobile'
  String get platformCategory {
    final cat = _s(device['platform_category']).toLowerCase();
    if (cat == 'desktop') return 'Desktop';
    if (cat == 'mobile') return 'Mobile';
    if (cat == 'web') return 'Web';

    final p = platform.toLowerCase();
    if (p == 'web') return 'Web';
    if (p == 'android' || p == 'ios' || p == 'fuchsia') return 'Mobile';
    if (p == 'linux' || p == 'macos' || p == 'windows') return 'Desktop';
    return 'Desktop';
  }

  /// OS name: 'Ubuntu', 'macOS', 'Windows', 'Android', 'iOS', 'Linux'
  String get osName {
    final os = _s(device['os']);
    if (os.isNotEmpty && os.toLowerCase() != 'web') {
      return os;
    }
    final p = platform.toLowerCase();
    if (p == 'macos') return 'macOS';
    if (p == 'linux') return 'Linux';
    if (p == 'windows') return 'Windows';
    if (p == 'android') return 'Android';
    if (p == 'ios') return 'iOS';
    return os.isNotEmpty ? os : (platform.isNotEmpty ? platform : '—');
  }

  /// OS version: e.g. '24.04', '14.5'
  String get osVersion => _s(device['os_version']);

  /// Linux kernel: 'Linux'
  String get kernel => _s(device['kernel']);

  /// Linux kernel version: e.g. '6.8.0-40-generic'
  String get kernelVersion => _s(device['kernel_version']);

  /// Whether this session is running on Linux Desktop
  bool get isLinuxDesktop =>
      platformCategory == 'Desktop' &&
      (osName.toLowerCase().contains('linux') ||
          osName.toLowerCase().contains('ubuntu') ||
          platform.toLowerCase() == 'linux');

  /// Browser name: 'Chrome', 'Firefox', etc.
  String get browserName {
    final b = _s(device['browser']);
    if (b.isNotEmpty && b.toLowerCase() != 'web' && !b.endsWith(' app')) {
      return b;
    }
    if (browser.isNotEmpty && browser.toLowerCase() != 'web' && !browser.endsWith(' app')) {
      return browser;
    }
    return '';
  }

  /// Browser version: e.g. '128.0.6613.120'
  String get browserVersion => _s(device['browser_version']);

  /// Whether this session is from a web browser
  bool get isWeb => platformCategory == 'Web' || platform.toLowerCase() == 'web';

  /// Hardware architecture: e.g. 'x86_64', 'arm64'
  String get arch => _s(device['arch']);

  /// Number of CPU cores if reported
  int? get cpuCores {
    final c = device['cpu_cores'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    if (c is String) return int.tryParse(c);
    return null;
  }

  /// Screen resolution: e.g. '1920×1080 (2.0x)'
  String get screenResolution {
    final scr = device['screen'];
    if (scr is Map) {
      final w = scr['w'];
      final h = scr['h'];
      final dpr = scr['dpr'];
      if (w != null && h != null) {
        if (dpr != null) {
          return '$w×$h (${dpr}x)';
        }
        return '$w×$h';
      }
    }
    return '';
  }

  /// Locale: e.g. 'tr-TR', 'en-US'
  String get locale =>
      _s(device['locale']).isNotEmpty ? _s(device['locale']) : _s(device['locale_name']);

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
    sdkName: _s(j['sdk_name']),
    sdkVersion: _s(j['sdk_version']),
  );
}

/// One line of a stack trace after the backend resolved it against the release's
/// source map. [resolved] is false for a frame no map covered — those are kept
/// rather than dropped, because a stack with a hole in it reads worse than one
/// with a minified line in it.
class SourceFrame {
  const SourceFrame({
    required this.file,
    required this.line,
    required this.column,
    required this.function,
    required this.minified,
    required this.resolved,
  });
  final String file, function, minified;
  final int line, column;
  final bool resolved;

  /// `lib/cashier.dart:120` — what the dashboard shows instead of
  /// `main.dart.js:12345`.
  String get location => line > 0 ? '$file:$line' : file;

  factory SourceFrame.fromJson(Map<String, Object?> j) => SourceFrame(
    file: _s(j['file']),
    line: _i(j['line']),
    column: _i(j['column']),
    function: _s(j['function']),
    minified: _s(j['minified']),
    resolved: j['resolved'] == true,
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
    this.frames = const [],
    this.platform = '',
    this.browser = '',
    this.release = '',
    this.ip = '',
    this.sdkName = '',
    this.sdkVersion = '',
    this.device = const {},
  });
  final int id;
  final DateTime ts;
  final String type, name, sessionId;
  final Map<String, Object?> body;
  final int? issueId;
  /// The stack resolved against a source map, when one was uploaded for the
  /// release this error came from. Empty otherwise, which is every native build
  /// and any web build without a map.
  final List<SourceFrame> frames;
  final String platform, browser, release, ip, sdkName, sdkVersion;
  final Map<String, Object?> device;

  Session toSession() => Session(
    id: sessionId,
    projectId: 0,
    startedAt: ts,
    lastSeenAt: ts,
    platform: platform,
    browser: browser,
    release: release,
    ip: ip,
    sdkName: sdkName,
    sdkVersion: sdkVersion,
    device: device,
  );

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
    platform: _s(j['platform']),
    browser: _s(j['browser']),
    release: _s(j['release']),
    ip: _s(j['ip']),
    sdkName: _s(j['sdk_name']),
    sdkVersion: _s(j['sdk_version']),
    device: _m(j['device']),
    // `symbolicated` sits beside `body` rather than inside it: the body is what
    // the SDK sent and the backend hands it back untouched.
    frames: [
      for (final f in (_m(j['symbolicated'])['frames'] as List?) ?? const [])
        if (f is Map) SourceFrame.fromJson(f.cast<String, Object?>()),
    ],
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
    this.hasDom = false,
  }) : pointer = const [];
  final Session session;

  /// The timeline items; pointer packets are not here but in [pointer].
  final List<TimelineItem> items;
  final List<Frame> frames;
  final List<PointerSample> pointer;
  final bool hasDom;

  bool get isFlutter =>
      session.sdkName.isEmpty ||
      session.sdkName == 'sightpane' ||
      session.sdkName.contains('flutter');

  const SessionDetail.withPointer({
    required this.session,
    required this.items,
    required this.frames,
    required this.pointer,
    this.hasDom = false,
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
      hasDom: j['has_dom'] == true || items.any((it) => it.type == 'dom'),
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
    this.status = 'open',
    this.assigneeUserId,
    this.assigneeEmail,
    this.snoozeUntil,
    this.snoozeCountThreshold,
    this.mergedInto,
    this.firstRelease = '',
    this.lastRelease = '',
    this.resolvedInRelease = '',
  });
  final int id;
  final String title, exception;
  final DateTime? firstSeen, lastSeen;
  final int count;
  final bool resolved;
  final String status;
  final int? assigneeUserId;
  final String? assigneeEmail;
  final DateTime? snoozeUntil;
  final int? snoozeCountThreshold;
  final int? mergedInto;
  final String firstRelease, lastRelease, resolvedInRelease;

  factory Issue.fromJson(Map<String, Object?> j) {
    final res = j['resolved'] == true || j['resolved'] == 1;
    final st = _s(j['status']);
    final effectiveStatus = st.isNotEmpty ? st : (res ? 'resolved' : 'open');
    return Issue(
      id: _i(j['id']),
      title: _s(j['title']),
      exception: _s(j['exception']),
      firstSeen: _t(j['first_seen']),
      lastSeen: _t(j['last_seen']),
      count: _i(j['count']),
      resolved: res || effectiveStatus == 'resolved',
      status: effectiveStatus,
      assigneeUserId:
          j['assignee_user_id'] == null ? null : _i(j['assignee_user_id']),
      assigneeEmail:
          j['assignee_email'] == null ? null : _s(j['assignee_email']),
      snoozeUntil: _t(j['snooze_until']),
      snoozeCountThreshold: j['snooze_count_threshold'] == null
          ? null
          : _i(j['snooze_count_threshold']),
      mergedInto: j['merged_into'] == null ? null : _i(j['merged_into']),
      firstRelease: _s(j['first_release']),
      lastRelease: _s(j['last_release']),
      resolvedInRelease: _s(j['resolved_in_release']),
    );
  }
}

class ReleaseHealth {
  const ReleaseHealth({
    required this.version,
    required this.firstSeen,
    required this.lastSeen,
    required this.sessionCount,
    required this.errorSessionCount,
    required this.errorCount,
    required this.userCount,
    required this.crashFreeRate,
    required this.adoptionRate,
  });
  final String version;
  final DateTime firstSeen, lastSeen;
  final int sessionCount, errorSessionCount, errorCount, userCount;
  final double crashFreeRate, adoptionRate;

  factory ReleaseHealth.fromJson(Map<String, Object?> j) => ReleaseHealth(
    version: _s(j['version']),
    firstSeen: _t(j['first_seen']) ?? DateTime.now(),
    lastSeen: _t(j['last_seen']) ?? DateTime.now(),
    sessionCount: _i(j['session_count']),
    errorSessionCount: _i(j['error_session_count']),
    errorCount: _i(j['error_count']),
    userCount: _i(j['user_count']),
    crashFreeRate: _d(j['crash_free_rate']),
    adoptionRate: _d(j['adoption_rate']),
  );
}


class IssueComment {
  const IssueComment({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.body,
    required this.createdAt,
  });
  final int id, issueId, userId;
  final String userEmail, userName, body;
  final DateTime createdAt;

  factory IssueComment.fromJson(Map<String, Object?> j) => IssueComment(
    id: _i(j['id']),
    issueId: _i(j['issue_id']),
    userId: _i(j['user_id']),
    userEmail: _s(j['user_email']),
    userName: _s(j['user_name']),
    body: _s(j['body']),
    createdAt: _t(j['created_at']) ?? DateTime.now(),
  );
}

class FingerprintRule {
  const FingerprintRule({
    required this.id,
    required this.projectId,
    this.exceptionMatch = '',
    this.messageGlob = '',
    this.stackContains = '',
    required this.action,
    this.groupFingerprint = '',
    this.priority = 0,
    required this.createdAt,
  });
  final int id, projectId, priority;
  final String exceptionMatch,
      messageGlob,
      stackContains,
      action,
      groupFingerprint;
  final DateTime createdAt;

  factory FingerprintRule.fromJson(Map<String, Object?> j) => FingerprintRule(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    exceptionMatch: _s(j['exception_match']),
    messageGlob: _s(j['message_glob']),
    stackContains: _s(j['stack_contains']),
    action: _s(j['action']),
    groupFingerprint: _s(j['group_fingerprint']),
    priority: _i(j['priority']),
    createdAt: _t(j['created_at']) ?? DateTime.now(),
  );
}

class IssueDetail {
  const IssueDetail({
    required this.issue,
    required this.occurrences,
    this.latestSession,
  });
  final Issue issue;
  final List<TimelineItem> occurrences;
  final Session? latestSession;

  Session? get activeSession =>
      latestSession ?? (occurrences.isNotEmpty ? occurrences.first.toSession() : null);

  factory IssueDetail.fromJson(Map<String, Object?> j) => IssueDetail(
    issue: Issue.fromJson(j),
    occurrences: [
      for (final o in (j['occurrences'] as List? ?? const []))
        TimelineItem.fromJson(_m(o)),
    ],
    latestSession: j['latest_session'] is Map
        ? Session.fromJson(_m(j['latest_session']))
        : null,
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

class AlertChannel {
  const AlertChannel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.kind,
    required this.target,
    this.secret = '',
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String kind; // 'email' | 'slack' | 'webhook'
  final String target;
  final String secret;
  final DateTime? createdAt;

  factory AlertChannel.fromJson(Map<String, Object?> j) => AlertChannel(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    kind: _s(j['kind']),
    target: _s(j['target']),
    secret: _s(j['secret']),
    createdAt: _t(j['created_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'kind': kind,
    'target': target,
    if (secret.isNotEmpty) 'secret': secret,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class AlertRule {
  const AlertRule({
    required this.id,
    required this.projectId,
    required this.name,
    required this.kind,
    this.params = const {},
    this.channelIds = const [],
    this.enabled = true,
    this.createdAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String kind; // 'new_issue' | 'regression' | 'rate_spike' | 'session_crash_free'
  final Map<String, dynamic> params;
  final List<int> channelIds;
  final bool enabled;
  final DateTime? createdAt;

  factory AlertRule.fromJson(Map<String, Object?> j) => AlertRule(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    kind: _s(j['kind']),
    params: _m(j['params']),
    channelIds: [
      for (final id in (j['channel_ids'] as List? ?? const [])) _i(id),
    ],
    enabled: j['enabled'] as bool? ?? true,
    createdAt: _t(j['created_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'kind': kind,
    'params': params,
    'channel_ids': channelIds,
    'enabled': enabled,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class PerformanceSummaryItem {
  const PerformanceSummaryItem({
    required this.op,
    required this.name,
    required this.count,
    required this.p50,
    required this.p95,
    required this.avgDuration,
    required this.errorCount,
    required this.errorRate,
  });

  final String op;
  final String name;
  final int count;
  final double p50;
  final double p95;
  final double avgDuration;
  final int errorCount;
  final double errorRate;

  factory PerformanceSummaryItem.fromJson(Map<String, Object?> j) =>
      PerformanceSummaryItem(
        op: _s(j['op']),
        name: _s(j['name']),
        count: _i(j['count']),
        p50: _d(j['p50']),
        p95: _d(j['p95']),
        avgDuration: _d(j['avg_duration']),
        errorCount: _i(j['error_count']),
        errorRate: _d(j['error_rate']),
      );
}

class PerformanceResponse {
  const PerformanceResponse({
    this.summary = const [],
    this.ops = const [],
  });

  final List<PerformanceSummaryItem> summary;
  final List<String> ops;

  factory PerformanceResponse.fromJson(Map<String, Object?> j) =>
      PerformanceResponse(
        summary: [
          for (final s in (j['summary'] as List? ?? const []))
            PerformanceSummaryItem.fromJson(_m(s)),
        ],
        ops: [for (final o in (j['ops'] as List? ?? const [])) _s(o)],
      );
}

class SpanSample {
  const SpanSample({
    required this.id,
    required this.sessionId,
    required this.ts,
    required this.durationMs,
    required this.status,
    this.tagsJson = '{}',
  });

  final int id;
  final String sessionId;
  final DateTime ts;
  final double durationMs;
  final String status;
  final String tagsJson;

  factory SpanSample.fromJson(Map<String, Object?> j) => SpanSample(
        id: _i(j['id']),
        sessionId: _s(j['session_id']),
        ts: _t(j['ts']) ?? DateTime.now(),
        durationMs: _d(j['duration_ms']),
        status: _s(j['status']),
        tagsJson: _s(j['tags_json']),
      );
}

class DailyPerformancePoint {
  const DailyPerformancePoint({
    required this.date,
    required this.count,
    required this.p50,
    required this.p95,
    required this.avgDuration,
  });

  final String date;
  final int count;
  final double p50;
  final double p95;
  final double avgDuration;

  factory DailyPerformancePoint.fromJson(Map<String, Object?> j) =>
      DailyPerformancePoint(
        date: _s(j['date']),
        count: _i(j['count']),
        p50: _d(j['p50']),
        p95: _d(j['p95']),
        avgDuration: _d(j['avg_duration']),
      );
}

class TransactionDetailResponse {
  const TransactionDetailResponse({
    required this.op,
    required this.name,
    required this.count,
    required this.p50,
    required this.p95,
    required this.avgDuration,
    required this.errorCount,
    required this.errorRate,
    this.daily = const [],
    this.samples = const [],
  });

  final String op;
  final String name;
  final int count;
  final double p50;
  final double p95;
  final double avgDuration;
  final int errorCount;
  final double errorRate;
  final List<DailyPerformancePoint> daily;
  final List<SpanSample> samples;

  factory TransactionDetailResponse.fromJson(Map<String, Object?> j) =>
      TransactionDetailResponse(
        op: _s(j['op']),
        name: _s(j['name']),
        count: _i(j['count']),
        p50: _d(j['p50']),
        p95: _d(j['p95']),
        avgDuration: _d(j['avg_duration']),
        errorCount: _i(j['error_count']),
        errorRate: _d(j['error_rate']),
        daily: [
          for (final d in (j['daily'] as List? ?? const []))
            DailyPerformancePoint.fromJson(_m(d)),
        ],
        samples: [
          for (final s in (j['samples'] as List? ?? const []))
            SpanSample.fromJson(_m(s)),
        ],
      );
}

class UserSummary {
  const UserSummary({
    required this.userId,
    this.email,
    this.name,
    this.user = const {},
    required this.sessionCount,
    required this.totalDurationSec,
    required this.avgDurationSec,
    required this.errorCount,
    required this.errorSessionCount,
    required this.firstSeen,
    required this.lastSeen,
    this.lastPlatform = '',
    this.lastBrowser = '',
    this.lastIP = '',
  });

  final String userId;
  final String? email;
  final String? name;
  final Map<String, Object?> user;
  final int sessionCount;
  final double totalDurationSec;
  final double avgDurationSec;
  final int errorCount;
  final int errorSessionCount;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final String lastPlatform;
  final String lastBrowser;
  final String lastIP;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty)
          ? name!
          : (email != null && email!.trim().isNotEmpty)
              ? email!
              : userId;

  String get initials {
    final d = displayName.trim();
    if (d.isEmpty) return '?';
    final parts = d.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return d.substring(0, d.length >= 2 ? 2 : 1).toUpperCase();
  }

  Duration get avgDuration => Duration(seconds: avgDurationSec.round());
  Duration get totalDuration => Duration(seconds: totalDurationSec.round());

  double get crashFreeRate => sessionCount > 0
      ? ((sessionCount - errorSessionCount) / sessionCount * 100)
      : 100.0;

  factory UserSummary.fromJson(Map<String, Object?> j) => UserSummary(
    userId: _s(j['user_id']),
    email: j['email'] is String ? j['email'] as String : null,
    name: j['name'] is String ? j['name'] as String : null,
    user: _m(j['user_json']),
    sessionCount: _i(j['session_count']),
    totalDurationSec: _d(j['total_duration_sec']),
    avgDurationSec: _d(j['avg_duration_sec']),
    errorCount: _i(j['error_count']),
    errorSessionCount: _i(j['error_session_count']),
    firstSeen: _t(j['first_seen']) ?? DateTime.now(),
    lastSeen: _t(j['last_seen']) ?? DateTime.now(),
    lastPlatform: _s(j['last_platform']),
    lastBrowser: _s(j['last_browser']),
    lastIP: _s(j['last_ip']),
  );
}

class UserDailyStat {
  const UserDailyStat({
    required this.day,
    required this.activeUsers,
    required this.errorUsers,
    required this.avgDurationSec,
  });

  final String day;
  final int activeUsers;
  final int errorUsers;
  final double avgDurationSec;

  factory UserDailyStat.fromJson(Map<String, Object?> j) => UserDailyStat(
    day: _s(j['day']),
    activeUsers: _i(j['active_users']),
    errorUsers: _i(j['error_users']),
    avgDurationSec: _d(j['avg_duration_sec']),
  );
}

class ProjectUsersData {
  const ProjectUsersData({
    required this.totalUsers,
    required this.activeUsers,
    required this.avgDurationSec,
    required this.sessionsPerUser,
    required this.errorUserCount,
    this.daily = const [],
    this.users = const [],
  });

  final int totalUsers;
  final int activeUsers;
  final double avgDurationSec;
  final double sessionsPerUser;
  final int errorUserCount;
  final List<UserDailyStat> daily;
  final List<UserSummary> users;

  Duration get avgDuration => Duration(seconds: avgDurationSec.round());

  factory ProjectUsersData.fromJson(Map<String, Object?> j) => ProjectUsersData(
    totalUsers: _i(j['total_users']),
    activeUsers: _i(j['active_users']),
    avgDurationSec: _d(j['avg_duration_sec']),
    sessionsPerUser: _d(j['sessions_per_user']),
    errorUserCount: _i(j['error_user_count']),
    daily: [
      for (final d in (j['daily'] as List? ?? const []))
        UserDailyStat.fromJson(_m(d)),
    ],
    users: [
      for (final u in (j['users'] as List? ?? const []))
        UserSummary.fromJson(_m(u)),
    ],
  );
}

class FunnelStep {
  const FunnelStep({required this.name});
  final String name;

  factory FunnelStep.fromJson(Map<String, Object?> j) => FunnelStep(
    name: _s(j['name']),
  );

  Map<String, Object?> toJson() => {'name': name};
}

class Funnel {
  const Funnel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    this.steps = const [],
    this.conversionWindowSeconds = 86400,
    this.createdAt,
    this.updatedAt,
  });

  final int id, projectId;
  final String name, description;
  final List<FunnelStep> steps;
  final int conversionWindowSeconds;
  final DateTime? createdAt, updatedAt;

  factory Funnel.fromJson(Map<String, Object?> j) => Funnel(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    description: _s(j['description']),
    steps: [
      for (final s in (j['steps'] as List? ?? const []))
        FunnelStep.fromJson(_m(s)),
    ],
    conversionWindowSeconds: _i(j['conversion_window_seconds']) > 0
        ? _i(j['conversion_window_seconds'])
        : 86400,
    createdAt: _t(j['created_at']),
    updatedAt: _t(j['updated_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'description': description,
    'steps': [for (final s in steps) s.toJson()],
    'conversion_window_seconds': conversionWindowSeconds,
  };
}

class FunnelStepResult {
  const FunnelStepResult({
    required this.stepIndex,
    required this.name,
    required this.count,
    required this.conversionRate,
    required this.dropOffCount,
    required this.dropOffRate,
  });

  final int stepIndex;
  final String name;
  final int count;
  final double conversionRate;
  final int dropOffCount;
  final double dropOffRate;

  factory FunnelStepResult.fromJson(Map<String, Object?> j) => FunnelStepResult(
    stepIndex: _i(j['step_index']),
    name: _s(j['name']),
    count: _i(j['count']),
    conversionRate: _d(j['conversion_rate']),
    dropOffCount: _i(j['drop_off_count']),
    dropOffRate: _d(j['drop_off_rate']),
  );
}

class FunnelResult {
  const FunnelResult({
    required this.funnelId,
    required this.periodDays,
    required this.totalSessions,
    required this.completedSessions,
    required this.overallConversionRate,
    required this.medianConversionSeconds,
    this.steps = const [],
  });

  final int funnelId;
  final int periodDays;
  final int totalSessions;
  final int completedSessions;
  final double overallConversionRate;
  final double medianConversionSeconds;
  final List<FunnelStepResult> steps;

  factory FunnelResult.fromJson(Map<String, Object?> j) => FunnelResult(
    funnelId: _i(j['funnel_id']),
    periodDays: _i(j['period_days']),
    totalSessions: _i(j['total_sessions']),
    completedSessions: _i(j['completed_sessions']),
    overallConversionRate: _d(j['overall_conversion_rate']),
    medianConversionSeconds: _d(j['median_conversion_seconds']),
    steps: [
      for (final s in (j['steps'] as List? ?? const []))
        FunnelStepResult.fromJson(_m(s)),
    ],
  );
}

class CohortRule {
  const CohortRule({
    this.type = 'event',
    this.eventName = '',
    this.propertyKey = '',
    this.operator = 'gte',
    this.value = '1',
    this.windowDays = 30,
  });

  final String type;
  final String eventName;
  final String propertyKey;
  final String operator;
  final String value;
  final int windowDays;

  factory CohortRule.fromJson(Map<String, Object?> j) => CohortRule(
    type: _s(j['type']).isEmpty ? 'event' : _s(j['type']),
    eventName: _s(j['event_name']),
    propertyKey: _s(j['property_key']),
    operator: _s(j['operator']).isEmpty ? 'gte' : _s(j['operator']),
    value: _s(j['value']),
    windowDays: _i(j['window_days']) > 0 ? _i(j['window_days']) : 30,
  );

  Map<String, Object?> toJson() => {
    'type': type,
    'event_name': eventName,
    'property_key': propertyKey,
    'operator': operator,
    'value': value,
    'window_days': windowDays,
  };
}

class Cohort {
  const Cohort({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    this.isDynamic = true,
    this.rules = const [],
    this.memberCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String description;
  final bool isDynamic;
  final List<CohortRule> rules;
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Cohort.fromJson(Map<String, Object?> j) => Cohort(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    description: _s(j['description']),
    isDynamic: j['is_dynamic'] as bool? ?? true,
    rules: [
      for (final r in (j['rules'] as List? ?? const []))
        CohortRule.fromJson(_m(r)),
    ],
    memberCount: _i(j['member_count']),
    createdAt: _t(j['created_at']),
    updatedAt: _t(j['updated_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'description': description,
    'is_dynamic': isDynamic,
    'rules': [for (final r in rules) r.toJson()],
  };
}

class RetentionPeriodActivity {
  const RetentionPeriodActivity({
    required this.periodIndex,
    required this.activeUsers,
    required this.percentage,
  });

  final int periodIndex;
  final int activeUsers;
  final double percentage;

  factory RetentionPeriodActivity.fromJson(Map<String, Object?> j) =>
      RetentionPeriodActivity(
        periodIndex: _i(j['period_index']),
        activeUsers: _i(j['active_users']),
        percentage: _d(j['percentage']),
      );
}

class RetentionCohortBucket {
  const RetentionCohortBucket({
    required this.bucketStart,
    required this.totalUsers,
    this.periods = const [],
  });

  final String bucketStart;
  final int totalUsers;
  final List<RetentionPeriodActivity> periods;

  factory RetentionCohortBucket.fromJson(Map<String, Object?> j) =>
      RetentionCohortBucket(
        bucketStart: _s(j['bucket_start']),
        totalUsers: _i(j['total_users']),
        periods: [
          for (final p in (j['periods'] as List? ?? const []))
            RetentionPeriodActivity.fromJson(_m(p)),
        ],
      );
}

class RetentionResult {
  const RetentionResult({
    required this.periodUnit,
    required this.targetEvent,
    required this.returnEvent,
    required this.totalBuckets,
    this.buckets = const [],
  });

  final String periodUnit;
  final String targetEvent;
  final String returnEvent;
  final int totalBuckets;
  final List<RetentionCohortBucket> buckets;

  factory RetentionResult.fromJson(Map<String, Object?> j) => RetentionResult(
    periodUnit: _s(j['period_unit']).isEmpty ? 'day' : _s(j['period_unit']),
    targetEvent: _s(j['target_event']),
    returnEvent: _s(j['return_event']),
    totalBuckets: _i(j['total_buckets']),
    buckets: [
      for (final b in (j['buckets'] as List? ?? const []))
        RetentionCohortBucket.fromJson(_m(b)),
    ],
  );
}

class PathNode {
  const PathNode({
    required this.id,
    required this.name,
    required this.step,
    required this.count,
  });

  final String id;
  final String name;
  final int step;
  final int count;

  factory PathNode.fromJson(Map<String, Object?> j) => PathNode(
    id: _s(j['id']),
    name: _s(j['name']),
    step: _i(j['step']),
    count: _i(j['count']),
  );
}

class PathLink {
  const PathLink({
    required this.source,
    required this.target,
    required this.count,
  });

  final String source;
  final String target;
  final int count;

  factory PathLink.fromJson(Map<String, Object?> j) => PathLink(
    source: _s(j['source']),
    target: _s(j['target']),
    count: _i(j['count']),
  );
}

class PathResult {
  const PathResult({
    required this.rootEvent,
    required this.direction,
    required this.stepLimit,
    this.nodes = const [],
    this.links = const [],
  });

  final String rootEvent;
  final String direction;
  final int stepLimit;
  final List<PathNode> nodes;
  final List<PathLink> links;

  factory PathResult.fromJson(Map<String, Object?> j) => PathResult(
    rootEvent: _s(j['root_event']),
    direction: _s(j['direction']).isEmpty ? 'forward' : _s(j['direction']),
    stepLimit: _i(j['step_limit']) > 0 ? _i(j['step_limit']) : 4,
    nodes: [
      for (final n in (j['nodes'] as List? ?? const []))
        PathNode.fromJson(_m(n)),
    ],
    links: [
      for (final l in (j['links'] as List? ?? const []))
        PathLink.fromJson(_m(l)),
    ],
  );
}

class FlagFilter {
  const FlagFilter({
    required this.property,
    required this.operator,
    required this.value,
  });

  final String property;
  final String operator;
  final dynamic value;

  factory FlagFilter.fromJson(Map<String, Object?> j) => FlagFilter(
    property: _s(j['property']),
    operator: _s(j['operator']).isEmpty ? 'exact' : _s(j['operator']),
    value: j['value'],
  );

  Map<String, Object?> toJson() => {
    'property': property,
    'operator': operator,
    'value': value,
  };
}

class FlagVariant {
  const FlagVariant({
    required this.key,
    required this.rollout,
  });

  final String key;
  final int rollout;

  factory FlagVariant.fromJson(Map<String, Object?> j) => FlagVariant(
    key: _s(j['key']),
    rollout: _i(j['rollout']) > 0 ? _i(j['rollout']) : 50,
  );

  Map<String, Object?> toJson() => {
    'key': key,
    'rollout': rollout,
  };
}

class FeatureFlag {
  const FeatureFlag({
    required this.id,
    required this.projectId,
    required this.key,
    required this.name,
    this.description = '',
    this.enabled = true,
    this.rolloutPercentage = 100,
    this.filters = const [],
    this.variants = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int projectId;
  final String key;
  final String name;
  final String description;
  final bool enabled;
  final int rolloutPercentage;
  final List<FlagFilter> filters;
  final List<FlagVariant> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FeatureFlag.fromJson(Map<String, Object?> j) => FeatureFlag(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    key: _s(j['key']),
    name: _s(j['name']),
    description: _s(j['description']),
    enabled: j['enabled'] != false,
    rolloutPercentage: _i(j['rollout_percentage']),
    filters: [
      for (final f in (j['filters'] as List? ?? const []))
        FlagFilter.fromJson(_m(f)),
    ],
    variants: [
      for (final v in (j['variants'] as List? ?? const []))
        FlagVariant.fromJson(_m(v)),
    ],
    createdAt: _t(j['created_at']),
    updatedAt: _t(j['updated_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'key': key,
    'name': name,
    'description': description,
    'enabled': enabled,
    'rollout_percentage': rolloutPercentage,
    'filters': [for (final f in filters) f.toJson()],
    'variants': [for (final v in variants) v.toJson()],
  };
}

class ExperimentVariant {
  const ExperimentVariant({
    required this.key,
    required this.name,
  });

  final String key;
  final String name;

  factory ExperimentVariant.fromJson(Map<String, Object?> j) => ExperimentVariant(
    key: _s(j['key']),
    name: _s(j['name']),
  );

  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
  };
}

class Experiment {
  const Experiment({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    required this.featureFlagKey,
    this.status = 'draft',
    required this.primaryMetricEvent,
    this.secondaryMetricEvents = const [],
    this.variants = const [],
    this.minimumSampleSize = 100,
    this.winnerVariant,
    this.startedAt,
    this.concludedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String description;
  final String featureFlagKey;
  final String status;
  final String primaryMetricEvent;
  final List<String> secondaryMetricEvents;
  final List<ExperimentVariant> variants;
  final int minimumSampleSize;
  final String? winnerVariant;
  final DateTime? startedAt;
  final DateTime? concludedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Experiment.fromJson(Map<String, Object?> j) => Experiment(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    description: _s(j['description']),
    featureFlagKey: _s(j['feature_flag_key']),
    status: _s(j['status']).isEmpty ? 'draft' : _s(j['status']),
    primaryMetricEvent: _s(j['primary_metric_event']),
    secondaryMetricEvents: [
      for (final s in (j['secondary_metric_events'] as List? ?? const []))
        _s(s),
    ],
    variants: [
      for (final v in (j['variants'] as List? ?? const []))
        ExperimentVariant.fromJson(_m(v)),
    ],
    minimumSampleSize: _i(j['minimum_sample_size']) == 0 ? 100 : _i(j['minimum_sample_size']),
    winnerVariant: j['winner_variant'] == null ? null : _s(j['winner_variant']),
    startedAt: _t(j['started_at']),
    concludedAt: _t(j['concluded_at']),
    createdAt: _t(j['created_at']),
    updatedAt: _t(j['updated_at']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'description': description,
    'feature_flag_key': featureFlagKey,
    'status': status,
    'primary_metric_event': primaryMetricEvent,
    'secondary_metric_events': secondaryMetricEvents,
    'variants': [for (final v in variants) v.toJson()],
    'minimum_sample_size': minimumSampleSize,
    'winner_variant': winnerVariant,
  };
}

class VariantResult {
  const VariantResult({
    required this.key,
    required this.name,
    required this.participants,
    required this.conversions,
    required this.conversionRate,
    this.confidenceInterval = const [0, 0],
    this.relativeLift = 0,
    this.chanceToWin = 0,
    this.pValue = 0,
  });

  final String key;
  final String name;
  final int participants;
  final int conversions;
  final double conversionRate;
  final List<double> confidenceInterval;
  final double relativeLift;
  final double chanceToWin;
  final double pValue;

  factory VariantResult.fromJson(Map<String, Object?> j) {
    final ciRaw = j['confidence_interval'] as List? ?? const [];
    return VariantResult(
      key: _s(j['key']),
      name: _s(j['name']),
      participants: _i(j['participants']),
      conversions: _i(j['conversions']),
      conversionRate: _d(j['conversion_rate']),
      confidenceInterval: [
        for (final c in ciRaw) _d(c),
      ],
      relativeLift: _d(j['relative_lift']),
      chanceToWin: _d(j['chance_to_win']),
      pValue: _d(j['p_value']),
    );
  }
}

class ExperimentResults {
  const ExperimentResults({
    required this.experimentId,
    required this.status,
    required this.totalParticipants,
    required this.statisticalSignificance,
    required this.isSignificant,
    this.recommendedAction = '',
    this.variants = const [],
  });

  final int experimentId;
  final String status;
  final int totalParticipants;
  final double statisticalSignificance;
  final bool isSignificant;
  final String recommendedAction;
  final List<VariantResult> variants;

  factory ExperimentResults.fromJson(Map<String, Object?> j) => ExperimentResults(
    experimentId: _i(j['experiment_id']),
    status: _s(j['status']),
    totalParticipants: _i(j['total_participants']),
    statisticalSignificance: _d(j['statistical_significance']),
    isSignificant: j['is_significant'] == true,
    recommendedAction: _s(j['recommended_action']),
    variants: [
      for (final v in (j['variants'] as List? ?? const []))
        VariantResult.fromJson(_m(v)),
    ],
  );
}

class SurveyTargeting {
  const SurveyTargeting({
    this.urlPattern = '',
    this.eventTrigger = '',
    this.sampleRate = 1.0,
  });

  final String urlPattern;
  final String eventTrigger;
  final double sampleRate;

  factory SurveyTargeting.fromJson(Map<String, Object?> j) => SurveyTargeting(
    urlPattern: _s(j['url_pattern']),
    eventTrigger: _s(j['event_trigger']),
    sampleRate: j.containsKey('sample_rate') ? _d(j['sample_rate']) : 1.0,
  );

  Map<String, Object?> toJson() => {
    if (urlPattern.isNotEmpty) 'url_pattern': urlPattern,
    if (eventTrigger.isNotEmpty) 'event_trigger': eventTrigger,
    'sample_rate': sampleRate,
  };
}

class Survey {
  const Survey({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.question,
    this.description = '',
    this.choices = const [],
    this.targeting = const SurveyTargeting(),
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String type; // 'nps', 'csat', 'rating', 'open_text', 'single_choice'
  final String question;
  final String description;
  final List<String> choices;
  final SurveyTargeting targeting;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Survey.fromJson(Map<String, Object?> j) => Survey(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    name: _s(j['name']),
    type: _s(j['type']),
    question: _s(j['question']),
    description: _s(j['description']),
    choices: [
      for (final c in (j['choices'] as List? ?? const [])) _s(c),
    ],
    targeting: SurveyTargeting.fromJson(_m(j['targeting'])),
    active: j['active'] == true,
    createdAt: _t(j['created_at']) ?? DateTime.now(),
    updatedAt: _t(j['updated_at']) ?? DateTime.now(),
  );
}

class SurveyResponse {
  const SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.projectId,
    this.sessionId,
    required this.userId,
    this.score,
    required this.responseText,
    required this.createdAt,
  });

  final int id;
  final int surveyId;
  final int projectId;
  final String? sessionId;
  final String userId;
  final int? score;
  final String responseText;
  final DateTime createdAt;

  factory SurveyResponse.fromJson(Map<String, Object?> j) => SurveyResponse(
    id: _i(j['id']),
    surveyId: _i(j['survey_id']),
    projectId: _i(j['project_id']),
    sessionId: j['session_id'] != null && _s(j['session_id']).isNotEmpty ? _s(j['session_id']) : null,
    userId: _s(j['user_id']),
    score: j['score'] != null ? _i(j['score']) : null,
    responseText: _s(j['response_text']),
    createdAt: _t(j['created_at']) ?? DateTime.now(),
  );
}

class ScoreBucket {
  const ScoreBucket({
    required this.score,
    required this.count,
  });

  final int score;
  final int count;

  factory ScoreBucket.fromJson(Map<String, Object?> j) => ScoreBucket(
    score: _i(j['score']),
    count: _i(j['count']),
  );
}

class SurveyResults {
  const SurveyResults({
    required this.surveyId,
    required this.type,
    required this.totalResponses,
    this.npsScore,
    this.promotersCount = 0,
    this.passivesCount = 0,
    this.detractorsCount = 0,
    this.averageScore,
    this.satisfactionRate,
    this.distribution = const [],
    this.choiceCounts = const {},
  });

  final int surveyId;
  final String type;
  final int totalResponses;
  final double? npsScore;
  final int promotersCount;
  final int passivesCount;
  final int detractorsCount;
  final double? averageScore;
  final double? satisfactionRate;
  final List<ScoreBucket> distribution;
  final Map<String, int> choiceCounts;

  factory SurveyResults.fromJson(Map<String, Object?> j) => SurveyResults(
    surveyId: _i(j['survey_id']),
    type: _s(j['type']),
    totalResponses: _i(j['total_responses']),
    npsScore: j['nps_score'] != null ? _d(j['nps_score']) : null,
    promotersCount: _i(j['promoters_count']),
    passivesCount: _i(j['passives_count']),
    detractorsCount: _i(j['detractors_count']),
    averageScore: j['average_score'] != null ? _d(j['average_score']) : null,
    satisfactionRate: j['satisfaction_rate'] != null ? _d(j['satisfaction_rate']) : null,
    distribution: [
      for (final b in (j['distribution'] as List? ?? const []))
        ScoreBucket.fromJson(_m(b)),
    ],
    choiceCounts: {
      for (final entry in _m(j['choice_counts']).entries)
        entry.key: _i(entry.value),
    },
  );
}

class CronMonitor {
  const CronMonitor({
    required this.id,
    required this.projectId,
    required this.slug,
    required this.name,
    required this.schedule,
    required this.timezone,
    required this.gracePeriodMinutes,
    required this.maxRuntimeMinutes,
    required this.status,
    this.lastCheckinAt,
    this.nextExpectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String slug;
  final String name;
  final String schedule;
  final String timezone;
  final int gracePeriodMinutes;
  final int maxRuntimeMinutes;
  final String status;
  final DateTime? lastCheckinAt;
  final DateTime? nextExpectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CronMonitor.fromJson(Map<String, Object?> j) => CronMonitor(
    id: _i(j['id']),
    projectId: _i(j['project_id']),
    slug: _s(j['slug']),
    name: _s(j['name']),
    schedule: _s(j['schedule']),
    timezone: _s(j['timezone']).isEmpty ? 'UTC' : _s(j['timezone']),
    gracePeriodMinutes: _i(j['grace_period_minutes']) == 0 ? 15 : _i(j['grace_period_minutes']),
    maxRuntimeMinutes: _i(j['max_runtime_minutes']) == 0 ? 60 : _i(j['max_runtime_minutes']),
    status: _s(j['status']).isEmpty ? 'ok' : _s(j['status']),
    lastCheckinAt: _t(j['last_checkin_at']),
    nextExpectedAt: _t(j['next_expected_at']),
    createdAt: _t(j['created_at']) ?? DateTime.now(),
    updatedAt: _t(j['updated_at']) ?? DateTime.now(),
  );
}

class CronCheckin {
  const CronCheckin({
    required this.id,
    required this.monitorId,
    required this.projectId,
    required this.status,
    this.durationMs,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final int monitorId;
  final int projectId;
  final String status;
  final int? durationMs;
  final String message;
  final DateTime createdAt;

  factory CronCheckin.fromJson(Map<String, Object?> j) => CronCheckin(
    id: _i(j['id']),
    monitorId: _i(j['monitor_id']),
    projectId: _i(j['project_id']),
    status: _s(j['status']),
    durationMs: j['duration_ms'] != null ? _i(j['duration_ms']) : null,
    message: _s(j['message']),
    createdAt: _t(j['created_at']) ?? DateTime.now(),
  );
}

class CronStats {
  const CronStats({
    this.totalMonitors = 0,
    this.okCount = 0,
    this.inProgressCount = 0,
    this.errorCount = 0,
    this.missedCount = 0,
  });

  final int totalMonitors;
  final int okCount;
  final int inProgressCount;
  final int errorCount;
  final int missedCount;

  factory CronStats.fromJson(Map<String, Object?> j) => CronStats(
    totalMonitors: _i(j['total_monitors']),
    okCount: _i(j['ok_count']),
    inProgressCount: _i(j['in_progress_count']),
    errorCount: _i(j['error_count']),
    missedCount: _i(j['missed_count']),
  );
}

class UptimeMonitor {
  const UptimeMonitor({
    required this.id,
    required this.projectId,
    required this.name,
    required this.url,
    required this.method,
    required this.headers,
    required this.expectedStatusCode,
    required this.intervalSeconds,
    required this.timeoutSeconds,
    required this.status,
    required this.sslCheckEnabled,
    this.sslIssuer,
    this.sslExpiresAt,
    this.lastCheckedAt,
    required this.uptimePercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String name;
  final String url;
  final String method;
  final Map<String, String> headers;
  final int expectedStatusCode;
  final int intervalSeconds;
  final int timeoutSeconds;
  final String status;
  final bool sslCheckEnabled;
  final String? sslIssuer;
  final DateTime? sslExpiresAt;
  final DateTime? lastCheckedAt;
  final double uptimePercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UptimeMonitor.fromJson(Map<String, Object?> j) {
    final rawHeaders = j['headers'];
    final headersMap = <String, String>{};
    if (rawHeaders is Map) {
      for (final e in rawHeaders.entries) {
        headersMap[e.key.toString()] = e.value?.toString() ?? '';
      }
    }
    return UptimeMonitor(
      id: _i(j['id']),
      projectId: _i(j['project_id']),
      name: _s(j['name']),
      url: _s(j['url']),
      method: _s(j['method']).isEmpty ? 'GET' : _s(j['method']),
      headers: headersMap,
      expectedStatusCode: _i(j['expected_status_code']) == 0 ? 200 : _i(j['expected_status_code']),
      intervalSeconds: _i(j['interval_seconds']) == 0 ? 60 : _i(j['interval_seconds']),
      timeoutSeconds: _i(j['timeout_seconds']) == 0 ? 10 : _i(j['timeout_seconds']),
      status: _s(j['status']).isEmpty ? 'up' : _s(j['status']),
      sslCheckEnabled: j['ssl_check_enabled'] == true,
      sslIssuer: j['ssl_issuer'] != null ? _s(j['ssl_issuer']) : null,
      sslExpiresAt: _t(j['ssl_expires_at']),
      lastCheckedAt: _t(j['last_checked_at']),
      uptimePercentage: _d(j['uptime_percentage']),
      createdAt: _t(j['created_at']) ?? DateTime.now(),
      updatedAt: _t(j['updated_at']) ?? DateTime.now(),
    );
  }
}

class UptimeCheck {
  const UptimeCheck({
    required this.id,
    required this.monitorId,
    required this.projectId,
    required this.checkedAt,
    required this.statusCode,
    required this.responseTimeMs,
    required this.isUp,
    required this.errorMessage,
  });

  final int id;
  final int monitorId;
  final int projectId;
  final DateTime checkedAt;
  final int statusCode;
  final int responseTimeMs;
  final bool isUp;
  final String errorMessage;

  factory UptimeCheck.fromJson(Map<String, Object?> j) => UptimeCheck(
    id: _i(j['id']),
    monitorId: _i(j['monitor_id']),
    projectId: _i(j['project_id']),
    checkedAt: _t(j['checked_at']) ?? DateTime.now(),
    statusCode: _i(j['status_code']),
    responseTimeMs: _i(j['response_time_ms']),
    isUp: j['is_up'] == true,
    errorMessage: _s(j['error_message']),
  );
}

class UptimeSSLInfo {
  const UptimeSSLInfo({
    required this.valid,
    this.expiresAt,
    required this.daysRemaining,
    required this.issuer,
  });

  final bool valid;
  final DateTime? expiresAt;
  final int daysRemaining;
  final String issuer;

  factory UptimeSSLInfo.fromJson(Map<String, Object?> j) => UptimeSSLInfo(
    valid: j['valid'] == true,
    expiresAt: _t(j['expires_at']),
    daysRemaining: _i(j['days_remaining']),
    issuer: _s(j['issuer']),
  );
}

class UptimeDaySummary {
  const UptimeDaySummary({
    required this.date,
    required this.status,
    required this.avgMs,
    required this.uptimePct,
  });

  final String date;
  final String status;
  final int avgMs;
  final double uptimePct;

  factory UptimeDaySummary.fromJson(Map<String, Object?> j) => UptimeDaySummary(
    date: _s(j['date']),
    status: _s(j['status']),
    avgMs: _i(j['avg_ms']),
    uptimePct: _d(j['uptime_pct']),
  );
}

class UptimeHistoryDetail {
  const UptimeHistoryDetail({
    this.monitor,
    required this.status,
    required this.uptimePercentage,
    required this.currentResponseTimeMs,
    this.ssl,
    this.history90d = const [],
    this.recentChecks = const [],
  });

  final UptimeMonitor? monitor;
  final String status;
  final double uptimePercentage;
  final int currentResponseTimeMs;
  final UptimeSSLInfo? ssl;
  final List<UptimeDaySummary> history90d;
  final List<UptimeCheck> recentChecks;

  factory UptimeHistoryDetail.fromJson(Map<String, Object?> j) {
    final rawHist = j['history_90d'];
    final rawChecks = j['recent_checks'];
    return UptimeHistoryDetail(
      monitor: j['monitor'] is Map<String, Object?>
          ? UptimeMonitor.fromJson(j['monitor'] as Map<String, Object?>)
          : null,
      status: _s(j['status']).isEmpty ? 'up' : _s(j['status']),
      uptimePercentage: _d(j['uptime_percentage']),
      currentResponseTimeMs: _i(j['current_response_time_ms']),
      ssl: j['ssl'] is Map<String, Object?>
          ? UptimeSSLInfo.fromJson(j['ssl'] as Map<String, Object?>)
          : null,
      history90d: rawHist is List
          ? rawHist
              .whereType<Map<String, Object?>>()
              .map(UptimeDaySummary.fromJson)
              .toList()
          : const [],
      recentChecks: rawChecks is List
          ? rawChecks
              .whereType<Map<String, Object?>>()
              .map(UptimeCheck.fromJson)
              .toList()
          : const [],
    );
  }
}

class UptimeStats {
  const UptimeStats({
    this.totalMonitors = 0,
    this.upCount = 0,
    this.degradedCount = 0,
    this.downCount = 0,
    this.avgUptimePct = 100.0,
  });

  final int totalMonitors;
  final int upCount;
  final int degradedCount;
  final int downCount;
  final double avgUptimePct;

  factory UptimeStats.fromJson(Map<String, Object?> j) => UptimeStats(
    totalMonitors: _i(j['total_monitors']),
    upCount: _i(j['up_count']),
    degradedCount: _i(j['degraded_count']),
    downCount: _i(j['down_count']),
    avgUptimePct: j.containsKey('avg_uptime_pct') ? _d(j['avg_uptime_pct']) : 100.0,
  );
}




