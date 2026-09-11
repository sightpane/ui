import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models.dart';

/// An error returned by the backend.
///
/// [code] is the backend's `code` field (e.g. `auth.invalid_credentials`) and
/// decides which sentence the dashboard shows — [message] is the English server
/// text, never shown to the user, and exists for logs and debugging.
/// The translation by code happens in `describeError`.
class ApiException implements Exception {
  const ApiException(this.status, this.message, {this.code = '', this.detail});
  final int status;
  final String message;
  final String code;

  /// Extra information tied to the code; for now only the server address on a
  /// network error.
  final String? detail;

  /// The network was never reached at all (CORS, server down, wrong address).
  static const codeNetwork = 'network';

  @override
  String toString() => message;
}

/// Backend access; swapped for a fake in tests.
abstract class SightpaneApi {
  Future<AuthSession> login(String email, String password);
  Future<AuthSession> register(String email, String name, String password);
  Future<void> logout();
  Future<SightpaneUser> me();

  /// Account settings; for now only the dashboard language.
  Future<SightpaneUser> updateMe({String? locale});

  Future<List<Project>> projects();
  Future<Project> project(int id);
  Future<Project> createProject(String name, {String platform = 'flutter'});
  Future<Project> updateProject(
    int id, {
    required String name,
    String platform = 'flutter',
    int? retentionDays,
    int? quotaItemsPerMinute,
    String? storeIp,
    String? scrubRulesJson,
  });
  Future<void> deleteUserData(int projectId, String userId);
  String userExportUrl(int projectId, String userId);
  Future<void> deleteProject(int id);
  Future<String> rotateKey(int id);
  Future<List<Member>> members(int id);
  Future<List<Member>> addMember(
    int id,
    String email, {
    String role = 'member',
  });
  Future<List<Member>> removeMember(int id, int userId);
  Future<ProjectStats> stats(int id, {int days = 14});
  Future<LiveStatus> live(int id, {int windowSeconds = 60});

