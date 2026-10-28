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

/// Project overview: KPIs with their trend, the daily chart beside who is in
/// the app right now, the most frequent issues, platforms / releases / events,
/// and a reliability strip (uptime, crons, metric alerts).
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
    final live = ref.watch(liveProvider(pid)).value;
    final project = ref.watch(projectProvider(pid)).value;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: project?.name ?? context.l10n.navOverview,
            subtitle:
                '${context.l10n.overviewSubtitle(_days)} · ${context.l10n.liveRefreshNote}',
            actions: [
              _LivePill(count: live?.count),
              _RangeSwitch(
                days: _days,
                onChanged: (d) => setState(() => _days = d),
              ),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(statsProvider),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(16),
          stats.when(
            skipLoadingOnReload: true,
            loading: () => PanelMessage(context.l10n.overviewStatsLoading),
            error: (e, _) => PanelMessage(
              context.l10n.overviewStatsFailed(describeError(context.l10n, e)),
              color: Tokens.danger,
            ),
            data: (s) => _body(context, s, live),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ProjectStats s, LiveStatus? live) {
    final pid = widget.projectId;
    final fmt = context.fmt;
    final l10n = context.l10n;
    final daily = s.daily;
    final isNarrow = MediaQuery.sizeOf(context).width < 1200;

    final chart = PanelCard(
      title: l10n.overviewSessionsAndErrors,
      subtitle: l10n.overviewSessionsAndErrorsNote,
      action: const _Legend(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
        child: daily.isEmpty
            ? PanelMessage(l10n.commonNoData)
            : DailyChart(
                values: [for (final d in daily) d.sessions],
                lower: [for (final d in daily) d.errors],
                labels: [for (final d in daily) fmt.day(d.day)],
                tooltip: (i) =>
                    '${fmt.day(daily[i].day)} · ${l10n.kpiSessions} ${fmt.integer(daily[i].sessions)} · ${l10n.overviewErrorSessions} ${fmt.integer(daily[i].errors)}',
              ),
      ),
    );
    final liveCard = _LiveCard(live: live, projectId: pid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                const Icon(
                  LucideIcons.triangleAlert,
                  size: 16,
                  color: Tokens.warning,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    l10n.overviewDropped(fmt.integer(s.dropped)),
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
            label: l10n.kpiSessions,
            value: fmt.integer(s.sessions),
            note: l10n.kpiVisitorsNote(fmt.integer(s.users)),
            trend: [for (final d in daily) d.sessions],
          ),
          KpiTile(
            label: l10n.kpiCrashFree,
            value: fmt.percent(s.crashFree),
            valueColor: s.crashFree >= 0.99
                ? Tokens.ok
                : (s.crashFree >= 0.9 ? Tokens.accentSoft : Tokens.danger),
            trend: [
              for (final d in daily)
                d.sessions == 0 ? 1 : 1 - d.errors / d.sessions,
            ],
            trendColor: Tokens.ok,
          ),
          KpiTile(
            label: l10n.kpiErrors,
            value: fmt.integer(s.errors),
            note: l10n.kpiOpenGroupsNote(fmt.integer(s.openIssues)),
            valueColor: s.errors > 0 ? Tokens.danger : Tokens.textStrong,
            trend: [for (final d in daily) d.errors],
            trendColor: Tokens.danger,
          ),
          KpiTile(
            label: l10n.kpiEvents,
            value: fmt.integer(s.events),
            note: l10n.kpiFramesNote(fmt.integer(s.frames)),
            trend: [for (final d in daily) d.events],
            trendColor: Tokens.info,
          ),
        ]),
        const Gap(12),
        if (isNarrow) ...[
          chart,
          const Gap(12),
          liveCard,
        ] else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: chart),
                const Gap(12),
                Expanded(flex: 3, child: liveCard),
              ],
            ),
          ),
        const Gap(12),
        _TopIssues(issues: s.topIssues, projectId: pid),
        const Gap(12),
        _ResponsiveRow(
          narrow: isNarrow,
          children: [
            PanelCard(
              title: l10n.overviewPlatforms,
              child: _NameCounts(s.platforms, total: s.sessions),
            ),
            PanelCard(
              title: l10n.overviewReleases,
              child: _NameCounts(
                s.releases,
                total: s.sessions,
                color: Tokens.textDim,
              ),
            ),
            PanelCard(
              title: l10n.overviewTopEvents,
              action: GhostButton(
                size: ButtonSize.small,
                onPressed: () => context.go('/projects/$pid/events'),
                child: Text(l10n.commonAll),
              ),
              child: _NameCounts(
                s.topEvents,
                total: s.events,
                color: Tokens.info,
              ),
            ),
          ],
        ),
        const Gap(12),
        _Reliability(projectId: pid, narrow: isNarrow),
      ],
    );
  }
}

