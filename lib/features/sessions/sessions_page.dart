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
    if (_query.text != expected) {
      _query.text = expected;
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

  void _addFilter(String token) {
    final cur = _query.text.trim();
    if (cur.contains(token)) return;
    final updated = cur.isEmpty ? token : '$cur $token';
    _query.text = updated;
    _go(query: updated);
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
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _query,
                  placeholder: Text(context.l10n.searchHint),
                  onSubmitted: (v) => _go(query: v.trim()),
                  features: [
                    const InputFeature.leading(Icon(LucideIcons.search, size: 14)),
                    if (_query.text.isNotEmpty)
                      InputFeature.trailing(
                        GhostButton(
                          density: ButtonDensity.compact,
                          size: ButtonSize.xSmall,
                          onPressed: () {
                            _query.clear();
                            _go(query: '');
                          },
                          child: const Icon(LucideIcons.x, size: 12),
                        ),
                      ),
                  ],
                ),
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
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.l10n.searchFilterQuick,
                style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
              ),
              OutlineButton(
                size: ButtonSize.xSmall,
                density: ButtonDensity.compact,
                onPressed: () => _addFilter('browser:Chrome'),
                child: const Text('browser:Chrome'),
              ),
              OutlineButton(
                size: ButtonSize.xSmall,
                density: ButtonDensity.compact,
                onPressed: () => _addFilter('platform:web'),
                child: const Text('platform:web'),
              ),
              OutlineButton(
                size: ButtonSize.xSmall,
                density: ButtonDensity.compact,
                onPressed: () => _addFilter('release:1.0'),
                child: const Text('release:1.0'),
              ),
              OutlineButton(
                size: ButtonSize.xSmall,
                density: ButtonDensity.compact,
                onPressed: () => _addFilter('route:/cashier'),
                child: const Text('route:/cashier'),
              ),
              if (_query.text.isNotEmpty)
                GhostButton(
                  size: ButtonSize.xSmall,
                  density: ButtonDensity.compact,
                  onPressed: () {
                    _query.clear();
                    _go(query: '');
                  },
                  child: Text(context.l10n.searchClear),
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
                      ),
                      Text(
                        platformLabel(
                          s.platform,
                          s.browser,
                          empty: context.l10n.commonEmpty,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Tokens.textMuted,
                        ),
                      ),
                      Text(
                        s.release.isEmpty
                            ? context.l10n.commonEmpty
                            : s.release,
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        context.fmt.dateTime(s.startedAt),
                        style: AppTheme.mono(size: 12, color: Tokens.textMuted),
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

/// "web · Chrome"; only the platform when there is no browser, and no
/// repetition when the two are the same. [empty] is the text shown when neither
/// is known (it comes from the translations).
String platformLabel(String platform, String browser, {String empty = '—'}) {
  final parts = <String>[
    if (platform.isNotEmpty) platform,
    if (browser.isNotEmpty && browser != platform) browser,
  ];
  return parts.isEmpty ? empty : parts.join(' · ');
}
