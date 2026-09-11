// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets.dart';
import 'survey_dialog.dart';

class SurveysPage extends ConsumerStatefulWidget {
  const SurveysPage({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  ConsumerState<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends ConsumerState<SurveysPage> {
  void _openCreateDialog() {
    showAppDialog(
      context,
      SurveyDialog(projectId: widget.projectId),
    );
  }

  void _openEditDialog(Survey survey) {
    showAppDialog(
      context,
      SurveyDialog(
        projectId: widget.projectId,
        survey: survey,
      ),
    );
  }

  Future<void> _deleteSurvey(Survey survey) async {
    final l = L.of(context);
    final confirmed = await showAppDialog<bool>(
      context,
      ConfirmDialog(
        title: l.commonDelete,
        message: 'This will delete "${survey.name}" and all of its collected responses permanently.',
        confirmLabel: l.commonDelete,
        destructive: true,
        onConfirm: () async {
          await ref.read(apiProvider).deleteSurvey(widget.projectId, survey.id);
        },
      ),
    );

    if (confirmed == true) {
      ref.invalidate(surveysProvider(widget.projectId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final surveysAsync = ref.watch(surveysProvider(widget.projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.surveysTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.surveysDesc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                onPressed: _openCreateDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 16),
                    const SizedBox(width: 6),
                    Text(l.surveysNew),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Body
        Expanded(
          child: surveysAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Failed to load surveys: $err',
                style: TextStyle(color: Tokens.danger),
              ),
            ),
            data: (surveys) {
              if (surveys.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Tokens.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Tokens.border),
                          ),
                          child: Icon(
                            LucideIcons.messageSquare,
                            size: 28,
                            color: Tokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.surveysEmpty,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.surveysDesc,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          onPressed: _openCreateDialog,
                          child: Text(l.surveysNew),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: surveys.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final s = surveys[idx];
                  return _buildSurveyCard(s);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyCard(Survey s) {
    final l = L.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go('/projects/${widget.projectId}/surveys/${s.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Tokens.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Tokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildTypeBadge(s.type),
                      const SizedBox(width: 8),
                      _buildStatusBadge(s.active),
                    ],
                  ),
                ),
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: () => _openEditDialog(s),
                  child: const Icon(LucideIcons.pencil, size: 14),
                ),
                const SizedBox(width: 4),
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: () => _deleteSurvey(s),
                  child: Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              s.question,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              ),
            ),
            if (s.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.description,
                style: TextStyle(fontSize: 12, color: Tokens.textMuted),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (s.targeting.urlPattern.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Tokens.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.globe, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          s.targeting.urlPattern,
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (s.targeting.eventTrigger.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Tokens.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Tokens.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.zap, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          s.targeting.eventTrigger,
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  context.fmt.dateTime(s.createdAt),
                  style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                ),
                const Spacer(),
                GhostButton(
                  density: ButtonDensity.compact,
                  onPressed: () => context.go('/projects/${widget.projectId}/surveys/${s.id}'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.surveysResponses, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowRight, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg;
    Color fg;
    String label;

    switch (type) {
      case 'nps':
        bg = const Color(0xFF0284C7).withValues(alpha: 0.15);
        fg = const Color(0xFF0284C7);
        label = 'NPS';
        break;
      case 'csat':
        bg = const Color(0xFF059669).withValues(alpha: 0.15);
        fg = const Color(0xFF059669);
        label = 'CSAT';
        break;
      case 'rating':
        bg = const Color(0xFFD97706).withValues(alpha: 0.15);
        fg = const Color(0xFFD97706);
        label = 'Rating';
        break;
      case 'single_choice':
        bg = const Color(0xFF7C3AED).withValues(alpha: 0.15);
        fg = const Color(0xFF7C3AED);
        label = 'Choice';
        break;
      case 'open_text':
      default:
        bg = const Color(0xFF4F46E5).withValues(alpha: 0.15);
        fg = const Color(0xFF4F46E5);
        label = 'Text';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    final l = L.of(context);
    final color = active ? Tokens.ok : Tokens.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        active ? l.surveysActive : l.surveysInactive,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
