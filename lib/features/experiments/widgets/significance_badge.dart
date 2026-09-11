// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';

class SignificanceBadge extends StatelessWidget {
  const SignificanceBadge({
    super.key,
    required this.isSignificant,
    required this.significance,
    required this.totalParticipants,
    required this.minSampleSize,
  });

  final bool isSignificant;
  final double significance;
  final int totalParticipants;
  final int minSampleSize;

  @override
  Widget build(BuildContext context) {
    final pct = (significance * 100).toStringAsFixed(1);
    if (isSignificant) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Tokens.ok.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: Border.all(color: Tokens.ok.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCheck, size: 14, color: Tokens.ok),
            const Gap(6),
            Text(
              'Statistically Significant ($pct%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Tokens.ok,
              ),
            ),
          ],
        ),
      );
    }

    final hasEnoughSamples = totalParticipants >= minSampleSize;
    final text = hasEnoughSamples
        ? 'Inconclusive ($pct%)'
        : 'Gathering Data ($totalParticipants / $minSampleSize)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Tokens.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Tokens.radius),
        border: Border.all(color: Tokens.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.clock, size: 14, color: Tokens.warning),
          const Gap(6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Tokens.warning,
            ),
          ),
        ],
      ),
    );
  }
}
