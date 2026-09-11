// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'funnel_create_dialog.dart';
import 'widgets/funnel_step_bar.dart';

class FunnelDetailPage extends ConsumerStatefulWidget {
  const FunnelDetailPage({
    super.key,
    required this.projectId,
    required this.funnelId,
  });

  final int projectId;
  final int funnelId;

  @override
  ConsumerState<FunnelDetailPage> createState() => _FunnelDetailPageState();
}

class _FunnelDetailPageState extends ConsumerState<FunnelDetailPage> {
  int _days = 7;

  String _formatSeconds(double seconds) {
    if (seconds <= 0) return context.l10n.commonEmpty;
    final totalSec = seconds.round();
    if (totalSec < 60) return context.l10n.fmtSeconds(totalSec);
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    if (m < 60) {
      return s > 0 ? '$m ${context.l10n.fmtMinutes(m)} $s ${context.l10n.fmtSeconds(s)}' : context.l10n.fmtMinutes(m);
    }
    final h = (m / 60.0).toStringAsFixed(1);
    return context.l10n.fmtHours(h);
  }

  Future<void> _editFunnel(Funnel funnel) async {
    final updated = await showAppDialog<bool>(
      context,
      FunnelCreateDialog(
        projectId: widget.projectId,
        existing: funnel,
      ),
    );
    if (updated == true && mounted) {
      ref.invalidate(funnelProvider((project: widget.projectId, funnelId: widget.funnelId)));
      ref.invalidate(funnelResultsProvider((project: widget.projectId, funnelId: widget.funnelId, days: _days)));
    }
  }

  Future<void> _deleteFunnel() async {
    await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: context.l10n.commonDelete,
        message: context.l10n.funnelDeleteConfirm,
        confirmLabel: context.l10n.commonDelete,
        destructive: true,
        onConfirm: () async {
          final api = ref.read(apiProvider);
          await api.deleteFunnel(widget.projectId, widget.funnelId);
          ref.invalidate(funnelsProvider(widget.projectId));
          if (mounted) {
            toast(context, context.l10n.funnelDeleted);
            context.go('/projects/${widget.projectId}/funnels');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final funnelAsync = ref.watch(
      funnelProvider((project: widget.projectId, funnelId: widget.funnelId)),
    );
    final resultsAsync = ref.watch(
      funnelResultsProvider((project: widget.projectId, funnelId: widget.funnelId, days: _days)),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: funnelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            describeError(context.l10n, e),
            style: const TextStyle(color: Tokens.danger),
          ),
        ),
        data: (funnel) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: context.l10n.navFunnels,
                    path: '/projects/${widget.projectId}/funnels',
                  ),
                  BreadcrumbItem(label: funnel.name),
                ],
              ),
              const Gap(14),
              PageHeader(
                title: funnel.name,
                subtitle: funnel.description.isNotEmpty
                    ? funnel.description
                    : '${funnel.steps.length} ${context.l10n.funnelSteps.toLowerCase()}',
                actions: [
                  // Range selector
                  Wrap(
                    spacing: 4,
                    children: [
                      for (final d in [7, 14, 30])
                        if (_days == d)
                          PrimaryButton(
                            density: ButtonDensity.compact,
                            size: ButtonSize.small,
                            onPressed: () => setState(() => _days = d),
                            child: Text(
                              '$d d',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          OutlineButton(
                            density: ButtonDensity.compact,
                            size: ButtonSize.small,
                            onPressed: () => setState(() => _days = d),
                            child: Text(
                              '$d d',
                              style: const TextStyle(
                                color: Tokens.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                    ],
                  ),
                  const Gap(8),
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.pencil, size: 14),
                    onPressed: () => _editFunnel(funnel),
                    child: Text(context.l10n.commonSave),
                  ),
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                    onPressed: _deleteFunnel,
                    child: Text(
                      context.l10n.commonDelete,
                      style: const TextStyle(color: Tokens.danger),
                    ),
                  ),
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.refreshCw, size: 14),
                    onPressed: () {
                      ref.invalidate(
                        funnelResultsProvider(
                          (project: widget.projectId, funnelId: widget.funnelId, days: _days),
                        ),
                      );
                    },
                    child: Text(context.l10n.commonRefresh),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: resultsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      describeError(context.l10n, e),
                      style: const TextStyle(color: Tokens.danger),
                    ),
                  ),
                  data: (res) {
                    final overallRatePct = (res.overallConversionRate * 100).toStringAsFixed(1);
                    final maxStepCount = res.steps.isNotEmpty ? res.steps.first.count : res.totalSessions;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KpiRow([
                            KpiTile(
                              label: context.l10n.funnelOverallConversion,
                              value: '$overallRatePct%',
                              valueColor: res.overallConversionRate >= 0.5 ? Tokens.ok : Tokens.accent,
                            ),
                            KpiTile(
                              label: context.l10n.funnelCompletedSessions,
                              value: context.fmt.integer(res.completedSessions),
                            ),
                            KpiTile(
                              label: context.l10n.funnelTotalSessions,
                              value: context.fmt.integer(res.totalSessions),
                            ),
                            KpiTile(
                              label: context.l10n.funnelMedianTime,
                              value: _formatSeconds(res.medianConversionSeconds),
                            ),
                          ]),
                          const Gap(20),
                          PanelCard(
                            title: context.l10n.funnelStepConversion,
                            child: res.steps.isEmpty
                                ? PanelMessage(context.l10n.commonNoData)
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      for (var i = 0; i < res.steps.length; i++)
                                        FunnelStepBar(
                                          projectId: widget.projectId,
                                          funnelId: widget.funnelId,
                                          step: res.steps[i],
                                          maxCount: maxStepCount > 0 ? maxStepCount : 1,
                                          days: _days,
                                          isLast: i == res.steps.length - 1,
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
