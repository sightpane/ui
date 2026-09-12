import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class SessionsPage extends ConsumerStatefulWidget {
  const SessionsPage({
    super.key,
    required this.projectId,
    this.onlyErrors = false,
    this.user = '',
    this.query = '',
  });
  final int projectId;
  final bool onlyErrors;
  final String user;
  final String query;
  @override
  ConsumerState<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends ConsumerState<SessionsPage> {
  late final _query = TextEditingController(
    text: widget.query.isNotEmpty
        ? widget.query
        : (widget.user.isNotEmpty ? 'user:${widget.user}' : ''),
  );

  @override
  void didUpdateWidget(SessionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final expected = widget.query.isNotEmpty
        ? widget.query
        : (widget.user.isNotEmpty ? 'user:${widget.user}' : '');
    if (_query.text.trim() != expected.trim()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _query.text.trim() != expected.trim()) {
          _query.text = expected;
        }
      });
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _go({bool? onlyErrors, String? query}) {
    final q = query ?? _query.text.trim();
    final errs = onlyErrors ?? widget.onlyErrors;
    final qp = <String, String>{
      if (errs) 'errors': '1',
      if (q.isNotEmpty) 'q': q,
    };
    context.go(
      Uri(
        path: '/projects/${widget.projectId}/sessions',
        queryParameters: qp.isEmpty ? null : qp,
      ).toString(),
    );
  }

  bool _hasFilter(String token) => _query.text.contains(token);

  void _toggleFilter(String token) {
    final cur = _query.text.trim();
    if (cur.contains(token)) {
      final updated = cur
          .split(RegExp(r'\s+'))
          .where((t) => t != token)
          .join(' ')
          .trim();
      _query.text = updated;
      _go(query: updated);
    } else {
      final updated = cur.isEmpty ? token : '$cur $token';
      _query.text = updated;
      _go(query: updated);
    }
  }

  List<FilterKeyDefinition> _buildFilterKeys(BuildContext context, List<Session>? sessions) {
    return [
      FilterKeyDefinition(
        key: 'browser',
        label: 'browser',
        description: context.l10n.filterBrowserDesc,
        icon: LucideIcons.globe,
        options: const [
          FilterOption(value: 'Chrome', label: 'Google Chrome', icon: LucideIcons.globe),
          FilterOption(value: 'Firefox', label: 'Mozilla Firefox', icon: LucideIcons.globe),
          FilterOption(value: 'Safari', label: 'Apple Safari', icon: LucideIcons.globe),
          FilterOption(value: 'Edge', label: 'Microsoft Edge', icon: LucideIcons.globe),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            final b = s.browserName.isNotEmpty ? s.browserName : s.browser;
            if (b.isNotEmpty && seen.add(b.toLowerCase())) {
              res.add(FilterOption(value: b, icon: LucideIcons.globe));
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'platform',
        label: 'platform',
        description: context.l10n.filterPlatformDesc,
        icon: LucideIcons.layers,
        options: const [
          FilterOption(value: 'web', label: 'Web application', icon: LucideIcons.globe),
          FilterOption(value: 'android', label: 'Android app', icon: LucideIcons.smartphone),
          FilterOption(value: 'ios', label: 'iOS app', icon: LucideIcons.smartphone),
          FilterOption(value: 'linux', label: 'Linux desktop', icon: LucideIcons.terminal),
          FilterOption(value: 'macos', label: 'macOS desktop', icon: LucideIcons.laptop),
          FilterOption(value: 'windows', label: 'Windows desktop', icon: LucideIcons.monitor),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            if (s.platform.isNotEmpty && seen.add(s.platform.toLowerCase())) {
              res.add(FilterOption(value: s.platform, icon: LucideIcons.layers));
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'release',
        label: 'release',
        description: context.l10n.filterReleaseDesc,
        icon: LucideIcons.tag,
        options: const [
          FilterOption(value: '1.0.0', icon: LucideIcons.tag),
          FilterOption(value: '1.0.0+1', icon: LucideIcons.tag),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            if (s.release.isNotEmpty && seen.add(s.release.toLowerCase())) {
              res.add(FilterOption(value: s.release, icon: LucideIcons.tag));
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'route',
        label: 'route',
        description: context.l10n.filterRouteDesc,
        icon: LucideIcons.milestone,
        options: const [
          FilterOption(value: '/', label: 'Home root', icon: LucideIcons.milestone),
          FilterOption(value: '/cashier', label: 'Cashier checkout', icon: LucideIcons.milestone),
          FilterOption(value: '/login', label: 'Sign in', icon: LucideIcons.milestone),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            if (s.currentRoute.isNotEmpty && seen.add(s.currentRoute.toLowerCase())) {
              res.add(FilterOption(value: s.currentRoute, icon: LucideIcons.milestone));
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'user',
        label: 'user',
        description: context.l10n.filterUserDesc,
        icon: LucideIcons.user,
        options: const [
          FilterOption(value: 'anonymous', label: 'Anonymous sessions', icon: LucideIcons.userX),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            if (s.userId.isNotEmpty && seen.add(s.userId.toLowerCase())) {
              res.add(
                FilterOption(
                  value: s.userId,
                  label: s.userLabel.isNotEmpty ? s.userLabel : null,
                  icon: LucideIcons.user,
                ),
              );
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'os',
        label: 'os',
        description: context.l10n.filterOsDesc,
        icon: LucideIcons.cpu,
        options: const [
          FilterOption(value: 'Linux', icon: LucideIcons.terminal),
          FilterOption(value: 'macOS', icon: LucideIcons.laptop),
          FilterOption(value: 'Windows', icon: LucideIcons.monitor),
          FilterOption(value: 'Android', icon: LucideIcons.smartphone),
          FilterOption(value: 'iOS', icon: LucideIcons.smartphone),
        ],
        dynamicOptions: () {
          if (sessions == null) return const [];
          final res = <FilterOption>[];
          final seen = <String>{};
          for (final s in sessions) {
            if (s.osName.isNotEmpty && s.osName != '—' && seen.add(s.osName.toLowerCase())) {
              res.add(FilterOption(value: s.osName, icon: LucideIcons.cpu));
            }
          }
          return res;
        },
      ),
      FilterKeyDefinition(
        key: 'errors',
        label: 'errors',
        description: context.l10n.filterErrorsDesc,
        icon: LucideIcons.circleAlert,
        options: const [
          FilterOption(value: 'true', label: 'Sessions with errors', icon: LucideIcons.circleAlert),
          FilterOption(value: 'false', label: 'Sessions without errors', icon: LucideIcons.circleCheck),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveQuery = widget.query.isNotEmpty
        ? widget.query
        : (widget.user.isNotEmpty ? 'user:${widget.user}' : '');
    final key = (
      project: widget.projectId,
      onlyErrors: widget.onlyErrors,
      user: widget.user,
      query: effectiveQuery,
    );
    final sessions = ref.watch(sessionsProvider(key));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.sessionsTitle,
            subtitle: sessions.value == null
                ? null
                : context.l10n.sessionsCount(sessions.value!.length),
            actions: [
              FilterSearchField(
                controller: _query,
                placeholder: context.l10n.searchHint,
                onSubmitted: (v) => _go(query: v.trim()),
                onClear: () => _go(query: ''),
                filterKeys: _buildFilterKeys(context, sessions.value),
                width: 320,
              ),
              Toggle(
                value: widget.onlyErrors,
                onChanged: (v) => _go(onlyErrors: v),
                child: Text(context.l10n.sessionsOnlyErrors),
              ),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(sessionsProvider(key)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(12),
          QuickFilterBar(
            showClear: _query.text.isNotEmpty,
            onClear: () {
              _query.clear();
              _go(query: '');
            },
            chips: [
              QuickFilterChip(
                token: 'browser:Chrome',
                icon: LucideIcons.globe,
                selected: _hasFilter('browser:Chrome'),
                onTap: () => _toggleFilter('browser:Chrome'),
              ),
              QuickFilterChip(
                token: 'platform:web',
                icon: LucideIcons.layers,
                selected: _hasFilter('platform:web'),
                onTap: () => _toggleFilter('platform:web'),
              ),
              QuickFilterChip(
                token: 'release:1.0',
                icon: LucideIcons.gitBranch,
                selected: _hasFilter('release:1.0'),
                onTap: () => _toggleFilter('release:1.0'),
              ),
              QuickFilterChip(
                token: 'route:/cashier',
                icon: LucideIcons.mapPin,
                selected: _hasFilter('route:/cashier'),
                onTap: () => _toggleFilter('route:/cashier'),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: PanelCard(
              title: context.l10n.sessionsRecent,
              child: sessions.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  context.l10n.sessionsLoadFailed(
                    describeError(context.l10n, e),
                  ),
                  color: Tokens.danger,
                ),
                data: (list) => SingleChildScrollView(
                  child: DataTable<Session>(
                    columns: [
                      (context.l10n.colSession, 2, false),
                      (context.l10n.colUser, 3, false),
                      (context.l10n.colIp, 2, false),
                      (context.l10n.colLocation, 3, false),
                      (context.l10n.colPlatform, 2, false),
                      (context.l10n.colRelease, 2, false),
                      (context.l10n.colStart, 3, false),
                      (context.l10n.colDuration, 2, true),
                      (context.l10n.colError, 1, true),
                      (context.l10n.colEvent, 1, true),
                      (context.l10n.colFrame, 1, true),
                      (context.l10n.colStatus, 2, true),
                    ],
                    rows: list,
                    emptyText: context.l10n.sessionsEmpty,
                    onTap: (s) => context.go(
                      '/projects/${widget.projectId}/sessions/${s.id}',
                    ),
                    cells: (s) => [
                      Text(
                        context.fmt.shortId(s.id),
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        s.userLabel.isEmpty
                            ? context.l10n.commonAnonymous
                            : s.userLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Tokens.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.ip.isEmpty ? context.l10n.commonEmpty : s.ip,
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      LocationBadge(
                        session: s,
                        compact: true,
                        showCoordinates: false,
                      ),
                      Text(
                        platformLabel(
                          s.platform,
                          s.browser,
                          appType: s.appType,
                          os: s.osName,
                          osVersion: s.osVersion,
                          empty: context.l10n.commonEmpty,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Tokens.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.release.isEmpty
                            ? context.l10n.commonEmpty
                            : s.release,
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.fmt.dateTime(s.startedAt),
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.fmt.duration(s.duration),
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        '${s.errorCount}',
                        style: AppTheme.mono(
                          size: 12,
                          weight: FontWeight.w600,
                          color: s.errorCount > 0
                              ? Tokens.danger
                              : Tokens.textDim,
                        ),
                      ),
                      Text(
                        '${s.eventCount}',
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        '${s.frameCount}',
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                      ),
                      s.endedAt == null
                          ? Pill(context.l10n.commonOpen, color: Tokens.ok)
                          : Pill(context.l10n.commonEnded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a multi-part label for the session platform / device.
/// e.g. "browser · Chrome · Windows 10" or "desktop · Ubuntu 24.04" or "mobile · Android 14".
/// When appType is empty, it falls back to the legacy "platform · browser" format.
/// [empty] is the text shown when neither is known (it comes from the translations).
String platformLabel(
  String platform,
  String browser, {
  String appType = '',
  String os = '',
  String osVersion = '',
  String empty = '—',
}) {
  final parts = <String>[];
  final primaryType = appType.isNotEmpty ? appType : platform;
  if (primaryType.isNotEmpty) {
    parts.add(primaryType);
  }

  // Include browser if present and adds information beyond the primary type
  if (browser.isNotEmpty &&
      browser.toLowerCase() != primaryType.toLowerCase() &&
      !browser.endsWith(' app')) {
    parts.add(browser);
  }

  // Include OS (e.g. "Ubuntu 24.04" or "Windows 10" or "Android 14")
  final osParts = <String>[
    if (os.isNotEmpty &&
        os != '—' &&
        os.toLowerCase() != primaryType.toLowerCase() &&
        os.toLowerCase() != browser.toLowerCase())
      os,
    if (osVersion.isNotEmpty &&
        os.isNotEmpty &&
        os != '—' &&
        os.toLowerCase() != primaryType.toLowerCase())
      osVersion,
  ];
  if (osParts.isNotEmpty) {
    parts.add(osParts.join(' '));
  }

  return parts.isEmpty ? empty : parts.join(' · ');
}
