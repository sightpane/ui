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




