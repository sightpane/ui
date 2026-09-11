// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import '../projects/export_downloader_stub.dart'
    if (dart.library.js_interop) '../projects/export_downloader_web.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({
    super.key,
    required this.projectId,
    required this.userId,
    this.initialUser,
  });

  final int projectId;
  final String userId;
  final UserSummary? initialUser;

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  bool _busy = false;

  Future<void> _deleteUser(UserSummary u) async {
    final ok = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: context.l10n.actionDeleteData,
        message: context.l10n.userDeleteConfirm,
        confirmLabel: context.l10n.commonDelete,
        destructive: true,
        onConfirm: () async {
          setState(() => _busy = true);
          try {
            await ref
                .read(apiProvider)
                .deleteUserData(widget.projectId, u.userId);
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
      ),
    );
    if (ok == true && mounted) {
      toast(context, context.l10n.userDeleteSuccess);
      ref.invalidate(usersProvider);
      context.go('/projects/${widget.projectId}/users');
    }
  }

  void _exportUser(UserSummary u) {
    final url =
        ref.read(apiProvider).userExportUrl(widget.projectId, u.userId);
    downloadExportUrl(url);
    toast(context, '${u.userId} export started');
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(
      usersProvider((
        project: widget.projectId,
        days: 90,
        query: widget.userId,
      )),
    );

    final usersList = usersAsync.value?.users ?? const [];
    final UserSummary? user = widget.initialUser ??
        (usersList.any((u) => u.userId == widget.userId)
            ? usersList.firstWhere((u) => u.userId == widget.userId)
            : (usersList.isNotEmpty ? usersList.first : null));

    if (user == null) {
      if (usersAsync.isLoading) {
        return Center(child: Text(context.l10n.commonLoading));
      }
      return PanelMessage(context.l10n.usersEmpty);
    }

    final u = user;
    final isAnon = u.userId.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            breadcrumb: AppBreadcrumb(
              items: [
                BreadcrumbItem(
                  label: context.l10n.usersTitle,
                  path: '/projects/${widget.projectId}/users',
                ),
                BreadcrumbItem(
                  label: isAnon
                      ? context.l10n.commonAnonymous
                      : (u.displayName.isNotEmpty ? u.displayName : u.userId),
                ),
              ],
            ),
            title: isAnon
                ? context.l10n.commonAnonymous
                : (u.displayName.isNotEmpty ? u.displayName : u.userId),
            subtitle: u.lastIP.isNotEmpty ? 'IP: ${u.lastIP}' : null,
            actions: [
              OutlineButton(
                size: ButtonSize.small,
                density: ButtonDensity.compact,
                leading: const Icon(LucideIcons.video, size: 14),
                onPressed: () {
                  context.go(
                    '/projects/${widget.projectId}/sessions?q=user:${Uri.encodeComponent(u.userId)}',
                  );
                },
                child: Text(context.l10n.actionViewSessions),
              ),
              if (!isAnon) ...[
                OutlineButton(
                  size: ButtonSize.small,
                  density: ButtonDensity.compact,
                  leading: const Icon(LucideIcons.download, size: 14),
                  onPressed: () => _exportUser(u),
                  child: Text(context.l10n.actionExportData),
                ),
                DestructiveButton(
                  size: ButtonSize.small,
                  density: ButtonDensity.compact,
                  leading: const Icon(LucideIcons.trash2, size: 14),
                  onPressed: _busy ? null : () => _deleteUser(u),
                  child: Text(context.l10n.actionDeleteData),
                ),
              ],
            ],
          ),
          const Gap(16),
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
          const Gap(16),
          PanelCard(
            title: context.l10n.colPlatform,
            child: Column(
              children: [
                if (u.lastPlatform.isNotEmpty)
                  CopyField(
                    label: context.l10n.colPlatform,
                    value: u.lastPlatform,
                  ),
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
            const Gap(16),
            PanelCard(
              title: context.l10n.userCustomProps,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in u.user.entries)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
    );
  }
}
