// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

class _RuleItem {
  _RuleItem({
    this.type = 'event',
    String eventName = '',
    this.operator = 'gte',
    String value = '1',
    int windowDays = 30,
  })  : eventCtrl = TextEditingController(text: eventName),
        valueCtrl = TextEditingController(text: value),
        windowCtrl = TextEditingController(text: '$windowDays');

  String type;
  final TextEditingController eventCtrl;
  String operator;
  final TextEditingController valueCtrl;
  final TextEditingController windowCtrl;

  void dispose() {
    eventCtrl.dispose();
    valueCtrl.dispose();
    windowCtrl.dispose();
  }
}

class CohortCreateDialog extends ConsumerStatefulWidget {
  const CohortCreateDialog({
    super.key,
    required this.projectId,
    this.existing,
  });

  final int projectId;
  final Cohort? existing;

  @override
  ConsumerState<CohortCreateDialog> createState() => _CohortCreateDialogState();
}

class _CohortCreateDialogState extends ConsumerState<CohortCreateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final List<_RuleItem> _ruleItems;
  bool _isDynamic = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _descController = TextEditingController(text: widget.existing?.description ?? '');
    _isDynamic = widget.existing?.isDynamic ?? true;

    if (widget.existing != null && widget.existing!.rules.isNotEmpty) {
      _ruleItems = [
        for (final r in widget.existing!.rules)
          _RuleItem(
            type: r.type,
            eventName: r.eventName,
            operator: r.operator,
            value: r.value,
            windowDays: r.windowDays,
          ),
      ];
    } else {
      _ruleItems = [
        _RuleItem(
          type: 'event',
          eventName: 'page_view',
          operator: 'gte',
          value: '3',
          windowDays: 30,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final r in _ruleItems) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRule() {
    setState(() {
      _ruleItems.add(_RuleItem(
        type: 'event',
        eventName: '',
        operator: 'gte',
        value: '1',
        windowDays: 30,
      ));
    });
  }

  void _removeRule(int index) {
    if (_ruleItems.length <= 1) return;
    setState(() {
      final removed = _ruleItems.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.cohortName);
      return;
    }

    final rules = <CohortRule>[];
    for (final r in _ruleItems) {
      final eName = r.eventCtrl.text.trim();
      if (eName.isEmpty) continue;
      final val = r.valueCtrl.text.trim();
      final win = int.tryParse(r.windowCtrl.text.trim()) ?? 30;
      rules.add(CohortRule(
        type: r.type,
        eventName: eName,
        operator: r.operator,
        value: val.isEmpty ? '1' : val,
        windowDays: win > 0 ? win : 30,
      ));
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ref.read(apiProvider);
      if (widget.existing != null) {
        await api.updateCohort(
          widget.projectId,
          widget.existing!.id,
          name: name,
          description: _descController.text.trim(),
          isDynamic: _isDynamic,
          rules: rules,
        );
      } else {
        await api.createCohort(
          widget.projectId,
          name: name,
          description: _descController.text.trim(),
          isDynamic: _isDynamic,
          rules: rules,
        );
      }
      ref.invalidate(cohortsProvider(widget.projectId));
      if (mounted) {
        toast(
          context,
          widget.existing != null
              ? context.l10n.cohortRefreshed
              : context.l10n.cohortCreated,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = describeError(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      filled: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing != null
                      ? widget.existing!.name
                      : context.l10n.newCohort,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Tokens.textStrong,
                ),
              ),
              const Gap(16),
              if (_error != null) ...[
                FieldError(_error!),
                const Gap(12),
              ],
              FieldLabel(context.l10n.cohortName),
              const Gap(6),
              TextField(
                controller: _nameController,
                placeholder: Text(context.l10n.cohortName),
              ),
              const Gap(14),
              FieldLabel(context.l10n.cohortDescription),
              const Gap(6),
              TextField(
                controller: _descController,
                placeholder: Text(context.l10n.cohortDescription),
                maxLines: 2,
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FieldLabel(context.l10n.cohortRules),
                  GhostButton(
                    size: ButtonSize.small,
                    leading: const Icon(LucideIcons.plus, size: 12),
                    onPressed: _addRule,
                    child: Text(context.l10n.cohortAddRule),
                  ),
                ],
              ),
              const Gap(8),
              for (var i = 0; i < _ruleItems.length; i++) ...[
                _buildRuleRow(context, i),
                const Gap(10),
              ],
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GhostButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: Text(context.l10n.commonCancel),
                  ),
                  const Gap(8),
                  PrimaryButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.existing != null
                            ? context.l10n.commonSave
                            : context.l10n.commonCreate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildRuleRow(BuildContext context, int index) {
    final rule = _ruleItems[index];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Tokens.surface,
        border: Border.all(color: Tokens.border),
        borderRadius: BorderRadius.circular(Tokens.radius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: rule.eventCtrl,
                  placeholder: Text(context.l10n.cohortEventName),
                ),
              ),
              const Gap(8),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: TextEditingController(text: rule.operator),
                  enabled: false,
                  placeholder: const Text('>='),
                ),
              ),
              const Gap(8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: rule.valueCtrl,
                  placeholder: Text(context.l10n.cohortValue),
                ),
              ),
              const Gap(8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: rule.windowCtrl,
                  placeholder: Text(context.l10n.cohortWindowDays),
                ),
              ),
              if (_ruleItems.length > 1) ...[
                const Gap(8),
                IconButton.ghost(
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                  onPressed: () => _removeRule(index),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
