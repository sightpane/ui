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
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/breadcrumb.dart';
import 'widgets/insight_chart.dart';

class InsightBuilderPage extends ConsumerStatefulWidget {
  const InsightBuilderPage({
    super.key,
    required this.projectId,
    this.insightId,
    this.dashboardId,
  });

  final int projectId;
  final String? insightId;
  final String? dashboardId;

  @override
  ConsumerState<InsightBuilderPage> createState() => _InsightBuilderPageState();
}

class _InsightBuilderPageState extends ConsumerState<InsightBuilderPage> {
  final _nameCtrl = TextEditingController(text: 'New Insight');
  String _chartType = 'line';
  String _dateRange = '14d';
  String _interval = 'day';
  String _breakdown = '';
  final _customBreakdownCtrl = TextEditingController();

  final List<_EventEntry> _events = [
    _EventEntry(nameCtrl: TextEditingController(text: 'purchase'), math: 'count', propCtrl: TextEditingController()),
  ];

  InsightQueryResult? _queryResult;
  bool _runningQuery = false;
  bool _saving = false;
  String? _queryError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initOrRun());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customBreakdownCtrl.dispose();
    for (final e in _events) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _initOrRun() async {
    if (_initialized) return;
    _initialized = true;

    if (widget.insightId != null && widget.insightId!.isNotEmpty) {
      try {
        final api = ref.read(apiProvider);
        final ins = await api.insight(widget.projectId, widget.insightId!);
        _nameCtrl.text = ins.name;
        _chartType = ins.chartType;
        _dateRange = ins.query.dateRange;
        _interval = ins.query.interval;
        _breakdown = ins.query.breakdown;
        if (_breakdown != 'platform' && _breakdown != 'browser' && _breakdown.isNotEmpty) {
          _customBreakdownCtrl.text = _breakdown;
        }

        _events.clear();
        for (final e in ins.query.events) {
          _events.add(
            _EventEntry(
              nameCtrl: TextEditingController(text: e.name),
              math: e.math,
              propCtrl: TextEditingController(text: e.property),
            ),
          );
        }
        if (_events.isEmpty) {
          _events.add(_EventEntry(nameCtrl: TextEditingController(text: 'event'), math: 'count', propCtrl: TextEditingController()));
        }
        setState(() {});
      } catch (e) {
        // ignore
      }
    }

    _runQuery();
  }

  InsightQuery _buildQuery() {
    final events = <InsightEvent>[];
    for (final e in _events) {
      final name = e.nameCtrl.text.trim();
      if (name.isNotEmpty) {
        events.add(InsightEvent(
          name: name,
          math: e.math,
          property: e.propCtrl.text.trim(),
        ));
      }
    }
    if (events.isEmpty) {
      events.add(const InsightEvent(name: 'pageview', math: 'count'));
    }

    String b = _breakdown;
    if (b == 'custom') {
      b = _customBreakdownCtrl.text.trim();
    }

    return InsightQuery(
      dateRange: _dateRange,
      interval: _interval,
      events: events,
      breakdown: b,
    );
  }

  Future<void> _runQuery() async {
    setState(() {
      _runningQuery = true;
      _queryError = null;
    });

    final query = _buildQuery();
    try {
      final api = ref.read(apiProvider);
      final res = await api.queryInsight(widget.projectId, query);
      if (mounted) {
        setState(() {
          _queryResult = res;
          _runningQuery = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _queryError = e.toString();
          _runningQuery = false;
        });
      }
    }
  }

  Future<void> _saveInsight() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    final query = _buildQuery();
    final api = ref.read(apiProvider);

    try {
      if (widget.insightId != null && widget.insightId!.isNotEmpty) {
        await api.updateInsight(
          widget.projectId,
          widget.insightId!,
          dashboardId: widget.dashboardId,
          name: name,
          chartType: _chartType,
          query: query,
        );
      } else {
        final created = await api.createInsight(
          widget.projectId,
          dashboardId: widget.dashboardId,
          name: name,
          chartType: _chartType,
          query: query,
        );
        // If a dashboardId was provided, automatically append this new insight tile to the dashboard!
        if (widget.dashboardId != null && widget.dashboardId!.isNotEmpty) {
          final dash = await api.dashboard(widget.projectId, widget.dashboardId!);
          final layout = List<DashboardTile>.from(dash.layout);
          layout.add(DashboardTile(
            insightId: created.id,
            col: 0,
            row: layout.length * 4,
            w: 6,
            h: 4,
          ));
          await api.updateDashboard(
            widget.projectId,
            widget.dashboardId!,
            name: dash.name,
            description: dash.description,
            isDefault: dash.isDefault,
            layout: layout,
          );
        }
      }

      ref.invalidate(insightsProvider((projectId: widget.projectId, dashboardId: widget.dashboardId)));
      ref.invalidate(insightsProvider((projectId: widget.projectId, dashboardId: null)));
      if (widget.dashboardId != null) {
        ref.invalidate(dashboardDetailProvider((projectId: widget.projectId, dashboardId: widget.dashboardId!)));
      }

      if (mounted) {
        if (widget.dashboardId != null && widget.dashboardId!.isNotEmpty) {
          context.go('/projects/${widget.projectId}/dashboards/${widget.dashboardId}');
        } else {
          context.go('/projects/${widget.projectId}/dashboards');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _queryError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBreadcrumb(
                        items: [
                          BreadcrumbItem(
                            label: context.l10n.dashboardsTitle,
                            path: '/projects/${widget.projectId}/dashboards',
                          ),
                          BreadcrumbItem(label: context.l10n.insightBuilderTitle),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        context.l10n.insightBuilderTitle,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Tokens.textStrong),
                      ),
                      const Gap(4),
                      Text(
                        context.l10n.insightBuilderSubtitle,
                        style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  leading: _saving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator())
                      : const Icon(LucideIcons.save, size: 15),
                  onPressed: _saving ? null : _saveInsight,
                  child: Text(context.l10n.insightSave),
                ),
              ],
            ),
            const Gap(24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;

                final queryConfigPanel = Card(
                  filled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Insight Name
                        Text(context.l10n.insightName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                        const Gap(6),
                        TextField(
                          controller: _nameCtrl,
                          placeholder: Text(context.l10n.insightNameHint),
                        ),
                        const Gap(20),

                        // Chart Type
                        Text(context.l10n.insightChartType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                        const Gap(8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChartTypeOption('line', context.l10n.chartTypeLine, LucideIcons.chartLine),
                            _buildChartTypeOption('bar', context.l10n.chartTypeBar, LucideIcons.chartBar),
                            _buildChartTypeOption('area', context.l10n.chartTypeArea, LucideIcons.activity),
                            _buildChartTypeOption('number', context.l10n.chartTypeNumber, LucideIcons.hash),
                            _buildChartTypeOption('donut', context.l10n.chartTypeDonut, LucideIcons.chartPie),
                            _buildChartTypeOption('table', context.l10n.chartTypeTable, LucideIcons.table),
                          ],
                        ),
                        const Gap(20),

                        // Date Range & Interval
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l10n.insightDateRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textMuted)),
                                  const Gap(6),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      _buildRangeOption('24h'),
                                      _buildRangeOption('7d'),
                                      _buildRangeOption('14d'),
                                      _buildRangeOption('30d'),
                                      _buildRangeOption('90d'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.l10n.insightInterval, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textMuted)),
                                  const Gap(6),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      _buildIntervalOption('hour', context.l10n.intervalHour),
                                      _buildIntervalOption('day', context.l10n.intervalDay),
                                      _buildIntervalOption('week', context.l10n.intervalWeek),
                                      _buildIntervalOption('month', context.l10n.intervalMonth),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),

                        // Events Section
                        Row(
                          children: [
                            Text(context.l10n.insightEvents, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                            const Spacer(),
                            OutlineButton(
                              density: ButtonDensity.compact,
                              leading: const Icon(LucideIcons.plus, size: 13),
                              onPressed: () {
                                setState(() {
                                  _events.add(_EventEntry(
                                    nameCtrl: TextEditingController(text: ''),
                                    math: 'count',
                                    propCtrl: TextEditingController(),
                                  ));
                                });
                              },
                              child: Text(context.l10n.insightEventAdd),
                            ),
                          ],
                        ),
                        const Gap(10),
                        for (int i = 0; i < _events.length; i++) ...[
                          _buildEventRow(i),
                          if (i < _events.length - 1) const Gap(10),
                        ],
                        const Gap(20),

                        // Breakdown Section
                        Text(context.l10n.insightBreakdown, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                        const Gap(8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBreakdownOption('', context.l10n.insightBreakdownNone),
                            _buildBreakdownOption('platform', context.l10n.insightBreakdownPlatform),
                            _buildBreakdownOption('browser', context.l10n.insightBreakdownBrowser),
                            _buildBreakdownOption('custom', context.l10n.insightBreakdownCustom),
                          ],
                        ),
                        if (_breakdown == 'custom') ...[
                          const Gap(8),
                          TextField(
                            controller: _customBreakdownCtrl,
                            placeholder: const Text('e.g. device.os or properties.category'),
                          ),
                        ],
                        const Gap(24),

                        // Run Query Button
                        PrimaryButton(
                          leading: _runningQuery
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator())
                              : const Icon(LucideIcons.play, size: 15),
                          onPressed: _runningQuery ? null : _runQuery,
                          child: Text(context.l10n.insightRunQuery),
                        ),
                      ],
                    ),
                  ),
                );

                final previewPanel = Card(
                  filled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.eye, size: 18, color: Tokens.brand),
                            const Gap(8),
                            Text(
                              context.l10n.insightPreview,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                            ),
                            const Spacer(),
                            if (_queryResult != null && _queryResult!.cached)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Tokens.ok.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.zap, size: 12, color: Tokens.ok),
                                    const Gap(4),
                                    Text(
                                      context.l10n.insightCached,
                                      style: const TextStyle(fontSize: 11, color: Tokens.ok, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const Gap(16),
                        if (_queryError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Tokens.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _queryError!,
                              style: const TextStyle(color: Tokens.danger, fontSize: 13),
                            ),
                          )
                        else if (_runningQuery)
                          const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_queryResult != null)
                          InsightChart(
                            chartType: _chartType,
                            result: _queryResult!,
                            height: 340,
                          )
                        else
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(
                                context.l10n.insightEmptyResults,
                                style: const TextStyle(color: Tokens.textMuted),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: queryConfigPanel),
                      const Gap(20),
                      Expanded(flex: 6, child: previewPanel),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      queryConfigPanel,
                      const Gap(20),
                      previewPanel,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeOption(String type, String label, IconData icon) {
    final active = _chartType == type;
    if (active) {
      return PrimaryButton(
        density: ButtonDensity.compact,
        leading: Icon(icon, size: 14),
        onPressed: () => setState(() => _chartType = type),
        child: Text(label),
      );
    }
    return OutlineButton(
      density: ButtonDensity.compact,
      leading: Icon(icon, size: 14),
      onPressed: () => setState(() => _chartType = type),
      child: Text(label),
    );
  }

  Widget _buildRangeOption(String r) {
    final active = _dateRange == r;
    if (active) {
      return PrimaryButton(
        density: ButtonDensity.compact,
        onPressed: () => setState(() => _dateRange = r),
        child: Text(r),
      );
    }
    return OutlineButton(
      density: ButtonDensity.compact,
      onPressed: () => setState(() => _dateRange = r),
      child: Text(r),
    );
  }

  Widget _buildIntervalOption(String i, String label) {
    final active = _interval == i;
    if (active) {
      return PrimaryButton(
        density: ButtonDensity.compact,
        onPressed: () => setState(() => _interval = i),
        child: Text(label),
      );
    }
    return OutlineButton(
      density: ButtonDensity.compact,
      onPressed: () => setState(() => _interval = i),
      child: Text(label),
    );
  }

  Widget _buildBreakdownOption(String b, String label) {
    final active = _breakdown == b;
    if (active) {
      return PrimaryButton(
        density: ButtonDensity.compact,
        onPressed: () => setState(() => _breakdown = b),
        child: Text(label),
      );
    }
    return OutlineButton(
      density: ButtonDensity.compact,
      onPressed: () => setState(() => _breakdown = b),
      child: Text(label),
    );
  }

  Widget _buildEventRow(int index) {
    final e = _events[index];
    final needsProp = e.math == 'avg' || e.math == 'sum' || e.math == 'min' || e.math == 'max' || e.math == 'p90';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Tokens.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: e.nameCtrl,
                  placeholder: Text(context.l10n.insightEventNameHint),
                ),
              ),
              const Gap(8),
              Expanded(
                flex: 2,
                child: OutlineButton(
                  density: ButtonDensity.compact,
                  onPressed: () => _showMathPicker(e),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_mathLabel(context, e.math), style: const TextStyle(fontSize: 12)),
                      const Icon(LucideIcons.chevronDown, size: 12),
                    ],
                  ),
                ),
              ),
              if (_events.length > 1) ...[
                const Gap(8),
                IconButton.ghost(
                  density: ButtonDensity.compact,
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                  onPressed: () {
                    setState(() {
                      _events.removeAt(index);
                    });
                  },
                ),
              ],
            ],
          ),
          if (needsProp) ...[
            const Gap(8),
            TextField(
              controller: e.propCtrl,
              placeholder: Text(context.l10n.insightPropertyHint),
            ),
          ],
        ],
      ),
    );
  }

  void _showMathPicker(_EventEntry entry) {
    final options = [
      ('count', context.l10n.mathCount),
      ('unique_users', context.l10n.mathUniqueUsers),
      ('avg', context.l10n.mathAvg),
      ('sum', context.l10n.mathSum),
      ('min', context.l10n.mathMin),
      ('max', context.l10n.mathMax),
      ('p90', context.l10n.mathP90),
    ];

    showAppDialog(
      context,
      Center(
        child: Card(
          filled: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.insightMath, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const Gap(12),
                  for (final opt in options)
                    if (entry.math == opt.$1)
                      PrimaryButton(
                        density: ButtonDensity.compact,
                        onPressed: () {
                          setState(() => entry.math = opt.$1);
                          closeOverlay(context);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(opt.$2),
                        ),
                      )
                    else
                      GhostButton(
                        density: ButtonDensity.compact,
                        onPressed: () {
                          setState(() => entry.math = opt.$1);
                          closeOverlay(context);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(opt.$2),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _mathLabel(BuildContext context, String math) {
    return switch (math) {
      'unique_users' => context.l10n.mathUniqueUsers,
      'avg' => context.l10n.mathAvg,
      'sum' => context.l10n.mathSum,
      'min' => context.l10n.mathMin,
      'max' => context.l10n.mathMax,
      'p90' => context.l10n.mathP90,
      _ => context.l10n.mathCount,
    };
  }
}

class _EventEntry {
  _EventEntry({
    required this.nameCtrl,
    required this.math,
    required this.propCtrl,
  });

  final TextEditingController nameCtrl;
  String math;
  final TextEditingController propCtrl;

  void dispose() {
    nameCtrl.dispose();
    propCtrl.dispose();
  }
}
