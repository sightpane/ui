// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import '../../core/models.dart';

/// A person the way the Users page lists them: their initials in a circle, the
/// name, and the email under it when both are known. An empty [name] is an
/// anonymous visitor.
class UserIdentity extends StatelessWidget {
  const UserIdentity({
    super.key,
    required this.name,
    this.email = '',
    this.location,
  });

  final String name;
  final String email;

  /// Shown under the name, e.g. a [LocationBadge].
  final Widget? location;

  @override
  Widget build(BuildContext context) {
    final anonymous = name.isEmpty;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: (anonymous ? Tokens.textDim : Tokens.accent).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: anonymous
                ? const Icon(LucideIcons.user, size: 12, color: Tokens.textDim)
                : Text(
                    initialsOf(name),
                    style: AppTheme.mono(
                      size: 11,
                      weight: FontWeight.w700,
                      color: Tokens.accent,
                    ),
                  ),
          ),
        ),
        const Gap(8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                anonymous ? context.l10n.commonAnonymous : name,
                style: AppTheme.mono(
                  size: 13,
                  weight: FontWeight.w600,
                  color: anonymous ? Tokens.textMuted : Tokens.textStrong,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (email.isNotEmpty && email != name)
                Text(
                  email,
                  style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                  overflow: TextOverflow.ellipsis,
                ),
              if (location != null) ...[const Gap(2), location!],
            ],
          ),
        ),
      ],
    );
  }
}