  Future<List<Session>> sessions(
    int projectId, {
    bool onlyErrors = false,
    String user = '',
    String query = '',
    int limit = 100,
  });
  Future<ProjectUsersData> users(
    int projectId, {
    int days = 14,
    String query = '',
  });
  Future<List<Funnel>> funnels(int projectId);
  Future<Funnel> createFunnel(
    int projectId, {
    required String name,
    String description = '',
    required List<FunnelStep> steps,
    int conversionWindowSeconds = 86400,
  });
  Future<Funnel> funnel(int projectId, int funnelId);
  Future<Funnel> updateFunnel(
    int projectId,
    int funnelId, {
    String? name,
    String? description,
    List<FunnelStep>? steps,
    int? conversionWindowSeconds,
  });
  Future<void> deleteFunnel(int projectId, int funnelId);
  Future<FunnelResult> funnelResults(
    int projectId,
    int funnelId, {
    int days = 7,
  });
  Future<List<String>> funnelDropoffs(
    int projectId,
    int funnelId, {
    required int step,
    int days = 7,
    int limit = 50,
  });
  Future<List<Cohort>> cohorts(int projectId);
  Future<Cohort> createCohort(
    int projectId, {
    required String name,
    String description = '',
    bool isDynamic = true,
    List<CohortRule> rules = const [],
  });
  Future<Cohort> cohort(int projectId, int id);
  Future<Cohort> updateCohort(
    int projectId,
    int id, {
    String? name,
    String? description,
    bool? isDynamic,
    List<CohortRule>? rules,
  });
  Future<void> deleteCohort(int projectId, int id);
  Future<List<String>> cohortMembers(
    int projectId,
    int id, {
    int limit = 50,
    int offset = 0,
  });
  Future<Map<String, Object?>> refreshCohort(int projectId, int id);
  Future<RetentionResult> retention(
    int projectId, {
    int days = 30,
    String period = 'day',
    String targetEvent = '',
    String returnEvent = '',
    int? cohortId,
  });
  Future<PathResult> paths(
    int projectId, {
    String rootEvent = '',
    String direction = 'forward',
    int stepLimit = 4,
    int days = 14,
    List<String> exclude = const [],
    double threshold = 1.0,
  });
  Future<List<String>> pathSessions(
    int projectId, {
    required String source,
    required String target,
    int days = 14,
    int limit = 50,
  });
  Future<List<FeatureFlag>> featureFlags(int projectId);
  Future<FeatureFlag> createFeatureFlag(
    int projectId, {
    required String key,
    required String name,
    String description = '',
    bool enabled = true,
    int rolloutPercentage = 100,
    List<FlagFilter> filters = const [],
    List<FlagVariant> variants = const [],
  });
  Future<FeatureFlag> updateFeatureFlag(
    int projectId,
    int flagId, {
    required String name,
    String description = '',
    bool enabled = true,
    int rolloutPercentage = 100,
    List<FlagFilter> filters = const [],
    List<FlagVariant> variants = const [],
  });
  Future<void> deleteFeatureFlag(int projectId, int flagId);
  Future<Map<String, dynamic>> testFeatureFlag(
    int projectId,
    int flagId, {
    required String distinctId,
    Map<String, dynamic> properties = const {},
  });
  Future<SessionDetail> session(String id);
  String frameUrl(String sessionId, int seq);
  Future<List<Issue>> issues(
    int projectId, {
    bool includeResolved = false,
    String query = '',
  });
  Future<IssueDetail> issue(int id);
  Future<void> resolveIssue(int id, {bool undo = false});
  Future<void> assignIssue(int id, int? userId);
  Future<void> setIssueStatus(int id, String status);
  Future<void> snoozeIssue(int id, {DateTime? until, int countThreshold = 0});
  Future<void> mergeIssue(int sourceId, int targetId);
  Future<List<IssueComment>> issueComments(int issueId);
  Future<IssueComment> addIssueComment(int issueId, String body);
  Future<List<FingerprintRule>> fingerprintRules(int projectId);
  Future<FingerprintRule> createFingerprintRule(
    int projectId, {
    String exceptionMatch = '',
    String messageGlob = '',
    String stackContains = '',
    required String action,
    String groupFingerprint = '',
    int priority = 0,
  });
  Future<void> deleteFingerprintRule(int projectId, int ruleId);
  Future<List<EventCount>> eventSummary(int projectId, {int days = 30});
  Future<List<ReleaseHealth>> releases(int projectId);
  Future<ReleaseHealth> releaseHealth(int projectId, String version);
  Future<PerformanceResponse> performance(
    int projectId, {
    int days = 14,
    String op = '',
  });
  Future<TransactionDetailResponse> transactionDetail(
    int projectId, {
    required String name,
    String op = '',
    int days = 14,
  });


  Future<List<AlertChannel>> alertChannels(int projectId);
  Future<AlertChannel> createAlertChannel(
    int projectId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  });
  Future<AlertChannel> updateAlertChannel(
    int projectId,
    int channelId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  });
  Future<void> deleteAlertChannel(int projectId, int channelId);
  Future<void> testAlertChannel(int projectId, int channelId);

  Future<List<AlertRule>> alertRules(int projectId);
  Future<AlertRule> createAlertRule(
    int projectId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    bool enabled = true,
  });
  Future<AlertRule> updateAlertRule(
    int projectId,
    int ruleId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    required bool enabled,
  });
  Future<void> deleteAlertRule(int projectId, int ruleId);

  Future<List<Org>> orgs();
  Future<Org> createOrg(String name);
  Future<Org> org(int id);
  Future<List<OrgMember>> orgMembers(int orgId);
  Future<List<OrgMember>> addOrgMember(
    int orgId,
    String email, {
    String role = 'member',
  });
  Future<void> updateOrgMemberRole(int orgId, int userId, String role);
  Future<void> removeOrgMember(int orgId, int userId);
  Future<List<AuditLogEntry>> auditLogs(
    int orgId, {
    int? projectId,
    int limit = 100,
  });
  Future<List<ApiToken>> apiTokens(int orgId);
  Future<ApiToken> createApiToken(
    int orgId, {
    required String name,
    required List<String> scopes,
    DateTime? expiresAt,
  });
  Future<void> deleteApiToken(int orgId, int tokenId);
}

