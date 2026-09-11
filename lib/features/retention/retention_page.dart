// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'widgets/retention_matrix_table.dart';

class RetentionPage extends ConsumerStatefulWidget {
  const RetentionPage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<RetentionPage> createState() => _RetentionPageState();
}

class _RetentionPageState extends ConsumerState<RetentionPage> {
  String _period = 'day';
  int _days = 30;
  String _targetEvent = '';
  String _returnEvent = '';
  int? _cohortId;

  late final TextEditingController _targetCtrl;
  late final TextEditingController _returnCtrl;

  @override
  void initState() {
    super.initState();
    _targetCtrl = TextEditingController(text: _targetEvent);
    _returnCtrl = TextEditingController(text: _returnEvent);
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _returnCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _targetEvent = _targetCtrl.text.trim();
      _returnEvent = _returnCtrl.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cohortsAsync = ref.watch(cohortsProvider(widget.projectId));
    final retentionKey = (
      project: widget.projectId,
      days: _days,
      period: _period,
      targetEvent: _targetEvent,
      returnEvent: _returnEvent,
      cohortId: _cohortId,
    );
    final retentionAsync = ref.watch(retentionProvider(retentionKey));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.retentionTitle,
            subtitle: context.l10n.retentionSubtitle,
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () {
                  ref.invalidate(retentionProvider(retentionKey));
                  ref.invalidate(cohortsProvider(widget.projectId));
                },
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(16),
          // Filter bar
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
                // Period toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_period == 'day')
                      PrimaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.retentionPeriodDay),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _period = 'day'),
                        child: Text(context.l10n.retentionPeriodDay),
                      ),
                    const Gap(4),
                    if (_period == 'week')
                      PrimaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.retentionPeriodWeek),
                      )
                    else
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _period = 'week'),
                        child: Text(context.l10n.retentionPeriodWeek),
                      ),
                  ],
                ),
                // Days selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in [14, 30, 60, 90]) ...[
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
                // Target event
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _targetCtrl,
                    placeholder: Text(context.l10n.retentionTargetEvent),
                    onSubmitted: (_) => _applyFilter(),
                  ),
                ),
                // Return event
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _returnCtrl,
                    placeholder: Text(context.l10n.retentionReturnEvent),
                    onSubmitted: (_) => _applyFilter(),
                  ),
                ),
                // Cohort picker
                cohortsAsync.maybeWhen(
                  data: (cohorts) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cohortId == null)
                        PrimaryButton(
                          size: ButtonSize.small,
                          onPressed: () {},
                          child: Text(context.l10n.retentionAllUsers),
                        )
                      else
                        OutlineButton(
                          size: ButtonSize.small,
                          onPressed: () => setState(() => _cohortId = null),
                          child: Text(context.l10n.retentionAllUsers),
                        ),
                      for (final c in cohorts) ...[
                        const Gap(4),
                        if (_cohortId == c.id)
                          PrimaryButton(
                            size: ButtonSize.small,
                            onPressed: () {},
                            child: Text(c.name),
                          )
                        else
                          OutlineButton(
                            size: ButtonSize.small,
                            onPressed: () => setState(() => _cohortId = c.id),
                            child: Text(c.name),
                          ),
                      ],
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
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
          // Heatmap Matrix Table
          Expanded(
            child: PanelCard(
              title: context.l10n.retentionHeatmapTitle,
              child: retentionAsync.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => PanelMessage(
                  describeError(context.l10n, e),
                  color: Tokens.danger,
                ),
                data: (result) => RetentionMatrixTable(result: result),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
