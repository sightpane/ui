// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/models.dart';

/// Renders a country flag with geographical location labels (City, Region, Country)
/// and optional coordinate indicators.
class LocationBadge extends StatelessWidget {
  const LocationBadge({
    super.key,
    required this.session,
    this.compact = true,
    this.showCoordinates = false,
  })  : countryCode = null,
        countryName = null,
        region = null,
        city = null,
        latitude = null,
        longitude = null,
        ip = null;

  LocationBadge.fromUser({
    super.key,
    required UserSummary user,
    this.compact = true,
    this.showCoordinates = false,
  })  : session = null,
        countryCode = user.countryCode,
        countryName = user.countryName,
        region = '',
        city = user.city,
        latitude = user.latitude,
        longitude = user.longitude,
        ip = user.lastIP;

  const LocationBadge.raw({
    super.key,
    required this.countryCode,
    this.countryName,
    this.region,
    this.city,
    this.latitude,
    this.longitude,
    this.ip,
    this.compact = true,
    this.showCoordinates = false,
  }) : session = null;

  final Session? session;
  final String? countryCode;
  final String? countryName;
  final String? region;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? ip;
  final bool compact;
  final bool showCoordinates;

  @override
  Widget build(BuildContext context) {
    final cc = (session?.countryCode ?? countryCode ?? '').trim().toUpperCase();
    final hasFlag = cc.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(cc) && cc != 'LOCAL';
    final cName = session?.countryName ?? countryName ?? '';
    final rName = session?.region ?? region ?? '';
    final cCity = session?.city ?? city ?? '';
    final lat = session?.latitude ?? latitude;
    final lon = session?.longitude ?? longitude;
    final clientIp = session?.ip ?? ip ?? '';
    final hasCoords = lat != null && lon != null;
    final coords = session != null
        ? session!.coordinatesLabel
        : (hasCoords ? '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}' : '');

    String locLabel = '';
    if (session != null) {
      locLabel = session!.locationLabel;
    } else if (cCity.isNotEmpty && cName.isNotEmpty) {
      locLabel = '$cCity, $cName';
    } else if (cCity.isNotEmpty && cc.isNotEmpty) {
      locLabel = '$cCity, $cc';
    } else if (cCity.isNotEmpty) {
      locLabel = cCity;
    } else if (cName.isNotEmpty) {
      locLabel = cName;
    }

    if (locLabel.isEmpty && cc.isEmpty && !hasCoords) {
      return Text(
        '—',
        style: TextStyle(
          fontSize: compact ? 12 : 13,
          color: Tokens.textMuted,
        ),
      );
    }

    Widget flagWidget;
    if (hasFlag) {
      flagWidget = ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: compact ? 17 : 21,
          height: compact ? 12 : 15,
          child: CountryFlag.fromCountryCode(cc),
        ),
      );
    } else {
      flagWidget = Icon(
        cc == 'LOCAL' ? LucideIcons.network : LucideIcons.globe,
        size: compact ? 13 : 15,
        color: Tokens.textMuted,
      );
    }

    final displayText = locLabel.isNotEmpty
        ? locLabel
        : (cc == 'LOCAL' ? 'Local Network' : (cc.isNotEmpty ? cc : coords));

    final tooltipParts = <String>[
      if (displayText.isNotEmpty) displayText,
      if (rName.isNotEmpty && !displayText.contains(rName)) rName,
      if (coords.isNotEmpty) 'Coordinates: $coords',
      if (clientIp.isNotEmpty) 'IP: $clientIp',
    ];

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        flagWidget,
        const Gap(6),
        Flexible(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              color: Tokens.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCoordinates && coords.isNotEmpty) ...[
          const Gap(6),
          Text(
            '($coords)',
            style: const TextStyle(
              fontSize: 11,
              color: Tokens.textMuted,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );

    if (tooltipParts.isNotEmpty) {
      return Tooltip(
        tooltip: (_) => TooltipContainer(
          child: Text(tooltipParts.join('\n')),
        ),
        child: content,
      );
    }

    return content;
  }
}
