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

class SurveyDetailPage extends ConsumerStatefulWidget {
  const SurveyDetailPage({
    super.key,
    required this.projectId,
    required this.surveyId,
  });

  final int projectId;
  final int surveyId;

  @override
  ConsumerState<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends ConsumerState<SurveyDetailPage> {
  void _openEditDialog(Survey survey) {
    showAppDialog(
      context,
      SurveyDialog(
        projectId: widget.projectId,
        survey: survey,
      ),
    );
  }

  Future<void> _toggleActive(Survey survey, bool active) async {
    try {
      await ref.read(apiProvider).updateSurvey(
        widget.projectId,
        widget.surveyId,
        active: active,
      );
      ref.invalidate(surveyProvider((projectId: widget.projectId, surveyId: widget.surveyId)));
      ref.invalidate(surveysProvider(widget.projectId));
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showToast(
          context: context,
          builder: (ctx, overlay) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Tokens.danger,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(e.toString(), style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surveyAsync = ref.watch(surveyProvider((
      projectId: widget.projectId,
      surveyId: widget.surveyId,
    )));
    final resultsAsync = ref.watch(surveyResultsProvider((
      projectId: widget.projectId,
      surveyId: widget.surveyId,
    )));
    final responsesAsync = ref.watch(surveyResponsesProvider((
      projectId: widget.projectId,
      surveyId: widget.surveyId,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Breadcrumb
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: AppBreadcrumb(
            items: [
              BreadcrumbItem(
                label: 'Surveys',
                path: '/projects/${widget.projectId}/surveys',
              ),
              BreadcrumbItem(
                label: surveyAsync.value?.name ?? 'Survey #${widget.surveyId}',
              ),
            ],
          ),
        ),

        Expanded(
          child: surveyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text('Error loading survey: $err', style: TextStyle(color: Tokens.danger)),
            ),
            data: (survey) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                                    survey.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildTypeBadge(survey.type),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: survey.active,
                                  onChanged: (v) => _toggleActive(survey, v),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  survey.active ? l.surveysActive : l.surveysInactive,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: survey.active ? Tokens.ok : Tokens.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GhostButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () => _openEditDialog(survey),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.pencil, size: 14),
                                      SizedBox(width: 4),
                                      Text('Edit', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          survey.question,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                          ),
                        ),
                        if (survey.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            survey.description,
                            style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Analytics / Results Section
                  resultsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error loading results: $err', style: TextStyle(color: Tokens.danger)),
                    ),
                    data: (results) => _buildAnalyticsView(survey, results),
                  ),

                  const SizedBox(height: 24),

                  // Responses Section
                  Text(
                    l.surveysIndividualResponses,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  responsesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error loading responses: $err', style: TextStyle(color: Tokens.danger)),
                    ),
                    data: (responses) {
                      if (responses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Tokens.panel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Tokens.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'No responses collected yet.',
                            style: TextStyle(color: Tokens.textMuted),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Tokens.panel,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Tokens.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: Tokens.surface,
                                child: const Row(
                                  children: [
                                    SizedBox(width: 120, child: Text('User ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                    SizedBox(width: 90, child: Text('Score / Choice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                    Expanded(child: Text('Feedback / Comment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                    SizedBox(width: 140, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                    SizedBox(width: 130, child: Text('Session Replay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              for (int i = 0; i < responses.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                _buildResponseRow(responses[i]),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsView(Survey survey, SurveyResults results) {
    final l = L.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (survey.type == 'nps') ...[
          // NPS KPI cards
          Row(
            children: [
              // NPS Big Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Tokens.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.surveysNpsScore,
                        style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        results.npsScore != null ? results.npsScore!.toStringAsFixed(1) : '—',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: results.npsScore == null
                              ? null
                              : results.npsScore! >= 0
                                  ? Tokens.ok
                                  : Tokens.danger,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total responses: ${results.totalResponses}',
                        style: TextStyle(fontSize: 12, color: Tokens.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Promoters Card
              Expanded(
                child: _buildMetricTile(
                  label: l.surveysPromoters,
                  count: results.promotersCount,
                  total: results.totalResponses,
                  color: Tokens.ok,
                ),
              ),
              const SizedBox(width: 12),
              // Passives Card
              Expanded(
                child: _buildMetricTile(
                  label: l.surveysPassives,
                  count: results.passivesCount,
                  total: results.totalResponses,
                  color: Tokens.warning,
                ),
              ),
              const SizedBox(width: 12),
              // Detractors Card
              Expanded(
                child: _buildMetricTile(
                  label: l.surveysDetractors,
                  count: results.detractorsCount,
                  total: results.totalResponses,
                  color: Tokens.danger,
                ),
              ),
            ],
          ),
        ] else if (survey.type == 'csat' || survey.type == 'rating') ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Tokens.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Rating',
                        style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            results.averageScore != null
                                ? results.averageScore!.toStringAsFixed(2)
                                : '—',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('/ 5.0', style: TextStyle(color: Tokens.textMuted, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Tokens.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satisfaction Rate (Score 4-5)',
                        style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        results.satisfactionRate != null
                            ? '${results.satisfactionRate!.toStringAsFixed(1)}%'
                            : '—',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Tokens.ok,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Tokens.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Responses',
                        style: TextStyle(fontSize: 13, color: Tokens.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${results.totalResponses}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],

        // Score Distribution Histogram
        if (results.distribution.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Tokens.panel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.surveysScoreDistribution,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildDistributionBars(results),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final pct = total > 0 ? (count / total) * 100.0 : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Tokens.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Tokens.textMuted)),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBars(SurveyResults results) {
    int maxCount = 1;
    for (final b in results.distribution) {
      if (b.count > maxCount) maxCount = b.count;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final b in results.distribution) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    b.count > 0 ? '${b.count}' : '',
                    style: TextStyle(fontSize: 10, color: Tokens.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: (b.count / maxCount) * 80 + 4,
                    decoration: BoxDecoration(
                      color: b.count > 0 ? Tokens.brand : Tokens.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${b.score}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResponseRow(SurveyResponse r) {
    final l = L.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // User
          SizedBox(
            width: 120,
            child: Text(
              r.userId.isNotEmpty ? r.userId : 'Anonymous',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          // Score / Choice
          SizedBox(
            width: 90,
            child: r.score != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Tokens.brand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Score: ${r.score}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Tokens.brand,
                      ),
                    ),
                  )
                : Text('—', style: TextStyle(color: Tokens.textMuted)),
          ),
          // Feedback comment
          Expanded(
            child: Text(
              r.responseText.isNotEmpty ? r.responseText : '—',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Submitted date
          SizedBox(
            width: 140,
            child: Text(
              context.fmt.dateTime(r.createdAt),
              style: TextStyle(fontSize: 12, color: Tokens.textMuted),
            ),
          ),
          // Watch Replay Action
          SizedBox(
            width: 130,
            child: r.sessionId != null && r.sessionId!.isNotEmpty
                ? PrimaryButton(
                    density: ButtonDensity.compact,
                    onPressed: () => context.go('/projects/${widget.projectId}/sessions/${r.sessionId}'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.play, size: 12),
                        const SizedBox(width: 4),
                        Text(l.surveysWatchReplay, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  )
                : Text(
                    l.surveysNoReplay,
                    style: TextStyle(fontSize: 12, color: Tokens.textMuted),
                  ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
}