/// The real HTTP client. [token] is supplied once a session is opened.
class HttpSightpaneApi implements SightpaneApi {
  HttpSightpaneApi({String? baseUrl, http.Client? client, this.tokenProvider})
    : baseUrl = (baseUrl ?? AppConfig.apiUrl).replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  final String? Function()? tokenProvider;

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    if (tokenProvider?.call() case final t? when t.isNotEmpty)
      'authorization': 'Bearer $t',
  };

  Future<Object?> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query == null || query.isEmpty ? null : query);
    final req = http.Request(method, uri)..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    late http.Response r;
    try {
      r = await http.Response.fromStream(await _client.send(req));
    } catch (e) {
      throw ApiException(
        0,
        'cannot reach $baseUrl: $e',
        code: ApiException.codeNetwork,
        detail: baseUrl,
      );
    }
    final decoded = r.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 400) {
      throw ApiException(
        r.statusCode,
        decoded is Map && decoded['error'] != null
            ? '${decoded['error']}'
            : 'HTTP ${r.statusCode}',
        code: decoded is Map ? '${decoded['code'] ?? ''}' : '',
      );
    }
    return decoded;
  }

  @override
  Future<SightpaneUser> updateMe({String? locale}) async =>
      SightpaneUser.fromJson(
        _map(
          await _send('PATCH', '/api/v1/auth/me', body: {'locale': ?locale}),
        ),
      );

  Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
  List<Map<String, Object?>> _list(Object? v) => [
    for (final e in (v as List? ?? const [])) _map(e),
  ];

  AuthSession _auth(Object? v) {
    final m = _map(v);
    return AuthSession(
      token: '${m['token']}',
      user: SightpaneUser.fromJson(_map(m['user'])),
    );
  }

  @override
  Future<AuthSession> login(String email, String password) async => _auth(
    await _send(
      'POST',
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    ),
  );
  @override
  Future<AuthSession> register(
    String email,
    String name,
    String password,
  ) async => _auth(
    await _send(
      'POST',
      '/api/v1/auth/register',
      body: {'email': email, 'name': name, 'password': password},
    ),
  );
  @override
  Future<void> logout() => _send('POST', '/api/v1/auth/logout');
  @override
  Future<SightpaneUser> me() async =>
      SightpaneUser.fromJson(_map(await _send('GET', '/api/v1/auth/me')));

  @override
  Future<List<Project>> projects() async => [
    for (final p in _list(await _send('GET', '/api/v1/projects')))
      Project.fromJson(p),
  ];
  @override
  Future<Project> project(int id) async =>
      Project.fromJson(_map(await _send('GET', '/api/v1/projects/$id')));
  @override
  Future<Project> createProject(
    String name, {
    String platform = 'flutter',
  }) async => Project.fromJson(
    _map(
      await _send(
        'POST',
        '/api/v1/projects',
        body: {'name': name, 'platform': platform},
      ),
    ),
  );
  @override
  Future<Project> updateProject(
    int id, {
    required String name,
    String platform = 'flutter',
    int? retentionDays,
    int? quotaItemsPerMinute,
    String? storeIp,
    String? scrubRulesJson,
  }) async => Project.fromJson(
    _map(
      await _send(
        'PATCH',
        '/api/v1/projects/$id',
        body: {
          'name': name,
          'platform': platform,
          'retention_days': ?retentionDays,
          'quota_items_per_minute': ?quotaItemsPerMinute,
          'store_ip': ?storeIp,
          'scrub_rules_json': ?scrubRulesJson,
        },
      ),
    ),
  );

  @override
  Future<void> deleteUserData(int projectId, String userId) =>
      _send('DELETE', '/api/v1/projects/$projectId/users/$userId');

  @override
  String userExportUrl(int projectId, String userId) =>
      '$baseUrl/api/v1/projects/$projectId/users/$userId/export';
  @override
  Future<void> deleteProject(int id) => _send('DELETE', '/api/v1/projects/$id');
  @override
  Future<String> rotateKey(int id) async =>
      '${_map(await _send('POST', '/api/v1/projects/$id/rotate-key'))['api_key']}';
  @override
  Future<List<Member>> members(int id) async => [
    for (final m in _list(await _send('GET', '/api/v1/projects/$id/members')))
      Member.fromJson(m),
  ];
  @override
  Future<List<Member>> addMember(
    int id,
    String email, {
    String role = 'member',
  }) async => [
    for (final m in _list(
      await _send(
        'POST',
        '/api/v1/projects/$id/members',
        body: {'email': email, 'role': role},
      ),
    ))
      Member.fromJson(m),
  ];
  @override
  Future<List<Member>> removeMember(int id, int userId) async => [
    for (final m in _list(
      await _send('DELETE', '/api/v1/projects/$id/members/$userId'),
    ))
      Member.fromJson(m),
  ];
  @override
  Future<LiveStatus> live(int id, {int windowSeconds = 60}) async =>
      LiveStatus.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$id/live',
            query: {'window': '$windowSeconds'},
          ),
        ),
      );

  @override
  Future<ProjectStats> stats(int id, {int days = 14}) async =>
      ProjectStats.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$id/stats',
            query: {'days': '$days'},
          ),
        ),
      );

  @override
  Future<List<Session>> sessions(
    int projectId, {
    bool onlyErrors = false,
    String user = '',
    String query = '',
    int limit = 100,
  }) async => [
    for (final s in _list(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/sessions',
        query: {
          'limit': '$limit',
          if (onlyErrors) 'errors': '1',
          if (user.isNotEmpty) 'user': user,
          if (query.isNotEmpty) 'q': query,
        },
      ),
    ))
      Session.fromJson(s),
  ];

  @override
  Future<ProjectUsersData> users(
    int projectId, {
    int days = 14,
    String query = '',
  }) async =>
      ProjectUsersData.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/users',
            query: {
              'days': '$days',
              if (query.isNotEmpty) 'q': query,
            },
          ),
        ),
      );

  @override
  Future<List<Funnel>> funnels(int projectId) async => [
    for (final f in _list(await _send('GET', '/api/v1/projects/$projectId/funnels')))
      Funnel.fromJson(_map(f)),
  ];

  @override
  Future<Funnel> createFunnel(
    int projectId, {
    required String name,
    String description = '',
    required List<FunnelStep> steps,
    int conversionWindowSeconds = 86400,
  }) async =>
      Funnel.fromJson(
        _map(
          await _send(
            'POST',
            '/api/v1/projects/$projectId/funnels',
            body: {
              'name': name,
              'description': description,
              'steps': [for (final s in steps) s.toJson()],
              'conversion_window_seconds': conversionWindowSeconds,
            },
          ),
        ),
      );

  @override
  Future<Funnel> funnel(int projectId, int funnelId) async =>
      Funnel.fromJson(
        _map(
          await _send('GET', '/api/v1/projects/$projectId/funnels/$funnelId'),
        ),
      );

  @override
  Future<Funnel> updateFunnel(
    int projectId,
    int funnelId, {
    String? name,
    String? description,
    List<FunnelStep>? steps,
    int? conversionWindowSeconds,
  }) async =>
      Funnel.fromJson(
        _map(
          await _send(
            'PATCH',
            '/api/v1/projects/$projectId/funnels/$funnelId',
            body: {
              'name': ?name,
              'description': ?description,
              if (steps != null) 'steps': [for (final s in steps) s.toJson()],
              'conversion_window_seconds': ?conversionWindowSeconds,
            },
          ),
        ),
      );

  @override
  Future<void> deleteFunnel(int projectId, int funnelId) async {
    await _send('DELETE', '/api/v1/projects/$projectId/funnels/$funnelId');
  }

  @override
  Future<FunnelResult> funnelResults(
    int projectId,
    int funnelId, {
    int days = 7,
  }) async =>
      FunnelResult.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/funnels/$funnelId/results',
            query: {'days': '$days'},
          ),
        ),
      );

  @override
  Future<List<String>> funnelDropoffs(
    int projectId,
    int funnelId, {
    required int step,
    int days = 7,
    int limit = 50,
  }) async {
    final res = _map(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/funnels/$funnelId/dropoffs',
        query: {'step': '$step', 'days': '$days', 'limit': '$limit'},
      ),
    );
    return [
      for (final s in (res['session_ids'] as List? ?? const [])) '$s',
    ];
  }

  @override
  Future<List<Cohort>> cohorts(int projectId) async => [
    for (final c in _list(await _send('GET', '/api/v1/projects/$projectId/cohorts')))
      Cohort.fromJson(c),
  ];

  @override
  Future<Cohort> createCohort(
    int projectId, {
    required String name,
    String description = '',
    bool isDynamic = true,
    List<CohortRule> rules = const [],
  }) async =>
      Cohort.fromJson(
        _map(
          await _send(
            'POST',
            '/api/v1/projects/$projectId/cohorts',
            body: {
              'name': name,
              'description': description,
              'is_dynamic': isDynamic,
              'rules': [for (final r in rules) r.toJson()],
            },
          ),
        ),
      );

  @override
  Future<Cohort> cohort(int projectId, int id) async => Cohort.fromJson(
    _map(await _send('GET', '/api/v1/projects/$projectId/cohorts/$id')),
  );

  @override
  Future<Cohort> updateCohort(
    int projectId,
    int id, {
    String? name,
    String? description,
    bool? isDynamic,
    List<CohortRule>? rules,
  }) async =>
      Cohort.fromJson(
        _map(
          await _send(
            'PUT',
            '/api/v1/projects/$projectId/cohorts/$id',
            body: {
              'name': ?name,
              'description': ?description,
              'is_dynamic': ?isDynamic,
              if (rules != null) 'rules': [for (final r in rules) r.toJson()],
            },
          ),
        ),
      );

  @override
  Future<void> deleteCohort(int projectId, int id) async {
    await _send('DELETE', '/api/v1/projects/$projectId/cohorts/$id');
  }

  @override
  Future<List<String>> cohortMembers(
    int projectId,
    int id, {
    int limit = 50,
    int offset = 0,
  }) async {
    final res = _map(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/cohorts/$id/members',
        query: {'limit': '$limit', 'offset': '$offset'},
      ),
    );
    return [for (final m in (res['members'] as List? ?? const [])) '$m'];
  }

  @override
  Future<Map<String, Object?>> refreshCohort(int projectId, int id) async =>
      _map(await _send('POST', '/api/v1/projects/$projectId/cohorts/$id/refresh'));

  @override
  Future<RetentionResult> retention(
    int projectId, {
    int days = 30,
    String period = 'day',
    String targetEvent = '',
    String returnEvent = '',
    int? cohortId,
  }) async =>
      RetentionResult.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/retention',
            query: {
              'days': '$days',
              'period': period,
              if (targetEvent.isNotEmpty) 'target_event': targetEvent,
              if (returnEvent.isNotEmpty) 'return_event': returnEvent,
              if (cohortId != null) 'cohort_id': '$cohortId',
            },
          ),
        ),
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
  }) async =>
      PathResult.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/paths',
            query: {
              if (rootEvent.isNotEmpty) 'root_event': rootEvent,
              'direction': direction,
              'step_limit': '$stepLimit',
              'days': '$days',
              if (exclude.isNotEmpty) 'exclude': exclude.join(','),
              'threshold': '$threshold',
            },
          ),
        ),
      );

  @override
  Future<List<String>> pathSessions(
    int projectId, {
    required String source,
    required String target,
    int days = 14,
    int limit = 50,
  }) async {
    final res = _map(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/paths/sessions',
        query: {
          'source': source,
          'target': target,
          'days': '$days',
          'limit': '$limit',
        },
      ),
    );
    return [
      for (final s in (res['session_ids'] as List? ?? const [])) '$s',
    ];
  }

  @override
  Future<List<FeatureFlag>> featureFlags(int projectId) async => [
    for (final f in _list(await _send('GET', '/api/v1/projects/$projectId/feature-flags')))
      FeatureFlag.fromJson(f),
  ];

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
  }) async =>
      FeatureFlag.fromJson(
        _map(
          await _send(
            'POST',
            '/api/v1/projects/$projectId/feature-flags',
            body: {
              'key': key,
              'name': name,
              'description': description,
              'enabled': enabled,
              'rollout_percentage': rolloutPercentage,
              'filters': filters.map((f) => f.toJson()).toList(),
              'variants': variants.map((v) => v.toJson()).toList(),
            },
          ),
        ),
      );

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
  }) async =>
      FeatureFlag.fromJson(
        _map(
          await _send(
            'PUT',
            '/api/v1/projects/$projectId/feature-flags/$flagId',
            body: {
              'name': name,
              'description': description,
              'enabled': enabled,
              'rollout_percentage': rolloutPercentage,
              'filters': filters.map((f) => f.toJson()).toList(),
              'variants': variants.map((v) => v.toJson()).toList(),
            },
          ),
        ),
      );

  @override
  Future<void> deleteFeatureFlag(int projectId, int flagId) async {
    await _send('DELETE', '/api/v1/projects/$projectId/feature-flags/$flagId');
  }

  @override
  Future<Map<String, dynamic>> testFeatureFlag(
    int projectId,
    int flagId, {
    required String distinctId,
    Map<String, dynamic> properties = const {},
  }) async =>
      _map(
        await _send(
          'POST',
          '/api/v1/projects/$projectId/feature-flags/$flagId/test',
          body: {
            'distinct_id': distinctId,
            'properties': properties,
          },
        ),
      );

  @override
  Future<SessionDetail> session(String id) async =>
      SessionDetail.fromJson(_map(await _send('GET', '/api/v1/sessions/$id')));
  @override
  String frameUrl(String sessionId, int seq) {
    final t = tokenProvider?.call();
    return '$baseUrl/api/v1/sessions/$sessionId/frames/$seq.png${t == null || t.isEmpty ? '' : '?token=$t'}';
  }

  @override
  Future<List<Issue>> issues(
    int projectId, {
    bool includeResolved = false,
    String query = '',
  }) async => [
    for (final i in _list(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/issues',
        query: {
          if (includeResolved) 'resolved': '1',
          if (query.isNotEmpty) 'q': query,
        },
      ),
    ))
      Issue.fromJson(i),
  ];
  @override
  Future<IssueDetail> issue(int id) async =>
      IssueDetail.fromJson(_map(await _send('GET', '/api/v1/issues/$id')));
  @override
  Future<void> resolveIssue(int id, {bool undo = false}) => _send(
    'POST',
    '/api/v1/issues/$id/resolve',
    query: {if (undo) 'undo': '1'},
  );
  @override
  Future<void> assignIssue(int id, int? userId) => _send(
    'POST',
    '/api/v1/issues/$id/assign',
    body: {'user_id': userId},
  );
  @override
  Future<void> setIssueStatus(int id, String status) => _send(
    'POST',
    '/api/v1/issues/$id/status',
    body: {'status': status},
  );
  @override
  Future<void> snoozeIssue(int id, {DateTime? until, int countThreshold = 0}) =>
      _send(
        'POST',
        '/api/v1/issues/$id/snooze',
        body: {
          if (until != null) 'until': until.toUtc().toIso8601String(),
          if (countThreshold > 0) 'count_threshold': countThreshold,
        },
      );
  @override
  Future<void> mergeIssue(int sourceId, int targetId) => _send(
    'POST',
    '/api/v1/issues/$sourceId/merge',
    body: {'target_id': targetId},
  );
  @override
  Future<List<IssueComment>> issueComments(int issueId) async => [
    for (final c in _list(await _send('GET', '/api/v1/issues/$issueId/comments')))
      IssueComment.fromJson(c),
  ];
  @override
  Future<IssueComment> addIssueComment(int issueId, String body) async =>
      IssueComment.fromJson(
        _map(
          await _send(
            'POST',
            '/api/v1/issues/$issueId/comments',
            body: {'body': body},
          ),
        ),
      );
  @override
  Future<List<FingerprintRule>> fingerprintRules(int projectId) async => [
    for (final r in _list(
      await _send('GET', '/api/v1/projects/$projectId/fingerprint-rules'),
    ))
      FingerprintRule.fromJson(r),
  ];
  @override
  Future<FingerprintRule> createFingerprintRule(
    int projectId, {
    String exceptionMatch = '',
    String messageGlob = '',
    String stackContains = '',
    required String action,
    String groupFingerprint = '',
    int priority = 0,
  }) async => FingerprintRule.fromJson(
    _map(
      await _send(
        'POST',
        '/api/v1/projects/$projectId/fingerprint-rules',
        body: {
          if (exceptionMatch.isNotEmpty) 'exception_match': exceptionMatch,
          if (messageGlob.isNotEmpty) 'message_glob': messageGlob,
          if (stackContains.isNotEmpty) 'stack_contains': stackContains,
          'action': action,
          if (groupFingerprint.isNotEmpty)
            'group_fingerprint': groupFingerprint,
          if (priority != 0) 'priority': priority,
        },
      ),
    ),
  );
  @override
  Future<void> deleteFingerprintRule(int projectId, int ruleId) =>
      _send('DELETE', '/api/v1/projects/$projectId/fingerprint-rules/$ruleId');
  @override
  Future<List<EventCount>> eventSummary(int projectId, {int days = 30}) async =>
      [
        for (final e in _list(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/events/summary',
            query: {'days': '$days'},
          ),
        ))
          EventCount.fromJson(e),
      ];

  @override
  Future<List<ReleaseHealth>> releases(int projectId) async => [
    for (final r in _list(await _send('GET', '/api/v1/projects/$projectId/releases')))
      ReleaseHealth.fromJson(r),
  ];

  @override
  Future<ReleaseHealth> releaseHealth(int projectId, String version) async =>
      ReleaseHealth.fromJson(
        _map(
          await _send('GET', '/api/v1/projects/$projectId/releases/$version'),
        ),
      );

  @override
  Future<PerformanceResponse> performance(
    int projectId, {
    int days = 14,
    String op = '',
  }) async =>
      PerformanceResponse.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/performance',
            query: {
              'days': '$days',
              if (op.isNotEmpty) 'op': op,
            },
          ),
        ),
      );

  @override
  Future<TransactionDetailResponse> transactionDetail(
    int projectId, {
    required String name,
    String op = '',
    int days = 14,
  }) async =>
      TransactionDetailResponse.fromJson(
        _map(
          await _send(
            'GET',
            '/api/v1/projects/$projectId/performance/detail',
            query: {
              'name': name,
              'days': '$days',
              if (op.isNotEmpty) 'op': op,
            },
          ),
        ),
      );



  @override
  Future<List<AlertChannel>> alertChannels(int projectId) async => [
    for (final c in _list(
      await _send('GET', '/api/v1/projects/$projectId/alert-channels'),
    ))
      AlertChannel.fromJson(c),
  ];

  @override
  Future<AlertChannel> createAlertChannel(
    int projectId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  }) async => AlertChannel.fromJson(
    _map(
      await _send(
        'POST',
        '/api/v1/projects/$projectId/alert-channels',
        body: {
          'name': name,
          'kind': kind,
          'target': target,
          'secret': secret,
        },
      ),
    ),
  );

  @override
  Future<AlertChannel> updateAlertChannel(
    int projectId,
    int channelId, {
    required String name,
    required String kind,
    required String target,
    String secret = '',
  }) async => AlertChannel.fromJson(
    _map(
      await _send(
        'PATCH',
        '/api/v1/projects/$projectId/alert-channels/$channelId',
        body: {
          'name': name,
          'kind': kind,
          'target': target,
          'secret': secret,
        },
      ),
    ),
  );

  @override
  Future<void> deleteAlertChannel(int projectId, int channelId) =>
      _send('DELETE', '/api/v1/projects/$projectId/alert-channels/$channelId');

  @override
  Future<void> testAlertChannel(int projectId, int channelId) =>
      _send('POST', '/api/v1/projects/$projectId/alert-channels/$channelId/test');

  @override
  Future<List<AlertRule>> alertRules(int projectId) async => [
    for (final r in _list(
      await _send('GET', '/api/v1/projects/$projectId/alerts'),
    ))
      AlertRule.fromJson(r),
  ];

  @override
  Future<AlertRule> createAlertRule(
    int projectId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    bool enabled = true,
  }) async => AlertRule.fromJson(
    _map(
      await _send(
        'POST',
        '/api/v1/projects/$projectId/alerts',
        body: {
          'name': name,
          'kind': kind,
          'params': params,
          'channel_ids': channelIds,
          'enabled': enabled,
        },
      ),
    ),
  );

  @override
  Future<AlertRule> updateAlertRule(
    int projectId,
    int ruleId, {
    required String name,
    required String kind,
    Map<String, dynamic> params = const {},
    required List<int> channelIds,
    required bool enabled,
  }) async => AlertRule.fromJson(
    _map(
      await _send(
        'PATCH',
        '/api/v1/projects/$projectId/alerts/$ruleId',
        body: {
          'name': name,
          'kind': kind,
          'params': params,
          'channel_ids': channelIds,
          'enabled': enabled,
        },
      ),
    ),
  );

  @override
  Future<void> deleteAlertRule(int projectId, int ruleId) =>
      _send('DELETE', '/api/v1/projects/$projectId/alerts/$ruleId');

  @override
  Future<List<Org>> orgs() async =>
      _list(await _send('GET', '/api/v1/orgs')).map(Org.fromJson).toList();

  @override
  Future<Org> createOrg(String name) async =>
      Org.fromJson(_map(await _send('POST', '/api/v1/orgs', body: {'name': name})));

  @override
  Future<Org> org(int id) async =>
      Org.fromJson(_map(await _send('GET', '/api/v1/orgs/$id')));

  @override
  Future<List<OrgMember>> orgMembers(int orgId) async =>
      _list(await _send('GET', '/api/v1/orgs/$orgId/members')).map(OrgMember.fromJson).toList();

  @override
  Future<List<OrgMember>> addOrgMember(
    int orgId,
    String email, {
    String role = 'member',
  }) async =>
      _list(
        await _send(
          'POST',
          '/api/v1/orgs/$orgId/members',
          body: {'email': email, 'role': role},
        ),
      ).map(OrgMember.fromJson).toList();

  @override
  Future<void> updateOrgMemberRole(int orgId, int userId, String role) =>
      _send('PUT', '/api/v1/orgs/$orgId/members/$userId', body: {'role': role});

  @override
  Future<void> removeOrgMember(int orgId, int userId) =>
      _send('DELETE', '/api/v1/orgs/$orgId/members/$userId');

  @override
  Future<List<AuditLogEntry>> auditLogs(
    int orgId, {
    int? projectId,
    int limit = 100,
  }) async =>
      _list(
        await _send(
          'GET',
          '/api/v1/orgs/$orgId/audit',
          query: {
            if (projectId != null) 'projectId': '$projectId',
            'limit': '$limit',
          },
        ),
      ).map(AuditLogEntry.fromJson).toList();

  @override
  Future<List<ApiToken>> apiTokens(int orgId) async =>
      _list(await _send('GET', '/api/v1/orgs/$orgId/tokens')).map(ApiToken.fromJson).toList();

  @override
  Future<ApiToken> createApiToken(
    int orgId, {
    required String name,
    required List<String> scopes,
    DateTime? expiresAt,
  }) async =>
      ApiToken.fromJson(
        _map(
          await _send(
            'POST',
            '/api/v1/orgs/$orgId/tokens',
            body: {
              'name': name,
              'scopes': scopes,
              if (expiresAt != null) 'expires_at': expiresAt.toUtc().toIso8601String(),
            },
          ),
        ),
      );

  @override
  Future<void> deleteApiToken(int orgId, int tokenId) =>
      _send('DELETE', '/api/v1/orgs/$orgId/tokens/$tokenId');
}

