// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/config.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../shared/widgets.dart';

class VisitorMap extends StatefulWidget {
  const VisitorMap({
    super.key,
    required this.locations,
    this.height = 360,
  });

  final List<GeoLocationPoint> locations;
  final double height;

  @override
  State<VisitorMap> createState() => _VisitorMapState();
}

class _VisitorMapState extends State<VisitorMap> {
  final MapController _mapController = MapController();
  GeoLocationPoint? _selectedPoint;

  int get _totalVisitors {
    var sum = 0;
    for (final loc in widget.locations) {
      sum += loc.count;
    }
    return sum;
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (zoom + 1).clamp(1.0, 18.0));
  }

  void _zoomOut() {
    final zoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (zoom - 1).clamp(1.0, 18.0));
  }

  void _resetView() {
    setState(() => _selectedPoint = null);
    if (widget.locations.isEmpty) {
      _mapController.move(const LatLng(20, 0), 2.0);
      return;
    }
    if (widget.locations.length == 1) {
      final loc = widget.locations.first;
      _mapController.move(LatLng(loc.latitude, loc.longitude), 6.0);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          for (final l in widget.locations) LatLng(l.latitude, l.longitude),
        ],
        padding: const EdgeInsets.all(48),
        maxZoom: 9,
      ),
    );
  }

  void _selectLocation(GeoLocationPoint point) {
    setState(() => _selectedPoint = point);
    _mapController.move(LatLng(point.latitude, point.longitude), 6.5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return PanelCard(
      title: l10n.usersVisitorMapTitle,
      subtitle: l10n.usersVisitorMapSub,
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.locations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Tokens.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Tokens.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.mapPin, size: 12, color: Tokens.accent),
                  const Gap(4),
                  Text(
                    l10n.usersMapLocationsCount(widget.locations.length),
                    style: AppTheme.mono(
                      size: 11,
                      weight: FontWeight.w600,
                      color: Tokens.accent,
                    ),
                  ),
                  const Gap(6),
                  Container(width: 1, height: 10, color: Tokens.border),
                  const Gap(6),
                  const Icon(LucideIcons.users, size: 12, color: Tokens.accent),
                  const Gap(4),
                  Text(
                    l10n.usersMapVisitorsCount(_totalVisitors),
                    style: AppTheme.mono(
                      size: 11,
                      weight: FontWeight.w600,
                      color: Tokens.accent,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],
          GhostButton(
            size: ButtonSize.small,
            density: ButtonDensity.compact,
            onPressed: _resetView,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.locateFixed, size: 13),
                const Gap(4),
                Text(l10n.usersMapResetView),
              ],
            ),
          ),
        ],
      ),
      child: widget.locations.isEmpty
          ? Container(
              height: 220,
              decoration: BoxDecoration(
                color: Tokens.panel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Tokens.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mapPinOff, size: 36, color: Tokens.textMuted),
                    const Gap(10),
                    Text(
                      l10n.usersMapNoData,
                      style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Tokens.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              widget.locations.first.latitude,
                              widget.locations.first.longitude,
                            ),
                            initialZoom: widget.locations.length == 1 ? 6.0 : 2.5,
                            minZoom: 1.0,
                            maxZoom: 18.0,
                            initialCameraFit: widget.locations.length > 1
                                ? CameraFit.coordinates(
                                    coordinates: [
                                      for (final l in widget.locations)
                                        LatLng(l.latitude, l.longitude),
                                    ],
                                    padding: const EdgeInsets.all(48),
                                    maxZoom: 8.5,
                                  )
                                : null,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: AppConfig.mapTileUrl,
                              userAgentPackageName: 'dev.sightpane.dashboard',
                              tileBuilder: (context, tileWidget, tile) {
                                if (!isDark) return tileWidget;
                                // Subtle dark mode filter to make bright OSM tiles look cohesive
                                return ColorFiltered(
                                  colorFilter: const ColorFilter.matrix(<double>[
                                    -0.85, 0, 0, 0, 240, // R
                                    0, -0.85, 0, 0, 240, // G
                                    0, 0, -0.85, 0, 240, // B
                                    0, 0, 0, 1, 0,       // A
                                  ]),
                                  child: tileWidget,
                                );
                              },
                            ),
                            MarkerLayer(
                              markers: [
                                for (final loc in widget.locations)
                                  Marker(
                                    point: LatLng(loc.latitude, loc.longitude),
                                    width: 44,
                                    height: 44,
                                    child: _VisitorMarker(
                                      point: loc,
                                      isSelected: _selectedPoint == loc,
                                      onTap: () => _selectLocation(loc),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Zoom and control overlay
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MapControlButton(
                                icon: LucideIcons.plus,
                                tooltip: l10n.usersMapZoomIn,
                                onPressed: _zoomIn,
                              ),
                              const Gap(4),
                              _MapControlButton(
                                icon: LucideIcons.minus,
                                tooltip: l10n.usersMapZoomOut,
                                onPressed: _zoomOut,
                              ),
                              const Gap(4),
                              _MapControlButton(
                                icon: LucideIcons.maximize2,
                                tooltip: l10n.usersMapResetView,
                                onPressed: _resetView,
                              ),
                            ],
                          ),
                        ),

                        // Selected location preview popover / floating card
                        if (_selectedPoint != null)
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: _SelectedLocationCard(
                              point: _selectedPoint!,
                              onClose: () => setState(() => _selectedPoint = null),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Quick jump pills for top locations
                if (widget.locations.isNotEmpty) ...[
                  const Gap(10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final loc in widget.locations.take(6))
                        GestureDetector(
                          onTap: () => _selectLocation(loc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedPoint == loc
                                  ? Tokens.accent.withValues(alpha: 0.2)
                                  : Tokens.chip,
                              border: Border.all(
                                color: _selectedPoint == loc
                                    ? Tokens.accent
                                    : Tokens.border,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (loc.countryCode.length == 2) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: SizedBox(
                                      width: 15,
                                      height: 11,
                                      child: CountryFlag.fromCountryCode(loc.countryCode),
                                    ),
                                  ),
                                  const Gap(6),
                                ],
                                Text(
                                  loc.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _selectedPoint == loc
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _selectedPoint == loc
                                        ? Tokens.accent
                                        : Tokens.text,
                                  ),
                                ),
                                const Gap(6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Tokens.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    '${loc.count}',
                                    style: AppTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: Tokens.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _VisitorMarker extends StatelessWidget {
  const _VisitorMarker({
    required this.point,
    required this.isSelected,
    required this.onTap,
  });

  final GeoLocationPoint point;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = point.count;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 38 : (count > 1 ? 32 : 26),
          height: isSelected ? 38 : (count > 1 ? 32 : 26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Tokens.accent, Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
              width: isSelected ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? Tokens.accent : Colors.black).withValues(alpha: 0.35),
                blurRadius: isSelected ? 8 : 4,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: count > 1
                ? Text(
                    count > 999 ? '999+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : const Icon(
                    LucideIcons.mapPin,
                    size: 13,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  const _SelectedLocationCard({
    required this.point,
    required this.onClose,
  });

  final GeoLocationPoint point;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (point.countryCode.length == 2) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    width: 18,
                    height: 13,
                    child: CountryFlag.fromCountryCode(point.countryCode),
                  ),
                ),
                const Gap(8),
              ],
              Expanded(
                child: Text(
                  point.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Tokens.textStrong,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(4),
              GhostButton(
                size: ButtonSize.xSmall,
                density: ButtonDensity.compact,
                onPressed: onClose,
                child: const Icon(LucideIcons.x, size: 12),
              ),
            ],
          ),
          if (point.region.isNotEmpty && !point.label.contains(point.region)) ...[
            const Gap(2),
            Text(
              point.region,
              style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
            ),
          ],
          const Gap(6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Tokens.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.usersMapVisitorsCount(point.count),
                  style: AppTheme.mono(
                    size: 11,
                    weight: FontWeight.w600,
                    color: Tokens.accent,
                  ),
                ),
              ),
              const Gap(8),
              Text(
                '${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)}',
                style: AppTheme.mono(size: 10, color: Tokens.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      tooltip: (_) => TooltipContainer(child: Text(tooltip)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Tokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GhostButton(
          size: ButtonSize.small,
          density: ButtonDensity.compact,
          onPressed: onPressed,
          child: Icon(icon, size: 14),
        ),
      ),
    );
  }
}
