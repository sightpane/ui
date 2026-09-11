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
import 'widgets/sankey_diagram.dart';

class PathsPage extends ConsumerStatefulWidget {
  const PathsPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<PathsPage> createState() => _PathsPageState();
}

class _PathsPageState extends ConsumerState<PathsPage> {
  String _rootEvent = '';
  String _direction = 'forward';
  int _stepLimit = 4;
  int _days = 14;
  final double _threshold = 1.0;
  final List<String> _excludeList = [];

  late final TextEditingController _rootCtrl;
  late final TextEditingController _excludeCtrl;

  @override
  void initState() {
    super.initState();
    _rootCtrl = TextEditingController(text: _rootEvent);
    _excludeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _rootCtrl.dispose();
    _excludeCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _rootEvent = _rootCtrl.text.trim();
    });
  }

  Future<void> _showSampleSessions(PathLink link) async {
    final api = ref.read(apiProvider);
    try {
      final sessionIds = await api.pathSessions(
        widget.projectId,
        source: link.source,
        target: link.target,
        days: _days,
        limit: 20,
      );

      if (!mounted) return;

      await showAppDialog(
        context,
        Card(
          filled: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.pathsReplaysModalTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Tokens.textStrong,
                        ),
                      ),
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.x, size: 14),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    '${link.source}  →  ${link.target}',
                    style: const TextStyle(fontSize: 12, color: Tokens.brand),
                  ),
                  const Gap(14),
                  if (sessionIds.isEmpty)
                    PanelMessage(context.l10n.commonNoRecords)
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: sessionIds.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, idx) {
                          final sid = sessionIds[idx];
                          return Row(
                            children: [
                              const Icon(LucideIcons.video, size: 14, color: Tokens.textMuted),
                              const Gap(10),
                              Expanded(
                                child: Text(
                                  sid,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    color: Tokens.textStrong,
                                  ),
                                ),
                              ),
                              OutlineButton(
                                size: ButtonSize.small,
                                leading: const Icon(LucideIcons.play, size: 12),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.push('/projects/${widget.projectId}/sessions/$sid');
                                },
                                child: const Text('Replay'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        toast(context, describeError(context.l10n, e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pathsKey = (
      project: widget.projectId,
      rootEvent: _rootEvent,
      direction: _direction,
      stepLimit: _stepLimit,
      days: _days,
      exclude: _excludeList,
      threshold: _threshold,
    );
    final pathsAsync = ref.watch(pathsProvider(pathsKey));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.pathsTitle,
            subtitle: context.l10n.pathsSubtitle,
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(pathsProvider(pathsKey)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(16),
          // Filter controls bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Tokens.panel,
              border: Border.all(color: Tokens.border),
              borderRadius: BorderRadius.circular(Tokens.radius),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Direction toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_direction == 'forward')
                      PrimaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.pathsForward),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _direction = 'forward'),
                        child: Text(context.l10n.pathsForward),
                      ),
                    const Gap(4),
                    if (_direction == 'reverse')
                      PrimaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.pathsReverse),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _direction = 'reverse'),
                        child: Text(context.l10n.pathsReverse),
                      ),
                  ],
                ),
                // Root event field
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _rootCtrl,
                    placeholder: Text(context.l10n.pathsRootPlaceholder),
                    onSubmitted: (_) => _applyFilter(),
                  ),
                ),
                // Step depth
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final s in [2, 3, 4, 5]) ...[
                      if (_stepLimit == s)
                        PrimaryButton(
                          size: ButtonSize.small,
                          onPressed: () {},
                          child: Text('$s steps'),
                        )
                      else
                        OutlineButton(
                          size: ButtonSize.small,
                          onPressed: () => setState(() => _stepLimit = s),
                          child: Text('$s steps'),
                        ),
                      const Gap(4),
                    ],
                  ],
                ),
                // Days selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in [14, 30]) ...[
                      if (_days == d)
                        PrimaryButton(
                          size: ButtonSize.small,
                          onPressed: () {},
                          child: Text('${d}d'),
                        )
                      else
                        OutlineButton(
                          size: ButtonSize.small,
                          onPressed: () => setState(() => _days = d),
                          child: Text('${d}d'),
                        ),
                      const Gap(4),
                    ],
                  ],
                ),
                OutlineButton(
                  size: ButtonSize.small,
                  leading: const Icon(LucideIcons.filter, size: 14),
                  onPressed: _applyFilter,
                  child: Text(context.l10n.commonApply),
                ),
              ],
            ),
          ),
          const Gap(16),
          // Sankey diagram
          Expanded(
            child: PanelCard(
              title: context.l10n.pathsDiagramTitle,
              child: pathsAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => PanelMessage(
                  describeError(context.l10n, e),
                  color: Tokens.danger,
                ),
                data: (result) => SankeyDiagram(
                  result: result,
                  onLinkTap: _showSampleSessions,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
