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

class FeatureFlagDialog extends ConsumerStatefulWidget {
  const FeatureFlagDialog({
    super.key,
    required this.projectId,
    this.flag,
  });

  final int projectId;
  final FeatureFlag? flag;

  @override
  ConsumerState<FeatureFlagDialog> createState() => _FeatureFlagDialogState();
}

class _FeatureFlagDialogState extends ConsumerState<FeatureFlagDialog> {
  late final TextEditingController _keyCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _testDistinctIdCtrl;

  late bool _enabled;
  late int _rolloutPercentage;
  late List<FlagFilter> _filters;
  late List<FlagVariant> _variants;

  bool _saving = false;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final f = widget.flag;
    _keyCtrl = TextEditingController(text: f?.key ?? '');
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _descCtrl = TextEditingController(text: f?.description ?? '');
    _testDistinctIdCtrl = TextEditingController(text: 'user_123');

    _enabled = f?.enabled ?? true;
    _rolloutPercentage = f?.rolloutPercentage ?? 100;
    _filters = f != null ? List.from(f.filters) : [];
    _variants = f != null ? List.from(f.variants) : [];
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _testDistinctIdCtrl.dispose();
    super.dispose();
  }

  void _addFilter() {
    setState(() {
      _filters.add(const FlagFilter(property: 'role', operator: 'exact', value: 'beta'));
    });
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
  }

  void _addVariant() {
    setState(() {
      final key = 'variant_${_variants.length + 1}';
      _variants.add(FlagVariant(key: key, rollout: 50));
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  Future<void> _runTest() async {
    final distinctId = _testDistinctIdCtrl.text.trim();
    if (distinctId.isEmpty) return;

    setState(() => _testing = true);
    final api = ref.read(apiProvider);
    try {
      if (widget.flag != null) {
        final res = await api.testFeatureFlag(
          widget.projectId,
          widget.flag!.id,
          distinctId: distinctId,
        );
        if (mounted) {
          setState(() {
            _testResult = 'Result: ${res['value']} (active: ${res['active']})';
            _testing = false;
          });
        }
      } else {
        // Evaluate locally using model
        final tempFlag = FeatureFlag(
          id: 0,
          projectId: widget.projectId,
          key: _keyCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          enabled: _enabled,
          rolloutPercentage: _rolloutPercentage,
          filters: _filters,
          variants: _variants,
        );
        final val = _evaluateLocally(tempFlag, distinctId);
        setState(() {
          _testResult = 'Preview: $val';
          _testing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = 'Error: $e';
          _testing = false;
        });
      }
    }
  }

  dynamic _evaluateLocally(FeatureFlag flag, String distinctId) {
    if (!flag.enabled || flag.rolloutPercentage <= 0) return false;
    final payload = '${flag.key}:$distinctId';
    var code = 0;
    for (var i = 0; i < payload.length; i++) {
      code = (code * 31 + payload.codeUnitAt(i)) % 100;
    }
    if (code >= flag.rolloutPercentage) return false;
    if (flag.variants.isNotEmpty) {
      return flag.variants.first.key;
    }
    return true;
  }

  Future<void> _save() async {
    final key = _keyCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || key.isEmpty) return;

    setState(() => _saving = true);
    final api = ref.read(apiProvider);
    try {
      if (widget.flag != null) {
        await api.updateFeatureFlag(
          widget.projectId,
          widget.flag!.id,
          name: name,
          description: _descCtrl.text.trim(),
          enabled: _enabled,
          rolloutPercentage: _rolloutPercentage,
          filters: _filters,
          variants: _variants,
        );
      } else {
        await api.createFeatureFlag(
          widget.projectId,
          key: key,
          name: name,
          description: _descCtrl.text.trim(),
          enabled: _enabled,
          rolloutPercentage: _rolloutPercentage,
          filters: _filters,
          variants: _variants,
        );
      }
      ref.invalidate(featureFlagsProvider(widget.projectId));
      if (mounted) {
        toast(context, context.l10n.flagsSaved);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        toast(context, describeError(context.l10n, e));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.flag != null;

    return Card(
      filled: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? widget.flag!.name : context.l10n.flagsNew,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                    ),
                  ),
                  IconButton.ghost(
                    size: ButtonSize.small,
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Key field
                      Text(context.l10n.flagsKey, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.textMuted)),
                      const Gap(6),
                      TextField(
                        controller: _keyCtrl,
                        readOnly: isEdit,
                        placeholder: Text(context.l10n.flagsKeyHint),
                      ),
                      const Gap(14),

                      // Name field
                      Text(context.l10n.flagsName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.textMuted)),
                      const Gap(6),
                      TextField(
                        controller: _nameCtrl,
                        placeholder: Text(context.l10n.flagsName),
                      ),
                      const Gap(14),

                      // Description
                      Text(context.l10n.flagsDesc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.textMuted)),
                      const Gap(6),
                      TextField(
                        controller: _descCtrl,
                        placeholder: Text(context.l10n.flagsDesc),
                      ),
                      const Gap(16),

                      // Enabled switch and Rollout slider
                      Row(
                        children: [
                          Switch(
                            value: _enabled,
                            onChanged: (v) => setState(() => _enabled = v),
                          ),
                          const Gap(8),
                          Text(_enabled ? context.l10n.flagsActive : context.l10n.flagsDisabled, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('${context.l10n.flagsRollout}: $_rolloutPercentage%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted)),
                        ],
                      ),
                      const Gap(8),
                      Slider(
                        value: SliderValue.single(_rolloutPercentage / 100.0),
                        divisions: 20,
                        onChanged: (v) => setState(() => _rolloutPercentage = (v.value * 100).round()),
                      ),
                      const Gap(16),

                      // Targeting Rules (Filters)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.l10n.flagsFilters, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                          OutlineButton(
                            size: ButtonSize.small,
                            leading: const Icon(LucideIcons.plus, size: 12),
                            onPressed: _addFilter,
                            child: Text(context.l10n.flagsAddFilter),
                          ),
                        ],
                      ),
                      const Gap(8),
                      if (_filters.isEmpty)
                        Text(context.l10n.commonAll, style: const TextStyle(fontSize: 12, color: Tokens.textFaint))
                      else
                        for (var i = 0; i < _filters.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    placeholder: const Text('Property'),
                                    controller: TextEditingController(text: _filters[i].property)
                                      ..selection = TextSelection.collapsed(offset: _filters[i].property.length),
                                    onChanged: (v) => _filters[i] = FlagFilter(property: v, operator: _filters[i].operator, value: _filters[i].value),
                                  ),
                                ),
                                const Gap(6),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    placeholder: const Text('exact'),
                                    controller: TextEditingController(text: _filters[i].operator)
                                      ..selection = TextSelection.collapsed(offset: _filters[i].operator.length),
                                    onChanged: (v) => _filters[i] = FlagFilter(property: _filters[i].property, operator: v, value: _filters[i].value),
                                  ),
                                ),
                                const Gap(6),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    placeholder: const Text('Value'),
                                    controller: TextEditingController(text: '${_filters[i].value}')
                                      ..selection = TextSelection.collapsed(offset: '${_filters[i].value}'.length),
                                    onChanged: (v) => _filters[i] = FlagFilter(property: _filters[i].property, operator: _filters[i].operator, value: v),
                                  ),
                                ),
                                const Gap(4),
                                IconButton.ghost(
                                  size: ButtonSize.small,
                                  icon: const Icon(LucideIcons.trash, size: 13, color: Tokens.danger),
                                  onPressed: () => _removeFilter(i),
                                ),
                              ],
                            ),
                          ),

                      const Gap(16),

                      // Multivariant section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.l10n.flagsVariants, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                          OutlineButton(
                            size: ButtonSize.small,
                            leading: const Icon(LucideIcons.plus, size: 12),
                            onPressed: _addVariant,
                            child: Text(context.l10n.flagsAddVariant),
                          ),
                        ],
                      ),
                      const Gap(8),
                      for (var i = 0; i < _variants.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  placeholder: const Text('Variant key'),
                                  controller: TextEditingController(text: _variants[i].key)
                                    ..selection = TextSelection.collapsed(offset: _variants[i].key.length),
                                  onChanged: (v) => _variants[i] = FlagVariant(key: v, rollout: _variants[i].rollout),
                                ),
                              ),
                              const Gap(6),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  placeholder: const Text('Rollout %'),
                                  controller: TextEditingController(text: '${_variants[i].rollout}')
                                    ..selection = TextSelection.collapsed(offset: '${_variants[i].rollout}'.length),
                                  onChanged: (v) => _variants[i] = FlagVariant(key: _variants[i].key, rollout: int.tryParse(v) ?? 50),
                                ),
                              ),
                              const Gap(4),
                              IconButton.ghost(
                                size: ButtonSize.small,
                                icon: const Icon(LucideIcons.trash, size: 13, color: Tokens.danger),
                                onPressed: () => _removeVariant(i),
                              ),
                            ],
                          ),
                        ),

                      const Gap(16),

                      // Live preview / test box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Tokens.panel,
                          border: Border.all(color: Tokens.border),
                          borderRadius: BorderRadius.circular(Tokens.radius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(context.l10n.flagsTestTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.textStrong)),
                            const Gap(8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _testDistinctIdCtrl,
                                    placeholder: Text(context.l10n.flagsTestDistinctId),
                                  ),
                                ),
                                const Gap(8),
                                OutlineButton(
                                  size: ButtonSize.small,
                                  onPressed: _testing ? null : _runTest,
                                  child: Text(_testing ? context.l10n.commonLoading : 'Test'),
                                ),
                              ],
                            ),
                            if (_testResult != null) ...[
                              const Gap(8),
                              Text(
                                _testResult!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.brand),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GhostButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.commonCancel),
                  ),
                  const Gap(8),
                  PrimaryButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? context.l10n.commonLoading : context.l10n.commonSave),
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
