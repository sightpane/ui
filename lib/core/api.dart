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
  });
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
    int limit = 100,
  });
  Future<SessionDetail> session(String id);
  String frameUrl(String sessionId, int seq);
  Future<List<Issue>> issues(int projectId, {bool includeResolved = false});
  Future<IssueDetail> issue(int id);
  Future<void> resolveIssue(int id, {bool undo = false});
  Future<List<EventCount>> eventSummary(int projectId, {int days = 30});
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
  }) async => Project.fromJson(
    _map(
      await _send(
        'PATCH',
        '/api/v1/projects/$id',
        body: {'name': name, 'platform': platform},
      ),
    ),
  );
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
        },
      ),
    ))
      Session.fromJson(s),
  ];
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
  }) async => [
    for (final i in _list(
      await _send(
        'GET',
        '/api/v1/projects/$projectId/issues',
        query: {if (includeResolved) 'resolved': '1'},
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
