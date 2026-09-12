import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'widgets/visitor_map.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({
    super.key,
    required this.projectId,
    this.query = '',
    this.days = 14,
  });

  final int projectId;
  final String query;
  final int days;

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  late int _days = widget.days;
  late final TextEditingController _searchController = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(UsersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && _searchController.text != widget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDetail(BuildContext context, UserSummary user) {
    context.go(
      '/projects/${widget.projectId}/users/detail?userId=${Uri.encodeQueryComponent(user.userId)}',
      extra: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final usersAsync = ref.watch(
      usersProvider((
        project: widget.projectId,
        days: _days,
        query: query,
      )),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.usersTitle,
            subtitle: usersAsync.maybeWhen(
              data: (d) => context.l10n.usersSubtitle(d.totalUsers),
              orElse: () => null,
            ),
            actions: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchController,
                  placeholder: Text(context.l10n.usersSearchPlaceholder),
                  features: [
                    const InputFeature.leading(Icon(LucideIcons.search, size: 14)),
                    if (_searchController.text.isNotEmpty)
                      InputFeature.trailing(
                        GhostButton(
                          density: ButtonDensity.compact,
                          size: ButtonSize.xSmall,
                          onPressed: () {
                            setState(() => _searchController.clear());
                          },
                          child: const Icon(LucideIcons.x, size: 12),
                        ),
                      ),
                  ],
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              const Gap(8),
              for (final d in const [7, 14, 30, 90]) ...[
                _days == d
                    ? SecondaryButton(
                        size: ButtonSize.small,
                        onPressed: () {},
                        child: Text(context.l10n.overviewDaysShort(d)),
                      )
                    : GhostButton(
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _days = d),
                        child: Text(context.l10n.overviewDaysShort(d)),
                      ),
                const Gap(4),
              ],
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(
                  usersProvider((
                    project: widget.projectId,
                    days: _days,
                    query: query,
                  )),
                ),
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: usersAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: PanelMessage(
                  context.l10n.usersLoadFailed(describeError(context.l10n, e)),
                  color: Tokens.danger,
                ),
              ),
              data: (data) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KpiRow([
                      KpiTile(
                        label: context.l10n.kpiTotalUsers,
                        value: context.fmt.integer(data.totalUsers),
                      ),
                      KpiTile(
                        label: context.l10n.kpiActiveUsers,
                        value: context.fmt.integer(data.activeUsers),
                      ),
                      KpiTile(
                        label: context.l10n.kpiAvgDuration,
                        value: context.fmt.duration(data.avgDuration),
                      ),
                      KpiTile(
                        label: context.l10n.kpiSessionsPerUser,
                        value: data.sessionsPerUser.toStringAsFixed(1),
                      ),
                    ]),
                    if (data.daily.isNotEmpty) ...[
                      const Gap(14),
                      PanelCard(
                        title: context.l10n.chartActiveUsers,
                        subtitle: context.l10n.chartActiveUsersSub,
                        child: BarChart(
                          values: [for (final d in data.daily) d.activeUsers],
                          secondary: [for (final d in data.daily) d.errorUsers],
                          labels: [for (final d in data.daily) context.fmt.day(d.day)],
                          color: Tokens.accent,
                          secondaryColor: Tokens.danger,
                          height: 110,
                        ),
                      ),
                    ],
                    const Gap(14),
                    VisitorMap(locations: data.locations),
                    const Gap(14),
                    PanelCard(
                      title: context.l10n.usersTitle,
                      subtitle: context.l10n.usersSubtitle(data.users.length),
                      child: data.users.isEmpty
                          ? PanelMessage(context.l10n.usersEmpty)
                          : DataTable<UserSummary>(
                              columns: [
                                (context.l10n.colUser, 4, false),
                                (context.l10n.kpiSessions, 2, true),
                                (context.l10n.colAvgDuration, 2, true),
                                (context.l10n.kpiErrors, 2, true),
                                (context.l10n.colPlatform, 3, false),
                                (context.l10n.colFirstSeen, 2, false),
                                (context.l10n.colLastSeen, 2, false),
                                ('', 2, true),
                              ],
                              rows: data.users,
                              onTap: (u) => _showUserDetail(context, u),
                              cells: (u) => [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Tokens.accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Center(
                                        child: Text(
                                          u.initials,
                                          style: AppTheme.mono(
                                            size: 11,
                                            weight: FontWeight.w700,
                                            color: Tokens.accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            u.displayName.isEmpty
                                                ? context.l10n.commonAnonymous
                                                : u.displayName,
                                            style: AppTheme.mono(
                                              size: 13,
                                              weight: FontWeight.w600,
                                              color: Tokens.textStrong,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (u.name != null && u.email != null)
                                            Text(
                                              u.email!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Tokens.textDim,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          if (u.locationLabel.isNotEmpty) ...[
                                            const Gap(2),
                                            LocationBadge.fromUser(
                                              user: u,
                                              compact: true,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  context.fmt.integer(u.sessionCount),
                                  style: AppTheme.mono(size: 13, color: Tokens.text),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Tokens.chip,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.fmt.duration(u.avgDuration),
                                    style: AppTheme.mono(
                                      size: 11,
                                      color: Tokens.textMuted,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (u.errorCount > 0 ? Tokens.danger : Tokens.ok)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.fmt.integer(u.errorCount),
                                    style: AppTheme.mono(
                                      size: 12,
                                      color: u.errorCount > 0 ? Tokens.danger : Tokens.ok,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (u.lastPlatform.isNotEmpty)
                                      Pill(
                                        u.lastPlatform,
                                        color: Tokens.accent,
                                      ),
                                    if (u.lastPlatform.isNotEmpty && u.lastBrowser.isNotEmpty)
                                      const Gap(4),
                                    if (u.lastBrowser.isNotEmpty)
                                      Pill(
                                        u.lastBrowser,
                                        color: Tokens.textDim,
                                      ),
                                  ],
                                ),
                                Text(
                                  context.fmt.relative(u.firstSeen),
                                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                ),
                                Text(
                                  context.fmt.relative(u.lastSeen),
                                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlineButton(
                                      size: ButtonSize.small,
                                      density: ButtonDensity.compact,
                                      onPressed: () => context.go(
                                        '/projects/${widget.projectId}/sessions?q=user:${Uri.encodeComponent(u.userId)}',
                                      ),
                                      child: const Icon(LucideIcons.video, size: 12),
                                    ),
                                    const Gap(4),
                                    GhostButton(
                                      size: ButtonSize.small,
                                      density: ButtonDensity.compact,
                                      onPressed: () => _showUserDetail(context, u),
                                      child: const Icon(LucideIcons.chevronRight, size: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

