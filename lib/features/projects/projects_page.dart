import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/config.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// The user's projects; 24-hour counters per card.
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: context.l10n.projectsTitle,
            subtitle: projects.value == null
                ? null
                : context.l10n.projectsCount(projects.value!.length),
            actions: [
              GhostButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.refreshCw, size: 14),
                onPressed: () => ref.invalidate(projectsProvider),
                child: Text(context.l10n.commonRefresh),
              ),
              PrimaryButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.plus, size: 14),
                onPressed: () =>
                    showAppDialog(context, const CreateProjectDialog()),
                child: Text(context.l10n.projectsNew),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: projects.when(
              skipLoadingOnReload: true,
              loading: () => PanelMessage(context.l10n.projectsLoading),
              error: (e, _) => PanelMessage(
                context.l10n.projectsLoadFailed(describeError(context.l10n, e)),
                color: Tokens.danger,
              ),
              data: (list) => list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.folderPlus,
                            size: 32,
                            color: Tokens.textDim,
                          ),
                          const Gap(10),
                          Text(
                            context.l10n.projectsEmptyTitle,
                            style: const TextStyle(color: Tokens.textMuted),
                          ),
                          const Gap(4),
                          Text(
                            context.l10n.projectsEmptyBody,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Tokens.textDim,
                            ),
                          ),
                          const Gap(14),
                          PrimaryButton(
                            onPressed: () => showAppDialog(
                              context,
                              const CreateProjectDialog(),
                            ),
                            child: Text(context.l10n.projectsCreateFirst),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, c) {
                        final cols = (c.maxWidth / 320).floor().clamp(1, 4);
                        return GridView.count(
                          crossAxisCount: cols,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            for (final p in list) ProjectCard(project: p),
                          ],
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

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return GhostButton(
      density: ButtonDensity.compact,
      alignment: Alignment.topLeft,
      onPressed: () => context.go('/projects/${p.id}'),
      child: Card(
        padding: const EdgeInsets.all(14),
        filled: true,
        fillColor: Tokens.panel,
        borderColor: Tokens.border,
        borderRadius: BorderRadius.circular(Tokens.radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Tokens.textStrong,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Pill(p.platform),
                if (p.isOwner) ...[
                  const Gap(6),
                  Pill(context.l10n.commonOwner, color: Tokens.accent),
                ],
              ],
            ),
            const Gap(4),
            Text(
              context.l10n.projectKeyAndAge(
                p.apiKey.length > 8 ? '${p.apiKey.substring(0, 8)}…' : p.apiKey,
                context.fmt.relative(p.createdAt),
              ),
              style: AppTheme.mono(size: 11, color: Tokens.textDim),
            ),
            const Spacer(),
            Row(
              children: [
                _Stat(
                  context.l10n.projectStatSessions24h,
                  context.fmt.integer(p.sessions24h),
                ),
                const Gap(18),
                _Stat(
                  context.l10n.projectStatErrors24h,
                  context.fmt.integer(p.errors24h),
                  color: p.errors24h > 0 ? Tokens.danger : Tokens.textStrong,
                ),
                const Gap(18),
                _Stat(
                  context.l10n.projectStatOpenIssues,
                  context.fmt.integer(p.openIssues),
                  color: p.openIssues > 0
                      ? Tokens.accentSoft
                      : Tokens.textStrong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color = Tokens.textStrong});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Tokens.textDim)),
      Text(
        value,
        style: AppTheme.mono(size: 16, weight: FontWeight.w600, color: color),
      ),
    ],
  );
}

/// A new project: name + platform; once created, the API key and the setup
/// snippet are shown.
class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({super.key});
  @override
  ConsumerState<CreateProjectDialog> createState() =>
      _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final _name = TextEditingController();
  String _platform = 'flutter';
  bool _busy = false;
  String? _error;
  Project? _created;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = context.l10n.projectNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final p = await ref
          .read(apiProvider)
          .createProject(_name.text.trim(), platform: _platform);
      ref.invalidate(projectsProvider);
      if (mounted) setState(() => _created = p);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    if (created != null) {
      return AlertDialog(
        title: Text(context.l10n.projectCreated(created.name)),
        content: SizedBox(width: 520, child: SetupSnippet(project: created)),
        actions: [
          OutlineButton(
            onPressed: () => closeOverlay(context),
            child: Text(context.l10n.commonClose),
          ),
          PrimaryButton(
            onPressed: () {
              closeOverlay(context);
              context.go('/projects/${created.id}');
            },
            child: Text(context.l10n.projectGoTo),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(context.l10n.projectsNew),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FieldLabel(context.l10n.projectName),
            TextField(
              controller: _name,
              enabled: !_busy,
              placeholder: Text(context.l10n.projectNameHint),
              autofocus: true,
              onSubmitted: (_) => _create(),
            ),
            const Gap(12),
            FieldLabel(context.l10n.projectPlatform),
            Row(
              children: [
                for (final p in const [
                  'flutter',
                  'web',
                  'desktop',
                  'mobile',
                ]) ...[
                  _platform == p
                      ? SecondaryButton(
                          size: ButtonSize.small,
                          onPressed: () {},
                          child: Text(p),
                        )
                      : GhostButton(
                          size: ButtonSize.small,
                          onPressed: () => setState(() => _platform = p),
                          child: Text(p),
                        ),
                  const Gap(4),
                ],
              ],
            ),
            if (_error != null) FieldError(_error!),
          ],
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: _busy ? null : () => closeOverlay(context),
          child: Text(context.l10n.commonCancel),
        ),
        PrimaryButton(
          onPressed: _busy ? null : _create,
          child: _busy
              ? const CircularProgressIndicator(size: 14)
              : Text(context.l10n.commonCreate),
        ),
      ],
    );
  }
}

