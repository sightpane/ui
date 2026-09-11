import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'models.dart';

final projectsProvider = FutureProvider.autoDispose<List<Project>>(
  (ref) => ref.watch(apiProvider).projects(),
);
final projectProvider = FutureProvider.autoDispose.family<Project, int>(
  (ref, id) => ref.watch(apiProvider).project(id),
);
final membersProvider = FutureProvider.autoDispose.family<List<Member>, int>(
  (ref, id) => ref.watch(apiProvider).members(id),
);

typedef StatsKey = ({int project, int days});
final statsProvider = FutureProvider.autoDispose.family<ProjectStats, StatsKey>(
  (ref, k) => ref.watch(apiProvider).stats(k.project, days: k.days),
);

typedef SessionsKey = ({int project, bool onlyErrors, String user, String query});
final sessionsProvider = FutureProvider.autoDispose
    .family<List<Session>, SessionsKey>(
      (ref, k) => ref
          .watch(apiProvider)
          .sessions(k.project, onlyErrors: k.onlyErrors, user: k.user, query: k.query),
    );
final sessionDetailProvider = FutureProvider.autoDispose
    .family<SessionDetail, String>(
      (ref, id) => ref.watch(apiProvider).session(id),
    );

typedef UsersKey = ({int project, int days, String query});
final usersProvider = FutureProvider.autoDispose
    .family<ProjectUsersData, UsersKey>(
      (ref, k) => ref.watch(apiProvider).users(k.project, days: k.days, query: k.query),
    );

typedef IssuesKey = ({int project, bool includeResolved, String query});
final issuesProvider = FutureProvider.autoDispose
    .family<List<Issue>, IssuesKey>(
      (ref, k) => ref
          .watch(apiProvider)
          .issues(k.project, includeResolved: k.includeResolved, query: k.query),
    );
final issueDetailProvider = FutureProvider.autoDispose.family<IssueDetail, int>(
  (ref, id) => ref.watch(apiProvider).issue(id),
);
final eventsProvider = FutureProvider.autoDispose.family<List<EventCount>, int>(
  (ref, id) => ref.watch(apiProvider).eventSummary(id),
);

final liveProvider = FutureProvider.autoDispose.family<LiveStatus, int>(
  (ref, id) => ref.watch(apiProvider).live(id),
);

final alertChannelsProvider =
    FutureProvider.autoDispose.family<List<AlertChannel>, int>(
      (ref, id) => ref.watch(apiProvider).alertChannels(id),
    );

final alertRulesProvider =
    FutureProvider.autoDispose.family<List<AlertRule>, int>(
      (ref, id) => ref.watch(apiProvider).alertRules(id),
    );

final issueCommentsProvider =
    FutureProvider.autoDispose.family<List<IssueComment>, int>(
      (ref, id) => ref.watch(apiProvider).issueComments(id),
    );

final fingerprintRulesProvider =
    FutureProvider.autoDispose.family<List<FingerprintRule>, int>(
      (ref, id) => ref.watch(apiProvider).fingerprintRules(id),
    );

final releasesProvider =
    FutureProvider.autoDispose.family<List<ReleaseHealth>, int>(
      (ref, id) => ref.watch(apiProvider).releases(id),
    );

typedef PerformanceFilter = ({int projectId, int days, String op});

final performanceProvider =
    FutureProvider.autoDispose.family<PerformanceResponse, PerformanceFilter>(
  (ref, filter) => ref.watch(apiProvider).performance(
        filter.projectId,
        days: filter.days,
        op: filter.op,
      ),
);

typedef TransactionDetailFilter = ({
  int projectId,
  String name,
  String op,
  int days,
});

final transactionDetailProvider = FutureProvider.autoDispose
    .family<TransactionDetailResponse, TransactionDetailFilter>(
  (ref, filter) => ref.watch(apiProvider).transactionDetail(
        filter.projectId,
        name: filter.name,
        op: filter.op,
        days: filter.days,
      ),
);

final orgsProvider = FutureProvider.autoDispose<List<Org>>(
  (ref) => ref.watch(apiProvider).orgs(),
);

final orgMembersProvider =
    FutureProvider.autoDispose.family<List<OrgMember>, int>(
  (ref, orgId) => ref.watch(apiProvider).orgMembers(orgId),
);

