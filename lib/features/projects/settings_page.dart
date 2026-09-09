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
  bool _busy = false;
  String? _loadedFor;

  @override
  void dispose() {
    _name.dispose();
    _memberEmail.dispose();
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
          if (_loadedFor != '${p.id}:${p.name}') {
            _loadedFor = '${p.id}:${p.name}';
            _name.text = p.name;
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
                            const Gap(8),
                            PrimaryButton(
                              size: ButtonSize.small,
                              onPressed: owner && !_busy
                                  ? () => _run(() async {
                                      await api.updateProject(
                                        pid,
                                        name: _name.text.trim(),
                                        platform: p.platform,
                                      );
                                      ref.invalidate(projectProvider(pid));
                                      ref.invalidate(projectsProvider);
                                    }, done: context.l10n.settingsSaved)
                                  : null,
                              child: Text(context.l10n.commonSave),
                            ),
                          ],
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
