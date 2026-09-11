// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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

class TransactionDetailPage extends ConsumerStatefulWidget {
  const TransactionDetailPage({
    super.key,
    required this.projectId,
    required this.name,
    required this.op,
    this.days = 14,
  });

  final int projectId;
  final String name;
  final String op;
  final int days;

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.days;
  }

  String _formatDuration(double ms) {
    if (ms < 1000) {
      return '${ms.toStringAsFixed(ms < 10 ? 1 : 0)} ms';
    }
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      transactionDetailProvider((
        projectId: widget.projectId,
        name: widget.name,
        op: widget.op,
        days: _days,
      )),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            breadcrumb: AppBreadcrumb(
              items: [
                BreadcrumbItem(
                  label: context.l10n.performanceTitle,
                  path: '/projects/${widget.projectId}/performance',
                ),
                BreadcrumbItem(label: widget.name),
              ],
            ),
            title: widget.name,
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final d in [7, 14, 30]) ...[
                    if (d != 7) const Gap(4),
                    if (_days == d)
                      PrimaryButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () => setState(() => _days = d),
                        child: Text(
                          d == 7
                              ? context.l10n.performanceDays7
                              : d == 14
                                  ? context.l10n.performanceDays14
                                  : context.l10n.performanceDays30,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () => setState(() => _days = d),
                        child: Text(
                          d == 7
                              ? context.l10n.performanceDays7
                              : d == 14
                                  ? context.l10n.performanceDays14
                                  : context.l10n.performanceDays30,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Tokens.textMuted,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              const Gap(8),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(transactionDetailProvider),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          if (widget.op.isNotEmpty) ...[
            const Gap(8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Tokens.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.op,
                    style: AppTheme.mono(size: 12, color: Tokens.accent),
                  ),
                ),
              ],
            ),
          ],
          const Gap(16),
          detailAsync.when(
            loading: () => PanelMessage(context.l10n.commonLoading),
            error: (e, _) => PanelMessage(
              context.l10n.performanceLoadFailed(
                describeError(context.l10n, e),
              ),
              color: Tokens.danger,
            ),
            data: (detail) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _KpiBox(
                          label: context.l10n.colP50,
                          value: _formatDuration(detail.p50),
                          color: Tokens.ok,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _KpiBox(
                          label: context.l10n.colP95,
                          value: _formatDuration(detail.p95),
                          color: detail.p95 > 1000
                              ? Tokens.danger
                              : Tokens.brand,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _KpiBox(
                          label: context.l10n.colAvg,
                          value: _formatDuration(detail.avgDuration),
                          color: Tokens.text,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _KpiBox(
                          label: context.l10n.colCalls,
                          value: context.fmt.integer(detail.count),
                          color: Tokens.text,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _KpiBox(
                          label: context.l10n.colErrorRate,
                          value:
                              '${(detail.errorRate * 100).toStringAsFixed(1)}%',
                          color: detail.errorRate > 0.05
                              ? Tokens.danger
                              : Tokens.ok,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  PanelCard(
                    title: context.l10n.performanceSlowestSamples,
                    child: detail.samples.isEmpty
                        ? PanelMessage(context.l10n.commonNoRecords)
                        : DataTable<SpanSample>(
                            columns: [
                              (context.l10n.colDuration, 2, true),
                              (context.l10n.colStatus, 2, false),
                              (context.l10n.colTime, 3, false),
                              (context.l10n.colAction, 3, true),
                            ],
                            rows: detail.samples,
                            onTap: (smp) => context.go(
                              '/projects/${widget.projectId}/sessions/${smp.sessionId}',
                            ),
                            cells: (smp) => [
                              Text(
                                _formatDuration(smp.durationMs),
                                style: AppTheme.mono(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: Tokens.textStrong,
                                ),
                              ),
                              Text(
                                smp.status,
                                style: AppTheme.mono(
                                  size: 12,
                                  color: smp.status != 'ok' &&
                                          smp.status != '200'
                                      ? Tokens.danger
                                      : Tokens.ok,
                                ),
                              ),
                              Text(
                                context.fmt.dateTime(smp.ts),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Tokens.textMuted,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PrimaryButton(
                                    size: ButtonSize.small,
                                    density: ButtonDensity.compact,
                                    leading: const Icon(LucideIcons.play, size: 12),
                                    onPressed: () => context.go(
                                      '/projects/${widget.projectId}/sessions/${smp.sessionId}',
                                    ),
                                    child: Text(context.l10n.performanceViewReplay),
                                  ),
                                  if (smp.traceId.isNotEmpty) ...[
                                    const Gap(8),
                                    SecondaryButton(
                                      size: ButtonSize.small,
                                      density: ButtonDensity.compact,
                                      leading: const Icon(LucideIcons.gitFork, size: 12),
                                      onPressed: () => context.go(
                                        '/projects/${widget.projectId}/traces/${smp.traceId}',
                                      ),
                                      child: Text(context.l10n.performanceViewTrace),
                                    ),
                                  ],
                                  const Gap(8),
                                  SecondaryButton(
                                    size: ButtonSize.small,
                                    density: ButtonDensity.compact,
                                    leading: const Icon(LucideIcons.flame, size: 12),
                                    onPressed: () => context.go(
                                      '/projects/${widget.projectId}/profiling?transaction=${Uri.encodeComponent(widget.name)}',
                                    ),
                                    child: Text(context.l10n.profilingViewProfile),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  const _KpiBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Tokens.raised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
          ),
          const Gap(2),
          Text(
            value,
            style: AppTheme.mono(
              size: 14,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
