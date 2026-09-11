// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

void toast(BuildContext context, String title, {String? subtitle}) => showToast(
  context: context,
  builder: (context, overlay) => SurfaceCard(
    child: Basic(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    ),
  ),
);

Future<T?> showAppDialog<T>(BuildContext context, Widget dialog) =>
    showOverlay<T>(
      context,
      const DialogConfiguration(),
      builder: (_) => dialog,
    ).future;
