import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../core/auth.dart';
import '../core/models.dart';
import '../features/auth/auth_pages.dart';
import '../features/cohorts/cohorts_page.dart';
import '../features/events/events_page.dart';
import '../features/experiments/experiment_detail_page.dart';
import '../features/experiments/experiments_page.dart';
import '../features/flags/feature_flags_page.dart';
import '../features/funnels/funnel_detail_page.dart';
import '../features/funnels/funnels_page.dart';
import '../features/issues/issue_detail_page.dart';
import '../features/issues/issues_page.dart';
import '../features/projects/overview_page.dart';
import '../features/projects/projects_page.dart';
import '../features/projects/settings_page.dart';
import '../features/retention/retention_page.dart';
import '../features/paths/paths_page.dart';
import '../features/performance/performance_page.dart';
import '../features/performance/transaction_detail_page.dart';
import '../features/releases/releases_page.dart';
import '../features/sessions/session_detail_page.dart';
import '../features/crons/cron_detail_page.dart';
import '../features/crons/crons_page.dart';
import '../features/uptime/uptime_detail_page.dart';
import '../features/uptime/uptime_page.dart';
import '../features/surveys/survey_detail_page.dart';
import '../features/surveys/surveys_page.dart';
import '../features/sessions/sessions_page.dart';
import '../features/users/user_detail_page.dart';
import '../features/users/users_page.dart';
import '../shell/app_shell.dart';

final _authRefreshProvider = Provider<Listenable>((ref) {
  final n = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => n.value++);
  ref.onDispose(n.dispose);
  return n;
});

/// Routes that need no authentication.
const publicPaths = {'/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_authRefreshProvider);
  return GoRouter(
    initialLocation: '/projects',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value != null;
      final public = publicPaths.contains(state.uri.path);
      if (!loggedIn && !public) {
        return '/login?next=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (loggedIn && public) {
        return state.uri.queryParameters['next'] ?? '/projects';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/', redirect: (_, _) => '/projects'),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/projects', builder: (_, _) => const ProjectsPage()),
          GoRoute(
            path: '/projects/:id',
            builder: (_, s) => OverviewPage(projectId: _id(s)),
            routes: [
              GoRoute(
                path: 'sessions',
                builder: (_, s) => SessionsPage(
                  projectId: _id(s),
                  onlyErrors: s.uri.queryParameters['errors'] == '1',
                  user: s.uri.queryParameters['user'] ?? '',
                  query: s.uri.queryParameters['q'] ?? '',
                ),
              ),
              GoRoute(
                path: 'sessions/:sid',
                builder: (_, s) => SessionDetailPage(
                  projectId: _id(s),
                  sessionId: s.pathParameters['sid']!,
                ),
              ),
              GoRoute(
                path: 'users',
                builder: (_, s) => UsersPage(
                  projectId: _id(s),
                  query: s.uri.queryParameters['q'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, s) => UserDetailPage(
                      projectId: _id(s),
                      userId: s.uri.queryParameters['userId'] ?? '',
                      initialUser: s.extra is UserSummary
                          ? s.extra as UserSummary
                          : null,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'issues',
                builder: (_, s) => IssuesPage(
                  projectId: _id(s),
                  includeResolved: s.uri.queryParameters['resolved'] == '1',
                  query: s.uri.queryParameters['q'] ?? '',
                ),
              ),
              GoRoute(
                path: 'issues/:iid',
                builder: (_, s) => IssueDetailPage(
                  projectId: _id(s),
                  issueId: int.parse(s.pathParameters['iid']!),
                ),
              ),
              GoRoute(
                path: 'performance',
                builder: (_, s) => PerformancePage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: 'transaction',
                    builder: (_, s) => TransactionDetailPage(
                      projectId: _id(s),
                      name: s.uri.queryParameters['name'] ?? '',
                      op: s.uri.queryParameters['op'] ?? '',
                      days: int.tryParse(s.uri.queryParameters['days'] ?? '') ??
                          14,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'releases',
                builder: (_, s) => ReleasesPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'events',
                builder: (_, s) => EventsPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'funnels',
                builder: (_, s) => FunnelsPage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: ':fid',
                    builder: (_, s) => FunnelDetailPage(
                      projectId: _id(s),
                      funnelId: int.parse(s.pathParameters['fid']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'retention',
                builder: (_, s) => RetentionPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'cohorts',
                builder: (_, s) => CohortsPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'paths',
                builder: (_, s) => PathsPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'feature-flags',
                builder: (_, s) => FeatureFlagsPage(projectId: _id(s)),
              ),
              GoRoute(
                path: 'experiments',
                builder: (_, s) => ExperimentsPage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: ':expId',
                    builder: (_, s) => ExperimentDetailPage(
                      projectId: _id(s),
                      expId: int.parse(s.pathParameters['expId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'surveys',
                builder: (_, s) => SurveysPage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: ':surveyId',
                    builder: (_, s) => SurveyDetailPage(
                      projectId: _id(s),
                      surveyId: int.parse(s.pathParameters['surveyId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'crons',
                builder: (_, s) => CronsPage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: ':monitorId',
                    builder: (_, s) => CronDetailPage(
                      projectId: _id(s),
                      monitorId: int.parse(s.pathParameters['monitorId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'uptime',
                builder: (_, s) => UptimePage(projectId: _id(s)),
                routes: [
                  GoRoute(
                    path: ':monitorId',
                    builder: (_, s) => UptimeDetailPage(
                      projectId: _id(s),
                      monitorId: int.parse(s.pathParameters['monitorId']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'settings',
                builder: (_, s) => SettingsPage(projectId: _id(s)),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

int _id(GoRouterState s) => int.tryParse(s.pathParameters['id'] ?? '') ?? 0;
