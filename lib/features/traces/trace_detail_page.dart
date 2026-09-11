// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class TraceDetailPage extends ConsumerStatefulWidget {
  const TraceDetailPage({
    super.key,
    required this.projectId,
    required this.traceId,
  });

  final int projectId;
  final String traceId;

  @override
  ConsumerState<TraceDetailPage> createState() => _TraceDetailPageState();
}

class _TraceDetailPageState extends ConsumerState<TraceDetailPage> {
  String? _selectedSpanId;

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

  IconData _opIcon(String op) {
    if (op.startsWith('db')) return LucideIcons.database;
    if (op.startsWith('http')) return LucideIcons.globe;
    if (op.startsWith('cache')) return LucideIcons.archive;
    if (op.startsWith('queue') || op.startsWith('job')) return LucideIcons.layers;
    return LucideIcons.cpu;
  }

  @override
  Widget build(BuildContext context) {
    final traceAsync = ref.watch(
      traceProvider((projectId: widget.projectId, traceId: widget.traceId)),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumb
          AppBreadcrumb(
            items: [
              BreadcrumbItem(
                label: context.l10n.projectsTitle,
                path: '/projects',
              ),
              BreadcrumbItem(
                label: context.l10n.settingsProject,
                path: '/projects/${widget.projectId}',
              ),
              BreadcrumbItem(
                label: context.l10n.navTraces,
                path: '/projects/${widget.projectId}/traces',
              ),
              BreadcrumbItem(
                label: widget.traceId.length > 16
                    ? '${widget.traceId.substring(0, 16)}...'
                    : widget.traceId,
              ),
            ],
          ),
          const Gap(16),

          Expanded(
            child: traceAsync.when(
              skipLoadingOnReload: true,
              loading: () => PanelMessage(context.l10n.commonLoading),
              error: (e, _) => PanelMessage(e.toString(), color: Tokens.danger),
              data: (detail) {
                final selectedSpan = detail.spans.firstWhere(
                  (s) => s.spanId == _selectedSpanId,
                  orElse: () => detail.spans.first,
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Waterfall & Tree view
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            _buildHeader(detail),
                            const Gap(16),

                            // KPI summary cards
                            _buildKpiRow(detail),
                            const Gap(16),

                            // Suspect N+1 Issues Banner
                            if (detail.suspectIssues.isNotEmpty) ...[
                              _buildSuspectBanner(detail),
                              const Gap(16),
                            ],

                            // Gantt Waterfall Visualizer Card
                            _buildWaterfallCard(detail, selectedSpan),
                          ],
                        ),
                      ),
                    ),

                    // Span Inspector Panel
                    const Gap(16),
                    SizedBox(
                      width: 360,
                      child: _buildSpanInspector(selectedSpan),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TraceDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
      ),
      child: Row(
        children: [
          Icon(
            _opIcon(detail.rootOp),
            size: 24,
            color: Tokens.accent,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      detail.rootName.isEmpty ? detail.rootOp : detail.rootName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Tokens.textStrong,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: detail.status == 'ok' || detail.status == '200'
                            ? Tokens.ok.withValues(alpha: 0.12)
                            : Tokens.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        detail.status.toUpperCase(),
                        style: AppTheme.mono(
                          size: 11,
                          weight: FontWeight.bold,
                          color: detail.status == 'ok' || detail.status == '200'
                              ? Tokens.ok
                              : Tokens.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    Text(
                      'Trace ID: ',
                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                    ),
                    Text(
                      detail.traceId,
                      style: AppTheme.mono(
                        size: 12,
                        color: Tokens.textStrong,
                      ),
                    ),
                    const Gap(6),
                    GhostButton(
                      size: ButtonSize.small,
                      density: ButtonDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: detail.traceId));
                        showToast(
                          context: context,
                          builder: (c, overlay) => SurfaceCard(
                            child: Text(context.l10n.commonCopied),
                          ),
                        );
                      },
                      child: const Icon(LucideIcons.copy, size: 12),
                    ),
                    const Gap(12),
                    Text(
                      '· ${context.fmt.dateTime(detail.startTime)}',
                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(TraceDetail detail) {
    return Row(
      children: [
        Expanded(
          child: _kpiTile(
            label: context.l10n.traceDetailDuration,
            value: _formatDuration(detail.totalDurationMs),
            icon: LucideIcons.clock,
            accentColor: Tokens.accent,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _kpiTile(
            label: context.l10n.traceDetailSpanCount,
            value: '${detail.spanCount}',
            icon: LucideIcons.gitFork,
            accentColor: const Color(0xFF6366F1),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _kpiTile(
            label: context.l10n.traceDetailServiceCount,
            value: '${detail.serviceCount} (${detail.services.join(', ')})',
            icon: LucideIcons.network,
            accentColor: const Color(0xFF06B6D4),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _kpiTile(
            label: 'N+1 / Sorunlar',
            value: detail.suspectIssues.isEmpty
                ? 'Temiz (0)'
                : '${detail.suspectIssues.length} Tespit Edildi',
            icon: LucideIcons.triangleAlert,
            accentColor: detail.suspectIssues.isEmpty ? Tokens.ok : Tokens.warning,
          ),
        ),
      ],
    );
  }

  Widget _kpiTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Tokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const Gap(6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Tokens.textStrong,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSuspectBanner(TraceDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tokens.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.triangleAlert, color: Tokens.warning, size: 18),
              const Gap(8),
              Text(
                context.l10n.traceSuspectNPlus1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Tokens.warning,
                ),
              ),
            ],
          ),
          const Gap(8),
          for (final issue in detail.suspectIssues) ...[
            Text(
              issue.message,
              style: const TextStyle(fontSize: 13, color: Tokens.textStrong),
            ),
            const Gap(6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Etkilenen Spanlar: ',
                  style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                ),
                for (final spId in issue.spanIds)
                  GestureDetector(
                    onTap: () => setState(() => _selectedSpanId = spId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Tokens.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Tokens.warning.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        spId.length > 8 ? '${spId.substring(0, 8)}...' : spId,
                        style: AppTheme.mono(
                          size: 11,
                          weight: FontWeight.w600,
                          color: Tokens.warning,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterfallCard(TraceDetail detail, TraceSpan selectedSpan) {
    final totalMs = max(1.0, detail.totalDurationMs);

    return PanelCard(
      title: 'Waterfall Gantt Timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Millisecond Ruler
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Tokens.border)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 320, child: Text('SPAN HIERARCHY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Tokens.textDim))),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 ms', style: AppTheme.mono(size: 10, color: Tokens.textDim)),
                      Text(_formatDuration(totalMs * 0.25), style: AppTheme.mono(size: 10, color: Tokens.textDim)),
                      Text(_formatDuration(totalMs * 0.50), style: AppTheme.mono(size: 10, color: Tokens.textDim)),
                      Text(_formatDuration(totalMs * 0.75), style: AppTheme.mono(size: 10, color: Tokens.textDim)),
                      Text(_formatDuration(totalMs), style: AppTheme.mono(size: 10, color: Tokens.textDim)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Spans rows
          for (final span in detail.spans)
            _buildSpanRow(span, totalMs, isSelected: span.spanId == selectedSpan.spanId),
        ],
      ),
    );
  }

  Widget _buildSpanRow(TraceSpan span, double totalMs, {required bool isSelected}) {
    final color = _serviceColor(span.serviceName);
    final isError = span.status != 'ok' && span.status != '200' && span.status.isNotEmpty;

    final leftFraction = (span.startOffsetMs / totalMs).clamp(0.0, 1.0);
    final widthFraction = (span.durationMs / totalMs).clamp(0.005, 1.0);

    return GestureDetector(
      onTap: () => setState(() => _selectedSpanId = span.spanId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Tokens.accent.withValues(alpha: 0.08)
              : span.isSuspectNPlusOne
                  ? Tokens.warning.withValues(alpha: 0.04)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Tokens.border.withValues(alpha: 0.5)),
            left: isSelected
                ? const BorderSide(color: Tokens.accent, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            // Left Hierarchy Column
            SizedBox(
              width: 320,
              child: Row(
                children: [
                  SizedBox(width: (span.depth * 16.0).clamp(0.0, 160.0)),
                  Icon(
                    _opIcon(span.op),
                    size: 14,
                    color: color,
                  ),
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      span.serviceName.isEmpty ? 'default' : span.serviceName,
                      style: AppTheme.mono(size: 10, weight: FontWeight.w600, color: color),
                    ),
                  ),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      span.name.isEmpty ? span.op : span.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isError ? Tokens.danger : Tokens.textStrong,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (span.isSuspectNPlusOne) ...[
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Tokens.warning,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'N+1',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right Waterfall Column
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barLeft = constraints.maxWidth * leftFraction;
                  final barWidth = max(4.0, constraints.maxWidth * widthFraction);

                  return Stack(
                    children: [
                      // Background grid line guide
                      Container(height: 24),

                      // Timing Gantt bar
                      Positioned(
                        left: barLeft,
                        top: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 18,
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: isError ? Tokens.danger : color,
                                borderRadius: BorderRadius.circular(3),
                                border: span.isSuspectNPlusOne
                                    ? Border.all(color: Tokens.warning, width: 2)
                                    : null,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              _formatDuration(span.durationMs),
                              style: AppTheme.mono(
                                size: 10,
                                color: isError ? Tokens.danger : Tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpanInspector(TraceSpan span) {
    final color = _serviceColor(span.serviceName);
    final isError = span.status != 'ok' && span.status != '200' && span.status.isNotEmpty;

    // Check for SQL Query
    final sql = span.data['db.statement'] ?? span.data['query'] ?? span.data['sql'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tokens.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_opIcon(span.op), size: 18, color: color),
                const Gap(8),
                Expanded(
                  child: Text(
                    context.l10n.traceSpanDetails,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Tokens.textStrong,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isError ? Tokens.danger.withValues(alpha: 0.12) : Tokens.ok.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    span.status.isEmpty ? 'OK' : span.status.toUpperCase(),
                    style: AppTheme.mono(
                      size: 10,
                      weight: FontWeight.bold,
                      color: isError ? Tokens.danger : Tokens.ok,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),

            // Operation & Name
            Text(
              span.name.isEmpty ? span.op : span.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Tokens.textStrong,
              ),
            ),
            Text(
              span.op,
              style: AppTheme.mono(size: 11, color: Tokens.textMuted),
            ),
            const Gap(12),
            const Divider(),
            const Gap(12),

            // Timing metrics
            _infoRow('Servis', span.serviceName.isEmpty ? 'default' : span.serviceName),
            _infoRow('Süre', _formatDuration(span.durationMs)),
            _infoRow('Başlangıç Ötelemesi', '+${_formatDuration(span.startOffsetMs)}'),
            _infoRow('Başlangıç', context.fmt.dateTime(span.startTime)),
            _infoRow('Span ID', span.spanId, mono: true, copyable: true),
            if (span.parentSpanId.isNotEmpty)
              _infoRow('Parent Span ID', span.parentSpanId, mono: true, copyable: true),

            // N+1 Alert badge
            if (span.isSuspectNPlusOne) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Tokens.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Tokens.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.triangleAlert, size: 16, color: Tokens.warning),
                    Gap(8),
                    Expanded(
                      child: Text(
                        'Bu span döngü içinde çalışan N+1 sorgusu olarak tespit edildi.',
                        style: TextStyle(fontSize: 11, color: Tokens.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // SQL Statement Section
            if (sql != null && sql.toString().isNotEmpty) ...[
              const Gap(16),
              Text(
                context.l10n.traceSqlStatement,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Tokens.textStrong),
              ),
              const Gap(6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Tokens.border),
                ),
                child: Stack(
                  children: [
                    SelectableText(
                      sql.toString(),
                      style: AppTheme.mono(size: 11, color: const Color(0xFFE2E8F0)),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GhostButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: sql.toString()));
                          showToast(
                            context: context,
                            builder: (c, overlay) => SurfaceCard(
                              child: Text(context.l10n.commonCopied),
                            ),
                          );
                        },
                        child: const Icon(LucideIcons.copy, size: 12, color: Color(0xB3FFFFFF)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Attributes / Metadata
            if (span.data.isNotEmpty) ...[
              const Gap(16),
              Text(
                context.l10n.traceAttributes,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Tokens.textStrong),
              ),
              const Gap(6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Tokens.border),
                ),
                child: Column(
                  children: [
                    for (final entry in span.data.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Tokens.border)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                entry.key,
                                style: AppTheme.mono(size: 10, color: Tokens.textDim),
                              ),
                            ),
                            const Gap(6),
                            Expanded(
                              child: SelectableText(
                                '${entry.value}',
                                style: AppTheme.mono(size: 10, color: Tokens.textStrong),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool mono = false, bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: mono
                        ? AppTheme.mono(size: 11, color: Tokens.textStrong)
                        : const TextStyle(fontSize: 11, color: Tokens.textStrong),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyable) ...[
                  const Gap(4),
                  GhostButton(
                    size: ButtonSize.small,
                    density: ButtonDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
