// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/api.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../shared/widgets.dart';

class FunnelStepBar extends ConsumerStatefulWidget {
  const FunnelStepBar({
    super.key,
    required this.projectId,
    required this.funnelId,
    required this.step,
    required this.maxCount,
    required this.days,
    required this.isLast,
  });

  final int projectId;
  final int funnelId;
  final FunnelStepResult step;
  final int maxCount;
  final int days;
  final bool isLast;

  @override
  ConsumerState<FunnelStepBar> createState() => _FunnelStepBarState();
}

class _FunnelStepBarState extends ConsumerState<FunnelStepBar> {
  bool _loadingDropoffs = false;

  Future<void> _viewDropoffs() async {
    if (widget.step.dropOffCount <= 0 || _loadingDropoffs) return;
    setState(() => _loadingDropoffs = true);
    try {
      final api = ref.read(apiProvider);
      final sessionIds = await api.funnelDropoffs(
        widget.projectId,
        widget.funnelId,
        step: widget.step.stepIndex,
        days: widget.days,
      );
      if (!mounted) return;
      if (sessionIds.isEmpty) {
        toast(context, context.l10n.commonNoRecords);
        return;
      }
      if (sessionIds.length == 1) {
        context.go('/projects/${widget.projectId}/sessions/${sessionIds.first}');
        return;
      }
      _showDropoffSessionsDialog(sessionIds);
    } catch (e) {
      if (mounted) {
        toast(context, context.l10n.commonError, subtitle: '$e');
      }
    } finally {
      if (mounted) setState(() => _loadingDropoffs = false);
    }
  }

  void _showDropoffSessionsDialog(List<String> sessionIds) {
    showAppDialog(
      context,
      Card(
        filled: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.step.name} — ${context.l10n.funnelDropOff} (${sessionIds.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Tokens.text,
                      ),
                    ),
                    GhostButton(
                      density: ButtonDensity.compact,
                      size: ButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(LucideIcons.x, size: 16),
                    ),
                  ],
                ),
                const Gap(12),
                Expanded(
                  child: ListView.separated(
                    itemCount: sessionIds.length,
                    separatorBuilder: (_, _) => const Gap(6),
                    itemBuilder: (context, i) {
                      final sid = sessionIds[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Tokens.raised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Tokens.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.video, size: 15, color: Tokens.accent),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                sid,
                                style: AppTheme.mono(size: 12, color: Tokens.text),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Gap(8),
                            PrimaryButton(
                              density: ButtonDensity.compact,
                              size: ButtonSize.small,
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.go('/projects/${widget.projectId}/sessions/$sid');
                              },
                              child: Text(context.l10n.actionViewSessions),
                            ),
                          ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.maxCount > 0 ? widget.step.count / widget.maxCount : 0.0;
    final convPct = (widget.step.conversionRate * 100).toStringAsFixed(1);
    final dropPct = (widget.step.dropOffRate * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Tokens.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Tokens.raised,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Tokens.border),
                ),
                child: Text(
                  '${widget.step.stepIndex + 1}',
                  style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: Tokens.accent),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  widget.step.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Tokens.text,
                  ),
                ),
              ),
              Text(
                '${context.fmt.integer(widget.step.count)} ${context.l10n.navSessions.toLowerCase()}',
                style: AppTheme.mono(size: 13, weight: FontWeight.w600, color: Tokens.text),
              ),
              const Gap(10),
              Pill(
                '$convPct%',
                color: widget.step.conversionRate >= 0.5 ? Tokens.ok : Tokens.accent,
              ),
            ],
          ),
          const Gap(12),
          // Shadcn Progress bar
          Progress(
            progress: ratio.clamp(0.0, 1.0),
            min: 0.0,
            max: 1.0,
          ),
          if (!widget.isLast && widget.step.dropOffCount > 0) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Tokens.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Tokens.danger.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.arrowDownRight, size: 14, color: Tokens.danger),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      '${context.l10n.funnelDropOff}: ${context.fmt.integer(widget.step.dropOffCount)} ($dropPct%)',
                      style: const TextStyle(fontSize: 12, color: Tokens.danger, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    onPressed: _loadingDropoffs ? null : _viewDropoffs,
                    leading: _loadingDropoffs
                        ? const CircularProgressIndicator(size: 13)
                        : const Icon(LucideIcons.video, size: 13, color: Tokens.danger),
                    child: Text(
                      context.l10n.funnelWatchReplays(widget.step.dropOffCount),
                      style: const TextStyle(fontSize: 12, color: Tokens.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
