// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
import 'funnel_create_dialog.dart';

class FunnelsPage extends ConsumerWidget {
  const FunnelsPage({super.key, required this.projectId});
  final int projectId;

  String _formatWindow(BuildContext context, int seconds) {
    if (seconds >= 2592000) return context.l10n.funnelWindow30d;
    if (seconds >= 1209600) return context.l10n.funnelWindow14d;
    if (seconds >= 604800) return context.l10n.funnelWindow7d;
    return context.l10n.funnelWindow1d;
  }

  void _openCreateDialog(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context,
      FunnelCreateDialog(projectId: projectId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funnelsAsync = ref.watch(funnelsProvider(projectId));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          funnelsAsync.maybeWhen(
            data: (list) => PageHeader(
              title: context.l10n.funnelsTitle,
              subtitle: context.l10n.funnelsSubtitle(list.length),
              actions: [
                PrimaryButton(
                  size: ButtonSize.small,
                  leading: const Icon(LucideIcons.plus, size: 14),
                  onPressed: () => _openCreateDialog(context, ref),
                  child: Text(context.l10n.funnelCreate),
                ),
                const Gap(8),
                GhostButton(
                  size: ButtonSize.small,
                  leading: const Icon(LucideIcons.refreshCw, size: 14),
                  onPressed: () => ref.invalidate(funnelsProvider(projectId)),
                  child: Text(context.l10n.commonRefresh),
                ),
              ],
            ),
            orElse: () => PageHeader(
              title: context.l10n.funnelsTitle,
              subtitle: '',
              actions: [
                PrimaryButton(
                  size: ButtonSize.small,
                  leading: const Icon(LucideIcons.plus, size: 14),
                  onPressed: () => _openCreateDialog(context, ref),
                  child: Text(context.l10n.funnelCreate),
                ),
              ],
            ),
          ),
          const Gap(16),
          Expanded(
            child: PanelCard(
              title: context.l10n.navFunnels,
              child: funnelsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => PanelMessage(
                  describeError(context.l10n, e),
                  color: Tokens.danger,
                ),
                data: (funnels) {
                  if (funnels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.filter, size: 36, color: Tokens.textMuted),
                          const Gap(12),
                          Text(
                            context.l10n.funnelsEmpty,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Tokens.text,
                            ),
                          ),
                          const Gap(6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Text(
                              context.l10n.funnelsEmptyHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Tokens.textMuted,
                              ),
                            ),
                          ),
                          const Gap(16),
                          PrimaryButton(
                            size: ButtonSize.small,
                            leading: const Icon(LucideIcons.plus, size: 14),
                            onPressed: () => _openCreateDialog(context, ref),
                            child: Text(context.l10n.funnelCreate),
                          ),
                        ],
                      ),
                    );
                  }

                  return DataTable<Funnel>(
                    columns: [
                      (context.l10n.funnelName, 3, false),
                      (context.l10n.funnelSteps, 4, false),
                      (context.l10n.funnelWindow, 2, false),
                      (context.l10n.colFirstSeen, 2, false),
                      ('', 1, true),
                    ],
                    rows: funnels,
                    onTap: (f) => context.go('/projects/$projectId/funnels/${f.id}'),
                    cells: (f) => [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            f.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Tokens.text,
                            ),
                          ),
                          if (f.description.isNotEmpty)
                            Text(
                              f.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Tokens.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      Text(
                        f.steps.map((s) => s.name).join('  →  '),
                        style: AppTheme.mono(size: 11.5, color: Tokens.accent),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatWindow(context, f.conversionWindowSeconds),
                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                      ),
                      Text(
                        f.createdAt != null
                            ? context.fmt.dateTime(f.createdAt!)
                            : context.l10n.commonEmpty,
                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                      ),
                      GhostButton(
                        density: ButtonDensity.compact,
                        size: ButtonSize.small,
                        onPressed: () => context.go('/projects/$projectId/funnels/${f.id}'),
                        child: const Icon(LucideIcons.chevronRight, size: 14),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
