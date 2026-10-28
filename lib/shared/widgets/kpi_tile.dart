// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart' show listEquals;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.valueColor = Tokens.textStrong,
    this.trend,
    this.trendColor = Tokens.accent,
  });

  final String label, value;
  final String? note;
  final Color valueColor;

  /// Values in time order, drawn as a sparkline beside [value].
  final List<num>? trend;
  final Color trendColor;

  @override
  Widget build(BuildContext context) => Card(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
    filled: true,
    fillColor: Tokens.panel,
    borderColor: Tokens.border,
    borderRadius: BorderRadius.circular(Tokens.radius),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Tokens.textDim),
        ),
        const Gap(4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTheme.mono(
                  size: 22,
                  weight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ),
            if (trend != null && trend!.length > 1)
              Sparkline(values: trend!, color: trendColor),
          ],
        ),
        if (note != null)
          Text(
            note!,
            style: const TextStyle(fontSize: 11, color: Tokens.textDim),
          ),
      ],
    ),
  );
}

/// A thin trend line, highest value at the top; a flat series is a flat line.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color = Tokens.accent,
    this.width = 88,
    this.height = 28,
  });

  final List<num> values;
  final Color color;
  final double width, height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(painter: _SparklinePainter(values, color)),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values, this.color);
  final List<num> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce((a, b) => a < b ? a : b).toDouble();
    final hi = values.reduce((a, b) => a > b ? a : b).toDouble();
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - 2 - (values[i] - lo) / span * (size.height - 4);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color || !listEquals(old.values, values);
}
