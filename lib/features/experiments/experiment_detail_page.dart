// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'widgets/significance_badge.dart';

class ExperimentDetailPage extends ConsumerStatefulWidget {
  const ExperimentDetailPage({
    super.key,
    required this.projectId,
    required this.expId,
  });

  final int projectId;
  final int expId;

  @override
  ConsumerState<ExperimentDetailPage> createState() => _ExperimentDetailPageState();
}

class _ExperimentDetailPageState extends ConsumerState<ExperimentDetailPage> {
  int _days = 14;
  bool _actionLoading = false;

  Future<void> _updateStatus(Experiment exp, String newStatus) async {
    setState(() => _actionLoading = true);
    final api = ref.read(apiProvider);
    try {
      await api.updateExperiment(
        widget.projectId,
        widget.expId,
        name: exp.name,
        description: exp.description,
        status: newStatus,
        minimumSampleSize: exp.minimumSampleSize,
      );
      ref.invalidate(experimentProvider((projectId: widget.projectId, expId: widget.expId)));
      ref.invalidate(experimentsProvider(widget.projectId));
      if (mounted) {
        toast(context, 'Experiment status updated to $newStatus.');
      }
    } catch (e) {
      if (mounted) {
        toast(context, describeError(context.l10n, e));
      }
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _declareWinner(Experiment exp, VariantResult variant) async {
    final confirmed = await showAppDialog<bool>(
      context,
      Card(
        filled: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.trophy, size: 20, color: Tokens.brand),
                    const Gap(8),
                    Text(
                      'Declare "${variant.name}" as Winner?',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  'Declaring "${variant.name}" (${variant.key}) as the winner will:\n'
                  '• Conclude this experiment\n'
                  '• Automatically update feature flag "${exp.featureFlagKey}" to 100% rollout for this variant',
                  style: const TextStyle(fontSize: 13, height: 1.5, color: Tokens.textMuted),
                ),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const Gap(8),
                    PrimaryButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Roll Out Winner (100%)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _actionLoading = true);
      final api = ref.read(apiProvider);
      try {
        await api.declareExperimentWinner(
          widget.projectId,
          widget.expId,
          winnerVariant: variant.key,
        );
        ref.invalidate(experimentProvider((projectId: widget.projectId, expId: widget.expId)));
        ref.invalidate(experimentResultsProvider((projectId: widget.projectId, expId: widget.expId, days: _days)));
        ref.invalidate(experimentsProvider(widget.projectId));
        ref.invalidate(featureFlagsProvider(widget.projectId));
        if (mounted) {
          toast(context, 'Winner declared! Feature flag updated to 100% rollout.');
        }
      } catch (e) {
        if (mounted) {
          toast(context, describeError(context.l10n, e));
        }
      } finally {
        if (mounted) {
          setState(() => _actionLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final expAsync = ref.watch(experimentProvider((projectId: widget.projectId, expId: widget.expId)));
    final resultsAsync = ref.watch(
      experimentResultsProvider((projectId: widget.projectId, expId: widget.expId, days: _days)),
    );

    return expAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            describeError(l, e),
            style: const TextStyle(color: Tokens.danger),
          ),
        ),
      ),
      data: (exp) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Breadcrumb
              AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: l.navExperiments,
                    path: '/projects/${widget.projectId}/experiments',
                  ),
                  BreadcrumbItem(label: exp.name),
                ],
              ),
              const Gap(16),

