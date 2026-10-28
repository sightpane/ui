import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app/theme/app_theme.dart';
import '../app/theme/tokens.dart';
import '../core/auth.dart';
import '../core/format.dart';
import '../core/models.dart';
import '../core/providers.dart';
import '../shared/brand.dart';
import '../shared/language_switch.dart';
import '../shared/widgets.dart';
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
    // Inside a project on a wide screen the sidebar carries the brand, the
    // account and the source address, so there is no top bar; elsewhere (the
    // project list, phones) the top bar stays.
    final Widget body;
    if (pid != null && !isMobile) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: Tokens.sidebarWidth,
            child: ProjectSidebar(projectId: pid, path: path),
          ),
          Expanded(child: child),
        ],
      );
    } else {
      body = Column(
        children: [
          TopBar(projectId: pid),
          if (pid != null)
            ProjectNav(projectId: pid, path: path, horizontal: true),
          Expanded(child: child),
        ],
      );
    }
    return Scaffold(
      backgroundColor: Tokens.bg,
      child: pid == null
          ? body
          : CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.keyK,
                  meta: true,
                ): () =>
                    showNavPalette(context, pid),
                const SingleActivator(
                  LogicalKeyboardKey.keyK,
                  control: true,
                ): () =>
                    showNavPalette(context, pid),
              },
              child: Focus(autofocus: true, child: body),
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

enum NavBadge { none, openIssues, live }

class NavEntry {
  const NavEntry(
    this.label,
    this.icon,
    this.suffix, [
    this.badge = NavBadge.none,
  ]);

  /// The label depends on the language, so this is not a string but a function
  /// that reads it from the translations.
  final String Function(L l10n) label;
  final IconData icon;
  final String suffix;
  final NavBadge badge;
}

class NavGroup {
  const NavGroup(this.label, this.entries);
  final String Function(L l10n) label;
  final List<NavEntry> entries;
}

String _navOverview(L l) => l.navOverview;
String _navDashboards(L l) => l.navDashboards;
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
String _navAlerts(L l) => l.navAlerts;
String _navTraces(L l) => l.navTraces;
String _navProfiling(L l) => l.navProfiling;
String _navPerformance(L l) => l.performanceTitle;
String _navReleases(L l) => l.navReleases;
String _navEvents(L l) => l.navEvents;
String _navSettings(L l) => l.navSettings;
String _groupMonitoring(L l) => l.navGroupMonitoring;
String _groupProduct(L l) => l.navGroupProduct;
String _groupRelease(L l) => l.navGroupRelease;
String _groupReliability(L l) => l.navGroupReliability;

/// The project menu in four groups: what breaks, what users do, what ships,
/// what keeps running. Settings sits apart at the foot of the sidebar.
const projectNavGroups = [
  NavGroup(_groupMonitoring, [
    NavEntry(_navOverview, LucideIcons.layoutDashboard, ''),
    NavEntry(_navIssues, LucideIcons.bug, '/issues', NavBadge.openIssues),
    NavEntry(_navSessions, LucideIcons.video, '/sessions', NavBadge.live),
    NavEntry(_navTraces, LucideIcons.gitFork, '/traces'),
    NavEntry(_navPerformance, LucideIcons.gauge, '/performance'),
    NavEntry(_navProfiling, LucideIcons.flame, '/profiling'),
  ]),
  NavGroup(_groupProduct, [
    NavEntry(_navDashboards, LucideIcons.layoutGrid, '/dashboards'),
    NavEntry(_navEvents, LucideIcons.chartBar, '/events'),
    NavEntry(_navUsers, LucideIcons.users, '/users'),
    NavEntry(_navFunnels, LucideIcons.filter, '/funnels'),
    NavEntry(_navRetention, LucideIcons.calendarDays, '/retention'),
    NavEntry(_navCohorts, LucideIcons.layers, '/cohorts'),
    NavEntry(_navPaths, LucideIcons.gitBranch, '/paths'),
  ]),
  NavGroup(_groupRelease, [
    NavEntry(_navReleases, LucideIcons.tag, '/releases'),
    NavEntry(_navFeatureFlags, LucideIcons.flag, '/feature-flags'),
    NavEntry(_navExperiments, LucideIcons.flaskConical, '/experiments'),
    NavEntry(_navSurveys, LucideIcons.messageSquare, '/surveys'),
  ]),
  NavGroup(_groupReliability, [
    NavEntry(_navUptime, LucideIcons.activity, '/uptime'),
    NavEntry(_navCrons, LucideIcons.timer, '/crons'),
    NavEntry(_navAlerts, LucideIcons.bellRing, '/alerts'),
  ]),
];

const settingsNavEntry = NavEntry(
  _navSettings,
  LucideIcons.settings,
  '/settings',
);

