// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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

class UptimePage extends ConsumerStatefulWidget {
  const UptimePage({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<UptimePage> createState() => _UptimePageState();
}

class _UptimePageState extends ConsumerState<UptimePage> {
  final Set<int> _checkingMonitorIds = {};

  void _openCreateDialog() {
    showAppDialog(
      context,
      UptimeDialog(projectId: widget.projectId),
    );
  }

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
        message: 'This will delete "${monitor.name}" and its check history permanently.',
        confirmLabel: l.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteUptimeMonitor(widget.projectId, monitor.id);
        },
      ),
    );

    if (confirmed == true) {
      ref.invalidate(uptimeMonitorsProvider(widget.projectId));
      ref.invalidate(uptimeStatsProvider(widget.projectId));
    }
  }

  Future<void> _checkNow(UptimeMonitor monitor) async {
    setState(() => _checkingMonitorIds.add(monitor.id));
    try {
      final res = await ref.read(apiProvider).triggerUptimeCheck(widget.projectId, monitor.id);
      ref.invalidate(uptimeMonitorsProvider(widget.projectId));
      ref.invalidate(uptimeStatsProvider(widget.projectId));
      ref.invalidate(uptimeMonitorProvider((projectId: widget.projectId, monitorId: monitor.id)));

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
        setState(() => _checkingMonitorIds.remove(monitor.id));
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Tokens.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Tokens.border),
      ),
      child: Text(
        method.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: Tokens.textStrong,
        ),
      ),
    );
  }

  Widget _buildSSLBadge(BuildContext context, UptimeMonitor monitor) {
    if (!monitor.sslCheckEnabled) {
      return const SizedBox.shrink();
    }
    final l = L.of(context);
    final expires = monitor.sslExpiresAt;
    if (expires == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Tokens.raised,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.shieldAlert, size: 11, color: Tokens.textMuted),
            SizedBox(width: 4),
            Text(
              'SSL: Pending check',
              style: TextStyle(fontSize: 11, color: Tokens.textMuted),
            ),
          ],
        ),
      );
    }

    final daysLeft = expires.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;
    final isExpiringSoon = daysLeft <= 14;

    final Color color;
    final String text;
    if (isExpired) {
      color = Tokens.danger;
      text = l.uptimeSSLExpired;
    } else if (isExpiringSoon) {
      color = Tokens.warning;
      text = l.uptimeSSLDaysLeft(daysLeft);
    } else {
      color = Tokens.ok;
      text = 'SSL ${l.uptimeSSLValid} (${daysLeft}d)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.shieldCheck, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
    final monitorsAsync = ref.watch(uptimeMonitorsProvider(widget.projectId));
    final statsAsync = ref.watch(uptimeStatsProvider(widget.projectId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.uptimeTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Tokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.uptimeDesc,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                onPressed: _openCreateDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 16),
                    const SizedBox(width: 6),
                    Text(l.uptimeNew),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          statsAsync.when(
            data: (stats) => LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final tiles = [
                  _StatTile(
                    label: l.uptimeTotal,
                    value: stats.totalMonitors.toString(),
                    icon: LucideIcons.activity,
                    color: Tokens.textStrong,
                  ),
                  _StatTile(
                    label: l.uptimeUp,
                    value: stats.upCount.toString(),
                    icon: LucideIcons.circleCheck,
                    color: Tokens.ok,
                  ),
                  _StatTile(
                    label: l.uptimeDegraded,
                    value: stats.degradedCount.toString(),
                    icon: LucideIcons.triangleAlert,
                    color: Tokens.warning,
                  ),
                  _StatTile(
                    label: l.uptimeDown,
                    value: stats.downCount.toString(),
                    icon: LucideIcons.circleAlert,
                    color: Tokens.danger,
                  ),
                  _StatTile(
                    label: l.uptimeSLA,
                    value: '${stats.avgUptimePct.toStringAsFixed(2)}%',
                    icon: LucideIcons.gauge,
                    color: stats.avgUptimePct >= 99.0 ? Tokens.ok : Tokens.warning,
                  ),
                ];

                if (isNarrow) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: tiles
                        .map((t) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: t))
                        .toList(),
                  );
                }

                return Row(
                  children: [
                    for (int i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: tiles[i]),
                    ],
                  ],
                );
              },
            ),
            loading: () => const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Monitors List
          monitorsAsync.when(
            data: (monitors) {
              if (monitors.isEmpty) {
                return Card(
                  filled: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Tokens.raised,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.activity,
                            size: 28,
                            color: Tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.uptimeEmpty,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Tokens.textStrong,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Text(
                            l.uptimeEmptyDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Tokens.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          onPressed: _openCreateDialog,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.plus, size: 16),
                              const SizedBox(width: 6),
                              Text(l.uptimeNew),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monitors.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final monitor = monitors[index];
                  final isChecking = _checkingMonitorIds.contains(monitor.id);

                  return Card(
                    filled: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.go('/projects/${widget.projectId}/uptime/${monitor.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                _buildMethodBadge(monitor.method),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        monitor.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Tokens.textStrong,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        monitor.url,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Tokens.textMuted,
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildSSLBadge(context, monitor),
                                const SizedBox(width: 12),
                                _buildStatusBadge(context, monitor.status),
                                const SizedBox(width: 8),
                                OutlineButton(
                                  density: ButtonDensity.compact,
                                  onPressed: isChecking ? null : () => _checkNow(monitor),
                                  child: isChecking
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(LucideIcons.refreshCw, size: 14),
                                ),
                                const SizedBox(width: 4),
                                GhostButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () => _openEditDialog(monitor),
                                  child: const Icon(LucideIcons.pencil, size: 14),
                                ),
                                const SizedBox(width: 4),
                                GhostButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () => _deleteMonitor(monitor),
                                  child: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                                ),
                                const SizedBox(width: 8),
                                PrimaryButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () {
                                    context.go('/projects/${widget.projectId}/uptime/${monitor.id}');
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Details'),
                                      SizedBox(width: 4),
                                      Icon(LucideIcons.chevronRight, size: 14),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.gauge, size: 13, color: Tokens.textMuted),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${l.uptimeSLA}: ',
                                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                    ),
                                    Text(
                                      '${monitor.uptimePercentage.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: monitor.uptimePercentage >= 99.0 ? Tokens.ok : Tokens.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.clock, size: 13, color: Tokens.textMuted),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${l.uptimeInterval}: ${monitor.intervalSeconds}s',
                                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.history, size: 13, color: Tokens.textMuted),
                                    const SizedBox(width: 5),
                                      Text(
                                        '${l.uptimeLastChecked}: ${monitor.lastCheckedAt != null ? context.fmt.relative(monitor.lastCheckedAt) : l.commonEmpty}',
                                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Card(
              filled: true,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading monitors: $err', style: const TextStyle(color: Tokens.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      filled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Tokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