typedef AuditLogKey = ({int orgId, int? projectId});
final auditLogsProvider =
    FutureProvider.autoDispose.family<List<AuditLogEntry>, AuditLogKey>(
  (ref, k) => ref.watch(apiProvider).auditLogs(k.orgId, projectId: k.projectId),
);

final apiTokensProvider =
    FutureProvider.autoDispose.family<List<ApiToken>, int>(
  (ref, orgId) => ref.watch(apiProvider).apiTokens(orgId),
);

final funnelsProvider = FutureProvider.autoDispose.family<List<Funnel>, int>(
  (ref, id) => ref.watch(apiProvider).funnels(id),
);

final funnelProvider =
    FutureProvider.autoDispose.family<Funnel, ({int project, int funnelId})>(
  (ref, k) => ref.watch(apiProvider).funnel(k.project, k.funnelId),
);

typedef FunnelResultKey = ({int project, int funnelId, int days});
final funnelResultsProvider =
    FutureProvider.autoDispose.family<FunnelResult, FunnelResultKey>(
  (ref, k) => ref.watch(apiProvider).funnelResults(k.project, k.funnelId, days: k.days),
);

final cohortsProvider =
    FutureProvider.autoDispose.family<List<Cohort>, int>(
  (ref, id) => ref.watch(apiProvider).cohorts(id),
);

final cohortProvider =
    FutureProvider.autoDispose.family<Cohort, ({int project, int id})>(
  (ref, k) => ref.watch(apiProvider).cohort(k.project, k.id),
);

typedef RetentionKey = ({
  int project,
  int days,
  String period,
  String targetEvent,
  String returnEvent,
  int? cohortId,
});

final retentionProvider =
    FutureProvider.autoDispose.family<RetentionResult, RetentionKey>(
  (ref, k) => ref.watch(apiProvider).retention(
    k.project,
    days: k.days,
    period: k.period,
    targetEvent: k.targetEvent,
    returnEvent: k.returnEvent,
    cohortId: k.cohortId,
  ),
);

typedef PathsKey = ({
  int project,
  String rootEvent,
  String direction,
  int stepLimit,
  int days,
  List<String> exclude,
  double threshold,
});

final pathsProvider =
    FutureProvider.autoDispose.family<PathResult, PathsKey>(
  (ref, k) => ref.watch(apiProvider).paths(
    k.project,
    rootEvent: k.rootEvent,
    direction: k.direction,
    stepLimit: k.stepLimit,
    days: k.days,
    exclude: k.exclude,
    threshold: k.threshold,
  ),
);

final featureFlagsProvider =
    FutureProvider.autoDispose.family<List<FeatureFlag>, int>(
  (ref, projectId) => ref.watch(apiProvider).featureFlags(projectId),
);

final experimentsProvider =
    FutureProvider.autoDispose.family<List<Experiment>, int>(
  (ref, projectId) => ref.watch(apiProvider).experiments(projectId),
);

typedef ExperimentKey = ({int projectId, int expId});

final experimentProvider =
    FutureProvider.autoDispose.family<Experiment, ExperimentKey>(
  (ref, k) => ref.watch(apiProvider).experiment(k.projectId, k.expId),
);

typedef ExperimentResultsKey = ({int projectId, int expId, int days});

final experimentResultsProvider =
    FutureProvider.autoDispose.family<ExperimentResults, ExperimentResultsKey>(
  (ref, k) => ref.watch(apiProvider).experimentResults(k.projectId, k.expId, days: k.days),
);

final surveysProvider =
    FutureProvider.autoDispose.family<List<Survey>, int>(
  (ref, projectId) => ref.watch(apiProvider).surveys(projectId),
);

typedef SurveyKey = ({int projectId, int surveyId});

final surveyProvider =
    FutureProvider.autoDispose.family<Survey, SurveyKey>(
  (ref, k) => ref.watch(apiProvider).survey(k.projectId, k.surveyId),
);

final surveyResultsProvider =
    FutureProvider.autoDispose.family<SurveyResults, SurveyKey>(
  (ref, k) => ref.watch(apiProvider).surveyResults(k.projectId, k.surveyId),
);

final surveyResponsesProvider =
    FutureProvider.autoDispose.family<List<SurveyResponse>, SurveyKey>(
  (ref, k) => ref.watch(apiProvider).surveyResponses(k.projectId, k.surveyId),
);



