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
import '../sessions/session_detail_page.dart' show StackTraceView;

class IssueDetailPage extends ConsumerStatefulWidget {
  const IssueDetailPage({
    super.key,
    required this.projectId,
    required this.issueId,
  });
  final int projectId;
  final int issueId;

  @override
  ConsumerState<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends ConsumerState<IssueDetailPage> {
  final _commentController = TextEditingController();
  bool _submittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _submittingComment) return;
    setState(() => _submittingComment = true);
    try {
      await ref.read(apiProvider).addIssueComment(widget.issueId, text);
      _commentController.clear();
      ref.invalidate(issueCommentsProvider(widget.issueId));
    } catch (e) {
      if (mounted) {
        toast(context, describeError(context.l10n, e));
      }
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(issueDetailProvider(widget.issueId));
    final comments = ref.watch(issueCommentsProvider(widget.issueId));

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
          final firstItem = d.occurrences.isEmpty ? null : d.occurrences.first;
          final first = firstItem?.body ?? const <String, Object?>{};
          final isOpen = i.status == 'open' && !i.resolved;

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
                    onPressed: () =>
                        context.go('/projects/${widget.projectId}/issues'),
                    child: Text(context.l10n.issuesTitle),
                  ),
                  if (!isOpen)
                    OutlineButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.rotateCcw, size: 14),
                      onPressed: () async {
                        await ref
                            .read(apiProvider)
                            .setIssueStatus(widget.issueId, 'open');
                        await ref
                            .read(apiProvider)
                            .resolveIssue(widget.issueId, undo: true);
                        ref.invalidate(issueDetailProvider(widget.issueId));
                      },
                      child: Text(context.l10n.issueReopen),
                    )
                  else ...[
                    GhostButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.eyeOff, size: 14),
                      onPressed: () async {
                        await ref
                            .read(apiProvider)
                            .setIssueStatus(widget.issueId, 'ignored');
                        ref.invalidate(issueDetailProvider(widget.issueId));
                        if (context.mounted) {
                          toast(context, context.l10n.issueIgnoredToast);
                        }
                      },
                      child: Text(context.l10n.issueActionIgnore),
                    ),
                    SecondaryButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.clock, size: 14),
                      onPressed: () {
                        showAppDialog(
                          context,
                          _SnoozeDialog(
                            onSnooze:
                                ({
                                  DateTime? until,
                                  int countThreshold = 0,
                                }) async {
                                  await ref
                                      .read(apiProvider)
                                      .snoozeIssue(
                                        widget.issueId,
                                        until: until,
                                        countThreshold: countThreshold,
                                      );
                                  ref.invalidate(
                                    issueDetailProvider(widget.issueId),
                                  );
                                  if (context.mounted) {
                                    toast(
                                      context,
                                      context.l10n.issueSnoozedToast,
                                    );
                                  }
                                },
                          ),
                        );
                      },
                      child: Text(context.l10n.issueActionSnooze),
                    ),
                    PrimaryButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.check, size: 14),
                      onPressed: () async {
                        await ref
                            .read(apiProvider)
                            .setIssueStatus(widget.issueId, 'resolved');
                        await ref
                            .read(apiProvider)
                            .resolveIssue(widget.issueId);
                        ref.invalidate(issueDetailProvider(widget.issueId));
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
                ],
              ),
              const Gap(12),
              // Status & Assignee Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Tokens.panel,
                  borderRadius: BorderRadius.circular(Tokens.radius),
                  border: Border.all(color: Tokens.border),
                ),
                child: Row(
                  children: [
                    Text(
                      '${context.l10n.issueStatus}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Tokens.textDim,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: i.status == 'resolved' || i.resolved
                            ? Tokens.ok.withValues(alpha: 0.15)
                            : i.status == 'snoozed'
                            ? Tokens.brand.withValues(alpha: 0.15)
                            : i.status == 'ignored'
                            ? Tokens.textMuted.withValues(alpha: 0.15)
                            : Tokens.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        i.status == 'resolved' || i.resolved
                            ? context.l10n.issueStatusResolved
                            : i.status == 'snoozed'
                            ? context.l10n.issueStatusSnoozed
                            : i.status == 'ignored'
                            ? context.l10n.issueStatusIgnored
                            : context.l10n.issueStatusOpen,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i.status == 'resolved' || i.resolved
                              ? Tokens.ok
                              : i.status == 'snoozed'
                              ? Tokens.brand
                              : i.status == 'ignored'
                              ? Tokens.textMuted
                              : Tokens.info,
                        ),
                      ),
                    ),
                    const Gap(24),
                    Text(
                      '${context.l10n.issueAssignee}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Tokens.textDim,
                      ),
                    ),
                    OutlineButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.user, size: 14),
                      onPressed: () {
                        showAppDialog(
                          context,
                          _AssignDialog(
                            projectId: widget.projectId,
                            currentUserId: i.assigneeUserId,
                            onAssign: (userId) async {
                              await ref
                                  .read(apiProvider)
                                  .assignIssue(widget.issueId, userId);
                              ref.invalidate(
                                issueDetailProvider(widget.issueId),
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        i.assigneeEmail ?? context.l10n.issueUnassigned,
                      ),
                    ),
                    if (i.firstRelease.isNotEmpty ||
                        i.lastRelease.isNotEmpty ||
                        i.resolvedInRelease.isNotEmpty) ...[
                      const Gap(24),
                      const Icon(
                        LucideIcons.tag,
                        size: 13,
                        color: Tokens.textDim,
                      ),
                      const Gap(6),
                      if (i.firstRelease.isNotEmpty) ...[
                        Text(
                          '${context.l10n.issueReleaseFirst}: ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Tokens.textDim,
                          ),
                        ),
                        Text(
                          i.firstRelease,
                          style: AppTheme.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: Tokens.text,
                          ),
                        ),
                        const Gap(12),
                      ],
                      if (i.lastRelease.isNotEmpty) ...[
                        Text(
                          '${context.l10n.issueReleaseLast}: ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Tokens.textDim,
                          ),
                        ),
                        Text(
                          i.lastRelease,
                          style: AppTheme.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: Tokens.text,
                          ),
                        ),
                        const Gap(12),
                      ],
                      if (i.resolvedInRelease.isNotEmpty) ...[
                        Text(
                          '${context.l10n.issueReleaseResolvedIn}: ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Tokens.textDim,
                          ),
                        ),
                        Text(
                          i.resolvedInRelease,
                          style: AppTheme.mono(
                            size: 12,
                            weight: FontWeight.w600,
                            color: Tokens.ok,
                          ),
                        ),
                      ],
                    ],
                    if (d.activeSession != null) ...[
                      const Spacer(),
                      ClientEnvironmentPill(session: d.activeSession!),
                    ],
                  ],
                ),
              ),

              if (d.activeSession != null) ...[
                const Gap(12),
                ClientEnvironmentCard(session: d.activeSession!),
              ],

              const Gap(12),
              PanelCard(
                title: context.l10n.issueStack,
                subtitle: i.exception,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: StackTraceView(
                    stack: '${first['stack'] ?? ''}',
                    frames: firstItem?.frames ?? const [],
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
                    (context.l10n.clientPlatform, 3, false),
                    (context.l10n.colRoute, 2, false),
                    (context.l10n.colFrame, 1, true),
                    (context.l10n.colMessage, 4, false),
                  ],
                  rows: d.occurrences,
                  onTap: (o) => context.go(
                    '/projects/${widget.projectId}/sessions/${o.sessionId}',
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
                    ClientEnvironmentPill(session: o.toSession()),
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
              const Gap(12),
              PanelCard(
                title: context.l10n.issueComments,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      comments.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(
                          describeError(context.l10n, e),
                          style: const TextStyle(
                            color: Tokens.danger,
                            fontSize: 12,
                          ),
                        ),
                        data: (list) {
                          if (list.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                context.l10n.issueCommentsEmpty,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Tokens.textMuted,
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final c in list) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Tokens.bg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Tokens.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.userName.isNotEmpty
                                                ? c.userName
                                                : 'User #${c.userId}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Tokens.textStrong,
                                            ),
                                          ),
                                          const Gap(8),
                                          Text(
                                            context.fmt.dateTime(c.createdAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Tokens.textDim,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(6),
                                      Text(
                                        c.body,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Tokens.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                              ],
                            ],
                          );
                        },
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              placeholder: Text(context.l10n.issueCommentAdd),
                              onSubmitted: (_) => _submitComment(),
                            ),
                          ),
                          const Gap(8),
                          PrimaryButton(
                            size: ButtonSize.small,
                            leading: _submittingComment
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(LucideIcons.send, size: 14),
                            onPressed: _submittingComment
                                ? null
                                : _submitComment,
                            child: Text(context.l10n.issueCommentSend),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SnoozeDialog extends StatelessWidget {
  const _SnoozeDialog({required this.onSnooze});
  final Future<void> Function({DateTime? until, int countThreshold}) onSnooze;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.issueSnoozeTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(context.l10n.issueSnoozeDuration),
            const Gap(6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(
                      until: DateTime.now().add(const Duration(hours: 1)),
                    );
                  },
                  child: Text(context.l10n.issueSnooze1Hour),
                ),
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(
                      until: DateTime.now().add(const Duration(hours: 24)),
                    );
                  },
                  child: Text(context.l10n.issueSnooze24Hours),
                ),
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(
                      until: DateTime.now().add(const Duration(days: 7)),
                    );
                  },
                  child: Text(context.l10n.issueSnooze7Days),
                ),
              ],
            ),
            const Gap(16),
            FieldLabel(context.l10n.issueSnoozeCount),
            const Gap(6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(countThreshold: 10);
                  },
                  child: Text(context.l10n.issueSnoozeCount10),
                ),
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(countThreshold: 50);
                  },
                  child: Text(context.l10n.issueSnoozeCount50),
                ),
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSnooze(countThreshold: 100);
                  },
                  child: Text(context.l10n.issueSnoozeCount100),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        GhostButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
      ],
    );
  }
}

class _AssignDialog extends ConsumerWidget {
  const _AssignDialog({
    required this.projectId,
    required this.currentUserId,
    required this.onAssign,
  });
  final int projectId;
  final int? currentUserId;
  final Future<void> Function(int? userId) onAssign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider(projectId));
    return AlertDialog(
      title: Text(context.l10n.issueAssignee),
      content: SizedBox(
        width: 360,
        child: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(describeError(context.l10n, e)),
          data: (members) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GhostButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAssign(null);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.issueUnassigned,
                      style: TextStyle(
                        fontWeight: currentUserId == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                for (final m in members) ...[
                  GhostButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAssign(m.userId);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${m.name} (${m.email})',
                              style: TextStyle(
                                fontWeight: currentUserId == m.userId
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (currentUserId == m.userId)
                            const Icon(LucideIcons.check, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const Gap(4),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        GhostButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
      ],
    );
  }
}
