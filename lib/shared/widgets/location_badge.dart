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
  });

  final Session session;
  final bool compact;
  final bool showCoordinates;

  @override
  Widget build(BuildContext context) {
    final cc = session.countryCode.trim().toUpperCase();
    final hasFlag = cc.length == 2 && cc != 'LOCAL';
    final locLabel = session.locationLabel;
    final coords = session.coordinatesLabel;

    if (locLabel.isEmpty && cc.isEmpty && !session.hasCoordinates) {
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
      if (session.region.isNotEmpty && !displayText.contains(session.region)) session.region,
      if (coords.isNotEmpty) 'Coordinates: $coords',
      if (session.ip.isNotEmpty) 'IP: ${session.ip}',
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
