// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class TracesPage extends ConsumerStatefulWidget {
  const TracesPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<TracesPage> createState() => _TracesPageState();
}

class _TracesPageState extends ConsumerState<TracesPage> {
  int _days = 14;
  String _service = '';
  String _status = '';
  double? _minDurationMs;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(double ms) {
    if (ms < 1) {
      return '<1 ms';
    }
    if (ms < 1000) {
      return '${ms.toStringAsFixed(ms < 10 ? 1 : 0)} ms';
    }
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  Color _serviceColor(String service) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF14B8A6), // Teal
    ];
    if (service.isEmpty) return const Color(0xFF64748B);
    final hash = service.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final tracesKey = (
      projectId: widget.projectId,
      days: _days,
      service: _service.isEmpty ? null : _service,
      status: _status.isEmpty ? null : _status,
      minDurationMs: _minDurationMs,
      query: _query.isEmpty ? null : _query,
      limit: 50,
    );

    final tracesAsync = ref.watch(tracesProvider(tracesKey));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.tracesTitle,
            subtitle: context.l10n.tracesSubtitle,
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
              OutlineButton(
                size: ButtonSize.small,
                density: ButtonDensity.compact,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(tracesProvider(tracesKey)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(16),

          // Filters row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Tokens.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Tokens.border),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search input
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchCtrl,
                    placeholder: Text(context.l10n.tracesSearchPlaceholder),
                    features: [
                      const InputFeature.leading(Icon(LucideIcons.search, size: 14)),
                      if (_query.isNotEmpty)
                        InputFeature.trailing(
                          GhostButton(
                            size: ButtonSize.small,
                            density: ButtonDensity.compact,
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(LucideIcons.x, size: 12),
                          ),
                        ),
                    ],
                    onSubmitted: (v) => setState(() => _query = v.trim()),
                  ),
                ),

                // Status Filter
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${context.l10n.traceStatus}: ',
                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                    ),
                    const Gap(6),
                    _filterChip(
                      label: context.l10n.commonAll,
                      selected: _status.isEmpty,
                      onTap: () => setState(() => _status = ''),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: 'OK',
                      selected: _status == 'ok',
                      onTap: () => setState(() => _status = 'ok'),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: context.l10n.commonError,
                      selected: _status == 'error',
                      onTap: () => setState(() => _status = 'error'),
                    ),
                  ],
                ),

                // Min Duration Filter
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${context.l10n.tracesFilterMinDuration}: ',
                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                    ),
                    const Gap(6),
                    _filterChip(
                      label: context.l10n.commonAll,
                      selected: _minDurationMs == null,
                      onTap: () => setState(() => _minDurationMs = null),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: '> 50ms',
                      selected: _minDurationMs == 50,
                      onTap: () => setState(() => _minDurationMs = 50),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: '> 200ms',
                      selected: _minDurationMs == 200,
                      onTap: () => setState(() => _minDurationMs = 200),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: '> 500ms',
                      selected: _minDurationMs == 500,
                      onTap: () => setState(() => _minDurationMs = 500),
                    ),
                    const Gap(4),
                    _filterChip(
                      label: '> 1s',
                      selected: _minDurationMs == 1000,
                      onTap: () => setState(() => _minDurationMs = 1000),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // Traces List
          Expanded(
            child: PanelCard(
              title: context.l10n.tracesTitle,
              child: tracesAsync.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  e.toString(),
                  color: Tokens.danger,
                ),
                data: (traces) {
                  if (traces.isEmpty) {
                    return PanelMessage(context.l10n.tracesEmpty);
                  }

                  // Find max duration for relative duration bar
                  final maxDur = traces.fold<double>(
                    1.0,
                    (prev, t) => max(prev, t.durationMs),
                  );

                  return SingleChildScrollView(
                    child: DataTable<TraceSummary>(
                      columns: [
                        (context.l10n.traceRootSpan, 4, false),
                        (context.l10n.tracesFilterService, 2, false),
                        (context.l10n.traceDetailSpanCount, 2, false),
                        (context.l10n.traceDetailDuration, 3, false),
                        (context.l10n.traceStatus, 1, false),
                        (context.l10n.traceTimestamp, 2, true),
                      ],
                      rows: traces,
                      onTap: (trace) => context.go(
                        '/projects/${widget.projectId}/traces/${trace.traceId}',
                      ),
                      cells: (trace) => [
                        // Root Span & Trace ID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  trace.rootOp.startsWith('http')
                                      ? LucideIcons.globe
                                      : trace.rootOp.startsWith('db')
                                          ? LucideIcons.database
                                          : LucideIcons.cpu,
                                  size: 14,
                                  color: _serviceColor(trace.serviceName),
                                ),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    trace.rootName.isEmpty ? trace.rootOp : trace.rootName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Tokens.textStrong,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(2),
                            Row(
                              children: [
                                Text(
                                  trace.traceId.length > 12
                                      ? '${trace.traceId.substring(0, 12)}...'
                                      : trace.traceId,
                                  style: AppTheme.mono(
                                    size: 11,
                                    color: Tokens.textMuted,
                                  ),
                                ),
                                const Gap(4),
                                GhostButton(
                                  size: ButtonSize.small,
                                  density: ButtonDensity.compact,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: trace.traceId));
                                    showToast(
                                      context: context,
                                      builder: (c, overlay) => SurfaceCard(
                                        child: Text(context.l10n.commonCopied),
                                      ),
                                    );
                                  },
                                  child: const Icon(LucideIcons.copy, size: 10),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Service chip
                        GestureDetector(
                          onTap: () => setState(() => _service = _service == trace.serviceName ? '' : trace.serviceName),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _serviceColor(trace.serviceName).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _serviceColor(trace.serviceName).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              trace.serviceName.isEmpty ? 'default' : trace.serviceName,
                              style: AppTheme.mono(
                                size: 11,
                                weight: FontWeight.w600,
                                color: _serviceColor(trace.serviceName),
                              ),
                            ),
                          ),
                        ),

                        // Span count & Service count
                        Text(
                          '${trace.spanCount} spans · ${trace.serviceCount} svc',
                          style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                        ),

                        // Duration + mini bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDuration(trace.durationMs),
                              style: AppTheme.mono(
                                size: 12,
                                weight: FontWeight.w600,
                                color: Tokens.textStrong,
                              ),
                            ),
                            const Gap(4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                height: 4,
                                width: 100,
                                color: Tokens.border,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: max(4.0, (trace.durationMs / maxDur) * 100),
                                    color: trace.hasErrors
                                        ? Tokens.danger
                                        : _serviceColor(trace.serviceName),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: trace.hasErrors
                                ? Tokens.danger.withValues(alpha: 0.12)
                                : Tokens.ok.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trace.hasErrors ? 'ERR' : 'OK',
                            style: AppTheme.mono(
                              size: 11,
                              weight: FontWeight.w600,
                              color: trace.hasErrors ? Tokens.danger : Tokens.ok,
                            ),
                          ),
                        ),

                        // Started
                        Text(
                          context.fmt.dateTime(trace.startTime),
                          style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
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

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    if (selected) {
      return PrimaryButton(
        size: ButtonSize.small,
        density: ButtonDensity.compact,
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
    }
    return OutlineButton(
      size: ButtonSize.small,
      density: ButtonDensity.compact,
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
      ),
    );
  }
}
