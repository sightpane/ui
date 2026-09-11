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
import 'feature_flag_dialog.dart';

class FeatureFlagsPage extends ConsumerStatefulWidget {
  const FeatureFlagsPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<FeatureFlagsPage> createState() => _FeatureFlagsPageState();
}

class _FeatureFlagsPageState extends ConsumerState<FeatureFlagsPage> {
  String _searchQuery = '';

  Future<void> _openDialog([FeatureFlag? flag]) async {
    await showAppDialog(
      context,
      FeatureFlagDialog(projectId: widget.projectId, flag: flag),
    );
  }

  Future<void> _toggleFlag(FeatureFlag flag, bool enabled) async {
    final api = ref.read(apiProvider);
    try {
      await api.updateFeatureFlag(
        widget.projectId,
        flag.id,
        name: flag.name,
        description: flag.description,
        enabled: enabled,
        rolloutPercentage: flag.rolloutPercentage,
        filters: flag.filters,
        variants: flag.variants,
      );
      ref.invalidate(featureFlagsProvider(widget.projectId));
    } catch (e) {
      if (mounted) {
        toast(context, describeError(context.l10n, e));
      }
    }
  }

  Future<void> _deleteFlag(FeatureFlag flag) async {
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
                  flag.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                ),
                const Gap(10),
                const Text(
                  'Are you sure you want to delete this feature flag?',
                  style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(context.l10n.commonCancel),
                    ),
                    const Gap(8),
                    DestructiveButton(
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(context.l10n.commonDelete),
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
        await api.deleteFeatureFlag(widget.projectId, flag.id);
        ref.invalidate(featureFlagsProvider(widget.projectId));
        if (mounted) {
          toast(context, context.l10n.flagsDeleted);
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
    final flagsAsync = ref.watch(featureFlagsProvider(widget.projectId));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.flagsTitle,
            subtitle: context.l10n.flagsSubtitle,
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(featureFlagsProvider(widget.projectId)),
                child: Text(context.l10n.commonRefresh),
              ),
              const Gap(8),
              PrimaryButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.plus, size: 14),
                onPressed: () => _openDialog(),
                child: Text(context.l10n.flagsNew),
              ),
            ],
          ),
          const Gap(16),
          // Search input
          Row(
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  placeholder: const Text('Search flags...'),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: flagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => PanelMessage(
                describeError(context.l10n, e),
                color: Tokens.danger,
              ),
              data: (flags) {
                final filtered = flags.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  return f.key.toLowerCase().contains(_searchQuery) ||
                      f.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return PanelCard(
                    title: context.l10n.navFeatureFlags,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          context.l10n.flagsEmpty,
                          style: const TextStyle(color: Tokens.textMuted),
                        ),
                      ),
                    ),
                  );
                }

                return PanelCard(
                  title: context.l10n.navFeatureFlags,
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, idx) {
                      final f = filtered[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Switch(
                              value: f.enabled,
                              onChanged: (v) => _toggleFlag(f, v),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        f.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Tokens.textStrong,
                                        ),
                                      ),
                                      const Gap(8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Tokens.raised,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          f.key,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Tokens.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (f.description.isNotEmpty) ...[
                                    const Gap(4),
                                    Text(
                                      f.description,
                                      style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Gap(12),
                            // Rollout badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: f.enabled ? Tokens.brand.withValues(alpha: 0.1) : Tokens.panel,
                                border: Border.all(
                                  color: f.enabled ? Tokens.brand.withValues(alpha: 0.4) : Tokens.border,
                                ),
                                borderRadius: BorderRadius.circular(Tokens.radius),
                              ),
                              child: Text(
                                '${f.rolloutPercentage}% rollout',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: f.enabled ? Tokens.brand : Tokens.textMuted,
                                ),
                              ),
                            ),
                            const Gap(8),
                            if (f.filters.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Tokens.panel,
                                  border: Border.all(color: Tokens.border),
                                  borderRadius: BorderRadius.circular(Tokens.radius),
                                ),
                                child: Text(
                                  '${f.filters.length} rules',
                                  style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                                ),
                              ),
                            if (f.variants.isNotEmpty) ...[
                              const Gap(6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Tokens.panel,
                                  border: Border.all(color: Tokens.border),
                                  borderRadius: BorderRadius.circular(Tokens.radius),
                                ),
                                child: Text(
                                  '${f.variants.length} variants',
                                  style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                                ),
                              ),
                            ],
                            const Gap(12),
                            IconButton.ghost(
                              size: ButtonSize.small,
                              icon: const Icon(LucideIcons.pencil, size: 14),
                              onPressed: () => _openDialog(f),
                            ),
                            const Gap(4),
                            IconButton.ghost(
                              size: ButtonSize.small,
                              icon: const Icon(LucideIcons.trash, size: 14, color: Tokens.danger),
                              onPressed: () => _deleteFlag(f),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
