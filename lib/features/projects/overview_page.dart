import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// Project overview: KPIs, the daily chart, the most frequent issues,
/// platforms.
class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key, required this.projectId});
  final int projectId;
  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  int _days = 14;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The main screen refreshes once a second: live viewers + statistics.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.invalidate(liveProvider(widget.projectId));
      ref.invalidate(statsProvider((project: widget.projectId, days: _days)));
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pid = widget.projectId;
    final stats = ref.watch(statsProvider((project: pid, days: _days)));
    final live = ref.watch(liveProvider(pid));
    final project = ref.watch(projectProvider(pid)).value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: project?.name ?? context.l10n.navOverview,
            subtitle: context.l10n.overviewSubtitle(_days),
            actions: [
              for (final d in const [7, 14, 30, 90])
                _days == d
                    ? SecondaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.overviewDaysShort(d)),
                      )
                    : GhostButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _days = d),
                        child: Text(context.l10n.overviewDaysShort(d)),
                      ),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(statsProvider),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),
          stats.when(
            skipLoadingOnReload: true,
            loading: () => PanelMessage(context.l10n.overviewStatsLoading),
            error: (e, _) => PanelMessage(
              context.l10n.overviewStatsFailed(describeError(context.l10n, e)),
              color: Tokens.danger,
            ),
            data: (s) => _body(context, s, live.value),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ProjectStats s, LiveStatus? live) {
    final pid = widget.projectId;
    final labels = [for (final d in s.daily) context.fmt.day(d.day)];
    final isNarrow = MediaQuery.sizeOf(context).width < Tokens.mobileBreakpoint;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelCard(
          title: context.l10n.overviewSessionsAndErrors,
          subtitle: context.l10n.overviewSessionsAndErrorsNote,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: BarChart(
              values: [for (final d in s.daily) d.sessions],
              secondary: [for (final d in s.daily) d.errors],
              labels: labels,
            ),
          ),
        ),
        const Gap(12),
        PanelCard(
          title: context.l10n.overviewEvents,
          subtitle: context.l10n.overviewByDay,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: BarChart(
              values: [for (final d in s.daily) d.events],
              labels: labels,
              color: Tokens.info,
              height: 80,
            ),
          ),
        ),
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelCard(
          title: context.l10n.overviewTopIssues,
          action: GhostButton(
            size: ButtonSize.small,
            onPressed: () => context.go('/projects/$pid/issues'),
            child: Text(context.l10n.commonAll),
          ),
          child: s.topIssues.isEmpty
              ? PanelMessage(context.l10n.overviewNoOpenIssues)
              : Column(
                  children: [
                    for (final i in s.topIssues)
                      GhostButton(
                        density: ButtonDensity.compact,
                        alignment: Alignment.centerLeft,
                        onPressed: () =>
                            context.go('/projects/$pid/issues/${i.id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  i.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Tokens.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                context.fmt.integer(i.count),
                                style: AppTheme.mono(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: Tokens.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const Gap(12),
        PanelCard(
          title: context.l10n.overviewPlatforms,
          child: _NameCounts(s.platforms, total: s.sessions),
        ),
        const Gap(12),
        PanelCard(
          title: context.l10n.overviewReleases,
          child: _NameCounts(s.releases, total: s.sessions),
        ),
        const Gap(12),
        PanelCard(
          title: context.l10n.overviewTopEvents,
          action: GhostButton(
            size: ButtonSize.small,
            onPressed: () => context.go('/projects/$pid/events'),
            child: Text(context.l10n.commonAll),
          ),
          child: _NameCounts(s.topEvents, total: s.events, color: Tokens.info),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LivePanel(live: live, projectId: pid),
        const Gap(14),
        if (s.dropped > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Tokens.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Tokens.radius),
              border: Border.all(color: Tokens.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.triangleAlert, size: 16, color: Tokens.warning),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Ingest quota exceeded: ${context.fmt.integer(s.dropped)} items dropped due to rate limit.',
                    style: const TextStyle(fontSize: 13, color: Tokens.warning),
                  ),
                ),
              ],
            ),
          ),
          const Gap(14),
        ],
        KpiRow([
          KpiTile(
            label: context.l10n.kpiSessions,
            value: context.fmt.integer(s.sessions),
            note: context.l10n.kpiVisitorsNote(context.fmt.integer(s.users)),
          ),
          KpiTile(
            label: context.l10n.kpiErrors,
            value: context.fmt.integer(s.errors),
            note: context.l10n.kpiOpenGroupsNote(
              context.fmt.integer(s.openIssues),
            ),
            valueColor: s.errors > 0 ? Tokens.danger : Tokens.textStrong,
          ),
          KpiTile(
            label: context.l10n.kpiCrashFree,
            value: context.fmt.percent(s.crashFree),
            valueColor: s.crashFree >= 0.99
                ? Tokens.ok
                : (s.crashFree >= 0.9 ? Tokens.accentSoft : Tokens.danger),
          ),
          KpiTile(
            label: context.l10n.kpiEvents,
            value: context.fmt.integer(s.events),
            note: context.l10n.kpiFramesNote(context.fmt.integer(s.frames)),
          ),
        ]),
        const Gap(14),
        if (isNarrow) ...[
          left,
          const Gap(12),
          right,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const Gap(12),
              Expanded(flex: 2, child: right),
            ],
          ),
      ],
    );
  }
}

