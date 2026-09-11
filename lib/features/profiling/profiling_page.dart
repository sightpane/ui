// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class ProfilingPage extends ConsumerStatefulWidget {
  const ProfilingPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<ProfilingPage> createState() => _ProfilingPageState();
}

class _ProfilingPageState extends ConsumerState<ProfilingPage> {
  int _days = 14;
  String _txQuery = '';
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
    final profilesKey = (
      projectId: widget.projectId,
      days: _days,
      transaction: _txQuery.isEmpty ? null : _txQuery,
      limit: 50,
    );

    final slowFuncsKey = (
      projectId: widget.projectId,
      days: _days,
      transaction: _txQuery.isEmpty ? null : _txQuery,
      limit: 10,
    );

    final profilesAsync = ref.watch(profilesProvider(profilesKey));
    final slowFuncsAsync = ref.watch(topSlowFunctionsProvider(slowFuncsKey));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.profilingTitle,
            subtitle: context.l10n.profilingSubtitle,
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final d in [7, 14, 30]) ...[
                    if (d != 7) const Gap(4),
                    if (_days == d)
                      PrimaryButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () {},
                        child: Text('$d d'),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () => setState(() => _days = d),
                        child: Text('$d d'),
                      ),
                  ],
                ],
              ),
            ],
          ),
          const Gap(16),

          // Filter bar
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
                    onSubmitted: (v) => setState(() => _txQuery = v.trim()),
                  ),
                ),
              ),
              const Gap(8),
              if (_txQuery.isNotEmpty)
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _txQuery = '');
                  },
                  child: Text(context.l10n.searchClear),
                ),
            ],
          ),
          const Gap(16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Slowest Functions Card
                  slowFuncsAsync.when(
                    data: (funcs) {
                      if (funcs.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.flame, size: 18, color: Color(0xFFF97316)),
                                    const Gap(8),
                                    Text(
                                      context.l10n.profilingSlowFunctions,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                for (final f in funcs) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Tokens.raised,
                                      borderRadius: BorderRadius.circular(Tokens.radius),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                f.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              if (f.file.isNotEmpty)
                                                Text(
                                                  f.file,
                                                  style: TextStyle(
                                                    color: Tokens.textMuted,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${context.l10n.profilingSelfTime}: ${_formatDuration(f.selfTimeMs)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                            Text(
                                              '${context.l10n.profilingTotalTime}: ${_formatDuration(f.totalTimeMs)} (${f.callCount})',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Tokens.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(6),
                                ],
                              ],
                            ),
                          ),
                          const Gap(16),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),

                  // 2. Profiles Table Card
                  profilesAsync.when(
                    skipLoadingOnReload: true,
                    loading: () => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => PanelMessage(e.toString(), color: Tokens.danger),
                    data: (profiles) {
                      if (profiles.isEmpty) {
                        return PanelMessage(context.l10n.profilingEmpty);
                      }

                      return Card(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      context.l10n.profilingTransaction,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      context.l10n.profilingDuration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      context.l10n.profilingCpuTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      context.l10n.profilingThread,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      context.l10n.profilingPlatform,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Tokens.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 120),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            for (final p in profiles) ...[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => context.go('/projects/${widget.projectId}/profiling/${p.id}'),
                                child: Padding(

                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.transactionName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Gap(2),
                                            Text(
                                              context.fmt.dateTime(p.createdAt),
                                              style: const TextStyle(
                                                color: Tokens.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatDuration(p.durationMs),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatDuration(p.cpuTimeMs),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF97316),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          p.threadName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Tokens.textMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            Pill(p.platform.isEmpty ? 'generic' : p.platform),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: OutlineButton(
                                          size: ButtonSize.small,
                                          density: ButtonDensity.compact,
                                          onPressed: () => context.go(
                                            '/projects/${widget.projectId}/profiling/${p.id}',
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.flame, size: 12),
                                              const Gap(4),
                                              Text(context.l10n.profilingViewProfile),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
