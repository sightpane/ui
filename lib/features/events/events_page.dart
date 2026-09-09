import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// Event name × day table (the last 30 days, the last 14 days as columns).
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider(projectId));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.eventsTitle,
            subtitle: context.l10n.eventsSubtitle,
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(eventsProvider(projectId)),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: PanelCard(
              title: context.l10n.eventsTypes,
              child: events.when(
                skipLoadingOnReload: true,
                loading: () => PanelMessage(context.l10n.commonLoading),
                error: (e, _) => PanelMessage(
                  context.l10n.eventsLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
                data: (rows) {
                  if (rows.isEmpty) {
                    return PanelMessage(context.l10n.eventsEmpty);
                  }
                  final agg = <String, EventAgg>{};
                  for (final r in rows) {
                    agg.putIfAbsent(r.name, () => EventAgg(r.name)).add(r);
                  }
                  final list = agg.values.toList()
                    ..sort((a, b) => b.count.compareTo(a.count));
                  final days = (rows.map((r) => r.day).toSet().toList()
                    ..sort());
                  final shown = days.length > 14
                      ? days.sublist(days.length - 14)
                      : days;
                  return LayoutBuilder(
                    builder: (context, c) => SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: math.max(
                            c.maxWidth,
                            360 + 64.0 * shown.length,
                          ),
                          child: DataTable<EventAgg>(
                            columns: [
                              (context.l10n.colEvent, 3, false),
                              (context.l10n.colTotal, 1, true),
                              (context.l10n.colUser, 1, true),
                              for (final d in shown)
                                (context.fmt.day(d), 1, true),
                            ],
                            rows: list,
                            cells: (a) => [
                              Text(
                                a.name,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Tokens.text,
                                ),
                              ),
                              Text(
                                context.fmt.integer(a.count),
                                style: AppTheme.mono(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: Tokens.accent,
                                ),
                              ),
                              Text(
                                context.fmt.integer(a.users),
                                style: AppTheme.mono(
                                  size: 12,
                                  color: Tokens.textMuted,
                                ),
                              ),
                              for (final d in shown)
                                Text(
                                  a.byDay[d] == null
                                      ? '·'
                                      : context.fmt.integer(a.byDay[d]!),
                                  style: AppTheme.mono(
                                    size: 11,
                                    color: a.byDay[d] == null
                                        ? Tokens.textFaint
                                        : Tokens.text,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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

class EventAgg {
  EventAgg(this.name);
  final String name;
  int count = 0, users = 0;
  final byDay = <String, int>{};
  void add(EventCount r) {
    count += r.count;
    if (r.users > users) users = r.users;
    byDay[r.day] = (byDay[r.day] ?? 0) + r.count;
  }
}
