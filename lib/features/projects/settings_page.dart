import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import 'projects_page.dart' show SetupSnippet;
import '../../core/format.dart';
import 'export_downloader.dart';

/// Project settings: name, API key (rotation), setup snippet, members,
/// deletion.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, required this.projectId});
  final int projectId;
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _name = TextEditingController();
  final _memberEmail = TextEditingController();
  final _retention = TextEditingController();
  final _quota = TextEditingController();
  bool _busy = false;
  String? _loadedFor;

  @override
  void dispose() {
    _name.dispose();
    _memberEmail.dispose();
    _retention.dispose();
    _quota.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f, {String? done}) async {
    setState(() => _busy = true);
    try {
      await f();
      if (mounted && done != null) toast(context, done);
    } catch (e) {
      if (mounted) {
        toast(
          context,
          context.l10n.commonError,
          subtitle: describeError(context.l10n, e),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pid = widget.projectId;
    final project = ref.watch(projectProvider(pid));
    final members = ref.watch(membersProvider(pid));
    final api = ref.read(apiProvider);
    final me = ref.watch(authControllerProvider).value?.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: project.when(
        loading: () => PanelMessage(context.l10n.commonLoading),
        error: (e, _) => PanelMessage(
          context.l10n.settingsProjectLoadFailed(
            describeError(context.l10n, e),
          ),
          color: Tokens.danger,
        ),
        data: (p) {
          if (_loadedFor != '${p.id}:${p.name}:${p.retentionDays}:${p.quotaItemsPerMinute}') {
            _loadedFor = '${p.id}:${p.name}:${p.retentionDays}:${p.quotaItemsPerMinute}';
            _name.text = p.name;
            _retention.text = '${p.retentionDays}';
            _quota.text = '${p.quotaItemsPerMinute}';
          }
          final owner = p.isOwner;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(title: context.l10n.settingsTitle),
                const Gap(14),
                PanelCard(
                  title: context.l10n.settingsProject,
                  subtitle: owner
                      ? context.l10n.commonOwner
                      : context.l10n.settingsMemberReadOnly,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FieldLabel(context.l10n.settingsProjectNameLabel),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _name,
                                enabled: owner && !_busy,
                              ),
                            ),
                          ],
                        ),
                        const Gap(14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const FieldLabel('Retention Period (Days)'),
                                  TextField(
                                    controller: _retention,
                                    enabled: owner && !_busy,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const Gap(4),
                                  const Text(
                                    'Sessions older than this are purged daily. 0 = keep forever.',
                                    style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const FieldLabel('Ingest Quota (items/min)'),
                                  TextField(
                                    controller: _quota,
                                    enabled: owner && !_busy,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const Gap(4),
                                  const Text(
                                    'Limit per-minute item volume. 0 = unlimited.',
                                    style: TextStyle(fontSize: 11, color: Tokens.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: PrimaryButton(
                            size: ButtonSize.small,
                            onPressed: owner && !_busy
                                ? () => _run(() async {
                                    await api.updateProject(
                                      pid,
                                      name: _name.text.trim(),
                                      platform: p.platform,
                                      retentionDays: int.tryParse(_retention.text.trim()),
                                      quotaItemsPerMinute: int.tryParse(_quota.text.trim()),
                                    );
                                    ref.invalidate(projectProvider(pid));
                                    ref.invalidate(projectsProvider);
                                  }, done: context.l10n.settingsSaved)
                                : null,
                            child: Text(context.l10n.commonSave),
                          ),
                        ),
                        const Gap(14),
                        FieldLabel(context.l10n.setupApiKey),
                        Row(
                          children: [
                            Expanded(child: CopyField(value: p.apiKey)),
                            const Gap(8),
                            OutlineButton(
                              size: ButtonSize.small,
                              onPressed: owner && !_busy
                                  ? () => showAppDialog(
                                      context,
                                      ConfirmDialog(
                                        title: context.l10n.settingsRotateKey,
                                        message:
                                            context.l10n.settingsRotateKeyBody,
                                        confirmLabel:
                                            context.l10n.settingsRotate,
                                        destructive: true,
                                        onConfirm: () async {
                                          await api.rotateKey(pid);
                                          ref.invalidate(projectProvider(pid));
                                          ref.invalidate(projectsProvider);
                                        },
                                      ),
                                    )
                                  : null,
                              child: Text(context.l10n.settingsRotate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                PanelCard(
                  title: context.l10n.settingsSdkSetup,
                  subtitle: context.l10n.settingsSdkSetupNote,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SetupSnippet(project: p),
                  ),
                ),
                const Gap(12),
                PanelCard(
                  title: context.l10n.settingsMembers,
                  subtitle: members.value == null
                      ? null
                      : '${members.value!.length}',
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        members.when(
                          loading: () => Text(
                            context.l10n.commonLoading,
                            style: const TextStyle(color: Tokens.textDim),
                          ),
                          error: (e, _) => Text(
                            describeError(context.l10n, e),
                            style: const TextStyle(color: Tokens.danger),
                          ),
                          data: (ms) => Column(
                            children: [
                              for (final m in ms)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Avatar(
                                        initials: SightpaneUser(
                                          id: m.userId,
                                          email: m.email,
                                          name: m.name,
                                        ).initials,
                                        size: 26,
                                        backgroundColor: Tokens.chip,
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: Text(
                                          m.name.isEmpty
                                              ? m.email
                                              : '${m.name} · ${m.email}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Tokens.text,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Pill(
                                        m.role == 'owner'
                                            ? context.l10n.commonOwner
                                            : context.l10n.commonMember,
                                        color: m.role == 'owner'
                                            ? Tokens.accent
                                            : Tokens.textMuted,
                                      ),
                                      if (owner && m.userId != me?.id) ...[
                                        const Gap(6),
                                        IconButton.ghost(
                                          size: ButtonSize.small,
                                          icon: const Icon(
                                            LucideIcons.x,
                                            size: 14,
                                          ),
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () async {
                                                    await api.removeMember(
                                                      pid,
                                                      m.userId,
                                                    );
                                                    ref.invalidate(
                                                      membersProvider(pid),
                                                    );
                                                  },
                                                  done: context
                                                      .l10n
                                                      .settingsMemberRemoved,
                                                ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (owner) ...[
                          const Gap(10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  key: const Key('member-email-input'),
                                  controller: _memberEmail,
                                  enabled: !_busy,
                                  placeholder: Text(
                                    context.l10n.settingsMemberEmailHint,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              OutlineButton(
                                size: ButtonSize.small,
                                leading: const Icon(
                                  LucideIcons.userPlus,
                                  size: 14,
                                ),
                                onPressed: _busy
                                    ? null
                                    : () => _run(
                                        () async {
                                          await api.addMember(
                                            pid,
                                            _memberEmail.text.trim(),
                                          );
                                          _memberEmail.clear();
                                          ref.invalidate(membersProvider(pid));
                                        },
                                        done: context.l10n.settingsMemberAdded,
                                      ),
                                child: Text(context.l10n.settingsAddMember),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (owner) ...[
                  const Gap(12),
                  _AlertChannelsPanel(
                    projectId: pid,
                    busy: _busy,
                    onRun: _run,
                  ),
                  const Gap(12),
                  _AlertRulesPanel(
                    projectId: pid,
                    busy: _busy,
                    onRun: _run,
                  ),
                  const Gap(12),
                  _PrivacyPanel(
                    project: p,
                    busy: _busy,
                    onRun: _run,
                  ),
                  const Gap(12),
                  PanelCard(
                    title: context.l10n.settingsDangerZone,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.settingsDeleteBody,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Tokens.textMuted,
                              ),
                            ),
                          ),
                          DestructiveButton(
                            size: ButtonSize.small,
                            onPressed: _busy
                                ? null
                                : () => showAppDialog(
                                    context,
                                    ConfirmDialog(
                                      title: context.l10n
                                          .settingsDeleteConfirmTitle(p.name),
                                      message: context
                                          .l10n
                                          .settingsDeleteConfirmBody,
                                      confirmLabel: context.l10n.commonDelete,
                                      destructive: true,
                                      onConfirm: () async {
                                        await api.deleteProject(pid);
                                        ref.invalidate(projectsProvider);
                                        if (context.mounted) {
                                          context.go('/projects');
                                        }
                                      },
                                    ),
                                  ),
                            child: Text(context.l10n.settingsDeleteProject),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlertChannelsPanel extends ConsumerWidget {
  const _AlertChannelsPanel({
    required this.projectId,
    required this.busy,
    required this.onRun,
  });

  final int projectId;
  final bool busy;
  final Future<void> Function(Future<void> Function(), {String? done}) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(alertChannelsProvider(projectId));
    final api = ref.read(apiProvider);

    return PanelCard(
      title: context.l10n.settingsAlertChannels,
      action: OutlineButton(
        size: ButtonSize.small,
        leading: const Icon(LucideIcons.plus, size: 14),
        onPressed: busy
            ? null
            : () => showAppDialog(
                  context,
                  _CreateChannelDialog(projectId: projectId),
                ),
        child: Text(context.l10n.settingsAlertChannelAdd),
      ),
      child: channelsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(14),
          child: Center(child: CircularProgressIndicator(size: 16)),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            describeError(context.l10n, e),
            style: const TextStyle(color: Tokens.danger, fontSize: 12),
          ),
        ),
        data: (channels) {
          if (channels.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                context.l10n.settingsAlertChannelsEmpty,
                style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var i = 0; i < channels.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 1,
                      color: Tokens.border,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  _ChannelRow(
                    channel: channels[i],
                    busy: busy,
                    onTest: () => onRun(
                      () => api.testAlertChannel(projectId, channels[i].id),
                      done: context.l10n.settingsAlertChannelTestSuccess,
                    ),
                    onDelete: () => showAppDialog(
                      context,
                      ConfirmDialog(
                        title: context.l10n.settingsAlertChannelDeleteConfirm,
                        message: channels[i].name,
                        confirmLabel: context.l10n.commonDelete,
                        destructive: true,
                        onConfirm: () async {
                          await api.deleteAlertChannel(
                            projectId,
                            channels[i].id,
                          );
                          ref.invalidate(alertChannelsProvider(projectId));
                          ref.invalidate(alertRulesProvider(projectId));
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.channel,
    required this.busy,
    required this.onTest,
    required this.onDelete,
  });

  final AlertChannel channel;
  final bool busy;
  final VoidCallback onTest;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = switch (channel.kind) {
      'email' => LucideIcons.mail,
      'slack' => LucideIcons.messageSquare,
      _ => LucideIcons.webhook,
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: Tokens.textDim),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Tokens.textStrong,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                channel.target,
                style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Gap(8),
        Pill(channel.kind.toUpperCase(), color: Tokens.chip),
        const Gap(8),
        OutlineButton(
          size: ButtonSize.small,
          leading: const Icon(LucideIcons.send, size: 12),
          onPressed: busy ? null : onTest,
          child: Text(context.l10n.settingsAlertChannelTest),
        ),
        const Gap(4),
        IconButton.ghost(
          size: ButtonSize.small,
          icon: const Icon(LucideIcons.trash2, size: 14),
          onPressed: busy ? null : onDelete,
        ),
      ],
    );
  }
}

class _CreateChannelDialog extends ConsumerStatefulWidget {
  const _CreateChannelDialog({required this.projectId});
  final int projectId;

  @override
  ConsumerState<_CreateChannelDialog> createState() =>
      _CreateChannelDialogState();
}

class _CreateChannelDialogState extends ConsumerState<_CreateChannelDialog> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _secret = TextEditingController();
  String _kind = 'email';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final target = _target.text.trim();
    if (name.isEmpty || target.isEmpty) {
      setState(() => _error = context.l10n.errAlertChannelInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).createAlertChannel(
            widget.projectId,
            name: name,
            kind: _kind,
            target: target,
            secret: _secret.text.trim(),
          );
      ref.invalidate(alertChannelsProvider(widget.projectId));
      if (mounted) closeOverlay(context);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settingsAlertChannelAdd),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(context.l10n.settingsAlertChannelName),
            TextField(
              controller: _name,
              enabled: !_busy,
              autofocus: true,
            ),
            const Gap(12),
            FieldLabel(context.l10n.settingsAlertChannelKind),
            Row(
              children: [
                for (final k in const ['email', 'slack', 'webhook']) ...[
                  _kind == k
                      ? SecondaryButton(
                          size: ButtonSize.small,
                          onPressed: () {},
                          child: Text(k.toUpperCase()),
                        )
                      : GhostButton(
                          size: ButtonSize.small,
                          onPressed: () => setState(() => _kind = k),
                          child: Text(k.toUpperCase()),
                        ),
                  const Gap(6),
                ],
              ],
            ),
            const Gap(12),
            FieldLabel(context.l10n.settingsAlertChannelTarget),
            TextField(
              controller: _target,
              enabled: !_busy,
              placeholder: Text(
                _kind == 'email'
                    ? 'dev-team@example.com'
                    : _kind == 'slack'
                        ? 'https://hooks.slack.com/services/...'
                        : 'https://example.com/webhook',
              ),
            ),
            if (_kind == 'webhook') ...[
              const Gap(12),
              FieldLabel(context.l10n.settingsAlertChannelSecret),
              TextField(
                controller: _secret,
                enabled: !_busy,
                placeholder: Text(context.l10n.settingsAlertChannelSecretHint),
              ),
            ],
            if (_error != null) ...[
              const Gap(8),
              FieldError(_error!),
            ],
          ],
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: _busy ? null : () => closeOverlay(context),
          child: Text(context.l10n.commonCancel),
        ),
        PrimaryButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const CircularProgressIndicator(size: 14)
              : Text(context.l10n.commonCreate),
        ),
      ],
    );
  }
}

class _AlertRulesPanel extends ConsumerWidget {
  const _AlertRulesPanel({
    required this.projectId,
    required this.busy,
    required this.onRun,
  });

  final int projectId;
  final bool busy;
  final Future<void> Function(Future<void> Function(), {String? done}) onRun;

  String _eventKindLabel(BuildContext context, String kind) => switch (kind) {
        'new_issue' => context.l10n.settingsAlertRuleKindNewIssue,
        'regression' => context.l10n.settingsAlertRuleKindRegression,
        'rate_spike' => context.l10n.settingsAlertRuleKindRateSpike,
        'crash_free_drop' => context.l10n.settingsAlertRuleKindCrashFree,
        _ => kind,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(alertRulesProvider(projectId));
    final channelsAsync = ref.watch(alertChannelsProvider(projectId));
    final api = ref.read(apiProvider);

    final channels = channelsAsync.value ?? const [];
    final channelMap = {for (final c in channels) c.id: c.name};

    return PanelCard(
      title: context.l10n.settingsAlertRules,
      action: OutlineButton(
        size: ButtonSize.small,
        leading: const Icon(LucideIcons.plus, size: 14),
        onPressed: busy
            ? null
            : () => showAppDialog(
                  context,
                  _CreateRuleDialog(
                    projectId: projectId,
                    availableChannels: channels,
                  ),
                ),
        child: Text(context.l10n.settingsAlertRuleAdd),
      ),
      child: rulesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(14),
          child: Center(child: CircularProgressIndicator(size: 16)),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            describeError(context.l10n, e),
            style: const TextStyle(color: Tokens.danger, fontSize: 12),
          ),
        ),
        data: (rules) {
          if (rules.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                context.l10n.settingsAlertRulesEmpty,
                style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var i = 0; i < rules.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 1,
                      color: Tokens.border,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  _RuleRow(
                    rule: rules[i],
                    channelMap: channelMap,
                    eventKindLabel:
                        _eventKindLabel(context, rules[i].kind),
                    busy: busy,
                    onToggle: (enabled) => onRun(
                      () async {
                        await api.updateAlertRule(
                          projectId,
                          rules[i].id,
                          name: rules[i].name,
                          kind: rules[i].kind,
                          params: rules[i].params,
                          channelIds: rules[i].channelIds,
                          enabled: enabled,
                        );
                        ref.invalidate(alertRulesProvider(projectId));
                      },
                    ),
                    onDelete: () => showAppDialog(
                      context,
                      ConfirmDialog(
                        title: context.l10n.settingsAlertRuleDeleteConfirm,
                        message: rules[i].name,
                        confirmLabel: context.l10n.commonDelete,
                        destructive: true,
                        onConfirm: () async {
                          await api.deleteAlertRule(projectId, rules[i].id);
                          ref.invalidate(alertRulesProvider(projectId));
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.rule,
    required this.channelMap,
    required this.eventKindLabel,
    required this.busy,
    required this.onToggle,
    required this.onDelete,
  });

  final AlertRule rule;
  final Map<int, String> channelMap;
  final String eventKindLabel;
  final bool busy;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final channelNames = rule.channelIds
        .map((id) => channelMap[id] ?? '#$id')
        .join(', ');

    return Row(
      children: [
        Switch(
          value: rule.enabled,
          onChanged: busy ? null : onToggle,
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      rule.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color:
                            rule.enabled ? Tokens.textStrong : Tokens.textDim,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  Pill(eventKindLabel, color: Tokens.accent),
                ],
              ),
              if (channelNames.isNotEmpty) ...[
                const Gap(3),
                Text(
                  '${context.l10n.settingsAlertRuleChannels}: $channelNames',
                  style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const Gap(8),
        IconButton.ghost(
          key: Key('delete-alert-rule-${rule.id}'),
          size: ButtonSize.small,
          icon: const Icon(LucideIcons.trash2, size: 14),
          onPressed: busy ? null : onDelete,
        ),
      ],
    );
  }
}

class _CreateRuleDialog extends ConsumerStatefulWidget {
  const _CreateRuleDialog({
    required this.projectId,
    required this.availableChannels,
  });

  final int projectId;
  final List<AlertChannel> availableChannels;

  @override
  ConsumerState<_CreateRuleDialog> createState() => _CreateRuleDialogState();
}

class _CreateRuleDialogState extends ConsumerState<_CreateRuleDialog> {
  final _name = TextEditingController();
  final _threshold = TextEditingController(text: '10');
  final _window = TextEditingController(text: '5');
  String _eventKind = 'new_issue';
  final Set<int> _selectedChannelIds = {};
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.availableChannels.isNotEmpty) {
      _selectedChannelIds.add(widget.availableChannels.first.id);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _threshold.dispose();
    _window.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.errAlertRuleInvalid);
      return;
    }
    if (_selectedChannelIds.isEmpty) {
      setState(() => _error = context.l10n.settingsAlertRuleChannelsSelectHint);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final params = <String, dynamic>{};
      if (_eventKind == 'rate_spike' || _eventKind == 'crash_free_drop') {
        final threshold = double.tryParse(_threshold.text.trim());
        final window = int.tryParse(_window.text.trim());
        if (threshold != null) params['threshold'] = threshold;
        if (window != null) params['window_minutes'] = window;
      }
      await ref.read(apiProvider).createAlertRule(
            widget.projectId,
            name: name,
            kind: _eventKind,
            params: params,
            channelIds: _selectedChannelIds.toList(),
          );
      ref.invalidate(alertRulesProvider(widget.projectId));
      if (mounted) closeOverlay(context);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kinds = [
      ('new_issue', context.l10n.settingsAlertRuleKindNewIssue),
      ('regression', context.l10n.settingsAlertRuleKindRegression),
      ('rate_spike', context.l10n.settingsAlertRuleKindRateSpike),
      ('crash_free_drop', context.l10n.settingsAlertRuleKindCrashFree),
    ];

    return AlertDialog(
      title: Text(context.l10n.settingsAlertRuleAdd),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(context.l10n.settingsAlertRuleName),
              TextField(
                controller: _name,
                enabled: !_busy,
                autofocus: true,
              ),
              const Gap(12),
              FieldLabel(context.l10n.settingsAlertRuleKind),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (k, label) in kinds)
                    _eventKind == k
                        ? SecondaryButton(
                            size: ButtonSize.small,
                            onPressed: () {},
                            child: Text(label),
                          )
                        : GhostButton(
                            size: ButtonSize.small,
                            onPressed: () => setState(() => _eventKind = k),
                            child: Text(label),
                          ),
                ],
              ),
              if (_eventKind == 'rate_spike' ||
                  _eventKind == 'crash_free_drop') ...[
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabel(context.l10n.settingsAlertRuleThreshold),
                          TextField(
                            controller: _threshold,
                            enabled: !_busy,
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabel(context.l10n.settingsAlertRuleWindow),
                          TextField(
                            controller: _window,
                            enabled: !_busy,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const Gap(12),
              FieldLabel(context.l10n.settingsAlertRuleChannels),
              if (widget.availableChannels.isEmpty)
                Text(
                  context.l10n.settingsAlertChannelsEmpty,
                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final ch in widget.availableChannels)
                      _selectedChannelIds.contains(ch.id)
                          ? SecondaryButton(
                              size: ButtonSize.small,
                              onPressed: () => setState(
                                () => _selectedChannelIds.remove(ch.id),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.check, size: 12),
                                  const Gap(4),
                                  Text(ch.name),
                                ],
                              ),
                            )
                          : GhostButton(
                              size: ButtonSize.small,
                              onPressed: () => setState(
                                () => _selectedChannelIds.add(ch.id),
                              ),
                              child: Text(ch.name),
                            ),
                  ],
                ),
              if (_error != null) ...[
                const Gap(8),
                FieldError(_error!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: _busy ? null : () => closeOverlay(context),
          child: Text(context.l10n.commonCancel),
        ),
        PrimaryButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const CircularProgressIndicator(size: 14)
              : Text(context.l10n.commonCreate),
        ),
      ],
    );
  }
}

class _PrivacyPanel extends StatefulWidget {
  const _PrivacyPanel({
    required this.project,
    required this.busy,
    required this.onRun,
  });

  final Project project;
  final bool busy;
  final Future<void> Function(Future<void> Function() f, {String? done}) onRun;

  @override
  State<_PrivacyPanel> createState() => _PrivacyPanelState();
}

class _PrivacyPanelState extends State<_PrivacyPanel> {
  late String _storeIp;
  final _userId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _storeIp = widget.project.storeIp;
  }

  @override
  void didUpdateWidget(covariant _PrivacyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.storeIp != widget.project.storeIp) {
      _storeIp = widget.project.storeIp;
    }
  }

  @override
  void dispose() {
    _userId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.project.isOwner;
    return Consumer(
      builder: (context, ref, _) {
        final api = ref.read(apiProvider);
        final pid = widget.project.id;
        final ipModes = [
          ('full', 'Full IP', 'Store full client IP address'),
          ('anonymized', 'Anonymized (/24)', 'Zero out last octet (e.g. 192.168.1.0)'),
          ('none', 'Do Not Store', 'Completely discard client IP addresses'),
        ];

        return PanelCard(
          title: 'Privacy & KVKK / GDPR',
          subtitle: 'IP address retention policies and per-user data deletion/export.',
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FieldLabel('Client IP Storage Policy'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (mode, label, _) in ipModes)
                      _storeIp == mode
                          ? SecondaryButton(
                              size: ButtonSize.small,
                              onPressed: () {},
                              child: Text(label),
                            )
                          : GhostButton(
                              size: ButtonSize.small,
                              onPressed: owner && !widget.busy
                                  ? () {
                                      setState(() => _storeIp = mode);
                                      widget.onRun(() async {
                                        await api.updateProject(
                                          pid,
                                          name: widget.project.name,
                                          platform: widget.project.platform,
                                          retentionDays: widget.project.retentionDays,
                                          quotaItemsPerMinute: widget.project.quotaItemsPerMinute,
                                          storeIp: mode,
                                        );
                                        ref.invalidate(projectProvider(pid));
                                      }, done: 'IP storage policy updated');
                                    }
                                  : null,
                              child: Text(label),
                            ),
                  ],
                ),
                const Gap(6),
                Text(
                  ipModes.firstWhere((m) => m.$1 == _storeIp).$3,
                  style: const TextStyle(fontSize: 12, color: Tokens.textMuted),
                ),
                const Gap(18),
                const FieldLabel('User Data Management (Right to be Forgotten / Export)'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userId,
                        enabled: !widget.busy,
                        placeholder: const Text('Enter user ID (e.g. user_123)'),
                      ),
                    ),
                    const Gap(8),
                    OutlineButton(
                      size: ButtonSize.small,
                      leading: const Icon(LucideIcons.download, size: 14),
                      onPressed: widget.busy
                          ? null
                          : () {
                              final uid = _userId.text.trim();
                              if (uid.isEmpty) {
                                toast(context, 'User ID is required');
                                return;
                              }
                              final url = api.userExportUrl(pid, uid);
                              downloadExportUrl(url);
                              toast(context, 'Exporting data for $uid');
                            },
                      child: const Text('Export (.zip)'),
                    ),
                    if (owner) ...[
                      const Gap(8),
                      DestructiveButton(
                        size: ButtonSize.small,
                        leading: const Icon(LucideIcons.trash2, size: 14),
                        onPressed: widget.busy
                            ? null
                            : () {
                                final uid = _userId.text.trim();
                                if (uid.isEmpty) {
                                  toast(context, 'User ID is required');
                                  return;
                                }
                                showAppDialog(
                                  context,
                                  ConfirmDialog(
                                    title: 'Delete User Data',
                                    message:
                                        'All sessions, items, spans, and frame recordings for user "$uid" will be permanently deleted. This cannot be undone.',
                                    confirmLabel: 'Delete',
                                    destructive: true,
                                    onConfirm: () => widget.onRun(() async {
                                      await api.deleteUserData(pid, uid);
                                      _userId.clear();
                                      ref.invalidate(projectProvider(pid));
                                      ref.invalidate(projectsProvider);
                                    }, done: 'User data deleted'),
                                  ),
                                );
                              },
                        child: const Text('Delete Data'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

