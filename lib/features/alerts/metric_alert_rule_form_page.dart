// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets.dart';

class MetricAlertRuleFormPage extends ConsumerStatefulWidget {
  const MetricAlertRuleFormPage({
    super.key,
    required this.projectId,
    this.ruleId,
  });

  final int projectId;
  final int? ruleId;

  @override
  ConsumerState<MetricAlertRuleFormPage> createState() => _MetricAlertRuleFormPageState();
}

class _MetricAlertRuleFormPageState extends ConsumerState<MetricAlertRuleFormPage> {
  final _nameCtrl = TextEditingController();
  final _critCtrl = TextEditingController(text: '10');
  final _warnCtrl = TextEditingController();
  final _filterCtrl = TextEditingController();

  String _metricType = 'error_count';
  String _compOp = 'gt';
  int _windowMinutes = 5;
  bool _isActive = true;
  List<int> _channelIds = [];
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.disposeexhaustive();
    _critCtrl.disposeexhaustive();
    _warnCtrl.disposeexhaustive();
    _filterCtrl.disposeexhaustive();
    super.dispose();
  }

  void _initFromRule(MetricAlertRule r) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = r.name;
    _metricType = r.metricType;
    _targetFilter = r.targetFilter;
    _filterCtrl.text = r.targetFilter;
    _compOp = r.comparisonOperator;
    _critCtrl.text = '${r.criticalThreshold}';
    _warnCtrl.text = r.warningThreshold == null ? '' : '${r.warningThreshold}';
    _windowMinutes = r.windowMinutes;
    _isActive = r.isActive;
    _channelIds = List.from(r.channelIds);
  }

  String _targetFilter = '';

  Future<void> _save() async {
    final l = L.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Text(l.alertsRuleName, style: const TextStyle(color: Tokens.danger)),
        ),
      );
      return;
    }

    final crit = double.tryParse(_critCtrl.text.trim());
    if (crit == null) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Text(l.alertsCriticalThreshold, style: const TextStyle(color: Tokens.danger)),
        ),
      );
      return;
    }

    final warn = _warnCtrl.text.trim().isEmpty ? null : double.tryParse(_warnCtrl.text.trim());

    setState(() => _saving = true);
    try {
      final api = ref.read(apiProvider);
      if (widget.ruleId == null) {
        await api.createMetricAlertRule(
          widget.projectId,
          name: name,
          metricType: _metricType,
          targetFilter: _filterCtrl.text.trim(),
          comparisonOperator: _compOp,
          criticalThreshold: crit,
          warningThreshold: warn,
          windowMinutes: _windowMinutes,
          channelIds: _channelIds,
          isActive: _isActive,
        );
      } else {
        await api.updateMetricAlertRule(
          widget.projectId,
          widget.ruleId!,
          name: name,
          metricType: _metricType,
          targetFilter: _filterCtrl.text.trim(),
          comparisonOperator: _compOp,
          criticalThreshold: crit,
          warningThreshold: warn,
          windowMinutes: _windowMinutes,
          channelIds: _channelIds,
          isActive: _isActive,
        );
      }
      ref.invalidate(metricAlertRulesProvider(widget.projectId));
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.circleCheck, size: 16, color: Tokens.ok),
                const SizedBox(width: 8),
                Text(l.alertsRuleSaved),
              ],
            ),
          ),
        );
        context.go('/projects/${widget.projectId}/alerts');
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Text('Error: $e', style: const TextStyle(color: Tokens.danger)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final isEditing = widget.ruleId != null;

    if (isEditing && !_initialized) {
      final ruleAsync = ref.watch(metricAlertRuleProvider((
        projectId: widget.projectId,
        ruleId: widget.ruleId!,
      )));
      return ruleAsync.when(
        data: (rule) {
          _initFromRule(rule);
          return _buildContent(context, l, isEditing);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Tokens.danger))),
      );
    }

    return _buildContent(context, l, isEditing);
  }

  Widget _buildContent(BuildContext context, L l, bool isEditing) {
    final previewAsync = ref.watch(metricAlertPreviewProvider((
      projectId: widget.projectId,
      metricType: _metricType,
      targetFilter: _targetFilter.isEmpty ? null : _targetFilter,
      windowMinutes: _windowMinutes,
      days: 7,
    )));

    final critVal = double.tryParse(_critCtrl.text.trim()) ?? 10.0;
    final warnVal = double.tryParse(_warnCtrl.text.trim());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBreadcrumb(
            items: [
              BreadcrumbItem(label: l.navAlerts, path: '/projects/${widget.projectId}/alerts'),
              BreadcrumbItem(label: isEditing ? l.alertsEditRule : l.alertsNewRule),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? l.alertsEditRule : l.alertsNewRule,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              PrimaryButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.alertsSaveRule),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Visual Preview Chart
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.chartLine, size: 18, color: Tokens.brand),
                      const SizedBox(width: 8),
                      Text(
                        l.alertsPreviewChart,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.alertsPreviewSub,
                    style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                  ),
                  const SizedBox(height: 16),
                  previewAsync.when(
                    data: (points) => _MetricPreviewChart(
                      points: points,
                      criticalThreshold: critVal,
                      warningThreshold: warnVal,
                      comparisonOperator: _compOp,
                    ),
                    loading: () => const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => SizedBox(
                      height: 150,
                      child: Center(
                        child: Text('Could not load preview: $e', style: const TextStyle(fontSize: 12, color: Tokens.textMuted)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Form fields
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rule Name
                  Text(l.alertsRuleName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    placeholder: const Text('e.g. High Error Rate in Checkout'),
                  ),
                  const SizedBox(height: 20),

                  // Metric Type
                  Text(l.alertsMetricType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetricTypeOption('error_count', l.alertsMetricErrorCount, LucideIcons.bug),
                      _buildMetricTypeOption('error_rate', l.alertsMetricErrorRate, LucideIcons.percent),
                      _buildMetricTypeOption('transaction_duration_p95', l.alertsMetricP95Duration, LucideIcons.timer),
                      _buildMetricTypeOption('unhandled_crash_count', l.alertsMetricCrashCount, LucideIcons.circleAlert),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Target Filter
                  Text(l.alertsTargetFilter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _filterCtrl,
                    placeholder: const Text('route:/checkout or platform:android (leave empty for all)'),
                    onChanged: (val) {
                      setState(() => _targetFilter = val.trim());
                    },
                  ),
                  const SizedBox(height: 20),

                  // Comparison Operator
                  Text(l.alertsComparison, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildOperatorOption('gt', l.alertsOperatorGt),
                      _buildOperatorOption('gte', l.alertsOperatorGte),
                      _buildOperatorOption('lt', l.alertsOperatorLt),
                      _buildOperatorOption('spike_multiplier', l.alertsOperatorSpike),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Thresholds row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _compOp == 'spike_multiplier' ? 'Katsayı Çarpanı (x Kat)' : l.alertsCriticalThreshold,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _critCtrl,
                              placeholder: Text(_compOp == 'spike_multiplier' ? '3.0' : '10'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_compOp != 'spike_multiplier')
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.alertsWarningThreshold, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _warnCtrl,
                                placeholder: const Text('e.g. 5 (optional)'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Evaluation Window
                  Text(l.alertsWindowMinutes, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in [1, 5, 10, 15, 30, 60])
                        _buildWindowOption(m),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Active Switch
                  Row(
                    children: [
                      Switch(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Kuralı Etkinleştir (Active)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTypeOption(String type, String label, IconData icon) {
    final isSelected = _metricType == type;
    return OutlineButton(
      onPressed: () => setState(() => _metricType = type),
      density: ButtonDensity.compact,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Tokens.brand.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Tokens.brand : Tokens.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Tokens.brand : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorOption(String op, String label) {
    final isSelected = _compOp == op;
    return OutlineButton(
      onPressed: () => setState(() => _compOp = op),
      density: ButtonDensity.compact,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Tokens.brand.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Tokens.brand : null,
          ),
        ),
      ),
    );
  }

  Widget _buildWindowOption(int minutes) {
    final isSelected = _windowMinutes == minutes;
    return OutlineButton(
      onPressed: () => setState(() => _windowMinutes = minutes),
      density: ButtonDensity.compact,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Tokens.brand.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          '$minutes dk',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Tokens.brand : null,
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeexhaustive() {
    dispose();
  }
}

/// Visual Preview Chart showing historical metric points with superimposed threshold lines
class _MetricPreviewChart extends StatelessWidget {
  const _MetricPreviewChart({
    required this.points,
    required this.criticalThreshold,
    this.warningThreshold,
    required this.comparisonOperator,
  });

  final List<MetricHistoryPoint> points;
  final double criticalThreshold;
  final double? warningThreshold;
  final String comparisonOperator;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Tokens.chip,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Henüz geçmiş metrik verisi bulunmuyor.',
          style: TextStyle(fontSize: 12, color: Tokens.textMuted),
        ),
      );
    }

    // Determine max value for chart scaling
    double maxVal = criticalThreshold * 1.25;
    if (warningThreshold != null && warningThreshold! * 1.25 > maxVal) {
      maxVal = warningThreshold! * 1.25;
    }
    for (final p in points) {
      if (p.value > maxVal) maxVal = p.value;
    }
    if (maxVal <= 0) maxVal = 10.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Tokens.chip,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = constraints.maxHeight;
          final critTop = (1.0 - (criticalThreshold / maxVal).clamp(0.0, 1.0)) * chartHeight;
          final warnTop = warningThreshold != null && warningThreshold! > 0
              ? (1.0 - (warningThreshold! / maxVal).clamp(0.0, 1.0)) * chartHeight
              : null;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Bars
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < points.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Tooltip(
                            tooltip: (_) => TooltipContainer(
                              child: Text(
                                '${points[i].timestamp.hour.toString().padLeft(2, '0')}:${points[i].timestamp.minute.toString().padLeft(2, '0')} - Değer: ${points[i].value.toStringAsFixed(1)}',
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: math.max((points[i].value / maxVal) * chartHeight, 2.0),
                                decoration: BoxDecoration(
                                  color: points[i].value >= criticalThreshold ? Tokens.danger : Tokens.accent,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Critical threshold line
              Positioned(
                top: critTop,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: Tokens.danger,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Tokens.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Kritik: ${criticalThreshold.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Warning threshold line (if present)
              if (warnTop != null)
                Positioned(
                  top: warnTop,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.0,
                          color: Tokens.warning,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Tokens.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Uyarı: ${warningThreshold!.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
