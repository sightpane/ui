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

class IssuesPage extends ConsumerStatefulWidget {
  const IssuesPage({
    super.key,
    required this.projectId,
    this.includeResolved = false,
    this.query = '',
  });
  final int projectId;
  final bool includeResolved;
  final String query;

  @override
  ConsumerState<IssuesPage> createState() => _IssuesPageState();
}

class _IssuesPageState extends ConsumerState<IssuesPage> {
  late final _query = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(IssuesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_query.text != widget.query) {
      _query.text = widget.query;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _go({bool? includeResolved, String? query}) {
    final q = query ?? _query.text.trim();
    final res = includeResolved ?? widget.includeResolved;
    final qp = <String, String>{
      if (res) 'resolved': '1',
      if (q.isNotEmpty) 'q': q,
    };
    context.go(
      Uri(
        path: '/projects/${widget.projectId}/issues',
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

  @override
  Widget build(BuildContext context) {
    final key = (
      project: widget.projectId,
      includeResolved: widget.includeResolved,
      query: widget.query,
    );
    final issues = ref.watch(issuesProvider(key));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.issuesTitle,
            subtitle: issues.value == null
                ? null
                : context.l10n.issuesOpenCount(
                    issues.value!.where((i) => !i.resolved).length,
                  ),
            actions: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _query,
                  placeholder: Text(context.l10n.searchPlaceholderIssues),
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
                value: widget.includeResolved,
                onChanged: (v) => _go(includeResolved: v),
                child: Text(context.l10n.issuesShowResolved),
              ),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(issuesProvider(key)),
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
                token: 'resolved:false',
                icon: LucideIcons.circleDot,
                selected: _hasFilter('resolved:false'),
                onTap: () => _toggleFilter('resolved:false'),
              ),
              QuickFilterChip(
                token: 'resolved:true',
                icon: LucideIcons.circleCheck,
                selected: _hasFilter('resolved:true'),
                onTap: () => _toggleFilter('resolved:true'),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: PanelCard(
              title: context.l10n.issuesGroups,
              subtitle: context.l10n.issuesGroupingNote,
              child: issues.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  context.l10n.issuesLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
                data: (list) => SingleChildScrollView(
                  child: DataTable<Issue>(
                    columns: [
                      (context.l10n.colError, 6, false),
                      (context.l10n.colException, 2, false),
                      (context.l10n.colCount, 1, true),
                      (context.l10n.colFirst, 2, true),
                      (context.l10n.colLast, 2, true),
                      (context.l10n.colStatus, 1, true),
                    ],
                    rows: list,
                    emptyText: context.l10n.issuesEmpty,
                    onTap: (i) =>
                        context.go('/projects/${widget.projectId}/issues/${i.id}'),
                    cells: (i) => [
                      Text(
                        i.title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Tokens.text,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        i.exception,
                        style: AppTheme.mono(size: 11, color: Tokens.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.fmt.integer(i.count),
                        style: AppTheme.mono(
                          size: 12,
                          weight: FontWeight.w600,
                          color: Tokens.danger,
                        ),
                      ),
                      Text(
                        context.fmt.relative(i.firstSeen),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Tokens.textDim,
                        ),
                      ),
                      Text(
                        context.fmt.relative(i.lastSeen),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Tokens.textDim,
                        ),
                      ),
                      i.resolved
                          ? Pill(context.l10n.commonResolved, color: Tokens.ok)
                          : Pill(context.l10n.commonOpen, color: Tokens.accent),
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
