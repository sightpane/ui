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
import 'cron_dialog.dart';

class CronDetailPage extends ConsumerStatefulWidget {
  const CronDetailPage({
    super.key,
    required this.projectId,
    required this.monitorId,
  });

  final int projectId;
  final int monitorId;

  @override
  ConsumerState<CronDetailPage> createState() => _CronDetailPageState();
}

class _CronDetailPageState extends ConsumerState<CronDetailPage> {
  int _selectedSnippetIndex = 0;

  void _openEditDialog(CronMonitor monitor) {
    showAppDialog(
      context,
      CronDialog(
        projectId: widget.projectId,
        monitor: monitor,
      ),
    );
  }

  Future<void> _deleteMonitor(CronMonitor monitor) async {
    final l = L.of(context);
    final confirmed = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: l.commonDelete,
        message: 'This will delete "${monitor.name}" and its entire check-in history permanently.',
        confirmLabel: l.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteCronMonitor(widget.projectId, monitor.id);
        },
      ),
    );

    if (confirmed == true && mounted) {
      ref.invalidate(cronMonitorsProvider(widget.projectId));
      ref.invalidate(cronStatsProvider(widget.projectId));
      context.go('/projects/${widget.projectId}/crons');
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final l = L.of(context);
    final Color color;
    final String label;
    final IconData icon;

    switch (status.toLowerCase()) {
      case 'in_progress':
        color = Tokens.info;
        label = l.cronsStatusInProgress;
        icon = LucideIcons.loader;
        break;
      case 'missed':
        color = Tokens.warning;
        label = l.cronsStatusMissed;
        icon = LucideIcons.clockAlert;
        break;
      case 'error':
        color = Tokens.danger;
        label = l.cronsStatusError;
        icon = LucideIcons.circleAlert;
        break;
      case 'ok':
      default:
        color = Tokens.ok;
        label = l.cronsStatusOk;
        icon = LucideIcons.circleCheck;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getSnippet(String slug, String host) {
    switch (_selectedSnippetIndex) {
      case 1: // Python
        return '''import requests, time

# Send start heartbeat
requests.post("$host/api/v1/crons/$slug/checkin", json={"status": "in_progress"})
start_time = time.time()

try:
    # Execute scheduled job here...
    duration_ms = int((time.time() - start_time) * 1000)
    requests.post("$host/api/v1/crons/$slug/checkin", json={
        "status": "ok",
        "duration_ms": duration_ms,
        "message": "Job completed successfully"
    })
except Exception as exc:
    requests.post("$host/api/v1/crons/$slug/checkin", json={
        "status": "error",
        "message": str(exc)
    })
    raise''';

      case 2: // Flutter / Dart SDK
        return '''import 'package:sightpane/sightpane.dart';

// Check in with status
await Sightpane.checkin(
  '$slug',
  status: CronStatus.ok,
  duration: Duration(milliseconds: 450),
  message: 'Daily backup complete',
);''';

      case 3: // Node.js
        return '''// In-progress signal
await fetch("$host/api/v1/crons/$slug/checkin", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ status: "in_progress" })
});

try {
  // Execute your task
  await fetch("$host/api/v1/crons/$slug/checkin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "ok", duration_ms: 1200 })
  });
} catch (err) {
  await fetch("$host/api/v1/crons/$slug/checkin", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "error", message: err.message })
  });
}''';

      case 0: // cURL / Bash
      default:
        return '''# Quick ping (crontab command example):
curl -fsS -m 10 --retry 5 "$host/api/v1/crons/$slug/checkin?status=ok"

# Complete job wrapper in bash:
curl -fsS -m 10 "$host/api/v1/crons/$slug/checkin?status=in_progress"
/usr/local/bin/backup_db.sh && \\
  curl -fsS -m 10 "$host/api/v1/crons/$slug/checkin?status=ok" || \\
  curl -fsS -m 10 "$host/api/v1/crons/$slug/checkin?status=error"''';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final monitorAsync = ref.watch(
      cronMonitorProvider((projectId: widget.projectId, monitorId: widget.monitorId)),
    );
    final checkinsAsync = ref.watch(
      cronCheckinsProvider((projectId: widget.projectId, monitorId: widget.monitorId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Breadcrumb
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: AppBreadcrumb(
            items: [
              BreadcrumbItem(
                label: l.navCrons,
                path: '/projects/${widget.projectId}/crons',
              ),
              BreadcrumbItem(
                label: monitorAsync.value?.name ?? 'Monitor #${widget.monitorId}',
              ),
            ],
          ),
        ),

        Expanded(
          child: monitorAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Error loading monitor: $err',
                style: const TextStyle(color: Tokens.danger),
              ),
            ),
            data: (monitor) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Tokens.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    monitor.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Tokens.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Tokens.border),
                                    ),
                                    child: Text(
                                      monitor.slug,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatusBadge(context, monitor.status),
                                ],
                              ),
                            ),
                            GhostButton(
                              density: ButtonDensity.compact,
                              onPressed: () => _openEditDialog(monitor),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.pencil, size: 14),
                                  SizedBox(width: 6),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GhostButton(
                              density: ButtonDensity.compact,
                              onPressed: () => _deleteMonitor(monitor),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                                  SizedBox(width: 6),
                                  Text('Delete', style: TextStyle(color: Tokens.danger)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Info Grid
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                label: l.cronsSchedule,
                                value: monitor.schedule,
                                icon: LucideIcons.calendarClock,
                                isMonospace: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoTile(
                                label: l.cronsTimezone,
                                value: monitor.timezone,
                                icon: LucideIcons.globe,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoTile(
                                label: l.cronsGracePeriod,
                                value: '${monitor.gracePeriodMinutes} min',
                                icon: LucideIcons.hourglass,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoTile(
                                label: l.cronsMaxRuntime,
                                value: '${monitor.maxRuntimeMinutes} min',
                                icon: LucideIcons.timer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoTile(
                                label: l.cronsNextExpected,
                                value: monitor.nextExpectedAt != null
                                    ? context.fmt.dateTime(monitor.nextExpectedAt)
                                    : l.commonEmpty,
                                icon: LucideIcons.clock,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 24h Status Bar Matrix
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Tokens.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.cronsTimeline24h,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        checkinsAsync.when(
                          loading: () => const SizedBox(
                            height: 36,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (checkins) {
                            return _TimelineMatrix(
                              checkins: checkins,
                              currentStatus: monitor.status,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Integration Code Snippets
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Tokens.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.cronsIntegrationSnippets,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                            OutlineButton(
                              density: ButtonDensity.compact,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _getSnippet(monitor.slug, 'https://sightpane.com')),
                                );
                                showToast(
                                  context: context,
                                  builder: (ctx, overlay) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Tokens.panel,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Tokens.border),
                                    ),
                                    child: Text(l.commonCopied),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.copy, size: 13),
                                  SizedBox(width: 5),
                                  Text('Copy Snippet'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SnippetTab(
                              label: 'cURL / Bash',
                              selected: _selectedSnippetIndex == 0,
                              onTap: () => setState(() => _selectedSnippetIndex = 0),
                            ),
                            const SizedBox(width: 8),
                            _SnippetTab(
                              label: 'Python',
                              selected: _selectedSnippetIndex == 1,
                              onTap: () => setState(() => _selectedSnippetIndex = 1),
                            ),
                            const SizedBox(width: 8),
                            _SnippetTab(
                              label: 'Flutter SDK',
                              selected: _selectedSnippetIndex == 2,
                              onTap: () => setState(() => _selectedSnippetIndex = 2),
                            ),
                            const SizedBox(width: 8),
                            _SnippetTab(
                              label: 'Node.js',
                              selected: _selectedSnippetIndex == 3,
                              onTap: () => setState(() => _selectedSnippetIndex = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Tokens.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Tokens.border),
                          ),
                          child: SelectableText(
                            _getSnippet(monitor.slug, 'https://sightpane.com'),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Check-in History Table
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Tokens.panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.cronsHistory,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        checkinsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text(
                            'Error loading history: $err',
                            style: const TextStyle(color: Tokens.danger),
                          ),
                          data: (checkins) {
                            if (checkins.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    l.commonNoRecords,
                                    style: const TextStyle(color: Tokens.textMuted),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: checkins.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (ctx, idx) {
                                final c = checkins[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      _buildStatusBadge(context, c.status),
                                      const SizedBox(width: 14),
                                      Text(
                                        context.fmt.dateTime(c.createdAt),
                                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      ),
                                      const SizedBox(width: 14),
                                      if (c.durationMs != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Tokens.surface,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Tokens.border),
                                          ),
                                          child: Text(
                                            c.durationMs! >= 1000
                                                ? '${(c.durationMs! / 1000).toStringAsFixed(2)}s'
                                                : '${c.durationMs}ms',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                              color: Tokens.textMuted,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                      ],
                                      Expanded(
                                        child: Text(
                                          c.message.isNotEmpty ? c.message : '—',
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Tokens.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Tokens.textMuted),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: Tokens.textStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnippetTab extends StatelessWidget {
  const _SnippetTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Tokens.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? Tokens.border : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Tokens.textStrong : Tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

class _TimelineMatrix extends StatelessWidget {
  const _TimelineMatrix({
    required this.checkins,
    required this.currentStatus,
  });

  final List<CronCheckin> checkins;
  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    // Generate 24 slots (representing the last 24 hours)
    final now = DateTime.now();
    final bars = <Widget>[];

    for (int i = 23; i >= 0; i--) {
      final slotStart = now.subtract(Duration(hours: i + 1));
      final slotEnd = now.subtract(Duration(hours: i));

      // Find checkins in this 1-hour slot
      final slotCheckins = checkins.where(
        (c) => c.createdAt.isAfter(slotStart) && c.createdAt.isBefore(slotEnd),
      ).toList();

      Color barColor = Tokens.surface;
      String tooltipText = '${i}h ago: No check-in';

      if (slotCheckins.isNotEmpty) {
        final hasError = slotCheckins.any((c) => c.status == 'error');
        final hasMissed = slotCheckins.any((c) => c.status == 'missed');
        final hasInProgress = slotCheckins.any((c) => c.status == 'in_progress');

        if (hasError) {
          barColor = Tokens.danger;
          tooltipText = '${i}h ago: Failed';
        } else if (hasMissed) {
          barColor = Tokens.warning;
          tooltipText = '${i}h ago: Missed';
        } else if (hasInProgress) {
          barColor = Tokens.info;
          tooltipText = '${i}h ago: In Progress';
        } else {
          barColor = Tokens.ok;
          tooltipText = '${i}h ago: Healthy (${slotCheckins.length} runs)';
        }
      }

      bars.add(
        Expanded(
          child: Tooltip(
            tooltip: (_) => TooltipContainer(child: Text(tooltipText)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: 28,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: bars),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('24h ago', style: TextStyle(fontSize: 11, color: Tokens.textFaint)),
            Text('12h ago', style: TextStyle(fontSize: 11, color: Tokens.textFaint)),
            Text('Now', style: TextStyle(fontSize: 11, color: Tokens.textFaint)),
          ],
        ),
      ],
    );
  }
}