/// Equal columns on a wide screen, stacked on a narrow one.
class _ResponsiveRow extends StatelessWidget {
  const _ResponsiveRow({required this.narrow, required this.children});
  final bool narrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Gap(12),
            children[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Gap(12),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class _RangeSwitch extends StatelessWidget {
  const _RangeSwitch({required this.days, required this.onChanged});
  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Tokens.panel,
      border: Border.all(color: Tokens.border),
      borderRadius: BorderRadius.circular(Tokens.radius + 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final d in const [7, 14, 30, 90])
          days == d
              ? SecondaryButton(
                  size: ButtonSize.small,
                  density: ButtonDensity.compact,
                  onPressed: () {},
                  child: Text(context.l10n.overviewDaysShort(d)),
                )
              : GhostButton(
                  size: ButtonSize.small,
                  density: ButtonDensity.compact,
                  onPressed: () => onChanged(d),
                  child: Text(
                    context.l10n.overviewDaysShort(d),
                    style: const TextStyle(color: Tokens.textMuted),
                  ),
                ),
      ],
    ),
  );
}

/// "23 live" — green while anyone is in the app.
class _LivePill extends StatelessWidget {
  const _LivePill({required this.count});
  final int? count;

  @override
  Widget build(BuildContext context) {
    final n = count ?? 0;
    final c = n > 0 ? Tokens.ok : Tokens.textMuted;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        border: Border.all(color: c.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const Gap(8),
          Text(
            context.l10n.overviewLivePill(n),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
        ),
      ],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(Tokens.accent, context.l10n.kpiSessions),
        const Gap(12),
        item(Tokens.danger, context.l10n.overviewErrorSessions),
      ],
    );
  }
}

