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

class PerformancePage extends ConsumerStatefulWidget {
  const PerformancePage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends ConsumerState<PerformancePage> {
  int _days = 14;
  String _selectedOp = '';

  String _formatDuration(double ms) {
    if (ms < 1000) {
      return '${ms.toStringAsFixed(ms < 10 ? 1 : 0)} ms';
    }
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  void _showDetail(BuildContext context, PerformanceSummaryItem item) {
    context.go(
      '/projects/${widget.projectId}/performance/transaction'
      '?name=${Uri.encodeQueryComponent(item.name)}'
      '&op=${Uri.encodeQueryComponent(item.op)}'
      '&days=$_days',
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfAsync = ref.watch(
      performanceProvider((
        projectId: widget.projectId,
        days: _days,
        op: _selectedOp,
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.performanceTitle,
            subtitle: perfAsync.maybeWhen(
              data: (data) => context.l10n.performanceSubtitle(data.summary.length),
              orElse: () => null,
            ),
            actions: [
              // Days selector
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
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                          style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                        ),
                      ),
                  ],
                ],
              ),
              const Gap(8),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(performanceProvider),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),

          // Op Filter pills
          perfAsync.maybeWhen(
            data: (data) {
              if (data.ops.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedOp.isEmpty)
                        PrimaryButton(
                          size: ButtonSize.small,
                          density: ButtonDensity.compact,
                          onPressed: () => setState(() => _selectedOp = ''),
                          child: Text(
                            context.l10n.commonAll,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        )
                      else
                        OutlineButton(
                          size: ButtonSize.small,
                          density: ButtonDensity.compact,
                          onPressed: () => setState(() => _selectedOp = ''),
                          child: Text(
                            context.l10n.commonAll,
                            style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                          ),
                        ),
                      for (final op in data.ops) ...[
                        const Gap(6),
                        if (_selectedOp == op)
                          PrimaryButton(
                            size: ButtonSize.small,
                            density: ButtonDensity.compact,
                            onPressed: () => setState(() => _selectedOp = op),
                            child: Text(
                              op,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          )
                        else
                          OutlineButton(
                            size: ButtonSize.small,
                            density: ButtonDensity.compact,
                            onPressed: () => setState(() => _selectedOp = op),
                            child: Text(
                              op,
                              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),

          Expanded(
            child: PanelCard(
              title: context.l10n.performanceTitle,
              child: perfAsync.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  context.l10n.performanceLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
                data: (data) {
                  if (data.summary.isEmpty) {
                    return PanelMessage(context.l10n.performanceEmpty);
                  }
                  return SingleChildScrollView(
                    child: DataTable<PerformanceSummaryItem>(
                      columns: [
                        (context.l10n.colTransaction, 4, false),
                        (context.l10n.colOperation, 2, false),
                        (context.l10n.colCalls, 2, true),
                        (context.l10n.colP50, 2, true),
                        (context.l10n.colP95, 2, true),
                        (context.l10n.colAvg, 2, true),
                        (context.l10n.colErrorRate, 2, true),
                      ],
                      rows: data.summary,
                      onTap: (item) => _showDetail(context, item),
                      cells: (item) => [
                        ClickableRowText(
                          text: item.name,
                          onTap: () => _showDetail(context, item),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Tokens.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.op,
                            style: AppTheme.mono(size: 11, color: Tokens.accent),
                          ),
                        ),
                        Text(
                          context.fmt.integer(item.count),
                          style: AppTheme.mono(size: 13, color: Tokens.text),
                        ),
                        Text(
                          _formatDuration(item.p50),
                          style: AppTheme.mono(size: 13, color: Tokens.textStrong, weight: FontWeight.w600),
                        ),
                        Text(
                          _formatDuration(item.p95),
                          style: AppTheme.mono(
                            size: 13,
                            color: item.p95 > 1000 ? Tokens.danger : Tokens.textStrong,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDuration(item.avgDuration),
                          style: AppTheme.mono(size: 13, color: Tokens.textMuted),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item.errorRate > 0.05
                                    ? Tokens.danger
                                    : item.errorRate > 0
                                        ? Tokens.brand
                                        : Tokens.ok)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(item.errorRate * 100).toStringAsFixed(1)}%',
                            style: AppTheme.mono(
                              size: 12,
                              color: item.errorRate > 0.05
                                  ? Tokens.danger
                                  : item.errorRate > 0
                                      ? Tokens.brand
                                      : Tokens.ok,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClickableRowText extends StatelessWidget {
  const ClickableRowText({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTheme.mono(
          size: 13,
          weight: FontWeight.w600,
          color: Tokens.brand,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

