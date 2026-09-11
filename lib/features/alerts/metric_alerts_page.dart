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

class MetricAlertsPage extends ConsumerStatefulWidget {
  const MetricAlertsPage({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<MetricAlertsPage> createState() => _MetricAlertsPageState();
}

class _MetricAlertsPageState extends ConsumerState<MetricAlertsPage> {
  int _selectedTab = 0; // 0 = Rules, 1 = Incidents

  Future<void> _toggleActive(MetricAlertRule rule) async {
    try {
      await ref.read(apiProvider).updateMetricAlertRule(
        widget.projectId,
        rule.id,
        isActive: !rule.isActive,
      );
      ref.invalidate(metricAlertRulesProvider(widget.projectId));
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Text('Toggle failed: $e', style: const TextStyle(color: Tokens.danger)),
          ),
        );
      }
    }
  }

  Future<void> _deleteRule(MetricAlertRule rule) async {
    final l = L.of(context);
    final confirmed = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: l.commonDelete,
        message: l.alertsDeleteConfirm,
        confirmLabel: l.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteMetricAlertRule(widget.projectId, rule.id);
        },
      ),
    );
    if (confirmed == true) {
      ref.invalidate(metricAlertRulesProvider(widget.projectId));
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Text(l.alertsDeleted),
          ),
        );
      }
    }
  }

  Future<void> _testRule(MetricAlertRule rule) async {
    final l = L.of(context);
    try {
      final res = await ref.read(apiProvider).testMetricAlertRule(widget.projectId, rule.id);
      final isFiring = res['is_firing'] == true;
      final currentVal = res['current_value'];
      final summary = res['summary'] ?? '';

      if (mounted) {
        showAppDialog(
          context,
          AlertDialog(
            title: Text('${rule.name} - ${l.alertsTriggerNow}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Durum: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFiring ? Tokens.danger.withValues(alpha: 0.15) : Tokens.ok.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isFiring ? l.alertsStatusFiring : l.alertsStatusOk,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isFiring ? Tokens.danger : Tokens.ok,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ölçülen Değer: $currentVal', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Text(summary.toString(), style: const TextStyle(fontSize: 12, color: Tokens.textMuted)),
              ],
            ),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.commonClose),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Text('Test failed: $e', style: const TextStyle(color: Tokens.danger)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final rulesAsync = ref.watch(metricAlertRulesProvider(widget.projectId));
    final incidentsAsync = ref.watch(metricAlertIncidentsProvider((
      projectId: widget.projectId,
      ruleId: null,
    )));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.alertsTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.alertsSubtitle,
                      style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                onPressed: () => context.go('/projects/${widget.projectId}/alerts/rules/new'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 16),
                    const SizedBox(width: 8),
                    Text(l.alertsNewRule),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs
          Row(
            children: [
              _buildTabButton(0, l.alertsTabRules, LucideIcons.slidersHorizontal),
              const SizedBox(width: 8),
              _buildTabButton(1, l.alertsTabIncidents, LucideIcons.flame),
            ],
          ),
          const SizedBox(height: 20),

          // Content based on tab
          if (_selectedTab == 0)
            rulesAsync.when(
              data: (rules) => _buildRulesList(context, l, rules),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Tokens.danger))),
            )
          else
            incidentsAsync.when(
              data: (incidents) => _buildIncidentsList(context, l, incidents),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Tokens.danger))),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return OutlineButton(
      onPressed: () => setState(() => _selectedTab = index),
      density: ButtonDensity.compact,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Tokens.brand.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Tokens.brand : Tokens.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Tokens.brand : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesList(BuildContext context, L l, List<MetricAlertRule> rules) {
    if (rules.isEmpty) {
      return SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.bellOff, size: 40, color: Tokens.textMuted),
                const SizedBox(height: 12),
                Text(
                  l.alertsEmptyRules,
                  style: const TextStyle(fontSize: 14, color: Tokens.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final r in rules)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRuleCard(context, l, r),
          ),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context, L l, MetricAlertRule r) {
    Color statusColor = Tokens.ok;
    String statusLabel = l.alertsStatusOk;
    IconData statusIcon = LucideIcons.circleCheck;

    if (r.currentStatus == 'firing') {
      statusColor = Tokens.danger;
      statusLabel = l.alertsStatusFiring;
      statusIcon = LucideIcons.flame;
    } else if (r.currentStatus == 'warning') {
      statusColor = Tokens.warning;
      statusLabel = l.alertsStatusWarning;
      statusIcon = LucideIcons.triangleAlert;
    }

    String metricName = switch (r.metricType) {
      'error_count' => l.alertsMetricErrorCount,
      'error_rate' => l.alertsMetricErrorRate,
      'transaction_duration_p95' => l.alertsMetricP95Duration,
      'unhandled_crash_count' => l.alertsMetricCrashCount,
      _ => r.metricType,
    };

    String opSymbol = switch (r.comparisonOperator) {
      'gt' => '>',
      'gte' => '>=',
      'lt' => '<',
      'spike_multiplier' => 'Spike',
      _ => r.comparisonOperator,
    };

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Icon/Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Rule Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        r.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (r.targetFilter.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Tokens.chip,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            r.targetFilter,
                            style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        metricName,
                        style: const TextStyle(fontSize: 12, color: Tokens.brand, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        r.comparisonOperator == 'spike_multiplier'
                            ? '${r.criticalThreshold}x Anomali Artışı'
                            : 'Değer $opSymbol ${r.criticalThreshold.toStringAsFixed(1)}${r.warningThreshold != null ? ' (Uyarı: ${r.warningThreshold!.toStringAsFixed(1)})' : ''}',
                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        '${r.windowMinutes} dk pencere',
                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Toggle switch
            Switch(
              value: r.isActive,
              onChanged: (_) => _toggleActive(r),
            ),
            const SizedBox(width: 8),

            // Test Button
            Tooltip(
              tooltip: (_) => TooltipContainer(child: Text(l.alertsTriggerNow)),
              child: IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.play, size: 15),
                onPressed: () => _testRule(r),
              ),
            ),

            // Edit Button
            Tooltip(
              tooltip: (_) => TooltipContainer(child: Text(l.alertsEditRule)),
              child: IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.pencil, size: 15),
                onPressed: () => context.go('/projects/${widget.projectId}/alerts/rules/${r.id}'),
              ),
            ),

            // Delete Button
            Tooltip(
              tooltip: (_) => TooltipContainer(child: Text(l.commonDelete)),
              child: IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.trash2, size: 15, color: Tokens.danger),
                onPressed: () => _deleteRule(r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentsList(BuildContext context, L l, List<MetricAlertIncident> incidents) {
    if (incidents.isEmpty) {
      return SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.circleCheck, size: 40, color: Tokens.ok),
                const SizedBox(height: 12),
                Text(
                  l.alertsEmptyIncidents,
                  style: const TextStyle(fontSize: 14, color: Tokens.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final inc in incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: inc.status == 'firing'
                            ? Tokens.danger.withValues(alpha: 0.15)
                            : Tokens.ok.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        inc.status == 'firing' ? l.alertsStatusFiring.toUpperCase() : l.alertsStatusResolved.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: inc.status == 'firing' ? Tokens.danger : Tokens.ok,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                inc.ruleName ?? 'Metric Alert #${inc.ruleId}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                context.fmt.relative(inc.triggeredAt),
                                style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inc.summary,
                            style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${l.alertsPeakValue}: ${inc.peakValue.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (inc.resolvedAt != null) ...[
                                const SizedBox(width: 16),
                                Text(
                                  '${l.alertsStatusResolved}: ${context.fmt.relative(inc.resolvedAt!)}',
                                  style: const TextStyle(fontSize: 12, color: Tokens.ok),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