              // Page Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              exp.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Tokens.textStrong,
                              ),
                            ),
                            const Gap(10),
                            _StatusBadge(status: exp.status),
                            if (exp.winnerVariant != null) ...[
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Tokens.ok.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Tokens.ok.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.trophy, size: 12, color: Tokens.ok),
                                    const Gap(4),
                                    Text(
                                      'Winner: ${exp.winnerVariant}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Tokens.ok),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (exp.description.isNotEmpty) ...[
                          const Gap(4),
                          Text(
                            exp.description,
                            style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                          ),
                        ],
                        const Gap(8),
                        Row(
                          children: [
                            const Icon(LucideIcons.flag, size: 13, color: Tokens.textMuted),
                            const Gap(4),
                            Text(
                              'Flag: ${exp.featureFlagKey}',
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Tokens.textMuted),
                            ),
                            const Gap(14),
                            const Icon(LucideIcons.target, size: 13, color: Tokens.textMuted),
                            const Gap(4),
                            Text(
                              'Metric: ${exp.primaryMetricEvent}',
                              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                            ),
                            const Gap(14),
                            const Icon(LucideIcons.users, size: 13, color: Tokens.textMuted),
                            const Gap(4),
                            Text(
                              'Min Sample: ${exp.minimumSampleSize}',
                              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions: Date filter & Status change
                  Row(
                    children: [
                      // Days selector
                      Container(
                        decoration: BoxDecoration(
                          color: Tokens.panel,
                          borderRadius: BorderRadius.circular(Tokens.radius),
                          border: Border.all(color: Tokens.border),
                        ),
                        child: Row(
                          children: [
                            for (final d in [7, 14, 30])
                              GestureDetector(
                                onTap: () => setState(() => _days = d),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _days == d ? Tokens.brand.withValues(alpha: 0.15) : null,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${d}d',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _days == d ? FontWeight.w600 : FontWeight.normal,
                                      color: _days == d ? Tokens.brand : Tokens.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      if (exp.status == 'draft')
                        PrimaryButton(
                          size: ButtonSize.small,
                          leading: const Icon(LucideIcons.play, size: 14),
                          onPressed: _actionLoading ? null : () => _updateStatus(exp, 'running'),
                          child: const Text('Start Experiment'),
                        ),
                      if (exp.status == 'running')
                        GhostButton(
                          size: ButtonSize.small,
                          leading: const Icon(LucideIcons.circleStop, size: 14),
                          onPressed: _actionLoading ? null : () => _updateStatus(exp, 'concluded'),
                          child: const Text('Conclude'),
                        ),
                    ],
                  ),
                ],
              ),
              const Gap(24),

              // Results view
              resultsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to calculate results: $e', style: const TextStyle(color: Tokens.danger)),
                  ),
                ),
                data: (results) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview Banner
                      Card(
                        filled: true,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SignificanceBadge(
                                    isSignificant: results.isSignificant,
                                    significance: results.statisticalSignificance,
                                    totalParticipants: results.totalParticipants,
                                    minSampleSize: exp.minimumSampleSize,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${results.totalParticipants} total participants',
                                    style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                                  ),
                                ],
                              ),
                              if (results.recommendedAction.isNotEmpty) ...[
                                const Gap(14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Tokens.brand.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(Tokens.radius),
                                    border: Border.all(color: Tokens.brand.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.sparkles, size: 16, color: Tokens.brand),
                                      const Gap(10),
                                      Expanded(
                                        child: Text(
                                          'Recommendation: ${_formatRecommendation(results.recommendedAction)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Tokens.textStrong,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),

                      // Variant Performance Cards Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          final variants = results.variants;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? (variants.length >= 3 ? 3 : variants.length) : 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 320,
                            ),
                            itemCount: variants.length,
                            itemBuilder: (context, index) {
                              final v = variants[index];
                              final isControl = index == 0;
                              final isWinner = exp.winnerVariant == v.key;
                              final crPct = (v.conversionRate * 100).toStringAsFixed(2);
                              final liftPct = (v.relativeLift * 100).toStringAsFixed(1);
                              final isPositiveLift = v.relativeLift > 0;
                              final ciMin = (v.confidenceInterval[0] * 100).toStringAsFixed(1);
                              final ciMax = (v.confidenceInterval[1] * 100).toStringAsFixed(1);

                              return Card(
                                filled: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              v.name.isEmpty ? v.key : v.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Tokens.textStrong,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Tokens.panel,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isControl ? 'CONTROL' : v.key,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Tokens.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(14),

                                      // Conversion Rate
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '$crPct%',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Tokens.textStrong,
                                            ),
                                          ),
                                          const Gap(8),
                                          if (!isControl) ...[
                                            Icon(
                                              isPositiveLift ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                                              size: 14,
                                              color: isPositiveLift ? Tokens.ok : Tokens.danger,
                                            ),
                                            const Gap(2),
                                            Text(
                                              '${isPositiveLift ? '+' : ''}$liftPct%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isPositiveLift ? Tokens.ok : Tokens.danger,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const Gap(4),
                                      Text(
                                        '${v.conversions} conversions / ${v.participants} participants',
                                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      ),
                                      const Gap(14),

                                      // 95% Confidence Interval
                                      const Text(
                                        '95% Confidence Interval',
                                        style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                                      ),
                                      const Gap(4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Tokens.panel,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '[$ciMin% — $ciMax%]',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                            color: Tokens.textStrong,
                                          ),
                                        ),
                                      ),
                                      const Gap(12),

                                      // Chance to Win (Bayesian)
                                      if (!isControl) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Chance to win', style: TextStyle(fontSize: 11, color: Tokens.textMuted)),
                                            Text(
                                              '${(v.chanceToWin * 100).toStringAsFixed(1)}%',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                                            ),
                                          ],
                                        ),
                                        const Gap(4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: v.chanceToWin.clamp(0.0, 1.0),
                                            minHeight: 6,
                                            backgroundColor: Tokens.panel,
                                          ),
                                        ),
                                      ],
                                      const Spacer(),

                                      // Winner Declaration Action
                                      if (isWinner) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Tokens.ok.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(Tokens.radius),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(LucideIcons.trophy, size: 14, color: Tokens.ok),
                                              Gap(6),
                                              Text(
                                                'Winning Variant (Rolled Out 100%)',
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.ok),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else if (exp.status != 'concluded') ...[
                                        GhostButton(
                                          size: ButtonSize.small,
                                          onPressed: _actionLoading ? null : () => _declareWinner(exp, v),
                                          child: const Text('Declare Winner'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRecommendation(String rec) {
    if (rec.contains('winning')) {
      return '$rec. Results are statistically significant, consider rolling out.';
    }
    if (rec.contains('keep_running')) {
      return 'Keep the experiment running to gather sufficient sample size.';
    }
    return rec;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = Tokens.panel;
    Color fg = Tokens.textMuted;
    String label = status.toUpperCase();

    if (status == 'running') {
      bg = Tokens.ok.withValues(alpha: 0.15);
      fg = Tokens.ok;
    } else if (status == 'concluded') {
      bg = Tokens.brand.withValues(alpha: 0.15);
      fg = Tokens.brand;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
