import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app/theme/tokens.dart';
import '../core/auth.dart';
import '../core/format.dart';
import '../core/providers.dart';
import '../shared/brand.dart';
import '../shared/language_switch.dart';
import '../l10n/gen/app_localizations.dart';

/// The top bar + (while inside a project) the left menu.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static int? projectIdOf(String path) {
    final m = RegExp(r'^/projects/(\d+)').firstMatch(path);
    return m == null ? null : int.parse(m.group(1)!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final pid = projectIdOf(path);
    final isMobile = MediaQuery.sizeOf(context).width < Tokens.mobileBreakpoint;
    final nav = pid == null
        ? null
        : ProjectNav(projectId: pid, path: path, horizontal: isMobile);
    return Scaffold(
      backgroundColor: Tokens.bg,
      child: Column(
        children: [
          TopBar(projectId: pid),
          if (isMobile && nav != null) nav,
          Expanded(
            child: isMobile || nav == null
                ? child
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: Tokens.sidebarWidth, child: nav),
                      Expanded(child: child),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class TopBar extends ConsumerWidget {
  const TopBar({super.key, this.projectId});
  final int? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final project = projectId == null
        ? null
        : ref.watch(projectProvider(projectId!)).value;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Tokens.surface,
        border: Border(bottom: BorderSide(color: Tokens.hairline)),
      ),
      child: Row(
        children: [
          GhostButton(
            density: ButtonDensity.compact,
            onPressed: () => context.go('/projects'),
            child: const SightpaneLockup(markSize: 18, fontSize: 15),
          ),
          if (project != null) ...[
            const Gap(6),
            const Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: Tokens.textFaint,
            ),
            const Gap(6),
            Text(
              project.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Tokens.text,
              ),
            ),
          ],
          const Spacer(),
          const LanguageSwitch(),
          const Gap(10),
          Tooltip(
            tooltip: (_) => TooltipContainer(
              child: Text(context.l10n.shellSourceTooltip(sourceUrl)),
            ),
            child: const Text(
              'AGPL-3.0',
              style: TextStyle(fontSize: 11, color: Tokens.textFaint),
            ),
          ),
          const Gap(12),
          if (user != null) ...[
            Text(
              user.displayName,
              style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
            ),
            const Gap(8),
            Avatar(
              initials: user.initials,
              size: 26,
              backgroundColor: Tokens.chip,
            ),
            const Gap(4),
            Tooltip(
              tooltip: (_) =>
                  TooltipContainer(child: Text(context.l10n.shellSignOut)),
              child: IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.logOut, size: 15),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// AGPL-3.0 §13: the source address for anyone using this over a network.
const sourceUrl = 'https://github.com/sightpane/sightpane';

class NavEntry {
  const NavEntry(this.label, this.icon, this.suffix);

  /// The label depends on the language, so this is not a string but a function
  /// that reads it from the translations.
  final String Function(L l10n) label;
  final IconData icon;
  final String suffix;
}

String _navOverview(L l) => l.navOverview;
String _navIssues(L l) => l.navIssues;
String _navSessions(L l) => l.navSessions;
String _navUsers(L l) => l.navUsers;
String _navFunnels(L l) => l.navFunnels;
String _navRetention(L l) => l.navRetention;
String _navCohorts(L l) => l.navCohorts;
String _navPaths(L l) => l.navPaths;
String _navFeatureFlags(L l) => l.navFeatureFlags;
String _navExperiments(L l) => l.navExperiments;
String _navSurveys(L l) => l.navSurveys;
String _navCrons(L l) => l.navCrons;
String _navUptime(L l) => l.navUptime;
String _navPerformance(L l) => l.performanceTitle;
String _navReleases(L l) => l.navReleases;
String _navEvents(L l) => l.navEvents;
String _navSettings(L l) => l.navSettings;

const projectNavEntries = [
  NavEntry(_navOverview, LucideIcons.layoutDashboard, ''),
  NavEntry(_navIssues, LucideIcons.bug, '/issues'),
  NavEntry(_navSessions, LucideIcons.video, '/sessions'),
  NavEntry(_navUsers, LucideIcons.users, '/users'),
  NavEntry(_navFunnels, LucideIcons.filter, '/funnels'),
  NavEntry(_navRetention, LucideIcons.calendarDays, '/retention'),
  NavEntry(_navCohorts, LucideIcons.layers, '/cohorts'),
  NavEntry(_navPaths, LucideIcons.gitBranch, '/paths'),
  NavEntry(_navFeatureFlags, LucideIcons.flag, '/feature-flags'),
  NavEntry(_navExperiments, LucideIcons.flaskConical, '/experiments'),
  NavEntry(_navSurveys, LucideIcons.messageSquare, '/surveys'),
  NavEntry(_navCrons, LucideIcons.timer, '/crons'),
  NavEntry(_navUptime, LucideIcons.activity, '/uptime'),
  NavEntry(_navPerformance, LucideIcons.gauge, '/performance'),
  NavEntry(_navReleases, LucideIcons.tag, '/releases'),
  NavEntry(_navEvents, LucideIcons.chartBar, '/events'),
  NavEntry(_navSettings, LucideIcons.settings, '/settings'),
];



class ProjectNav extends StatelessWidget {
  const ProjectNav({
    super.key,
    required this.projectId,
    required this.path,
    this.horizontal = false,
  });
  final int projectId;
  final String path;
  final bool horizontal;

  bool _selected(NavEntry e) {
    final base = '/projects/$projectId';
    if (e.suffix.isEmpty) return path == base;
    return path.startsWith('$base${e.suffix}');
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final e in projectNavEntries)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? 2 : 8,
            vertical: horizontal ? 0 : 1,
          ),
          child: _selected(e)
              ? SecondaryButton(
                  density: ButtonDensity.dense,
                  alignment: Alignment.centerLeft,
                  onPressed: () =>
                      context.go('/projects/$projectId${e.suffix}'),
                  leading: Icon(e.icon, size: 15, color: Tokens.accent),
                  child: Text(
                    e.label(context.l10n),
                    style: const TextStyle(
                      color: Tokens.textStrong,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : GhostButton(
                  density: ButtonDensity.dense,
                  alignment: Alignment.centerLeft,
                  onPressed: () =>
                      context.go('/projects/$projectId${e.suffix}'),
                  leading: Icon(e.icon, size: 15, color: Tokens.textDim),
                  child: Text(
                    e.label(context.l10n),
                    style: const TextStyle(color: Tokens.textMuted),
                  ),
                ),
        ),
    ];
    if (horizontal) {
      return Container(
        decoration: const BoxDecoration(
          color: Tokens.surface,
          border: Border(bottom: BorderSide(color: Tokens.hairline)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: buttons),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        color: Tokens.surface,
        border: Border(right: BorderSide(color: Tokens.hairline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }
}
