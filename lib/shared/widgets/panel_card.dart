// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    padding: EdgeInsets.zero,
    filled: true,
    fillColor: Tokens.panel,
    borderColor: Tokens.border,
    borderRadius: BorderRadius.circular(Tokens.radius),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tokens.border)),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Tokens.textStrong,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(10),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              ?action,
            ],
          ),
        ),
        Flexible(child: child),
      ],
    ),
  );
}
