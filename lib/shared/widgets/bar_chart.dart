// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

/// A simple bar chart: [values] in day order; the highest value is full height.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = Tokens.accent,
    this.height = 120,
    this.secondary,
    this.secondaryColor = Tokens.danger,
  });
  final List<int> values;
  final List<String> labels;
  final List<int>? secondary;
  final Color color, secondaryColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final max = [
      ...values,
      ...?secondary,
    ].fold<int>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: height + 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      tooltip: (_) => TooltipContainer(
                        child: Text(
                          '${labels[i]}: ${values[i]}${secondary == null ? '' : ' / ${secondary![i]}'}',
                        ),
                      ),
                      child: SizedBox(
                        height: height,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                height: height * values[i] / max,
                                decoration: BoxDecoration(
                                  color: values[i] == 0 ? Tokens.chip : color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            if (secondary != null) ...[
                              const Gap(1),
                              Expanded(
                                child: Container(
                                  height: height * secondary![i] / max,
                                  decoration: BoxDecoration(
                                    color: secondary![i] == 0
                                        ? Tokens.chip
                                        : secondaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      i % (values.length > 14 ? 7 : 2) == 0 ? labels[i] : '',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Tokens.textFaint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