enum SdkPlatform { flutter, web, html, reactNative }

/// Project-specific setup: address + API key + SDK snippet.
class SetupSnippet extends StatefulWidget {
  const SetupSnippet({super.key, required this.project});
  final Project project;

  @override
  State<SetupSnippet> createState() => _SetupSnippetState();
}

class _SetupSnippetState extends State<SetupSnippet> {
  late SdkPlatform _platform;

  @override
  void initState() {
    super.initState();
    final p = widget.project.platform.toLowerCase();
    if (p == 'html') {
      _platform = SdkPlatform.html;
    } else if (p == 'web') {
      _platform = SdkPlatform.web;
    } else if (p.contains('native') || p.contains('rn')) {
      _platform = SdkPlatform.reactNative;
    } else {
      _platform = SdkPlatform.flutter;
    }
  }

  String get code => switch (_platform) {
    SdkPlatform.flutter =>
      """
import 'package:sightpane/sightpane.dart';

void main() {
  Sightpane.init(
    SightpaneOptions(
      endpoint: '${AppConfig.apiUrl}',
      apiKey: '${widget.project.apiKey}',
      release: '1.0.0',
    ),
    appRunner: () => runApp(const MyApp()),
  );
}

// Inside MaterialApp.builder / ShadcnApp.builder:
// builder: (context, child) => SightpaneReplay(child: SightpaneUserInteractionWidget(child: child!)),
// go_router: observers: [SightpaneNavigatorObserver()]""",
    SdkPlatform.web =>
      """
import { init } from '@sightpane/browser';

init({
  endpoint: '${AppConfig.apiUrl}',
  apiKey: '${widget.project.apiKey}',
  release: '1.0.0',
  replay: true, // records DOM mutations & snapshots
});""",
    // The backend serves the script-tag build of @sightpane/browser at
    // /js/sightpane.js; the endpoint defaults to the origin it came from.
    SdkPlatform.html =>
      """
<script src="${AppConfig.apiUrl}/js/sightpane.js"
        data-key="${widget.project.apiKey}"
        data-release="1.0.0"
        data-replay="true"></script>
<script>
  // Optional: everything the SDK exports is on window.Sightpane.
  Sightpane.track('page_viewed', { path: location.pathname });
</script>""",
    SdkPlatform.reactNative =>
      """
import * as Sightpane from '@sightpane/react-native';

Sightpane.init({
  endpoint: '${AppConfig.apiUrl}',
  apiKey: '${widget.project.apiKey}',
  release: '1.0.0',
});""",
  };

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CopyField(label: context.l10n.setupAddress, value: AppConfig.apiUrl),
      const Gap(6),
      CopyField(label: context.l10n.setupApiKey, value: widget.project.apiKey),
      const Gap(10),
      Row(
        children: [
          FieldLabel(context.l10n.setupTitle),
          const Spacer(),
          _platformButton(SdkPlatform.flutter, 'Flutter'),
          const Gap(4),
          _platformButton(SdkPlatform.web, 'React / Web'),
          const Gap(4),
          _platformButton(SdkPlatform.html, 'HTML'),
          const Gap(4),
          _platformButton(SdkPlatform.reactNative, 'React Native'),
        ],
      ),
      const Gap(6),
      Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Tokens.surface,
              border: Border.all(color: Tokens.border),
              borderRadius: BorderRadius.circular(Tokens.radius),
            ),
            child: SelectableText(
              code,
              style: AppTheme.mono(size: 11.5, color: Tokens.textMuted),
            ),
          ),
          Positioned(top: 4, right: 4, child: CopyButton(value: code)),
        ],
      ),
    ],
  );

  Widget _platformButton(SdkPlatform p, String label) {
    final active = _platform == p;
    return GestureDetector(
      onTap: () => setState(() => _platform = p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active ? Tokens.brand.withValues(alpha: 0.15) : Tokens.surface,
          border: Border.all(color: active ? Tokens.brand : Tokens.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? Tokens.brand : Tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

class CopyButton extends StatelessWidget {
  const CopyButton({super.key, required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => IconButton.ghost(
    size: ButtonSize.small,
    icon: const Icon(LucideIcons.copy, size: 14),
    onPressed: () {
      Clipboard.setData(ClipboardData(text: value));
      toast(context, context.l10n.commonCopied);
    },
  );
}
