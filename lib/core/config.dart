import 'package:flutter/foundation.dart' show kIsWeb;

/// Settings that arrive via `--dart-define-from-file=config.json`.
abstract final class AppConfig {
  static const _apiUrlRaw = String.fromEnvironment('SIGHTPANE_API_URL');
  static const _mapTileUrlRaw = String.fromEnvironment('SIGHTPANE_MAP_TILE_URL');

  /// The sightpane backend root address. Left empty, the page's own origin is
  /// used on web (when the dashboard is served by the backend itself, e.g. under
  /// Docker); on other platforms `http://localhost:8790`.
  static String get apiUrl {
    if (_apiUrlRaw.isNotEmpty) return _apiUrlRaw;
    if (kIsWeb) return Uri.base.origin;
    return 'http://localhost:8790';
  }

  /// The tile provider URL template for flutter_map (e.g. OpenStreetMap, Carto, Mapbox).
  /// Can be overridden via `--dart-define=SIGHTPANE_MAP_TILE_URL=...`.
  static String get mapTileUrl {
    if (_mapTileUrlRaw.isNotEmpty) return _mapTileUrlRaw;
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }
}
