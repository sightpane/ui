import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class ReleasesPage extends ConsumerWidget {
  const ReleasesPage({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releases = ref.watch(releasesProvider(projectId));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.releasesTitle,
            subtitle: releases.maybeWhen(
              data: (list) => context.l10n.releasesCount(list.length),
              orElse: () => null,
            ),
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(releasesProvider(projectId)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: PanelCard(
              title: context.l10n.releasesTitle,
              child: releases.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  context.l10n.releasesLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return PanelMessage(context.l10n.releasesEmpty);
                  }
                  return SingleChildScrollView(
                    child: DataTable<ReleaseHealth>(
                      columns: [
                        (context.l10n.colRelease, 3, false),
                        (context.l10n.colCrashFreeRate, 2, true),
                        (context.l10n.colAdoption, 2, true),
                        (context.l10n.kpiSessions, 2, true),
                        (context.l10n.kpiErrors, 2, true),
                        (context.l10n.colErrorSessions, 2, true),
                        (context.l10n.colFirst, 2, false),
                        (context.l10n.colLast, 2, false),
                      ],
                      rows: list,
                      cells: (r) => [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.tag, size: 13, color: Tokens.accent),
                            const Gap(6),
                            Text(
                              r.version,
                              style: AppTheme.mono(
                                size: 13,
                                weight: FontWeight.w600,
                                color: Tokens.textStrong,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (r.crashFreeRate >= 99.0
                                    ? Tokens.ok
                                    : r.crashFreeRate >= 95.0
                                        ? Tokens.brand
                                        : Tokens.danger)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${r.crashFreeRate.toStringAsFixed(1)}%',
                            style: AppTheme.mono(
                              size: 12,
                              weight: FontWeight.w600,
                              color: r.crashFreeRate >= 99.0
                                  ? Tokens.ok
                                  : r.crashFreeRate >= 95.0
                                      ? Tokens.brand
                                      : Tokens.danger,
                            ),
                          ),
                        ),
                        Text(
                          '${r.adoptionRate.toStringAsFixed(1)}%',
                          style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                        ),
                        Text(
                          context.fmt.integer(r.sessionCount),
                          style: AppTheme.mono(size: 12, color: Tokens.text),
                        ),
                        Text(
                          context.fmt.integer(r.errorCount),
                          style: AppTheme.mono(
                            size: 12,
                            weight: r.errorCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            color: r.errorCount > 0 ? Tokens.danger : Tokens.textMuted,
                          ),
                        ),
                        Text(
                          context.fmt.integer(r.errorSessionCount),
                          style: AppTheme.mono(size: 12, color: Tokens.textMuted),
                        ),
                        Text(
                          context.fmt.dateTime(r.firstSeen),
                          style: AppTheme.mono(size: 11, color: Tokens.textDim),
                        ),
                        Text(
                          context.fmt.dateTime(r.lastSeen),
                          style: AppTheme.mono(size: 11, color: Tokens.textDim),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
