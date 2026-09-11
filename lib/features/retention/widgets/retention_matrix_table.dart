// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../shared/widgets/panel_message.dart';

class RetentionMatrixTable extends StatelessWidget {
  const RetentionMatrixTable({
    super.key,
    required this.result,
  });

  final RetentionResult result;

  @override
  Widget build(BuildContext context) {
    if (result.buckets.isEmpty) {
      return PanelMessage(context.l10n.retentionEmpty);
    }

    // Determine max periods across all buckets
    int maxPeriods = 0;
    for (final b in result.buckets) {
      if (b.periods.length > maxPeriods) {
        maxPeriods = b.periods.length;
      }
    }

    final unitLabel = result.periodUnit == 'week'
        ? context.l10n.retentionPeriodWeek
        : context.l10n.retentionPeriodDay;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Tokens.hairline)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    context.l10n.retentionBucket,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Tokens.textMuted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    context.l10n.retentionUsers,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Tokens.textMuted,
                    ),
                  ),
                ),
                const Gap(16),
                for (var i = 0; i < maxPeriods; i++)
                  Container(
                    width: 72,
                    margin: const EdgeInsets.only(right: 6),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.retentionPeriodN(unitLabel, i),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Tokens.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Data rows
          for (final bucket in result.buckets)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Tokens.hairline)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      bucket.bucketStart,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Tokens.textStrong,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      '${bucket.totalUsers}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Tokens.text,
                      ),
                    ),
                  ),
                  const Gap(16),
                  for (var i = 0; i < maxPeriods; i++) ...[
                    _buildCell(context, bucket, i),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, RetentionCohortBucket bucket, int periodIndex) {
    RetentionPeriodActivity? activity;
    for (final p in bucket.periods) {
      if (p.periodIndex == periodIndex) {
        activity = p;
        break;
      }
    }

    if (activity == null) {
      return Container(
        width: 72,
        height: 38,
        margin: const EdgeInsets.only(right: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Tokens.panel,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '—',
          style: TextStyle(fontSize: 11, color: Tokens.textDim),
        ),
      );
    }

    final act = activity;
    final pct = act.percentage;
    final alpha = (pct / 100.0).clamp(0.12, 0.90);
    final bg = Tokens.ok.withValues(alpha: alpha);

    return Tooltip(
      tooltip: (_) => TooltipContainer(
        child: Text(
          '${act.activeUsers} / ${bucket.totalUsers} (${pct.toStringAsFixed(1)}%)',
        ),
      ),
      child: Container(
        width: 72,
        height: 38,
        margin: const EdgeInsets.only(right: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${pct.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: alpha > 0.45 ? const Color(0xFF0E0D0B) : Tokens.textStrong,
          ),
        ),
      ),
    );
  }
}
