// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

/// Daily bars with a second series hanging below the baseline on its own
/// scale — errors are a few percent of sessions and would vanish on a shared
/// axis. One tooltip per day carries both numbers.
class DailyChart extends StatelessWidget {
  const DailyChart({
    super.key,
    required this.values,
    required this.lower,
    required this.labels,
    required this.tooltip,
    this.color = Tokens.accent,
    this.lowerColor = Tokens.danger,
    this.height = 170,
    this.lowerHeight = 40,
  });

  final List<int> values, lower;
  final List<String> labels;
  final String Function(int index) tooltip;
  final Color color, lowerColor;
  final double height, lowerHeight;

  @override
  Widget build(BuildContext context) {
    int maxOf(List<int> v) => v.fold<int>(1, (m, x) => x > m ? x : m);
    final top = maxOf(values), bottom = maxOf(lower);
    final n = values.length;
    final gap = n > 30 ? 1.0 : 3.0;
    final every = n <= 14 ? 1 : (n <= 31 ? 3 : 10);
    Widget bar(double h, Color c, BorderRadius r) => Container(
      height: h,
      decoration: BoxDecoration(color: c, borderRadius: r),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height + lowerHeight + 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: Tooltip(
                    tooltip: (_) => TooltipContainer(child: Text(tooltip(i))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: gap / 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: height,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: bar(
                                values[i] == 0 ? 2 : height * values[i] / top,
                                values[i] == 0 ? Tokens.chip : color,
                                const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          Container(height: 1, color: Tokens.border),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.topCenter,
                            child: bar(
                              lower[i] == 0
                                  ? 2
                                  : lowerHeight * lower[i] / bottom,
                              lower[i] == 0 ? Tokens.chip : lowerColor,
                              const BorderRadius.vertical(
                                bottom: Radius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: Text(
                  (n - 1 - i) % every == 0 ? labels[i] : '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: const TextStyle(fontSize: 10, color: Tokens.textMuted),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
