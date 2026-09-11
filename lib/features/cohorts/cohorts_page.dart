// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'cohort_create_dialog.dart';

class CohortsPage extends ConsumerWidget {
  const CohortsPage({super.key, required this.projectId});
  final int projectId;

  void _openCreateDialog(BuildContext context, WidgetRef ref, [Cohort? existing]) {
    showAppDialog(
      context,
      CohortCreateDialog(projectId: projectId, existing: existing),
    );
  }

  Future<void> _refreshCohort(BuildContext context, WidgetRef ref, Cohort cohort) async {
    try {
      await ref.read(apiProvider).refreshCohort(projectId, cohort.id);
      ref.invalidate(cohortsProvider(projectId));
      if (context.mounted) {
        toast(context, context.l10n.cohortRefreshed);
      }
    } catch (e) {
      if (context.mounted) {
        toast(
          context,
          describeError(context.l10n, e),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Cohort cohort) async {
    final confirmed = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: context.l10n.commonDelete,
        message: context.l10n.cohortDeleteConfirm,
        confirmLabel: context.l10n.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteCohort(projectId, cohort.id);
        },
      ),
    );
    if (confirmed == true) {
      ref.invalidate(cohortsProvider(projectId));
      if (context.mounted) {
        toast(context, context.l10n.cohortDeleted);
      }
    }
  }

  String _formatRules(Cohort cohort) {
    if (cohort.rules.isEmpty) return '—';
    return cohort.rules.map((r) {
      final op = switch (r.operator) {
        'gte' => '>=',
        'gt' => '>',
        'lte' => '<=',
        'lt' => '<',
        'eq' => '=',
        _ => r.operator,
      };
      if (r.type == 'event') {
        return '${r.eventName} $op ${r.value} (${r.windowDays}d)';
      }
      return '${r.propertyKey} $op ${r.value}';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortsAsync = ref.watch(cohortsProvider(projectId));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.cohortsTitle,
            subtitle: context.l10n.cohortsSubtitle,
            actions: [
              PrimaryButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.plus, size: 14),
                onPressed: () => _openCreateDialog(context, ref),
                child: Text(context.l10n.newCohort),
              ),
              const Gap(8),
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(cohortsProvider(projectId)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: PanelCard(
              title: context.l10n.navCohorts,
              child: cohortsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => PanelMessage(
                  describeError(context.l10n, e),
                  color: Tokens.danger,
                ),
                data: (cohorts) {
                  if (cohorts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.users, size: 36, color: Tokens.textMuted),
                          const Gap(12),
                          Text(
                            context.l10n.cohortEmpty,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Tokens.textStrong,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            context.l10n.cohortEmptyHint,
                            style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                          ),
                          const Gap(16),
                          PrimaryButton(
                            size: ButtonSize.small,
                            leading: const Icon(LucideIcons.plus, size: 14),
                            onPressed: () => _openCreateDialog(context, ref),
                            child: Text(context.l10n.newCohort),
                          ),
                        ],
                      ),
                    );
                  }

                  return DataTable<Cohort>(
                    columns: [
                      (context.l10n.cohortName, 3, false),
                      (context.l10n.cohortRules, 4, false),
                      (context.l10n.cohortMemberCount, 2, true),
                      ('', 2, true),
                    ],
                    rows: cohorts,
                    cells: (c) => [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Tokens.textStrong,
                                ),
                              ),
                              const Gap(8),
                              Pill(
                                c.isDynamic
                                    ? context.l10n.cohortDynamic
                                    : context.l10n.cohortStatic,
                                color: c.isDynamic ? Tokens.brand : Tokens.textDim,
                              ),
                            ],
                          ),
                          if (c.description.isNotEmpty) ...[
                            const Gap(2),
                            Text(
                              c.description,
                              style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatRules(c),
                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${c.memberCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Tokens.textStrong,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.ghost(
                            icon: const Icon(LucideIcons.refreshCw, size: 14),
                            onPressed: () => _refreshCohort(context, ref, c),
                          ),
                          IconButton.ghost(
                            icon: const Icon(LucideIcons.pencil, size: 14),
                            onPressed: () => _openCreateDialog(context, ref, c),
                          ),
                          IconButton.ghost(
                            icon: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                            onPressed: () => _confirmDelete(context, ref, c),
                          ),
                        ],
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