/// Every project page in menu order, settings last.
final projectNavEntries = [
  for (final g in projectNavGroups) ...g.entries,
  settingsNavEntry,
];

bool _isSelected(NavEntry e, int projectId, String path) {
  final base = '/projects/$projectId';
  if (e.suffix.isEmpty) return path == base;
  return path.startsWith('$base${e.suffix}');
}

/// One menu row. The selected row is filled and its icon takes the brand
/// colour; [trailing] is a count or a live dot.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.entry,
    required this.projectId,
    required this.selected,
    this.trailing,
  });
  final NavEntry entry;
  final int projectId;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    void go() => context.go('/projects/$projectId${entry.suffix}');
    final label = Text(
      entry.label(context.l10n),
      overflow: TextOverflow.ellipsis,
      style: selected
          ? const TextStyle(
              color: Tokens.textStrong,
              fontWeight: FontWeight.w600,
            )
          : const TextStyle(color: Tokens.textMuted),
    );
    return selected
        ? SecondaryButton(
            density: ButtonDensity.dense,
            alignment: Alignment.centerLeft,
            onPressed: go,
            leading: Icon(entry.icon, size: 15, color: Tokens.accent),
            trailing: trailing,
            child: label,
          )
        : GhostButton(
            density: ButtonDensity.dense,
            alignment: Alignment.centerLeft,
            onPressed: go,
            leading: Icon(entry.icon, size: 15, color: Tokens.textDim),
            trailing: trailing,
            child: label,
          );
  }
}

/// The open-issue count and the live-session dot next to their menu rows.
///
/// Only the overview refreshes the live status (every second); elsewhere the
/// dot would keep its last value for good, so it refreshes itself slowly.
class _NavBadgeView extends ConsumerStatefulWidget {
  const _NavBadgeView({required this.badge, required this.projectId});
  final NavBadge badge;
  final int projectId;

  @override
  ConsumerState<_NavBadgeView> createState() => _NavBadgeViewState();
}

class _NavBadgeViewState extends ConsumerState<_NavBadgeView> {
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    if (widget.badge == NavBadge.live) {
      _refresh = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) ref.invalidate(liveProvider(widget.projectId));
      });
    }
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    switch (widget.badge) {
      case NavBadge.none:
        return const SizedBox.shrink();
      case NavBadge.openIssues:
        final n = ref.watch(projectProvider(projectId)).value?.openIssues ?? 0;
        if (n == 0) return const SizedBox.shrink();
        return Tooltip(
          tooltip: (_) => TooltipContainer(
            child: Text(context.l10n.kpiOpenGroupsNote(context.fmt.integer(n))),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Tokens.danger.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.fmt.integer(n),
              style: AppTheme.mono(
                size: 11,
                weight: FontWeight.w600,
                color: Tokens.danger,
              ),
            ),
          ),
        );
      case NavBadge.live:
        final n = ref.watch(liveProvider(projectId)).value?.count ?? 0;
        if (n == 0) return const SizedBox.shrink();
        return Tooltip(
          tooltip: (_) =>
              TooltipContainer(child: Text(context.l10n.shellLiveBadge(n))),
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Tokens.ok,
              shape: BoxShape.circle,
            ),
          ),
        );
    }
  }
}

/// The menu as a horizontal strip, under the top bar on narrow screens.
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

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Tokens.surface,
      border: Border(bottom: BorderSide(color: Tokens.hairline)),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          for (final e in projectNavEntries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _NavButton(
                entry: e,
                projectId: projectId,
                selected: _isSelected(e, projectId, path),
              ),
            ),
        ],
      ),
    ),
  );
}

