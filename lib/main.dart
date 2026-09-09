// sightpane — error tracking, analytics and session replay for Flutter.
// Copyright (C) 2026 Can Us
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version. This program is distributed WITHOUT ANY WARRANTY; see the GNU
// Affero General Public License for more details: <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'app/app.dart';
import 'core/locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date symbols are loaded for every supported locale, because the language
  // can change at runtime.
  for (final l in supportedLocales) {
    await initializeDateFormatting(l.languageCode);
  }
  // The locale is resolved before `runApp` so the dashboard never paints a
  // frame in the wrong language.
  final locale = await loadStartupLocale();
  runApp(
    ProviderScope(
      overrides: [initialLocaleProvider.overrideWithValue(locale)],
      retry: (retryCount, _) =>
          retryCount >= 3 ? null : Duration(seconds: 1 << retryCount),
      child: const SightpaneApp(),
    ),
  );
}
