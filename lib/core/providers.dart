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

typedef SessionsKey = ({int project, bool onlyErrors, String user});
final sessionsProvider = FutureProvider.autoDispose
    .family<List<Session>, SessionsKey>(
      (ref, k) => ref
          .watch(apiProvider)
          .sessions(k.project, onlyErrors: k.onlyErrors, user: k.user),
    );
final sessionDetailProvider = FutureProvider.autoDispose
    .family<SessionDetail, String>(
      (ref, id) => ref.watch(apiProvider).session(id),
    );

typedef IssuesKey = ({int project, bool includeResolved});
final issuesProvider = FutureProvider.autoDispose
    .family<List<Issue>, IssuesKey>(
      (ref, k) => ref
          .watch(apiProvider)
          .issues(k.project, includeResolved: k.includeResolved),
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
