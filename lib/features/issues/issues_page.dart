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

class IssuesPage extends ConsumerWidget {
  const IssuesPage({
    super.key,
    required this.projectId,
    this.includeResolved = false,
  });
  final int projectId;
  final bool includeResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (project: projectId, includeResolved: includeResolved);
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
              Toggle(
                value: includeResolved,
                onChanged: (v) => context.go(
                  '/projects/$projectId/issues${v ? '?resolved=1' : ''}',
                ),
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
                        context.go('/projects/$projectId/issues/${i.id}'),
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
