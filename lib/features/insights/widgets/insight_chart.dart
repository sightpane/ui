// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../shared/widgets/data_table.dart';

const List<Color> insightPalette = [
  Tokens.accent,
  Tokens.info,
  Tokens.ok,
  Tokens.danger,
  Color(0xFFA78BFA), // purple
  Color(0xFFFB923C), // orange
  Color(0xFFF472B6), // pink
  Color(0xFF2DD4BF), // teal
];

class InsightChart extends StatefulWidget {
  const InsightChart({
    super.key,
    required this.chartType,
    required this.result,
    this.height = 240,
    this.compact = false,
  });

  final String chartType; // line, bar, area, number, donut, table
  final InsightQueryResult result;
  final double height;
  final bool compact;

  @override
  State<InsightChart> createState() => _InsightChartState();
}

class _InsightChartState extends State<InsightChart> {
  Offset? _hoverPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.result.series.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            context.l10n.insightEmptyResults,
            style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
          ),
        ),
      );
    }

    return switch (widget.chartType) {
      'bar' => _buildBarChart(context),
      'area' => _buildAreaChart(context),
      'number' => _buildNumberCard(context),
      'donut' => _buildDonutChart(context),
      'table' => _buildTableView(context),
      _ => _buildLineChart(context),
    };
  }

  Widget _buildLineChart(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.compact && widget.result.series.length > 1)
            _buildLegend(),
          Expanded(
            child: MouseRegion(
              onHover: (e) => setState(() => _hoverPosition = e.localPosition),
              onExit: (_) => setState(() => _hoverPosition = null),
              child: CustomPaint(
                painter: _TimeSeriesPainter(
                  series: widget.result.series,
                  isArea: false,
                  hoverOffset: _hoverPosition,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.compact && widget.result.series.length > 1)
            _buildLegend(),
          Expanded(
            child: MouseRegion(
              onHover: (e) => setState(() => _hoverPosition = e.localPosition),
              onExit: (_) => setState(() => _hoverPosition = null),
              child: CustomPaint(
                painter: _TimeSeriesPainter(
                  series: widget.result.series,
                  isArea: true,
                  hoverOffset: _hoverPosition,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final seriesList = widget.result.series;
    final allTimes = <String>{};
    for (final s in seriesList) {
      for (final p in s.data) {
        allTimes.add(p.time);
      }
    }
    final sortedTimes = allTimes.toList()..sort();

    if (sortedTimes.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            context.l10n.insightEmptyResults,
            style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
          ),
        ),
      );
    }

    double maxVal = 1;
    for (final s in seriesList) {
      for (final p in s.data) {
        if (p.value > maxVal) maxVal = p.value;
      }
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.compact && seriesList.length > 1) _buildLegend(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int tIdx = 0; tIdx < sortedTimes.length; tIdx++) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (int sIdx = 0; sIdx < seriesList.length; sIdx++) ...[
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (ctx, constraints) {
                                        final s = seriesList[sIdx];
                                        final dp = s.data.firstWhere(
                                          (d) => d.time == sortedTimes[tIdx],
                                          orElse: () => InsightDataPoint(time: sortedTimes[tIdx], value: 0),
                                        );
                                        final barH = (dp.value / maxVal) * constraints.maxHeight;
                                        final color = insightPalette[sIdx % insightPalette.length];
                                        final label = s.label.isNotEmpty ? s.label : 'Event';

                                        return Tooltip(
                                          tooltip: (_) => TooltipContainer(
                                            child: Text(
                                              '${sortedTimes[tIdx]}\n$label: ${context.fmt.integer(dp.value.round())}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: math.max(2, barH),
                                              decoration: BoxDecoration(
                                                color: dp.value > 0
                                                    ? color
                                                    : Tokens.chip.withValues(alpha: 0.3),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (sIdx < seriesList.length - 1) const Gap(1),
                                ],
                              ],
                            ),
                          ),
                          const Gap(6),
                          if (!widget.compact)
                            Text(
                              tIdx % (sortedTimes.length > 10 ? 4 : 1) == 0
                                  ? _shortTime(sortedTimes[tIdx])
                                  : '',
                              style: const TextStyle(fontSize: 10, color: Tokens.textFaint),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(BuildContext context) {
    final s = widget.result.series.first;
    final total = s.aggregatedValue;
    final sparklinePoints = s.data.map((d) => d.value).toList();

    return SizedBox(
      height: widget.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.fmt.integer(total.round()),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Tokens.textStrong,
                letterSpacing: -1,
              ),
            ),
            const Gap(4),
            Text(
              s.label.isNotEmpty ? s.label : context.l10n.mathCount,
              style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
            ),
            if (sparklinePoints.length > 1) ...[
              const Gap(16),
              SizedBox(
                height: 40,
                width: 140,
                child: CustomPaint(
                  painter: _SparklinePainter(points: sparklinePoints),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart(BuildContext context) {
    final seriesList = widget.result.series;
    final double total = seriesList.fold(0.0, (sum, s) => sum + s.aggregatedValue);

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CustomPaint(
              painter: _DonutChartPainter(
                series: seriesList,
                total: total > 0 ? total : 1,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.fmt.integer(total.round()),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Tokens.textStrong,
                      ),
                    ),
                    Text(
                      context.l10n.commonAll,
                      style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            flex: 2,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: seriesList.length,
              separatorBuilder: (_, _) => const Gap(6),
              itemBuilder: (ctx, i) {
                final s = seriesList[i];
                final color = insightPalette[i % insightPalette.length];
                final pct = total > 0 ? (s.aggregatedValue / total * 100) : 0.0;
                final label = s.label.isNotEmpty ? s.label : 'Segment ${i + 1}';

                return Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 12, color: Tokens.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Tokens.textMuted,
                      ),
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

  Widget _buildTableView(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        child: DataTable<InsightSeries>(
          columns: [
            (context.l10n.insightName, 3, false),
            (context.l10n.insightInterval, 2, false),
            (context.l10n.mathSum, 2, true),
          ],
          rows: widget.result.series,
          cells: (s) {
            final i = widget.result.series.indexOf(s);
            final color = insightPalette[i % insightPalette.length];
            return [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      s.label.isNotEmpty ? s.label : 'Series ${i + 1}',
                      style: const TextStyle(fontSize: 13, color: Tokens.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '${s.data.length} points',
                style: const TextStyle(fontSize: 12, color: Tokens.textDim),
              ),
              Text(
                context.fmt.integer(s.aggregatedValue.round()),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong),
              ),
            ];
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (int i = 0; i < widget.result.series.length; i++) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: insightPalette[i % insightPalette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(6),
                Text(
                  widget.result.series[i].label.isNotEmpty
                      ? widget.result.series[i].label
                      : 'Series ${i + 1}',
                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _shortTime(String t) {
    if (t.contains('T')) {
      return t.split('T').first;
    }
    return t;
  }
}

class _TimeSeriesPainter extends CustomPainter {
  const _TimeSeriesPainter({
    required this.series,
    required this.isArea,
    this.hoverOffset,
  });

  final List<InsightSeries> series;
  final bool isArea;
  final Offset? hoverOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final allPoints = <InsightDataPoint>[];
    for (final s in series) {
      allPoints.addAll(s.data);
    }
    if (allPoints.isEmpty) return;

    double maxVal = 1;
    for (final p in allPoints) {
      if (p.value > maxVal) maxVal = p.value;
    }
    // Add 10% head room
    maxVal *= 1.1;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Tokens.hairline
      ..strokeWidth = 1;
    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw lines & areas for each series
    for (int sIdx = 0; sIdx < series.length; sIdx++) {
      final s = series[sIdx];
      if (s.data.length < 2) continue;

      final color = insightPalette[sIdx % insightPalette.length];
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final points = <Offset>[];
      final stepX = size.width / (s.data.length - 1);

      for (int i = 0; i < s.data.length; i++) {
        final x = i * stepX;
        final y = size.height - (s.data[i].value / maxVal) * size.height;
        points.add(Offset(x, y));
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      if (isArea) {
        final areaPath = Path.from(path);
        areaPath.lineTo(points.last.dx, size.height);
        areaPath.lineTo(points.first.dx, size.height);
        areaPath.close();

        final areaPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;
        canvas.drawPath(areaPath, areaPaint);
      }

      canvas.drawPath(path, linePaint);

      // Draw point markers
      final markerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (final pt in points) {
        canvas.drawCircle(pt, 2.5, markerPaint);
      }
    }

    // Draw hover vertical line if mouse is over
    if (hoverOffset != null && hoverOffset!.dx >= 0 && hoverOffset!.dx <= size.width) {
      final crosshairPaint = Paint()
        ..color = Tokens.border
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(hoverOffset!.dx, 0),
        Offset(hoverOffset!.dx, size.height),
        crosshairPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimeSeriesPainter oldDelegate) => true;
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.points});
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    double min = points.first;
    double max = points.first;
    for (final v in points) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final range = max - min == 0 ? 1.0 : (max - min);

    final path = Path();
    final stepX = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - min) / range) * (size.height - 8) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final isUp = points.last >= points.first;
    final strokePaint = Paint()
      ..color = isUp ? Tokens.ok : Tokens.danger
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.series, required this.total});
  final List<InsightSeries> series;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    if (radius <= 0) return;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < series.length; i++) {
      final sweepAngle = (series[i].aggregatedValue / total) * 2 * math.pi;
      final color = insightPalette[i % insightPalette.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
