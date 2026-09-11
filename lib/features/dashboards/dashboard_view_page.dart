// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/breadcrumb.dart';
import 'widgets/dashboard_tile_card.dart';

class DashboardViewPage extends ConsumerStatefulWidget {
  const DashboardViewPage({
    super.key,
    required this.projectId,
    required this.dashboardId,
  });

  final int projectId;
  final String dashboardId;

  @override
  ConsumerState<DashboardViewPage> createState() => _DashboardViewPageState();
}

class _DashboardViewPageState extends ConsumerState<DashboardViewPage> {
  Timer? _refreshTimer;
  int _refreshIntervalSeconds = 0; // 0 = off, 10, 30, 60
  List<DashboardTile>? _layout;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRefreshTimer() {
    _refreshTimer?.cancel();
    if (_refreshIntervalSeconds > 0) {
      _refreshTimer = Timer.periodic(Duration(seconds: _refreshIntervalSeconds), (_) {
        if (!mounted) return;
        ref.invalidate(dashboardDetailProvider((projectId: widget.projectId, dashboardId: widget.dashboardId)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardDetailProvider((projectId: widget.projectId, dashboardId: widget.dashboardId)));

    return Scaffold(
      child: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            '${context.l10n.commonError}: $err',
            style: const TextStyle(color: Tokens.danger),
          ),
        ),
        data: (dashboard) {
          _layout ??= List.from(dashboard.layout);
          final currentLayout = _layout!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBreadcrumb(
                            items: [
                              BreadcrumbItem(
                                label: context.l10n.dashboardsTitle,
                                path: '/projects/${widget.projectId}/dashboards',
                              ),
                              BreadcrumbItem(label: dashboard.name),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Text(
                                dashboard.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Tokens.textStrong,
                                ),
                              ),
                              if (dashboard.isDefault) ...[
                                const Gap(10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Tokens.accent.withValues(alpha: 0.15),
                                    border: Border.all(color: Tokens.accent.withValues(alpha: 0.4)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.l10n.dashboardIsDefault,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Tokens.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (dashboard.description.isNotEmpty) ...[
                            const Gap(4),
                            Text(
                              dashboard.description,
                              style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Auto-refresh control
                    Row(
                      children: [
                        const Icon(LucideIcons.timer, size: 16, color: Tokens.textDim),
                        const Gap(6),
                        _buildRefreshButton(0, context.l10n.dashboardRefreshOff),
                        const Gap(4),
                        _buildRefreshButton(10, '10s'),
                        const Gap(4),
                        _buildRefreshButton(30, '30s'),
                        const Gap(4),
                        _buildRefreshButton(60, '1m'),
                      ],
                    ),
                    const Gap(16),
                    OutlineButton(
                      leading: const Icon(LucideIcons.plus, size: 15),
                      onPressed: () => _showAddInsightDialog(context, currentLayout),
                      child: Text(context.l10n.dashboardTileAdd),
                    ),
                    const Gap(8),
                    PrimaryButton(
                      leading: const Icon(LucideIcons.save, size: 15),
                      onPressed: () => _saveLayout(dashboard, currentLayout),
                      child: Text(context.l10n.dashboardLayoutSave),
                    ),
                  ],
                ),
                const Gap(24),
                if (currentLayout.isEmpty)
                  Card(
                    filled: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.chartBar, size: 40, color: Tokens.textDim),
                          const Gap(12),
                          Text(
                            context.l10n.dashboardEmpty,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                          ),
                          const Gap(16),
                          PrimaryButton(
                            leading: const Icon(LucideIcons.plus, size: 16),
                            onPressed: () => _showAddInsightDialog(context, currentLayout),
                            child: Text(context.l10n.dashboardTileAdd),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 960;
                      final isTablet = constraints.maxWidth >= 640 && !isDesktop;

                      if (!isDesktop) {
                        // Responsive 1 or 2 column flow
                        final tileWidth = isTablet
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (int i = 0; i < currentLayout.length; i++)
                              SizedBox(
                                width: tileWidth,
                                height: 320,
                                child: DashboardTileCard(
                                  projectId: widget.projectId,
                                  tile: currentLayout[i],
                                  onRemove: () {
                                    setState(() => currentLayout.removeAt(i));
                                  },
                                  onEdit: () {
                                    context.go('/projects/${widget.projectId}/insights?insightId=${currentLayout[i].insightId}');
                                  },
                                ),
                              ),
                          ],
                        );
                      }

                      // 12-column Grid on Desktop
                      const colCount = 12;
                      const gap = 16.0;
                      final totalGapWidth = (colCount - 1) * gap;
                      final colWidth = (constraints.maxWidth - totalGapWidth) / colCount;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (int i = 0; i < currentLayout.length; i++) ...[
                            Builder(
                              builder: (ctx) {
                                final t = currentLayout[i];
                                final span = t.w.clamp(3, 12);
                                final wPx = (span * colWidth) + ((span - 1) * gap);
                                final hPx = (t.h * 65.0).clamp(280.0, 600.0);

                                return SizedBox(
                                  width: wPx,
                                  height: hPx,
                                  child: DashboardTileCard(
                                    projectId: widget.projectId,
                                    tile: t,
                                    onRemove: () {
                                      setState(() => currentLayout.removeAt(i));
                                    },
                                    onEdit: () {
                                      context.go('/projects/${widget.projectId}/insights?insightId=${t.insightId}');
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefreshButton(int seconds, String label) {
    final active = _refreshIntervalSeconds == seconds;
    if (active) {
      return PrimaryButton(
        density: ButtonDensity.compact,
        onPressed: () {
          setState(() {
            _refreshIntervalSeconds = seconds;
            _setupRefreshTimer();
          });
        },
        child: Text(label),
      );
    }
    return OutlineButton(
      density: ButtonDensity.compact,
      onPressed: () {
        setState(() {
          _refreshIntervalSeconds = seconds;
          _setupRefreshTimer();
        });
      },
      child: Text(label),
    );
  }

  Future<void> _saveLayout(Dashboard d, List<DashboardTile> layout) async {
    final api = ref.read(apiProvider);
    await api.updateDashboard(
      widget.projectId,
      d.id,
      name: d.name,
      description: d.description,
      isDefault: d.isDefault,
      layout: layout,
    );
    ref.invalidate(dashboardDetailProvider((projectId: widget.projectId, dashboardId: widget.dashboardId)));
    if (mounted) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Text(context.l10n.commonSave, style: const TextStyle(color: Tokens.ok)),
        ),
      );
    }
  }

  Future<void> _showAddInsightDialog(BuildContext context, List<DashboardTile> currentLayout) async {
    final insightsAsync = await ref.read(insightsProvider((projectId: widget.projectId, dashboardId: null)).future);
    final existingIds = currentLayout.map((t) => t.insightId).toSet();
    final available = insightsAsync.where((ins) => !existingIds.contains(ins.id)).toList();

    if (!context.mounted) return;

    await showAppDialog(
      context,
      Center(
        child: Card(
          filled: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, size: 18, color: Tokens.brand),
                      const Gap(10),
                      Text(
                        context.l10n.dashboardTileAdd,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                      ),
                      const Spacer(),
                      IconButton.ghost(
                        density: ButtonDensity.compact,
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () => closeOverlay(context),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${available.length} available insights',
                          style: const TextStyle(fontSize: 13, color: Tokens.textMuted),
                        ),
                      ),
                      PrimaryButton(
                        density: ButtonDensity.compact,
                        leading: const Icon(LucideIcons.plus, size: 14),
                        onPressed: () {
                          closeOverlay(context);
                          context.go('/projects/${widget.projectId}/insights?dashboardId=${widget.dashboardId}');
                        },
                        child: Text(context.l10n.insightBuilderTitle),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (available.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No more existing insights. Create a new one!',
                          style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: available.length,
                        separatorBuilder: (_, _) => const Gap(8),
                        itemBuilder: (context, idx) {
                          final ins = available[idx];
                          return Card(
                            filled: false,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ins.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                                        ),
                                        const Gap(4),
                                        Text(
                                          '${ins.chartType} · ${ins.query.dateRange} · ${ins.query.events.map((e) => e.name).join(", ")}',
                                          style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlineButton(
                                    density: ButtonDensity.compact,
                                    onPressed: () {
                                      setState(() {
                                        currentLayout.add(DashboardTile(
                                          insightId: ins.id,
                                          col: 0,
                                          row: currentLayout.length * 4,
                                          w: 6,
                                          h: 4,
                                        ));
                                      });
                                      closeOverlay(context);
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
