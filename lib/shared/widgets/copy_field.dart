// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import 'app_dialog.dart';

/// A single copyable line (API key, address).
class CopyField extends StatelessWidget {
  const CopyField({super.key, required this.value, this.label});

  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (label != null) ...[
        SizedBox(
          width: 90,
          child: Text(
            label!,
            style: const TextStyle(fontSize: 12, color: Tokens.textDim),
          ),
        ),
        const Gap(8),
      ],
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Tokens.surface,
            border: Border.all(color: Tokens.border),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: SelectableText(value, style: AppTheme.mono(size: 12)),
        ),
      ),
      const Gap(6),
      IconButton.ghost(
        size: ButtonSize.small,
        icon: const Icon(LucideIcons.copy, size: 14),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          toast(context, context.l10n.commonCopied);
        },
      ),
    ],
  );
}