/// A single API for the whole app; [tokenStoreProvider] supplies the token.
final apiProvider = Provider<SightpaneApi>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return HttpSightpaneApi(tokenProvider: () => store.token);
});

/// Stores the token in SharedPreferences and keeps it in memory.
class TokenStore {
  static const tokenKey = 'sightpane_token';
  static const userKey = 'sightpane_user';

  /// The keys used before the project was renamed. A stored session is migrated
  /// the first time it is read, so an upgrade does not sign everybody out.
  static const legacyTokenKey = 'hog_token';
  static const legacyUserKey = 'hog_user';
  String? _token;
  String? get token => _token;

  Future<AuthSession?> restore() async {
    final p = await SharedPreferences.getInstance();
    var t = p.getString(tokenKey), u = p.getString(userKey);
    if (t == null || u == null) {
      // Carry a session stored under the old names across, once.
      final lt = p.getString(legacyTokenKey), lu = p.getString(legacyUserKey);
      if (lt != null && lt.isNotEmpty && lu != null) {
        t ??= lt;
        u ??= lu;
        await p.setString(tokenKey, t);
        await p.setString(userKey, u);
        await p.remove(legacyTokenKey);
        await p.remove(legacyUserKey);
      }
    }
    if (t == null || t.isEmpty || u == null) return null;
    _token = t;
    return AuthSession(
      token: t,
      user: SightpaneUser.fromJson(
        (jsonDecode(u) as Map).cast<String, Object?>(),
      ),
    );
  }

  Future<void> save(AuthSession s) async {
    _token = s.token;
    final p = await SharedPreferences.getInstance();
    await p.setString(tokenKey, s.token);
    await p.setString(userKey, jsonEncode(s.user.toJson()));
  }

  Future<void> clear() async {
    _token = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(tokenKey);
    await p.remove(userKey);
    await p.remove(legacyTokenKey);
    await p.remove(legacyUserKey);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