class _NameCounts extends StatelessWidget {
  const _NameCounts(
    this.items, {
    required this.total,
    this.color = Tokens.accent,
  });
  final List<NameCount> items;
  final int total;
  final Color color;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return PanelMessage(context.l10n.commonNoData);
    final max = items.fold<int>(1, (m, i) => i.count > m ? i.count : m);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Column(
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      i.name,
                      style: const TextStyle(fontSize: 12, color: Tokens.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: i.count / max,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${context.fmt.integer(i.count)} · ${total == 0 ? 0 : (100 * i.count / total).round()}%',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Who is on which page right now: open sessions whose heartbeat arrived in
/// the last 60 s.
class LivePanel extends StatelessWidget {
  const LivePanel({super.key, required this.live, required this.projectId});
  final LiveStatus? live;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l = live;
    final isNarrow = MediaQuery.sizeOf(context).width < Tokens.mobileBreakpoint;
    final routes = PanelCard(
      title: context.l10n.livePages,
      subtitle: l == null ? null : context.l10n.liveRouteCount(l.routes.length),
      child: l == null || l.routes.isEmpty
          ? PanelMessage(context.l10n.liveNoPages)
          : Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Column(
                children: [
                  for (final r in l.routes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.name.isEmpty
                                  ? context.l10n.liveNoRoute
                                  : r.name,
                              style: AppTheme.mono(
                                size: 12,
                                color: Tokens.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            context.l10n.livePeopleCount(r.count),
                            style: AppTheme.mono(
                              size: 12,
                              weight: FontWeight.w600,
                              color: Tokens.accentSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
    final viewers = PanelCard(
      title: context.l10n.liveViewers,
      subtitle: l == null ? null : context.l10n.liveWindow(l.windowSeconds),
      child: l == null || l.viewers.isEmpty
          ? PanelMessage(context.l10n.liveNoOpenSessions)
          : Column(
              children: [
                for (final v in l.viewers.take(20))
                  GhostButton(
                    density: ButtonDensity.compact,
                    alignment: Alignment.centerLeft,
                    onPressed: () => context.go(
                      '/projects/$projectId/sessions/${v.sessionId}',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Tokens.ok,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              v.userLabel.isEmpty
                                  ? context.l10n.commonAnonymous
                                  : v.userLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Tokens.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${v.browser} · ${v.ip}',
                              style: AppTheme.mono(
                                size: 11,
                                color: Tokens.textDim,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              v.route.isEmpty
                                  ? context.l10n.commonEmpty
                                  : v.route,
                              style: AppTheme.mono(
                                size: 11,
                                color: Tokens.info,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            context.fmt.duration(
                              DateTime.now().difference(v.startedAt),
                            ),
                            style: AppTheme.mono(
                              size: 11,
                              color: Tokens.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (l.viewers.length > 20)
                  PanelMessage(context.l10n.liveMore(l.viewers.length - 20)),
              ],
            ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: (l?.count ?? 0) > 0 ? Tokens.ok : Tokens.textFaint,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(8),
            Text(
              l == null
                  ? context.l10n.liveWaiting
                  : context.l10n.liveSummary(l.count, l.visitors),
              key: const ValueKey('live-summary'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Tokens.textStrong,
              ),
            ),
            const Gap(8),
            Text(
              context.l10n.liveRefreshNote,
              style: const TextStyle(fontSize: 11, color: Tokens.textDim),
            ),
          ],
        ),
        const Gap(8),
        if (isNarrow) ...[
          viewers,
          const Gap(12),
          routes,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: viewers),
              const Gap(12),
              Expanded(flex: 2, child: routes),
            ],
          ),
      ],
    );
  }
}
