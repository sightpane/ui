// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

class QuickFilterChip extends StatefulWidget {
  const QuickFilterChip({
    super.key,
    required this.token,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String token;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<QuickFilterChip> createState() => _QuickFilterChipState();
}

class _QuickFilterChipState extends State<QuickFilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected;
    final bg = isSelected
        ? Tokens.brand.withValues(alpha: 0.16)
        : (_hovered ? Tokens.raised : Tokens.panel);
    final borderColor = isSelected
        ? Tokens.brand.withValues(alpha: 0.55)
        : (_hovered ? Tokens.brand.withValues(alpha: 0.3) : Tokens.border);
    final fg = isSelected ? Tokens.brand : (_hovered ? Tokens.textStrong : Tokens.text);
    final iconColor = isSelected ? Tokens.brand : (_hovered ? Tokens.textMuted : Tokens.textDim);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 12, color: iconColor),
                const Gap(6),
              ],
              Text(
                widget.token,
                style: AppTheme.mono(
                  size: 11.5,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
              if (isSelected) ...[
                const Gap(5),
                const Icon(
                  LucideIcons.check,
                  size: 11,
                  color: Tokens.brand,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
