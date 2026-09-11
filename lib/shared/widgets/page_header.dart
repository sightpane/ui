// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.breadcrumb,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? breadcrumb;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (breadcrumb != null) ...[
        breadcrumb!,
        const Gap(8),
      ],
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Tokens.textStrong,
            ),
          ),
          if (subtitle != null) ...[
            const Gap(10),
            Flexible(
              child: Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: Tokens.textDim),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          for (final a in actions) ...[a, const Gap(8)],
        ],
      ),
    ],
  );
}