/// Who is in the app right now (heartbeat in the last 60 s) and on which
/// page; a row opens that session.
class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.live, required this.projectId});
  final LiveStatus? live;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l = live;
    final l10n = context.l10n;
    return PanelCard(
      title: l10n.overviewLiveNow,
      subtitle: l == null ? null : l10n.liveWindow(l.windowSeconds),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Text(
              l == null
                  ? l10n.liveWaiting
                  : l10n.liveSummary(l.count, l.visitors),
              key: const ValueKey('live-summary'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: (l?.count ?? 0) > 0 ? Tokens.ok : Tokens.textMuted,
              ),
            ),
          ),
          if (l == null || l.viewers.isEmpty)
            PanelMessage(l10n.liveNoOpenSessions)
          else ...[
            for (final v in l.viewers.take(6))
              _LiveRow(viewer: v, projectId: projectId),
            if (l.viewers.length > 6)
              PanelMessage(l10n.liveMore(l.viewers.length - 6)),
          ],
          if (l != null && l.routes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Tokens.hairline)),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in l.routes.take(8))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Tokens.raised,
                        borderRadius: BorderRadius.circular(Tokens.radius),
                      ),
                      child: Text(
                        '${r.name.isEmpty ? l10n.liveNoRoute : r.name} · ${l10n.livePeopleCount(r.count)}',
                        style: AppTheme.mono(size: 11, color: Tokens.text),
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

/// One person in the live card: titled by name when the SDK sent one, the
/// email beside it, the route under it — the way the sessions list shows them.
class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.viewer, required this.projectId});
  final LiveViewer viewer;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final v = viewer;
    final l10n = context.l10n;
    final label = v.userName.isNotEmpty ? v.userName : v.userLabel;
    final email = v.userName.isNotEmpty ? v.userEmail : '';
    final client = [v.browser, v.ip].where((p) => p.isNotEmpty).join(' · ');
    return GhostButton(
      density: ButtonDensity.compact,
      alignment: Alignment.centerLeft,
      onPressed: () =>
          context.go('/projects/$projectId/sessions/${v.sessionId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          children: [
            Avatar(
              initials: label.isEmpty ? '—' : initialsOf(label),
              size: 26,
              backgroundColor: Tokens.chip,
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: label.isEmpty ? l10n.commonAnonymous : label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Tokens.text,
                          ),
                        ),
                        if (email.isNotEmpty)
                          TextSpan(
                            text: '  $email',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Tokens.textMuted,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    v.route.isEmpty ? l10n.commonEmpty : v.route,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (client.isNotEmpty)
                  Text(
                    client,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Tokens.textMuted,
                    ),
                  ),
                Text(
                  context.fmt.duration(DateTime.now().difference(v.startedAt)),
                  style: AppTheme.mono(size: 11, color: Tokens.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The most frequent open issues as a table: what, how often, in which
/// release, when last.
class _TopIssues extends StatelessWidget {
  const _TopIssues({required this.issues, required this.projectId});
  final List<Issue> issues;
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = context.fmt;
    const head = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Tokens.textMuted,
    );
    return PanelCard(
      title: l10n.overviewTopIssues,
      subtitle: l10n.issuesGroupingNote,
      action: GhostButton(
        size: ButtonSize.small,
        onPressed: () => context.go('/projects/$projectId/issues'),
        child: Text(l10n.commonAll),
      ),
      child: issues.isEmpty
          ? PanelMessage(l10n.overviewNoOpenIssues)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(fmt.upper(l10n.commonError), style: head),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          fmt.upper(l10n.kpiEvents),
                          textAlign: TextAlign.right,
                          style: head,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          fmt.upper(l10n.issueReleaseLast),
                          textAlign: TextAlign.right,
                          style: head,
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          fmt.upper(l10n.colLastSeen),
                          textAlign: TextAlign.right,
                          style: head,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final i in issues)
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Tokens.hairline)),
                    ),
                    child: GhostButton(
                      density: ButtonDensity.compact,
                      alignment: Alignment.centerLeft,
                      onPressed: () =>
                          context.go('/projects/$projectId/issues/${i.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Tokens.textStrong,
                                    ),
                                  ),
                                  if (i.exception.isNotEmpty &&
                                      i.exception != i.title)
                                    Text(
                                      i.exception,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.mono(
                                        size: 11,
                                        color: Tokens.danger,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                fmt.integer(i.count),
                                textAlign: TextAlign.right,
                                style: AppTheme.mono(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: Tokens.textStrong,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                i.lastRelease.isEmpty
                                    ? l10n.commonEmpty
                                    : i.lastRelease,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.mono(
                                  size: 12,
                                  color: Tokens.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                fmt.relative(i.lastSeen),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Tokens.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          i.name,
                          style: AppTheme.mono(size: 12, color: Tokens.text),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${context.fmt.integer(i.count)} · ${context.fmt.percent(total == 0 ? 0 : (i.count / total * 100).round() / 100)}',
                        style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Tokens.chip,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: i.count / max,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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

/// Uptime checks, cron monitors and metric alerts in one row: one square per
/// monitor or rule, coloured by its state, and a link to the page.
class _Reliability extends ConsumerWidget {
  const _Reliability({required this.projectId, required this.narrow});
  final int projectId;
  final bool narrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final uptime = ref.watch(uptimeMonitorsProvider(projectId)).value;
    final crons = ref.watch(cronMonitorsProvider(projectId)).value;
    final rules = ref.watch(metricAlertRulesProvider(projectId)).value;

    Color uptimeColor(String s) => switch (s) {
      'up' => Tokens.ok,
      'degraded' => Tokens.warning,
      'down' => Tokens.danger,
      _ => Tokens.chip,
    };
    Color cronColor(String s) => switch (s) {
      'ok' => Tokens.ok,
      'in_progress' => Tokens.info,
      'error' || 'missed' => Tokens.danger,
      _ => Tokens.chip,
    };
    Color ruleColor(String s) => switch (s) {
      'firing' => Tokens.danger,
      'warning' => Tokens.warning,
      _ => Tokens.ok,
    };

    final activeRules = rules?.where((r) => r.isActive).toList();
    final firing =
        activeRules?.where((r) => r.currentStatus == 'firing').length ?? 0;
    final failingCrons =
        crons
            ?.where((c) => c.status == 'error' || c.status == 'missed')
            .length ??
        0;
    final up = uptime?.where((m) => m.status == 'up').length ?? 0;
    final avg = uptime == null || uptime.isEmpty
        ? 0.0
        : uptime.map((m) => m.uptimePercentage).reduce((a, b) => a + b) /
              uptime.length;

    return PanelCard(
      title: l10n.navGroupReliability,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _ResponsiveRow(
          narrow: narrow,
          children: [
            _HealthTile(
              title: l10n.navUptime,
              icon: LucideIcons.activity,
              headline: uptime == null || uptime.isEmpty
                  ? l10n.overviewNoneConfigured
                  : l10n.overviewUptimeUp(up, uptime.length),
              ok: uptime == null || up == uptime.length,
              note: uptime == null || uptime.isEmpty
                  ? null
                  : l10n.overviewUptimeAvg(context.fmt.percent(avg / 100)),
              dots: [
                for (final m in uptime ?? const <UptimeMonitor>[])
                  uptimeColor(m.status),
              ],
              onOpen: () => context.go('/projects/$projectId/uptime'),
            ),
            _HealthTile(
              title: l10n.navCrons,
              icon: LucideIcons.timer,
              headline: crons == null || crons.isEmpty
                  ? l10n.overviewNoneConfigured
                  : l10n.overviewCronsOk(
                      crons.where((c) => c.status == 'ok').length,
                      crons.length,
                    ),
              ok: failingCrons == 0,
              note: failingCrons == 0
                  ? null
                  : l10n.overviewCronsFailing(failingCrons),
              dots: [
                for (final c in crons ?? const <CronMonitor>[])
                  cronColor(c.status),
              ],
              onOpen: () => context.go('/projects/$projectId/crons'),
            ),
            _HealthTile(
              title: l10n.navAlerts,
              icon: LucideIcons.bellRing,
              headline: activeRules == null || activeRules.isEmpty
                  ? l10n.overviewNoneConfigured
                  : (firing > 0
                        ? l10n.overviewAlertsFiring(firing)
                        : l10n.overviewAlertsQuiet),
              ok: firing == 0,
              note: activeRules == null || activeRules.isEmpty
                  ? null
                  : l10n.overviewAlertRules(activeRules.length),
              dots: [
                for (final r in activeRules ?? const <MetricAlertRule>[])
                  ruleColor(r.currentStatus),
              ],
              onOpen: () => context.go('/projects/$projectId/alerts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({
    required this.title,
    required this.icon,
    required this.headline,
    required this.ok,
    required this.dots,
    required this.onOpen,
    this.note,
  });
  final String title, headline;
  final String? note;
  final IconData icon;
  final bool ok;
  final List<Color> dots;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => GhostButton(
    onPressed: onOpen,
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Tokens.textMuted),
              const Gap(6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ok ? Tokens.ok : Tokens.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Tokens.textStrong,
            ),
          ),
          if (note != null)
            Text(
              note!,
              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
            ),
          if (dots.isNotEmpty) ...[
            const Gap(8),
            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: [
                for (final c in dots.take(40))
                  Container(
                    width: 10,
                    height: 14,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
