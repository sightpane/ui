import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app/theme/app_theme.dart';
import '../app/theme/tokens.dart';
import '../core/format.dart';
import '../core/models.dart';
import 'widgets.dart';

/// The card displaying granular client and device runtime parameters:
/// Platform, OS, OS Version, Linux Kernel & Version, Browser & Version, Architecture, CPU cores, Screen, etc.
class ClientEnvironmentCard extends StatelessWidget {
  const ClientEnvironmentCard({
    super.key,
    required this.session,
    this.title,
  });

  final Session session;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final l = context.l10n;

    final IconData platformIcon;
    final String platformLocalized;
    switch (s.platformCategory) {
      case 'Web':
        platformIcon = LucideIcons.globe;
        platformLocalized = l.clientPlatformWeb;
        break;
      case 'Mobile':
        platformIcon = LucideIcons.smartphone;
        platformLocalized = l.clientPlatformMobile;
        break;
      case 'Desktop':
      default:
        platformIcon = LucideIcons.monitor;
        platformLocalized = l.clientPlatformDesktop;
        break;
    }

    final items = <EnvItem>[
      EnvItem(
        label: l.clientPlatform,
        value: platformLocalized,
        icon: platformIcon,
        highlight: true,
      ),
      EnvItem(
        label: l.clientOS,
        value: s.osName,
        icon: LucideIcons.hardDrive,
      ),
      if (s.osVersion.isNotEmpty)
        EnvItem(
          label: l.clientOsVersion,
          value: s.osVersion,
          icon: LucideIcons.tag,
        ),
      if (s.isLinuxDesktop || s.kernel.isNotEmpty || s.kernelVersion.isNotEmpty) ...[
        EnvItem(
          label: l.clientKernel,
          value: s.kernel.isNotEmpty ? s.kernel : 'Linux',
          icon: LucideIcons.cpu,
        ),
        if (s.kernelVersion.isNotEmpty)
          EnvItem(
            label: l.clientKernelVersion,
            value: s.kernelVersion,
            icon: LucideIcons.binary,
            mono: true,
          ),
      ],
      if (s.isWeb || s.browserName.isNotEmpty || s.browserVersion.isNotEmpty) ...[
        if (s.browserName.isNotEmpty)
          EnvItem(
            label: l.clientBrowser,
            value: s.browserName,
            icon: LucideIcons.globe,
          ),
        if (s.browserVersion.isNotEmpty)
          EnvItem(
            label: l.clientBrowserVersion,
            value: s.browserVersion,
            icon: LucideIcons.hash,
            mono: true,
          ),
      ],
      if (s.arch.isNotEmpty)
        EnvItem(
          label: l.clientArch,
          value: s.arch,
          icon: LucideIcons.cpu,
          mono: true,
        ),
      EnvItem(
        label: l.clientCores,
        value: (s.cpuCores != null && s.cpuCores! > 0) ? '${s.cpuCores}' : '-',
        icon: LucideIcons.gauge,
      ),
      if (s.screenResolution.isNotEmpty)
        EnvItem(
          label: l.clientScreen,
          value: s.screenResolution,
          icon: LucideIcons.expand,
          mono: true,
        ),
      if (s.locale.isNotEmpty)
        EnvItem(
          label: l.clientLocale,
          value: s.locale,
          icon: LucideIcons.languages,
        ),
      if (s.sdkName.isNotEmpty)
        EnvItem(
          label: l.clientSdk,
          value: '${s.sdkName} ${s.sdkVersion}'.trim(),
          icon: LucideIcons.box,
          mono: true,
        ),
    ];

    return PanelCard(
      title: title ?? l.sessionClientInfo,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (final item in items)
              EnvBadge(item: item),
          ],
        ),
      ),
    );
  }
}

class EnvItem {
  const EnvItem({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.mono = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final bool mono;
}

class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.item});
  final EnvItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.highlight ? Tokens.brand.withValues(alpha: 0.08) : Tokens.surface,
        border: Border.all(
          color: item.highlight ? Tokens.brand.withValues(alpha: 0.3) : Tokens.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 13,
            color: item.highlight ? Tokens.brand : Tokens.textDim,
          ),
          const Gap(6),
          Text(
            '${item.label}:',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Tokens.textDim,
            ),
          ),
          const Gap(4),
          Text(
            item.value,
            style: item.mono
                ? AppTheme.mono(
                    size: 11.5,
                    color: item.highlight ? Tokens.brand : Tokens.textStrong,
                  )
                : TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: item.highlight ? Tokens.brand : Tokens.textStrong,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Compact badge row for displaying platform & OS in headers, bars or table rows
class ClientEnvironmentPill extends StatelessWidget {
  const ClientEnvironmentPill({
    super.key,
    required this.session,
    this.compact = false,
  });

  final Session session;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final l = context.l10n;

    final IconData platformIcon;
    final String platformLocalized;
    switch (s.platformCategory) {
      case 'Web':
        platformIcon = LucideIcons.globe;
        platformLocalized = l.clientPlatformWeb;
        break;
      case 'Mobile':
        platformIcon = LucideIcons.smartphone;
        platformLocalized = l.clientPlatformMobile;
        break;
      case 'Desktop':
      default:
        platformIcon = LucideIcons.monitor;
        platformLocalized = l.clientPlatformDesktop;
        break;
    }

    // Compose descriptive label: e.g. "Ubuntu 24.04" or "Chrome 128" or "macOS 14.5"
    String envText = '';
    if (s.isWeb && s.browserName.isNotEmpty) {
      envText = s.browserVersion.isNotEmpty
          ? '${s.browserName} ${s.browserVersion}'
          : s.browserName;
    } else {
      if (s.osName.isNotEmpty && s.osName != '—') {
        envText = s.osVersion.isNotEmpty
            ? '${s.osName} ${s.osVersion}'
            : s.osName;
      }
      if (s.isLinuxDesktop && s.kernelVersion.isNotEmpty) {
        envText = envText.isNotEmpty
            ? '$envText (${s.kernelVersion})'
            : s.kernelVersion;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Tokens.brand.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Tokens.brand.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(platformIcon, size: 12, color: Tokens.brand),
              const Gap(4),
              Text(
                platformLocalized,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Tokens.brand,
                ),
              ),
            ],
          ),
        ),
        if (envText.isNotEmpty) ...[
          const Gap(6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Tokens.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Tokens.border),
            ),
            child: Text(
              envText,
              style: AppTheme.mono(
                size: 11,
                color: Tokens.textStrong,
                weight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
