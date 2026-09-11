// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';

class BreadcrumbItem {
  const BreadcrumbItem({
    required this.label,
    this.path,
  });

  final String label;
  final String? path;
}

/// A unified breadcrumb navigation component based on shadcn_flutter's Breadcrumb.
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({
    super.key,
    required this.items,
  });

  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Breadcrumb(
      separator: Breadcrumb.arrowSeparator,
      children: [
        for (var i = 0; i < items.length; i++)
          if (i == items.length - 1 || items[i].path == null)
            Text(
              items[i].label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Tokens.textStrong,
              ),
              overflow: TextOverflow.ellipsis,
            )
          else
            GhostButton(
              density: ButtonDensity.compact,
              size: ButtonSize.small,
              onPressed: () => context.go(items[i].path!),
              child: Text(
                items[i].label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Tokens.textDim,
                ),
              ),
            ),
      ],
    );
  }
}
