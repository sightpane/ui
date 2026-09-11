// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
  });

  final String label, value;
  final String? note;
  final Color valueColor;

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
        Text(
          value,
          style: AppTheme.mono(
            size: 22,
            weight: FontWeight.w600,
            color: valueColor,
          ),
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