/// The project sidebar on wide screens: brand, project switcher, search, the
/// grouped menu, and at the foot settings, the account, the language and the
/// source address (AGPL-3.0 §13).
class ProjectSidebar extends ConsumerWidget {
  const ProjectSidebar({
    super.key,
    required this.projectId,
    required this.path,
  });
  final int projectId;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value?.user;
    final project = ref.watch(projectProvider(projectId)).value;
    Widget item(NavEntry e) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: _NavButton(
        entry: e,
        projectId: projectId,
        selected: _isSelected(e, projectId, path),
        trailing: e.badge == NavBadge.none
            ? null
            : _NavBadgeView(badge: e.badge, projectId: projectId),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: Tokens.surface,
        border: Border(right: BorderSide(color: Tokens.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            child: Row(
              children: [
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: () => context.go('/projects'),
                  child: const SightpaneLockup(markSize: 20, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _ProjectSwitcher(project: project),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: OutlineButton(
              density: ButtonDensity.compact,
              alignment: Alignment.centerLeft,
              onPressed: () => showNavPalette(context, projectId),
              leading: const Icon(
                LucideIcons.search,
                size: 14,
                color: Tokens.textMuted,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: Tokens.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _paletteShortcutLabel,
                  style: AppTheme.mono(size: 10, color: Tokens.textMuted),
                ),
              ),
              child: Text(
                context.l10n.shellSearch,
                style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final g in projectNavGroups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                      child: Text(
                        context.fmt.upper(g.label(context.l10n)),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Tokens.textMuted,
                        ),
                      ),
                    ),
                    for (final e in g.entries) item(e),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Tokens.hairline)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                item(settingsNavEntry),
                if (user != null) ...[
                  const Gap(8),
                  Row(
                    children: [
                      const Gap(6),
                      Avatar(
                        initials: user.initials,
                        size: 28,
                        backgroundColor: Tokens.chip,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          user.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Tokens.text,
                          ),
                        ),
                      ),
                      Tooltip(
                        tooltip: (_) => TooltipContainer(
                          child: Text(context.l10n.shellSignOut),
                        ),
                        child: IconButton.ghost(
                          size: ButtonSize.small,
                          icon: const Icon(LucideIcons.logOut, size: 15),
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .logout(),
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(8),
                Row(
                  children: [
                    const LanguageSwitch(),
                    const Spacer(),
                    Tooltip(
                      tooltip: (_) => TooltipContainer(
                        child: Text(context.l10n.shellSourceTooltip(sourceUrl)),
                      ),
                      child: const Text(
                        'AGPL-3.0',
                        style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                      ),
                    ),
                    const Gap(4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The current project and a dropdown to jump to another one.
class _ProjectSwitcher extends ConsumerWidget {
  const _ProjectSwitcher({required this.project});
  final Project? project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = project;
    final name = p?.name ?? '';
    return OutlineButton(
      density: ButtonDensity.compact,
      alignment: Alignment.centerLeft,
      onPressed: () => showDropdown(
        context: context,
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final projects = ref.watch(projectsProvider).value ?? const [];
            return DropdownMenu(
              children: [
                MenuLabel(child: Text(context.l10n.shellSwitchProject)),
                for (final other in projects)
                  MenuButton(
                    leading: Icon(
                      other.id == p?.id
                          ? LucideIcons.check
                          : LucideIcons.folder,
                      size: 14,
                    ),
                    onPressed: (_) => context.go('/projects/${other.id}'),
                    child: Text(other.name),
                  ),
                const MenuDivider(),
                MenuButton(
                  onPressed: (_) => context.go('/projects'),
                  child: Text(context.l10n.shellAllProjects),
                ),
              ],
            );
          },
        ),
      ),
      leading: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Tokens.accent,
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Text(
          name.isEmpty ? '' : context.fmt.upper(name.characters.first),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Tokens.accentInk,
          ),
        ),
      ),
      trailing: const Icon(
        LucideIcons.chevronsUpDown,
        size: 14,
        color: Tokens.textMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Tokens.textStrong,
            ),
          ),
          if (p != null)
            Text(
              p.platform,
              style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
            ),
        ],
      ),
    );
  }
}

/// ⌘K on a Mac, Ctrl+K elsewhere; both are bound everywhere.
String get _paletteShortcutLabel =>
    defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS
    ? '⌘K'
    : 'Ctrl K';

/// ⌘K: search the project's pages by name and jump to one.
void showNavPalette(BuildContext context, int projectId) {
  final router = GoRouter.of(context);
  final l10n = context.l10n;
  showOverlay<void>(
    context,
    const DialogConfiguration(),
    builder: (ctx) => SizedBox(
      // Command measures itself with IntrinsicWidth unless it gets a fixed
      // size, and its lazy list cannot report one.
      width: 520,
      height: 440,
      child: Command(
        debounceDuration: Duration.zero,
        searchPlaceholder: Text(l10n.shellSearchPages),
        emptyBuilder: (_) => PanelMessage(l10n.shellNoResults),
        builder: (context, query) async* {
          final q = (query ?? '').toLowerCase().trim();
          bool hit(NavEntry e) =>
              q.isEmpty || e.label(l10n).toLowerCase().contains(q);
          final categories = <Widget>[
            for (final g in [
              ...projectNavGroups,
              NavGroup(_navSettings, const [settingsNavEntry]),
            ])
              if (g.entries.any(hit))
                CommandCategory(
                  title: Text(g.label(l10n)),
                  children: [
                    for (final e in g.entries.where(hit))
                      CommandItem(
                        leading: Icon(e.icon, size: 15),
                        title: Text(e.label(l10n)),
                        onTap: () {
                          closeOverlay(ctx);
                          router.go('/projects/$projectId${e.suffix}');
                        },
                      ),
                  ],
                ),
          ];
          yield categories;
        },
      ),
    ),
  );
}
