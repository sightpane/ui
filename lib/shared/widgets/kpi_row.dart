// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

/// KPIs side by side; stacked on a narrow screen.
class KpiRow extends StatelessWidget {
  const KpiRow(this.tiles, {super.key});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < Tokens.mobileBreakpoint
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in tiles) ...[t, const Gap(8)],
            ],
          )
        : Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                Expanded(child: tiles[i]),
                if (i < tiles.length - 1) const Gap(10),
              ],
            ],
          ),
  );
}
