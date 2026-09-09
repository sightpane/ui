import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import '../sessions/session_detail_page.dart' show CodeBlock;

class IssueDetailPage extends ConsumerWidget {
  const IssueDetailPage({
    super.key,
    required this.projectId,
    required this.issueId,
  });
  final int projectId;
  final int issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(issueDetailProvider(issueId));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: detail.when(
        loading: () => PanelMessage(context.l10n.commonLoading),
        error: (e, _) => PanelMessage(
          context.l10n.issueDetailFailed(describeError(context.l10n, e)),
          color: Tokens.danger,
        ),
        data: (d) {
          final i = d.issue;
          final first = d.occurrences.isEmpty
              ? const <String, Object?>{}
              : d.occurrences.first.body;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: i.title,
                subtitle: context.l10n.issueSeenSummary(
                  context.fmt.integer(i.count),
                  context.fmt.dateTime(i.firstSeen),
                  context.fmt.dateTime(i.lastSeen),
                ),
                actions: [
                  GhostButton(
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.chevronLeft, size: 14),
                    onPressed: () => context.go('/projects/$projectId/issues'),
                    child: Text(context.l10n.issuesTitle),
                  ),
                  i.resolved
                      ? OutlineButton(
                          size: ButtonSize.small,
                          onPressed: () async {
                            await ref
                                .read(apiProvider)
                                .resolveIssue(issueId, undo: true);
                            ref.invalidate(issueDetailProvider(issueId));
                          },
                          child: Text(context.l10n.issueReopen),
                        )
                      : PrimaryButton(
                          size: ButtonSize.small,
                          leading: const Icon(LucideIcons.check, size: 14),
                          onPressed: () async {
                            await ref.read(apiProvider).resolveIssue(issueId);
                            ref.invalidate(issueDetailProvider(issueId));
                            if (context.mounted) {
                              toast(
                                context,
                                context.l10n.issueResolvedToast,
                                subtitle: context.l10n.issueResolvedToastNote,
                              );
                            }
                          },
                          child: Text(context.l10n.issueResolve),
                        ),
                ],
              ),
              const Gap(12),
              PanelCard(
                title: context.l10n.issueStack,
                subtitle: i.exception,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: CodeBlock(
                    text: '${first['stack'] ?? context.l10n.issueNoStack}',
                  ),
                ),
              ),
              const Gap(12),
              PanelCard(
                title: context.l10n.issueOccurrences,
                subtitle: context.l10n.issueOccurrencesNote(
                  d.occurrences.length,
                ),
                child: DataTable<TimelineItem>(
                  columns: [
                    (context.l10n.colTime, 2, false),
                    (context.l10n.colSession, 2, false),
                    (context.l10n.colRoute, 2, false),
                    (context.l10n.colFrame, 1, true),
                    (context.l10n.colMessage, 5, false),
                  ],
                  rows: d.occurrences,
                  onTap: (o) => context.go(
                    '/projects/$projectId/sessions/${o.sessionId}',
                  ),
                  cells: (o) => [
                    Text(
                      context.fmt.dateTime(o.ts),
                      style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                    ),
                    Text(
                      context.fmt.shortId(o.sessionId),
                      style: AppTheme.mono(size: 12, color: Tokens.info),
                    ),
                    Text(
                      '${o.body['route'] ?? context.l10n.commonEmpty}',
                      style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                    ),
                    Text(
                      o.body['frame_seq'] == null
                          ? context.l10n.commonEmpty
                          : '#${o.body['frame_seq']}',
                      style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                    ),
                    Text(
                      '${o.body['message'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Tokens.text),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
