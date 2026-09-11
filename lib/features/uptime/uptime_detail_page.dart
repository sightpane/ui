// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets.dart';
import 'uptime_dialog.dart';

class UptimeDetailPage extends ConsumerStatefulWidget {
  const UptimeDetailPage({
    super.key,
    required this.projectId,
    required this.monitorId,
  });

  final int projectId;
  final int monitorId;

  @override
  ConsumerState<UptimeDetailPage> createState() => _UptimeDetailPageState();
}

class _UptimeDetailPageState extends ConsumerState<UptimeDetailPage> {
  bool _isChecking = false;

  void _openEditDialog(UptimeMonitor monitor) {
    showAppDialog(
      context,
      UptimeDialog(
        projectId: widget.projectId,
        monitor: monitor,
      ),
    );
  }

  Future<void> _deleteMonitor(UptimeMonitor monitor) async {
    final l = L.of(context);
    final confirmed = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: l.commonDelete,
        message: 'This will delete "${monitor.name}" and its entire check history permanently.',
        confirmLabel: l.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteUptimeMonitor(widget.projectId, monitor.id);
        },
      ),
    );

    if (confirmed == true && mounted) {
      ref.invalidate(uptimeMonitorsProvider(widget.projectId));
      ref.invalidate(uptimeStatsProvider(widget.projectId));
      context.go('/projects/${widget.projectId}/uptime');
    }
  }

  Future<void> _triggerCheck() async {
    setState(() => _isChecking = true);
    try {
      final res = await ref.read(apiProvider).triggerUptimeCheck(widget.projectId, widget.monitorId);
      ref.invalidate(uptimeMonitorsProvider(widget.projectId));
      ref.invalidate(uptimeStatsProvider(widget.projectId));
      ref.invalidate(uptimeMonitorProvider((projectId: widget.projectId, monitorId: widget.monitorId)));

      if (mounted) {
        final isUp = res['is_up'] == true;
        final ms = res['response_time_ms'] ?? 0;
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                  size: 16,
                  color: isUp ? Tokens.ok : Tokens.danger,
                ),
                const SizedBox(width: 8),
                Text(
                  isUp ? 'Operational (${ms}ms)' : 'Endpoint Down',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Text(
              'Check failed: $e',
              style: const TextStyle(fontSize: 13, color: Tokens.danger),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final l = L.of(context);
    final Color color;
    final String label;
    final IconData icon;

    switch (status.toLowerCase()) {
      case 'degraded':
        color = Tokens.warning;
        label = l.uptimeDegraded;
        icon = LucideIcons.triangleAlert;
        break;
      case 'down':
        color = Tokens.danger;
        label = l.uptimeDown;
        icon = LucideIcons.circleAlert;
        break;
      case 'up':
      default:
        color = Tokens.ok;
        label = l.uptimeUp;
        icon = LucideIcons.circleCheck;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final detailAsync = ref.watch(uptimeMonitorProvider((
      projectId: widget.projectId,
      monitorId: widget.monitorId,
    )));

    return detailAsync.when(
      data: (detail) {
        final monitor = detail.monitor;
        final monitorName = monitor?.name ?? 'Monitor #${widget.monitorId}';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Breadcrumb navigation
              AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: 'Project',
                    path: '/projects/${widget.projectId}',
                  ),
                  BreadcrumbItem(
                    label: l.navUptime,
                    path: '/projects/${widget.projectId}/uptime',
                  ),
                  BreadcrumbItem(label: monitorName),
                ],
              ),
              const SizedBox(height: 16),

              // Title and Quick Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Tokens.raised,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Text(
                      monitor?.method.toUpperCase() ?? 'GET',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Tokens.textStrong,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              monitorName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Tokens.textStrong,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusBadge(context, detail.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              monitor?.url ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: Tokens.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GhostButton(
                              density: ButtonDensity.compact,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: monitor?.url ?? ''));
                                showToast(
                                  context: context,
                                  builder: (context, overlay) => SurfaceCard(
                                    child: Text(l.commonCopied),
                                  ),
                                );
                              },
                              child: const Icon(LucideIcons.copy, size: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlineButton(
                    onPressed: _isChecking ? null : _triggerCheck,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isChecking) ...[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 6),
                          Text(l.uptimeChecking),
                        ] else ...[
                          const Icon(LucideIcons.refreshCw, size: 14),
                          const SizedBox(width: 6),
                          Text(l.uptimeCheckNow),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (monitor != null) ...[
                    GhostButton(
                      onPressed: () => _openEditDialog(monitor),
                      child: const Icon(LucideIcons.pencil, size: 15),
                    ),
                    const SizedBox(width: 4),
                    GhostButton(
                      onPressed: () => _deleteMonitor(monitor),
                      child: const Icon(LucideIcons.trash2, size: 15, color: Tokens.danger),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // KPI Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 800;
                  final cards = [
                    // SLA Card
                    _MetricCard(
                      title: l.uptimeSLA,
                      value: '${detail.uptimePercentage.toStringAsFixed(2)}%',
                      subtitle: '90-day SLA reliability',
                      icon: LucideIcons.gauge,
                      color: detail.uptimePercentage >= 99.0 ? Tokens.ok : Tokens.warning,
                    ),
                    // Latency Card
                    _MetricCard(
                      title: l.uptimeResponseTime,
                      value: '${detail.currentResponseTimeMs}ms',
                      subtitle: 'Last check response latency',
                      icon: LucideIcons.zap,
                      color: detail.currentResponseTimeMs > 1000 ? Tokens.warning : Tokens.ok,
                    ),
                    // SSL Certificate Card
                    _MetricCard(
                      title: 'SSL / TLS Certificate',
                      value: detail.ssl != null
                          ? (detail.ssl!.valid ? 'Valid (${detail.ssl!.daysRemaining}d)' : 'Expired')
                          : (monitor?.sslCheckEnabled == true ? 'Checking...' : 'Disabled'),
                      subtitle: detail.ssl?.issuer.isNotEmpty == true
                          ? detail.ssl!.issuer
                          : 'Probed on every check',
                      icon: LucideIcons.shieldCheck,
                      color: detail.ssl == null || !detail.ssl!.valid
                          ? Tokens.danger
                          : (detail.ssl!.daysRemaining <= 14 ? Tokens.warning : Tokens.ok),
                    ),
                    // Interval / Config Card
                    _MetricCard(
                      title: 'Interval & Timeout',
                      value: '${monitor?.intervalSeconds ?? 60}s',
                      subtitle: 'Timeout: ${monitor?.timeoutSeconds ?? 10}s | Expected: ${monitor?.expectedStatusCode ?? 200}',
                      icon: LucideIcons.clock,
                      color: Tokens.textStrong,
                    ),
                  ];

                  if (isNarrow) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: cards
                          .map((c) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: c))
                          .toList(),
                    );
                  }

                  return Row(
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 90-Day Operational Matrix
              Card(
                filled: true,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l.uptimeTimeline90d,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Tokens.textStrong,
                            ),
                          ),
                          Row(
                            children: [
                              _LegendDot(color: Tokens.ok, label: l.uptimeUp),
                              const SizedBox(width: 12),
                              _LegendDot(color: Tokens.warning, label: l.uptimeDegraded),
                              const SizedBox(width: 12),
                              _LegendDot(color: Tokens.danger, label: l.uptimeDown),
                              const SizedBox(width: 12),
                              _LegendDot(color: Tokens.raised, label: 'No Data'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Timeline strip of 90 days
                      SizedBox(
                        height: 36,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final day in detail.history90d)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 1),
                                  child: Tooltip(
                                    tooltip: (_) => TooltipContainer(
                                      child: Text(
                                        '${day.date}\nStatus: ${day.status}\nAvg Latency: ${day.avgMs}ms\nUptime: ${day.uptimePct.toStringAsFixed(1)}%',
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _colorForStatus(day.status),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            detail.history90d.isNotEmpty ? detail.history90d.first.date : '90 days ago',
                            style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                          ),
                          Text(
                            detail.history90d.isNotEmpty ? detail.history90d.last.date : 'Today',
                            style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Checks Table
              Card(
                filled: true,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.history, size: 18, color: Tokens.textStrong),
                          const SizedBox(width: 8),
                          Text(
                            l.uptimeRecentChecks,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Tokens.textStrong,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Tokens.raised,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${detail.recentChecks.length}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (detail.recentChecks.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No checks recorded yet. Click "Check Now" to run a test.',
                              style: TextStyle(color: Tokens.textMuted, fontSize: 13),
                            ),
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 90, child: _TableHeader(l.uptimeStatus)),
                              SizedBox(width: 90, child: _TableHeader(l.uptimeStatusCode)),
                              SizedBox(width: 110, child: _TableHeader(l.uptimeResponseTime)),
                              Expanded(child: _TableHeader(l.uptimeErrorMessage)),
                              SizedBox(width: 120, child: _TableHeader(l.uptimeCheckedAt)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        for (final c in detail.recentChecks) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Row(
                                    children: [
                                      Icon(
                                        c.isUp ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                                        size: 15,
                                        color: c.isUp ? Tokens.ok : Tokens.danger,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        c.isUp ? 'OK' : 'FAIL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: c.isUp ? Tokens.ok : Tokens.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    c.statusCode > 0 ? '${c.statusCode}' : '—',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w500,
                                      color: c.statusCode >= 200 && c.statusCode < 400
                                          ? Tokens.ok
                                          : Tokens.danger,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    '${c.responseTimeMs}ms',
                                    style: const TextStyle(fontSize: 13, color: Tokens.textStrong),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    c.errorMessage.isNotEmpty ? c.errorMessage : '—',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: c.errorMessage.isNotEmpty ? Tokens.danger : Tokens.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    context.fmt.relative(c.checkedAt),
                                    style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Error loading monitor: $err', style: const TextStyle(color: Tokens.danger)),
        ),
      ),
    );
  }

  Color _colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'up':
        return Tokens.ok;
      case 'degraded':
        return Tokens.warning;
      case 'down':
        return Tokens.danger;
      default:
        return Tokens.raised;
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      filled: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Tokens.textMuted)),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Tokens.textMuted,
        ),
      ),
    );
  }
}
