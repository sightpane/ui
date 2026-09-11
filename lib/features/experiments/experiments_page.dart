// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'experiment_dialog.dart';

class ExperimentsPage extends ConsumerStatefulWidget {
  const ExperimentsPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<ExperimentsPage> createState() => _ExperimentsPageState();
}

class _ExperimentsPageState extends ConsumerState<ExperimentsPage> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'running', 'draft', 'concluded'

  Future<void> _openDialog([Experiment? exp]) async {
    await showAppDialog(
      context,
      ExperimentDialog(projectId: widget.projectId, experiment: exp),
    );
  }

  Future<void> _deleteExperiment(Experiment exp) async {
    final confirmed = await showAppDialog<bool>(
      context,
      Card(
        filled: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  exp.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                ),
                const Gap(10),
                const Text(
                  'Are you sure you want to delete this experiment?',
                  style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const Gap(8),
                    DestructiveButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final api = ref.read(apiProvider);
      try {
        await api.deleteExperiment(widget.projectId, exp.id);
        ref.invalidate(experimentsProvider(widget.projectId));
        if (mounted) {
          toast(context, 'Experiment deleted.');
        }
      } catch (e) {
        if (mounted) {
          toast(context, describeError(context.l10n, e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final expsAsync = ref.watch(experimentsProvider(widget.projectId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          PageHeader(
            title: l.experimentsTitle,
            subtitle: l.experimentsDesc,
            actions: [
              PrimaryButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.plus, size: 14),
                onPressed: () => _openDialog(),
                child: Text(l.experimentsNew),
              ),
            ],
          ),
          const Gap(24),

          // Filters & Search
          Row(
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  placeholder: const Text('Search experiments...'),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),
              const Gap(12),
              // Status tabs
              _FilterChip(
                label: 'All',
                selected: _statusFilter == 'all',
                onTap: () => setState(() => _statusFilter = 'all'),
              ),
              const Gap(6),
              _FilterChip(
                label: 'Running',
                selected: _statusFilter == 'running',
                onTap: () => setState(() => _statusFilter = 'running'),
              ),
              const Gap(6),
              _FilterChip(
                label: 'Draft',
                selected: _statusFilter == 'draft',
                onTap: () => setState(() => _statusFilter = 'draft'),
              ),
              const Gap(6),
              _FilterChip(
                label: 'Concluded',
                selected: _statusFilter == 'concluded',
                onTap: () => setState(() => _statusFilter = 'concluded'),
              ),
            ],
          ),
          const Gap(16),

          expsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => PanelMessage(
              describeError(context.l10n, err),
              color: Tokens.danger,
            ),
            data: (experiments) {
              var filtered = experiments.where((e) {
                if (_statusFilter != 'all' && e.status != _statusFilter) {
                  return false;
                }
                if (_searchQuery.isNotEmpty) {
                  final matchName = e.name.toLowerCase().contains(_searchQuery);
                  final matchKey = e.featureFlagKey.toLowerCase().contains(_searchQuery);
                  final matchMetric = e.primaryMetricEvent.toLowerCase().contains(_searchQuery);
                  return matchName || matchKey || matchMetric;
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Card(
                  filled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.flaskConical, size: 48, color: Tokens.textMuted),
                        const Gap(16),
                        Text(
                          l.experimentsEmpty,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                        ),
                        const Gap(6),
                        const Text(
                          'Create an experiment to start comparing conversion rates between variants.',
                          style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                        ),
                        const Gap(16),
                        PrimaryButton(
                          size: ButtonSize.small,
                          onPressed: () => _openDialog(),
                          child: Text(l.experimentsNew),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Gap(10),
                itemBuilder: (context, index) {
                  final exp = filtered[index];
                  return Card(
                    filled: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.go('/projects/${widget.projectId}/experiments/${exp.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Tokens.brand.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(Tokens.radius),
                              ),
                              child: const Icon(LucideIcons.flaskConical, size: 20, color: Tokens.brand),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        exp.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Tokens.textStrong,
                                        ),
                                      ),
                                      const Gap(10),
                                      _StatusBadge(status: exp.status),
                                      if (exp.winnerVariant != null) ...[
                                        const Gap(8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Tokens.ok.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Tokens.ok.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.trophy, size: 12, color: Tokens.ok),
                                              const Gap(4),
                                              Text(
                                                'Winner: ${exp.winnerVariant}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Tokens.ok),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (exp.description.isNotEmpty) ...[
                                    const Gap(4),
                                    Text(
                                      exp.description,
                                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const Gap(8),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.flag, size: 13, color: Tokens.textMuted),
                                      const Gap(4),
                                      Text(
                                        exp.featureFlagKey,
                                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Tokens.textMuted),
                                      ),
                                      const Gap(14),
                                      const Icon(LucideIcons.target, size: 13, color: Tokens.textMuted),
                                      const Gap(4),
                                      Text(
                                        exp.primaryMetricEvent,
                                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      ),
                                      const Gap(14),
                                      const Icon(LucideIcons.users, size: 13, color: Tokens.textMuted),
                                      const Gap(4),
                                      Text(
                                        'Min samples: ${exp.minimumSampleSize}',
                                        style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GhostButton(
                              size: ButtonSize.small,
                              onPressed: () => _openDialog(exp),
                              child: const Icon(LucideIcons.pencil, size: 16, color: Tokens.textMuted),
                            ),
                            GhostButton(
                              size: ButtonSize.small,
                              onPressed: () => _deleteExperiment(exp),
                              child: const Icon(LucideIcons.trash2, size: 16, color: Tokens.danger),
                            ),
                            const Gap(4),
                            const Icon(LucideIcons.chevronRight, size: 18, color: Tokens.textMuted),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Tokens.brand.withValues(alpha: 0.15) : Tokens.panel,
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: Border.all(
            color: selected ? Tokens.brand : Tokens.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Tokens.brand : Tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg = Tokens.panel;
    Color fg = Tokens.textMuted;
    String label = status.toUpperCase();

    if (status == 'running') {
      bg = Tokens.ok.withValues(alpha: 0.15);
      fg = Tokens.ok;
    } else if (status == 'concluded') {
      bg = Tokens.brand.withValues(alpha: 0.15);
      fg = Tokens.brand;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
