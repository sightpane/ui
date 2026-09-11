// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/format.dart';

class QuickFilterBar extends StatelessWidget {
  const QuickFilterBar({
    super.key,
    required this.chips,
    this.onClear,
    this.showClear = false,
  });

  final List<Widget> chips;
  final VoidCallback? onClear;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Tokens.surface,
        border: Border.all(color: Tokens.border),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.filter, size: 13, color: Tokens.brand),
              const Gap(6),
              Text(
                l10n.searchFilterQuick,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Tokens.textDim,
                ),
              ),
            ],
          ),
          Container(
            height: 16,
            width: 1,
            color: Tokens.border,
            margin: const EdgeInsets.symmetric(horizontal: 2),
          ),
          ...chips,
          if (showClear && onClear != null) ...[
            const SizedBox(width: 4),
            GhostButton(
              size: ButtonSize.xSmall,
              density: ButtonDensity.compact,
              leading: const Icon(LucideIcons.x, size: 12, color: Tokens.danger),
              onPressed: onClear,
              child: Text(
                l10n.searchClear,
                style: const TextStyle(fontSize: 11.5, color: Tokens.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
