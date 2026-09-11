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
import 'cron_dialog.dart';

class CronsPage extends ConsumerStatefulWidget {
  const CronsPage({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<CronsPage> createState() => _CronsPageState();
}

class _CronsPageState extends ConsumerState<CronsPage> {
  void _openCreateDialog() {
    showAppDialog(
      context,
      CronDialog(projectId: widget.projectId),
    );
  }

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

    if (confirmed == true) {
      ref.invalidate(cronMonitorsProvider(widget.projectId));
      ref.invalidate(cronStatsProvider(widget.projectId));
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

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final monitorsAsync = ref.watch(cronMonitorsProvider(widget.projectId));
    final statsAsync = ref.watch(cronStatsProvider(widget.projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.cronsTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.cronsDesc,
                      style: const TextStyle(
                        fontSize: 13,
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
                    Text(l.cronsNew),
                  ],
                ),
              ),
            ],
          ),
        ),

        // KPI Stats Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l.cronsTotal,
                    value: stats.totalMonitors.toString(),
                    color: Tokens.textStrong,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l.cronsStatusOk,
                    value: stats.okCount.toString(),
                    color: Tokens.ok,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l.cronsStatusInProgress,
                    value: stats.inProgressCount.toString(),
                    color: Tokens.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l.cronsStatusMissed,
                    value: stats.missedCount.toString(),
                    color: Tokens.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l.cronsStatusError,
                    value: stats.errorCount.toString(),
                    color: Tokens.danger,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Monitors List
        Expanded(
          child: monitorsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Error loading monitors: $err',
                style: const TextStyle(color: Tokens.danger),
              ),
            ),
            data: (monitors) {
              if (monitors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.timer, size: 48, color: Tokens.textFaint),
                      const SizedBox(height: 16),
                      Text(
                        l.cronsEmpty,
                        style: const TextStyle(fontSize: 14, color: Tokens.textMuted),
                      ),
                      const SizedBox(height: 16),
                      OutlineButton(
                        onPressed: _openCreateDialog,
                        child: Text(l.cronsNew),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: monitors.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final m = monitors[idx];
                  return Container(
                    decoration: BoxDecoration(
                      color: Tokens.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Tokens.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    m.name,
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
                                      color: Tokens.surface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Tokens.border),
                                    ),
                                    child: Text(
                                      m.slug,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(context, m.status),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Details Row
                        Row(
                          children: [
                            // Schedule Crontab
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Tokens.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Tokens.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.calendarClock, size: 13, color: Tokens.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    m.schedule,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${m.timezone})',
                                    style: const TextStyle(fontSize: 11, color: Tokens.textFaint),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Last Checkin
                            const Icon(LucideIcons.activity, size: 14, color: Tokens.textMuted),
                            const SizedBox(width: 5),
                            Text(
                              '${l.cronsLastCheckin}: ',
                              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                            ),
                            Text(
                              m.lastCheckinAt != null
                                  ? context.fmt.relative(m.lastCheckinAt)
                                  : l.commonEmpty,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 16),

                            // Next Expected
                            const Icon(LucideIcons.clock, size: 14, color: Tokens.textMuted),
                            const SizedBox(width: 5),
                            Text(
                              '${l.cronsNextExpected}: ',
                              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                            ),
                            Text(
                              m.nextExpectedAt != null
                                  ? context.fmt.dateTime(m.nextExpectedAt)
                                  : l.commonEmpty,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),

                            const Spacer(),

                            // Actions
                            GhostButton(
                              density: ButtonDensity.compact,
                              onPressed: () => _openEditDialog(m),
                              child: const Icon(LucideIcons.pencil, size: 14),
                            ),
                            const SizedBox(width: 4),
                            GhostButton(
                              density: ButtonDensity.compact,
                              onPressed: () => _deleteMonitor(m),
                              child: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                            ),
                            const SizedBox(width: 8),
                            PrimaryButton(
                              density: ButtonDensity.compact,
                              onPressed: () {
                                context.go('/projects/${widget.projectId}/crons/${m.id}');
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Tokens.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
