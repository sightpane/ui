// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'widgets/flame_chart.dart';

class ProfileDetailPage extends ConsumerStatefulWidget {
  const ProfileDetailPage({
    super.key,
    required this.projectId,
    required this.profileId,
  });

  final int projectId;
  final String profileId;

  @override
  ConsumerState<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends ConsumerState<ProfileDetailPage> {
  String _searchQuery = '';
  bool _inverted = false;
  double _zoomLevel = 1.0;
  FlameBlock? _selectedBlock;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(double ms) {
    if (ms < 1) return '<1 ms';
    if (ms < 1000) return '${ms.toStringAsFixed(ms < 10 ? 1 : 0)} ms';
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  @override
  Widget build(BuildContext context) {
    final detailKey = (projectId: widget.projectId, profileId: widget.profileId);
    final detailAsync = ref.watch(profileDetailProvider(detailKey));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          detailAsync.maybeWhen(
            data: (p) => AppBreadcrumb(
              items: [
                BreadcrumbItem(
                  label: context.l10n.projectsTitle,
                  path: '/projects',
                ),
                BreadcrumbItem(
                  label: context.l10n.settingsProject,
                  path: '/projects/${widget.projectId}',
                ),
                BreadcrumbItem(
                  label: context.l10n.profilingTitle,
                  path: '/projects/${widget.projectId}/profiling',
                ),
                BreadcrumbItem(
                  label: p.transactionName.isNotEmpty ? p.transactionName : p.id,
                ),
              ],
            ),
            orElse: () => AppBreadcrumb(
              items: [
                BreadcrumbItem(
                  label: context.l10n.projectsTitle,
                  path: '/projects',
                ),
                BreadcrumbItem(
                  label: context.l10n.settingsProject,
                  path: '/projects/${widget.projectId}',
                ),
                BreadcrumbItem(
                  label: context.l10n.profilingTitle,
                  path: '/projects/${widget.projectId}/profiling',
                ),
                BreadcrumbItem(
                  label: widget.profileId,
                ),
              ],
            ),
          ),
          const Gap(16),

          Expanded(
            child: detailAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => PanelMessage(e.toString(), color: Tokens.danger),
              data: (profile) {
                final frames = profile.callTree.frames;
                final samples = profile.callTree.samples;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Trace action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.transactionName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  context.fmt.dateTime(profile.createdAt),
                                  style: const TextStyle(
                                    color: Tokens.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (profile.traceId.isNotEmpty)
                            OutlineButton(
                              size: ButtonSize.small,
                              onPressed: () => context.go(
                                '/projects/${widget.projectId}/traces/${profile.traceId}',
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.gitFork, size: 14),
                                  const Gap(6),
                                  Text(context.l10n.performanceViewTrace),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Gap(16),

                      // KPI Cards
                      Row(
                        children: [
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingDuration,
                              value: _formatDuration(profile.durationMs),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingCpuTime,
                              value: _formatDuration(profile.cpuTimeMs),
                              valueColor: const Color(0xFFF97316),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingThread,
                              value: profile.threadName,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingPlatform,
                              value: profile.platform.isEmpty ? 'generic' : profile.platform,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingFrames,
                              value: '${frames.length}',
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: KpiTile(
                              label: context.l10n.profilingSamples,
                              value: '${samples.length}',
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),

                      // Flame Graph Card
                      Card(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Toolbar
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 36,
                                    child: TextField(
                                      controller: _searchCtrl,
                                      placeholder: Text(context.l10n.profilingSearchFrame),
                                      features: const [
                                        InputFeature.leading(Icon(LucideIcons.search, size: 14)),
                                      ],
                                      onChanged: (v) => setState(() => _searchQuery = v),
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                OutlineButton(
                                  size: ButtonSize.small,
                                  onPressed: () => setState(() => _zoomLevel = math.max(0.5, _zoomLevel - 0.25)),
                                  child: const Icon(LucideIcons.minus, size: 14),
                                ),
                                const Gap(4),
                                OutlineButton(
                                  size: ButtonSize.small,
                                  onPressed: () => setState(() => _zoomLevel = math.min(4.0, _zoomLevel + 0.25)),
                                  child: const Icon(LucideIcons.plus, size: 14),
                                ),
                                const Gap(4),
                                if (_zoomLevel != 1.0) ...[
                                  OutlineButton(
                                    size: ButtonSize.small,
                                    onPressed: () => setState(() => _zoomLevel = 1.0),
                                    child: Text(context.l10n.profilingResetZoom),
                                  ),
                                  const Gap(8),
                                ],
                                OutlineButton(
                                  size: ButtonSize.small,
                                  onPressed: () => setState(() => _inverted = !_inverted),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _inverted ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                                        size: 14,
                                      ),
                                      const Gap(6),
                                      Text(context.l10n.profilingInvertFlame),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),

                            // Interactive Flame Chart Canvas
                            Container(
                              decoration: BoxDecoration(
                                color: Tokens.panel,
                                borderRadius: BorderRadius.circular(Tokens.radius),
                                border: Border.all(color: Tokens.border),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: FlameChart(
                                callTree: profile.callTree,
                                totalDurationMs: profile.durationMs,
                                searchQuery: _searchQuery,
                                inverted: _inverted,
                                zoomLevel: _zoomLevel,
                                selectedBlock: _selectedBlock,
                                onBlockSelected: (b) => setState(() => _selectedBlock = b),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),

                      // Selected Frame Inspector Card
                      if (_selectedBlock != null) ...[
                        Card(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.info, size: 16, color: Color(0xFF3B82F6)),
                                  const Gap(8),
                                  Text(
                                    context.l10n.profilingSelectedFrame,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlineButton(
                                    size: ButtonSize.small,
                                    density: ButtonDensity.compact,
                                    onPressed: () => setState(() => _selectedBlock = null),
                                    child: const Icon(LucideIcons.x, size: 12),
                                  ),
                                ],
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedBlock!.frame.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_selectedBlock!.frame.file.isNotEmpty) ...[
                                          const Gap(2),
                                          Text(
                                            '${_selectedBlock!.frame.file}${_selectedBlock!.frame.line > 0 ? ':${_selectedBlock!.frame.line}' : ''}',
                                            style: TextStyle(
                                              color: Tokens.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${context.l10n.profilingSelfTime}: ${_formatDuration(_selectedBlock!.selfTimeMs)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                        Text(
                                          '${context.l10n.profilingTotalTime}: ${_formatDuration(_selectedBlock!.totalTimeMs)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Tokens.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                      ],
                    ],
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
