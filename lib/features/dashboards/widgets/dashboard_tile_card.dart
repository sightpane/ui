// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../core/providers.dart';
import '../../insights/widgets/insight_chart.dart';

class DashboardTileCard extends ConsumerWidget {
  const DashboardTileCard({
    super.key,
    required this.projectId,
    required this.tile,
    this.onRemove,
    this.onEdit,
  });

  final int projectId;
  final DashboardTile tile;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(insightDetailProvider((projectId: projectId, insightId: tile.insightId)));

    return Card(
      filled: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: insightAsync.when(
          loading: () => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              '${context.l10n.commonError}: $err',
              style: const TextStyle(fontSize: 12, color: Tokens.danger),
            ),
          ),
          data: (insight) {
            final resultsAsync = ref.watch(insightResultsProvider((projectId: projectId, insightId: insight.id)));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Tokens.textStrong,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Tokens.chip,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _chartTypeLabel(context, insight.chartType),
                                  style: const TextStyle(fontSize: 10, color: Tokens.textMuted),
                                ),
                              ),
                              const Gap(6),
                              Text(
                                '${insight.query.dateRange} · ${insight.query.interval}',
                                style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null)
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.pencil, size: 14),
                        onPressed: onEdit,
                      ),
                    IconButton.ghost(
                      size: ButtonSize.small,
                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                      onPressed: () {
                        ref.invalidate(insightResultsProvider((projectId: projectId, insightId: insight.id)));
                      },
                    ),
                    if (onRemove != null)
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.x, size: 14),
                        onPressed: onRemove,
                      ),
                  ],
                ),
                const Gap(12),
                Expanded(
                  child: resultsAsync.when(
                    loading: () => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text(
                        '${context.l10n.commonError}: $err',
                        style: const TextStyle(fontSize: 12, color: Tokens.danger),
                      ),
                    ),
                    data: (res) => InsightChart(
                      chartType: insight.chartType,
                      result: res,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _chartTypeLabel(BuildContext context, String chartType) {
    return switch (chartType) {
      'bar' => context.l10n.chartTypeBar,
      'area' => context.l10n.chartTypeArea,
      'number' => context.l10n.chartTypeNumber,
      'donut' => context.l10n.chartTypeDonut,
      'table' => context.l10n.chartTypeTable,
      _ => context.l10n.chartTypeLine,
    };
  }
}
