// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import 'panel_message.dart';

/// A plain table: headers + rows; a row can be tapped.
class DataTable<T> extends StatelessWidget {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.cells,
    this.onTap,
    this.emptyText,
  });
  final List<(String, int, bool)> columns; // header, flex, right-aligned
  final List<T> rows;
  final List<Widget> Function(T row) cells;
  final void Function(T)? onTap;

  /// The text shown when there are no rows; left out, "Kayıt yok." comes from
  /// the translations (the default cannot be a `const` string, it depends on the
  /// language).
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return PanelMessage(emptyText ?? context.l10n.commonNoRecords);
    }
    Widget line(List<Widget> cells, {bool header = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].$2,
              child: Align(
                alignment: columns[i].$3
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cells[i],
              ),
            ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tokens.hairline)),
          ),
          child: line([
            for (final c in columns)
              Text(
                context.fmt.upper(c.$1),
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: Tokens.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ]),
        ),
        for (final r in rows)
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Tokens.hairline)),
            ),
            child: onTap == null
                ? line(cells(r))
                : GhostButton(
                    density: ButtonDensity.compact,
                    alignment: Alignment.centerLeft,
                    onPressed: () => onTap!(r),
                    child: line(cells(r)),
                  ),
          ),
      ],
    );
  }
}
