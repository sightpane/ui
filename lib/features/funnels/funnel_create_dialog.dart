// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class FunnelCreateDialog extends ConsumerStatefulWidget {
  const FunnelCreateDialog({
    super.key,
    required this.projectId,
    this.existing,
  });

  final int projectId;
  final Funnel? existing;

  @override
  ConsumerState<FunnelCreateDialog> createState() => _FunnelCreateDialogState();
}

class _FunnelCreateDialogState extends ConsumerState<FunnelCreateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final List<TextEditingController> _stepControllers;
  int _conversionWindowSeconds = 86400;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
    _conversionWindowSeconds = widget.existing?.conversionWindowSeconds ?? 86400;

    if (widget.existing != null && widget.existing!.steps.isNotEmpty) {
      _stepControllers = [
        for (final s in widget.existing!.steps)
          TextEditingController(text: s.name),
      ];
    } else {
      _stepControllers = [
        TextEditingController(text: ''),
        TextEditingController(text: ''),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length <= 2) return;
    setState(() {
      final removed = _stepControllers.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.funnelName);
      return;
    }
    final steps = <FunnelStep>[];
    for (final c in _stepControllers) {
      final sName = c.text.trim();
      if (sName.isNotEmpty) {
        steps.add(FunnelStep(name: sName));
      }
    }
    if (steps.length < 2) {
      setState(() => _error = context.l10n.funnelStepMin);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ref.read(apiProvider);
      if (widget.existing != null) {
        await api.updateFunnel(
          widget.projectId,
          widget.existing!.id,
          name: name,
          description: _descController.text.trim(),
          steps: steps,
          conversionWindowSeconds: _conversionWindowSeconds,
        );
        if (mounted) {
          toast(context, context.l10n.funnelUpdated);
        }
      } else {
        await api.createFunnel(
          widget.projectId,
          name: name,
          description: _descController.text.trim(),
          steps: steps,
          conversionWindowSeconds: _conversionWindowSeconds,
        );
        if (mounted) {
          toast(context, context.l10n.funnelCreated);
        }
      }
      ref.invalidate(funnelsProvider(widget.projectId));
      if (widget.existing != null) {
        ref.invalidate(
          funnelProvider((project: widget.projectId, funnelId: widget.existing!.id)),
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      filled: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? context.l10n.funnelCreate
                    : context.l10n.funnelsTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Tokens.text,
                ),
              ),
              const Gap(16),
              FieldLabel(context.l10n.funnelName),
              const Gap(6),
              TextField(
                controller: _nameController,
                placeholder: Text(context.l10n.funnelName),
              ),
              const Gap(14),
              FieldLabel(context.l10n.funnelDescription),
              const Gap(6),
              TextField(
                controller: _descController,
                placeholder: Text(context.l10n.funnelDescription),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FieldLabel(context.l10n.funnelSteps),
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.plus, size: 14),
                    onPressed: _addStep,
                    child: Text(context.l10n.funnelStepAdd),
                  ),
                ],
              ),
              const Gap(8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _stepControllers.length,
                  separatorBuilder: (_, _) => const Gap(8),
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Tokens.raised,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Tokens.border),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Tokens.accent,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: TextField(
                            controller: _stepControllers[i],
                            placeholder: Text('${context.l10n.funnelStepEvent} (e.g. signup_submit)'),
                          ),
                        ),
                        if (_stepControllers.length > 2) ...[
                          const Gap(6),
                          GhostButton(
                            density: ButtonDensity.compact,
                            size: ButtonSize.small,
                            onPressed: () => _removeStep(i),
                            child: const Icon(LucideIcons.trash2, size: 15, color: Tokens.danger),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const Gap(16),
              FieldLabel(context.l10n.funnelWindow),
              const Gap(6),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in [
                    (86400, context.l10n.funnelWindow1d),
                    (604800, context.l10n.funnelWindow7d),
                    (1209600, context.l10n.funnelWindow14d),
                    (2592000, context.l10n.funnelWindow30d),
                  ])
                    if (_conversionWindowSeconds == entry.$1)
                      PrimaryButton(
                        density: ButtonDensity.compact,
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _conversionWindowSeconds = entry.$1),
                        child: Text(
                          entry.$2,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      OutlineButton(
                        density: ButtonDensity.compact,
                        size: ButtonSize.small,
                        onPressed: () => setState(() => _conversionWindowSeconds = entry.$1),
                        child: Text(
                          entry.$2,
                          style: const TextStyle(color: Tokens.textMuted),
                        ),
                      ),
                ],
              ),
              if (_error != null) ...[
                const Gap(12),
                FieldError(_error!),
              ],
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GhostButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: Text(context.l10n.commonCancel),
                  ),
                  const Gap(10),
                  PrimaryButton(
                    onPressed: _saving ? null : _submit,
                    leading: _saving ? const CircularProgressIndicator(size: 14) : null,
                    child: Text(
                      widget.existing == null
                          ? context.l10n.commonCreate
                          : context.l10n.commonSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
