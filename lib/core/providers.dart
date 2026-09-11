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

final cronMonitorsProvider =
    FutureProvider.autoDispose.family<List<CronMonitor>, int>(
  (ref, projectId) => ref.watch(apiProvider).cronMonitors(projectId),
);

final cronStatsProvider =
    FutureProvider.autoDispose.family<CronStats, int>(
  (ref, projectId) => ref.watch(apiProvider).cronStats(projectId),
);

typedef CronMonitorKey = ({int projectId, int monitorId});

final cronMonitorProvider =
    FutureProvider.autoDispose.family<CronMonitor, CronMonitorKey>(
  (ref, k) => ref.watch(apiProvider).cronMonitor(k.projectId, k.monitorId),
);

final cronCheckinsProvider =
    FutureProvider.autoDispose.family<List<CronCheckin>, CronMonitorKey>(
  (ref, k) => ref.watch(apiProvider).cronCheckins(k.projectId, k.monitorId),
);

final uptimeMonitorsProvider =
    FutureProvider.autoDispose.family<List<UptimeMonitor>, int>(
  (ref, projectId) => ref.watch(apiProvider).uptimeMonitors(projectId),
);

final uptimeStatsProvider =
    FutureProvider.autoDispose.family<UptimeStats, int>(
  (ref, projectId) => ref.watch(apiProvider).uptimeStats(projectId),
);

typedef UptimeMonitorKey = ({int projectId, int monitorId});

final uptimeMonitorProvider =
    FutureProvider.autoDispose.family<UptimeHistoryDetail, UptimeMonitorKey>(
  (ref, k) => ref.watch(apiProvider).uptimeMonitor(k.projectId, k.monitorId),
);

final metricAlertRulesProvider =
    FutureProvider.autoDispose.family<List<MetricAlertRule>, int>(
  (ref, projectId) => ref.watch(apiProvider).metricAlertRules(projectId),
);

typedef MetricAlertIncidentsKey = ({int projectId, int? ruleId});

final metricAlertIncidentsProvider =
    FutureProvider.autoDispose.family<List<MetricAlertIncident>, MetricAlertIncidentsKey>(
  (ref, k) => ref.watch(apiProvider).metricAlertIncidents(k.projectId, ruleId: k.ruleId),
);

typedef MetricAlertRuleKey = ({int projectId, int ruleId});

final metricAlertRuleProvider =
    FutureProvider.autoDispose.family<MetricAlertRule, MetricAlertRuleKey>(
  (ref, k) => ref.watch(apiProvider).metricAlertRule(k.projectId, k.ruleId),
);

typedef MetricAlertPreviewKey = ({
  int projectId,
  String metricType,
  String? targetFilter,
  int windowMinutes,
  int days,
});

final metricAlertPreviewProvider =
    FutureProvider.autoDispose.family<List<MetricHistoryPoint>, MetricAlertPreviewKey>(
  (ref, k) => ref.watch(apiProvider).metricAlertPreview(
    k.projectId,
    metricType: k.metricType,
    targetFilter: k.targetFilter,
    windowMinutes: k.windowMinutes,
    days: k.days,
  ),
);

typedef TracesKey = ({
  int projectId,
  int days,
  String? service,
  String? status,
  double? minDurationMs,
  String? query,
  int limit,
});

final tracesProvider =
    FutureProvider.autoDispose.family<List<TraceSummary>, TracesKey>(
  (ref, k) => ref.watch(apiProvider).traces(
    k.projectId,
    days: k.days,
    service: k.service,
    status: k.status,
    minDurationMs: k.minDurationMs,
    query: k.query,
    limit: k.limit,
  ),
);

typedef TraceKey = ({int projectId, String traceId});

final traceProvider =
    FutureProvider.autoDispose.family<TraceDetail, TraceKey>(
  (ref, k) => ref.watch(apiProvider).trace(k.projectId, k.traceId),
);

typedef ProfilesKey = ({
  int projectId,
  int days,
  String? transaction,
  int limit,
});

final profilesProvider =
    FutureProvider.autoDispose.family<List<ProfileSummary>, ProfilesKey>(
  (ref, k) => ref.watch(apiProvider).profiles(
    k.projectId,
    days: k.days,
    transaction: k.transaction,
    limit: k.limit,
  ),
);

typedef ProfileDetailKey = ({int projectId, String profileId});

final profileDetailProvider =
    FutureProvider.autoDispose.family<ProfileDetail, ProfileDetailKey>(
  (ref, k) => ref.watch(apiProvider).profile(k.projectId, k.profileId),
);

typedef SlowFunctionsKey = ({
  int projectId,
  int days,
  String? transaction,
  int limit,
});

final topSlowFunctionsProvider =
    FutureProvider.autoDispose.family<List<SlowFunction>, SlowFunctionsKey>(
  (ref, k) => ref.watch(apiProvider).topSlowFunctions(
    k.projectId,
    days: k.days,
    transaction: k.transaction,
    limit: k.limit,
  ),
);

// ---------------------------------------------------------------------------
// Dashboards & Insights (#18)
// ---------------------------------------------------------------------------

typedef DashboardsKey = ({int projectId});

final dashboardsProvider =
    FutureProvider.autoDispose.family<List<Dashboard>, DashboardsKey>(
  (ref, k) => ref.watch(apiProvider).dashboards(k.projectId),
);

typedef DashboardDetailKey = ({int projectId, String dashboardId});

final dashboardDetailProvider =
    FutureProvider.autoDispose.family<Dashboard, DashboardDetailKey>(
  (ref, k) => ref.watch(apiProvider).dashboard(k.projectId, k.dashboardId),
);

typedef InsightsKey = ({int projectId, String? dashboardId});

final insightsProvider =
    FutureProvider.autoDispose.family<List<Insight>, InsightsKey>(
  (ref, k) => ref.watch(apiProvider).insights(k.projectId, dashboardId: k.dashboardId),
);

typedef InsightDetailKey = ({int projectId, String insightId});

final insightDetailProvider =
    FutureProvider.autoDispose.family<Insight, InsightDetailKey>(
  (ref, k) => ref.watch(apiProvider).insight(k.projectId, k.insightId),
);

typedef InsightResultsKey = ({int projectId, String insightId});

final insightResultsProvider =
    FutureProvider.autoDispose.family<InsightQueryResult, InsightResultsKey>(
  (ref, k) => ref.watch(apiProvider).insightResults(k.projectId, k.insightId),
);

