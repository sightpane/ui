// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/page_header.dart';

class DashboardsPage extends ConsumerStatefulWidget {
  const DashboardsPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<DashboardsPage> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends ConsumerState<DashboardsPage> {
  @override
  Widget build(BuildContext context) {
    final dashboardsAsync = ref.watch(dashboardsProvider((projectId: widget.projectId)));

    return Scaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: context.l10n.dashboardsTitle,
              subtitle: context.l10n.dashboardsSubtitle,
              actions: [
                OutlineButton(
                  leading: const Icon(LucideIcons.sparkles, size: 16),
                  onPressed: () => context.go('/projects/${widget.projectId}/insights'),
                  child: Text(context.l10n.insightBuilderTitle),
                ),
                const Gap(8),
                PrimaryButton(
                  leading: const Icon(LucideIcons.plus, size: 16),
                  onPressed: () => _showDashboardDialog(context),
                  child: Text(context.l10n.dashboardCreate),
                ),
              ],
            ),
            const Gap(24),
            dashboardsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Card(
                filled: true,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${context.l10n.commonError}: $err',
                    style: const TextStyle(color: Tokens.danger),
                  ),
                ),
              ),
              data: (dashboards) {
                if (dashboards.isEmpty) {
                  return Card(
                    filled: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.layoutGrid, size: 40, color: Tokens.textDim),
                          const Gap(12),
                          Text(
                            context.l10n.dashboardEmpty,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                          ),
                          const Gap(16),
                          PrimaryButton(
                            leading: const Icon(LucideIcons.plus, size: 16),
                            onPressed: () => _showDashboardDialog(context),
                            child: Text(context.l10n.dashboardCreate),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final d in dashboards)
                          SizedBox(
                            width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                            child: Card(
                              filled: true,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  d.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Tokens.textStrong,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (d.isDefault) ...[
                                                const Gap(8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Tokens.accent.withValues(alpha: 0.15),
                                                    border: Border.all(color: Tokens.accent.withValues(alpha: 0.4)),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(LucideIcons.star, size: 11, color: Tokens.accent),
                                                      const Gap(4),
                                                      Text(
                                                        context.l10n.dashboardIsDefault,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: Tokens.accent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton.ghost(
                                          size: ButtonSize.small,
                                          icon: const Icon(LucideIcons.pencil, size: 14),
                                          onPressed: () => _showDashboardDialog(context, dashboard: d),
                                        ),
                                        IconButton.ghost(
                                          size: ButtonSize.small,
                                          icon: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                                          onPressed: () => _deleteDashboard(context, d),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    Text(
                                      d.description.isNotEmpty ? d.description : context.l10n.commonEmpty,
                                      style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Gap(16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Tokens.chip,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${d.layout.length} insights',
                                            style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!d.isDefault) ...[
                                          OutlineButton(
                                            size: ButtonSize.small,
                                            onPressed: () => _setDefault(context, d),
                                            child: Text(context.l10n.dashboardSetDefault),
                                          ),
                                          const Gap(8),
                                        ],
                                        PrimaryButton(
                                          size: ButtonSize.small,
                                          onPressed: () => context.go('/projects/${widget.projectId}/dashboards/${d.id}'),
                                          child: const Text('Open'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, Dashboard d) async {
    final api = ref.read(apiProvider);
    await api.setDefaultDashboard(widget.projectId, d.id);
    ref.invalidate(dashboardsProvider((projectId: widget.projectId)));
  }

  Future<void> _deleteDashboard(BuildContext context, Dashboard d) async {
    await showAppDialog(
      context,
      ConfirmDialog(
        title: context.l10n.dashboardDelete,
        message: context.l10n.dashboardDeleteConfirm,
        confirmLabel: context.l10n.commonDelete,
        destructive: true,
        onConfirm: () async {
          final api = ref.read(apiProvider);
          await api.deleteDashboard(widget.projectId, d.id);
          ref.invalidate(dashboardsProvider((projectId: widget.projectId)));
        },
      ),
    );
  }

  Future<void> _showDashboardDialog(BuildContext context, {Dashboard? dashboard}) async {
    final nameCtrl = TextEditingController(text: dashboard?.name ?? '');
    final descCtrl = TextEditingController(text: dashboard?.description ?? '');
    bool isDefault = dashboard?.isDefault ?? false;

    final isNew = dashboard == null;

    await showAppDialog(
      context,
      StatefulBuilder(
        builder: (ctx, setDialogState) => Center(
          child: Card(
            filled: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isNew ? LucideIcons.layoutGrid : LucideIcons.pencil,
                          size: 18,
                          color: Tokens.brand,
                        ),
                        const Gap(10),
                        Text(
                          isNew ? context.l10n.dashboardCreate : context.l10n.dashboardEdit,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                        ),
                        const Spacer(),
                        IconButton.ghost(
                          size: ButtonSize.small,
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () => closeOverlay(ctx),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Text(context.l10n.dashboardName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textMuted)),
                    const Gap(6),
                    TextField(
                      controller: nameCtrl,
                      placeholder: Text(context.l10n.dashboardNameHint),
                    ),
                    const Gap(16),
                    Text(context.l10n.dashboardDescription, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textMuted)),
                    const Gap(6),
                    TextField(
                      controller: descCtrl,
                      placeholder: Text(context.l10n.dashboardDescriptionHint),
                      maxLines: 3,
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Checkbox(
                          state: isDefault ? CheckboxState.checked : CheckboxState.unchecked,
                          onChanged: (val) {
                            setDialogState(() => isDefault = val == CheckboxState.checked);
                          },
                        ),
                        const Gap(8),
                        Text(context.l10n.dashboardSetDefault, style: const TextStyle(fontSize: 13, color: Tokens.text)),
                      ],
                    ),
                    const Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlineButton(
                          onPressed: () => closeOverlay(ctx),
                          child: Text(context.l10n.commonCancel),
                        ),
                        const Gap(8),
                        PrimaryButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;

                            final api = ref.read(apiProvider);
                            if (isNew) {
                              await api.createDashboard(
                                widget.projectId,
                                name: name,
                                description: descCtrl.text.trim(),
                                isDefault: isDefault,
                              );
                            } else {
                              await api.updateDashboard(
                                widget.projectId,
                                dashboard.id,
                                name: name,
                                description: descCtrl.text.trim(),
                                isDefault: isDefault,
                                layout: dashboard.layout,
                              );
                            }
                            ref.invalidate(dashboardsProvider((projectId: widget.projectId)));
                            if (ctx.mounted) closeOverlay(ctx);
                          },
                          child: Text(context.l10n.commonSave),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
