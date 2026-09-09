import 'package:flutter/foundation.dart' show kIsWeb;

/// Settings that arrive via `--dart-define-from-file=config.json`.
abstract final class AppConfig {
  static const _apiUrlRaw = String.fromEnvironment('SIGHTPANE_API_URL');

  /// The sightpane backend root address. Left empty, the page's own origin is
  /// used on web (when the dashboard is served by the backend itself, e.g. under
  /// Docker); on other platforms `http://localhost:8790`.
  static String get apiUrl {
    if (_apiUrlRaw.isNotEmpty) return _apiUrlRaw;
    if (kIsWeb) return Uri.base.origin;
    return 'http://localhost:8790';
  }
}
