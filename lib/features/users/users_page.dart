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
import '../projects/export_downloader_stub.dart'
    if (dart.library.js_interop) '../projects/export_downloader_web.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({
    super.key,
    required this.projectId,
    this.query = '',
    this.days = 14,
  });

  final int projectId;
  final String query;
  final int days;

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  late int _days = widget.days;
  late final TextEditingController _searchController = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(UsersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && _searchController.text != widget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDetail(BuildContext context, UserSummary user) {
    showAppDialog(
      context,
      _UserDetailDialog(
        projectId: widget.projectId,
        user: user,
        onRefresh: () => ref.invalidate(
          usersProvider((
            project: widget.projectId,
            days: _days,
            query: _searchController.text.trim(),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final usersAsync = ref.watch(
      usersProvider((
        project: widget.projectId,
        days: _days,
        query: query,
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.usersTitle,
            subtitle: usersAsync.maybeWhen(
              data: (d) => context.l10n.usersSubtitle(d.totalUsers),
              orElse: () => null,
            ),
            actions: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchController,
                  placeholder: Text(context.l10n.usersSearchPlaceholder),
                  features: [
                    const InputFeature.leading(Icon(LucideIcons.search, size: 14)),
                    if (_searchController.text.isNotEmpty)
                      InputFeature.trailing(
                        GhostButton(
                          density: ButtonDensity.compact,
                          size: ButtonSize.xSmall,
                          onPressed: () {
                            setState(() => _searchController.clear());
                          },
                          child: const Icon(LucideIcons.x, size: 12),
                        ),
                      ),
                  ],
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              const Gap(8),
              for (final d in const [7, 14, 30, 90]) ...[
                _days == d
                    ? SecondaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.overviewDaysShort(d)),
                      )
                    : GhostButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _days = d),
                        child: Text(context.l10n.overviewDaysShort(d)),
                      ),
                const Gap(4),
              ],
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(
                  usersProvider((
                    project: widget.projectId,
                    days: _days,
                    query: query,
                  )),
                ),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: usersAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: PanelMessage(
                  context.l10n.usersLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
              ),
              data: (data) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KpiRow([
                      KpiTile(
                        label: context.l10n.kpiTotalUsers,
                        value: context.fmt.integer(data.totalUsers),
                      ),
                      KpiTile(
                        label: context.l10n.kpiActiveUsers,
                        value: context.fmt.integer(data.activeUsers),
                      ),
                      KpiTile(
                        label: context.l10n.kpiAvgDuration,
                        value: context.fmt.duration(data.avgDuration),
                      ),
                      KpiTile(
                        label: context.l10n.kpiSessionsPerUser,
                        value: data.sessionsPerUser.toStringAsFixed(1),
                      ),
                    ]),
                    if (data.daily.isNotEmpty) ...[
                      const Gap(14),
                      PanelCard(
                        title: context.l10n.chartActiveUsers,
                        subtitle: context.l10n.chartActiveUsersSub,
                        child: BarChart(
                          values: [for (final d in data.daily) d.activeUsers],
                          secondary: [for (final d in data.daily) d.errorUsers],
                          labels: [for (final d in data.daily) context.fmt.day(d.day)],
                          color: Tokens.accent,
                          secondaryColor: Tokens.danger,
                          height: 110,
                        ),
                      ),
                    ],
                    const Gap(14),
                    PanelCard(
                      title: context.l10n.usersTitle,
                      subtitle: context.l10n.usersSubtitle(data.users.length),
                      child: data.users.isEmpty
                          ? PanelMessage(context.l10n.usersEmpty)
                          : DataTable<UserSummary>(
                              columns: [
                                (context.l10n.colUser, 4, false),
                                (context.l10n.kpiSessions, 2, true),
                                (context.l10n.colAvgDuration, 2, true),
                                (context.l10n.kpiErrors, 2, true),
                                (context.l10n.colPlatform, 3, false),
                                (context.l10n.colFirstSeen, 2, false),
                                (context.l10n.colLastSeen, 2, false),
                                ('', 2, true),
                              ],
                              rows: data.users,
                              onTap: (u) => _showUserDetail(context, u),
                              cells: (u) => [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Tokens.accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Center(
                                        child: Text(
                                          u.initials,
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
                                            u.displayName.isEmpty
                                                ? context.l10n.commonAnonymous
                                                : u.displayName,
                                            style: AppTheme.mono(
                                              size: 13,
                                              weight: FontWeight.w600,
                                              color: Tokens.textStrong,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (u.name != null && u.email != null)
                                            Text(
                                              u.email!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Tokens.textDim,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  context.fmt.integer(u.sessionCount),
                                  style: AppTheme.mono(size: 13, color: Tokens.text),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Tokens.chip,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.fmt.duration(u.avgDuration),
                                    style: AppTheme.mono(
                                      size: 11,
                                      color: Tokens.textMuted,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (u.errorCount > 0 ? Tokens.danger : Tokens.ok)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.fmt.integer(u.errorCount),
                                    style: AppTheme.mono(
                                      size: 12,
                                      color: u.errorCount > 0 ? Tokens.danger : Tokens.ok,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (u.lastPlatform.isNotEmpty)
                                      Pill(
                                        u.lastPlatform,
                                        color: Tokens.accent,
                                      ),
                                    if (u.lastPlatform.isNotEmpty && u.lastBrowser.isNotEmpty)
                                      const Gap(4),
                                    if (u.lastBrowser.isNotEmpty)
                                      Pill(
                                        u.lastBrowser,
                                        color: Tokens.textDim,
                                      ),
                                  ],
                                ),
                                Text(
                                  context.fmt.relative(u.firstSeen),
                                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                ),
                                Text(
                                  context.fmt.relative(u.lastSeen),
                                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlineButton(
                                      size: ButtonSize.small,
                                      density: ButtonDensity.compact,
                                      onPressed: () => context.go(
                                        '/projects/${widget.projectId}/sessions?q=user:${Uri.encodeComponent(u.userId)}',
                                      ),
                                      child: const Icon(LucideIcons.video, size: 12),
                                    ),
                                    const Gap(4),
                                    GhostButton(
                                      size: ButtonSize.small,
                                      density: ButtonDensity.compact,
                                      onPressed: () => _showUserDetail(context, u),
                                      child: const Icon(LucideIcons.chevronRight, size: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailDialog extends ConsumerStatefulWidget {
  const _UserDetailDialog({
    required this.projectId,
    required this.user,
    required this.onRefresh,
  });

  final int projectId;
  final UserSummary user;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<_UserDetailDialog> {
  final bool _busy = false;

  Future<void> _deleteUser() async {
    final ok = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: context.l10n.actionDeleteData,
        message: context.l10n.userDeleteConfirm,
        confirmLabel: context.l10n.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteUserData(widget.projectId, widget.user.userId);
        },
      ),
    );
    if (ok == true && mounted) {
      toast(context, context.l10n.userDeleteSuccess);
      widget.onRefresh();
      closeOverlay(context, true);
    }
  }

  void _exportUser() {
    final url = ref.read(apiProvider).userExportUrl(widget.projectId, widget.user.userId);
    downloadExportUrl(url);
    toast(context, '${widget.user.userId} export started');
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final isAnon = u.userId.isEmpty;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Tokens.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                u.initials,
                style: AppTheme.mono(size: 13, weight: FontWeight.w700, color: Tokens.accent),
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAnon ? context.l10n.commonAnonymous : u.displayName,
                  style: AppTheme.mono(size: 15, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (u.lastIP.isNotEmpty)
                  Text(
                    'IP: ${u.lastIP}',
                    style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              KpiRow([
                KpiTile(
                  label: context.l10n.kpiSessions,
                  value: context.fmt.integer(u.sessionCount),
                ),
                KpiTile(
                  label: context.l10n.colAvgDuration,
                  value: context.fmt.duration(u.avgDuration),
                ),
                KpiTile(
                  label: context.l10n.kpiErrors,
                  value: context.fmt.integer(u.errorCount),
                  valueColor: u.errorCount > 0 ? Tokens.danger : Tokens.ok,
                ),
              ]),
              const Gap(14),
              PanelCard(
                title: context.l10n.colPlatform,
                child: Column(
                  children: [
                    if (u.lastPlatform.isNotEmpty)
                      CopyField(label: context.l10n.colPlatform, value: u.lastPlatform),
                    if (u.lastBrowser.isNotEmpty) ...[
                      const Gap(8),
                      CopyField(label: 'Browser', value: u.lastBrowser),
                    ],
                    if (u.lastIP.isNotEmpty) ...[
                      const Gap(8),
                      CopyField(label: 'IP', value: u.lastIP),
                    ],
                    const Gap(8),
                    CopyField(
                      label: context.l10n.colFirstSeen,
                      value: context.fmt.dateTime(u.firstSeen),
                    ),
                    const Gap(8),
                    CopyField(
                      label: context.l10n.colLastSeen,
                      value: context.fmt.dateTime(u.lastSeen),
                    ),
                  ],
                ),
              ),
              if (u.user.isNotEmpty) ...[
                const Gap(14),
                PanelCard(
                  title: context.l10n.userCustomProps,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in u.user.entries)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Tokens.surface,
                            border: Border.all(color: Tokens.hairline),
                            borderRadius: BorderRadius.circular(Tokens.radius),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: AppTheme.mono(size: 11, color: Tokens.text),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        OutlineButton(
          size: ButtonSize.small,
          leading: const Icon(LucideIcons.video, size: 14),
          onPressed: () {
            closeOverlay(context, false);
            context.go(
              '/projects/${widget.projectId}/sessions?q=user:${Uri.encodeComponent(u.userId)}',
            );
          },
          child: Text(context.l10n.actionViewSessions),
        ),
        if (!isAnon) ...[
          OutlineButton(
            size: ButtonSize.small,
            leading: const Icon(LucideIcons.download, size: 14),
            onPressed: _exportUser,
            child: Text(context.l10n.actionExportData),
          ),
          DestructiveButton(
            size: ButtonSize.small,
            leading: const Icon(LucideIcons.trash2, size: 14),
            onPressed: _busy ? null : _deleteUser,
            child: Text(context.l10n.actionDeleteData),
          ),
        ],
        PrimaryButton(
          size: ButtonSize.small,
          onPressed: () => closeOverlay(context, false),
          child: Text(context.l10n.commonClose),
        ),
      ],
    );
  }
}
