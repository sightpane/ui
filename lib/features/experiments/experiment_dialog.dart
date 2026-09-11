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

class ExperimentDialog extends ConsumerStatefulWidget {
  const ExperimentDialog({
    super.key,
    required this.projectId,
    this.experiment,
  });

  final int projectId;
  final Experiment? experiment;

  @override
  ConsumerState<ExperimentDialog> createState() => _ExperimentDialogState();
}

class _ExperimentDialogState extends ConsumerState<ExperimentDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _flagKeyCtrl;
  late final TextEditingController _metricCtrl;
  late final TextEditingController _sampleSizeCtrl;

  late List<ExperimentVariant> _variants;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final exp = widget.experiment;
    _nameCtrl = TextEditingController(text: exp?.name ?? '');
    _descCtrl = TextEditingController(text: exp?.description ?? '');
    _flagKeyCtrl = TextEditingController(text: exp?.featureFlagKey ?? '');
    _metricCtrl = TextEditingController(text: exp?.primaryMetricEvent ?? '');
    _sampleSizeCtrl = TextEditingController(
      text: '${exp?.minimumSampleSize ?? 1000}',
    );

    if (exp != null && exp.variants.isNotEmpty) {
      _variants = List.from(exp.variants);
    } else {
      _variants = [
        const ExperimentVariant(key: 'control', name: 'Control'),
        const ExperimentVariant(key: 'treatment', name: 'Treatment'),
      ];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _flagKeyCtrl.dispose();
    _metricCtrl.dispose();
    _sampleSizeCtrl.dispose();
    super.dispose();
  }

  void _addVariant() {
    setState(() {
      final idx = _variants.length + 1;
      _variants.add(ExperimentVariant(key: 'variant_$idx', name: 'Variant $idx'));
    });
  }

  void _removeVariant(int index) {
    if (_variants.length <= 2) {
      setState(() => _error = 'An experiment must have at least 2 variants.');
      return;
    }
    setState(() {
      _variants.removeAt(index);
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final flagKey = _flagKeyCtrl.text.trim();
    final metric = _metricCtrl.text.trim();
    final sampleSize = int.tryParse(_sampleSizeCtrl.text.trim()) ?? 1000;

    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    if (flagKey.isEmpty) {
      setState(() => _error = 'Linked Feature Flag Key is required.');
      return;
    }
    if (metric.isEmpty) {
      setState(() => _error = 'Primary Metric Event is required.');
      return;
    }
    if (_variants.length < 2) {
      setState(() => _error = 'At least 2 variants are required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final api = ref.read(apiProvider);
    try {
      if (widget.experiment == null) {
        await api.createExperiment(
          widget.projectId,
          name: name,
          description: _descCtrl.text.trim(),
          featureFlagKey: flagKey,
          primaryMetricEvent: metric,
          variants: _variants,
          minimumSampleSize: sampleSize,
        );
      } else {
        await api.updateExperiment(
          widget.projectId,
          widget.experiment!.id,
          name: name,
          description: _descCtrl.text.trim(),
          minimumSampleSize: sampleSize,
        );
      }
      ref.invalidate(experimentsProvider(widget.projectId));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = describeError(context.l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.experiment == null;

    return Card(
      filled: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.flaskConical, size: 20, color: Tokens.brand),
                  const Gap(10),
                  Text(
                    isNew ? 'Create New Experiment' : 'Edit Experiment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Tokens.textStrong,
                    ),
                  ),
                  const Spacer(),
                  GhostButton(
                    size: ButtonSize.small,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(LucideIcons.x, size: 16),
                  ),
                ],
              ),
              const Gap(16),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Tokens.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Tokens.radius),
                    border: Border.all(color: Tokens.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontSize: 12, color: Tokens.danger),
                  ),
                ),
                const Gap(14),
              ],
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Experiment Name',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                      const Gap(6),
                      TextField(
                        controller: _nameCtrl,
                        placeholder: const Text('e.g. Sign-up Button Color Test'),
                      ),
                      const Gap(14),
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                      const Gap(6),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 2,
                        placeholder: const Text('Hypothesis or goal for this experiment'),
                      ),
                      const Gap(14),
                      const Text(
                        'Linked Feature Flag Key',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                      const Gap(6),
                      TextField(
                        controller: _flagKeyCtrl,
                        enabled: isNew,
                        placeholder: const Text('e.g. cta_button_color'),
                      ),
                      const Gap(14),
                      const Text(
                        'Primary Metric Event',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                      const Gap(6),
                      TextField(
                        controller: _metricCtrl,
                        enabled: isNew,
                        placeholder: const Text('e.g. subscription_started or signup_completed'),
                      ),
                      const Gap(14),
                      const Text(
                        'Target Minimum Sample Size',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                      const Gap(6),
                      TextField(
                        controller: _sampleSizeCtrl,
                        placeholder: const Text('e.g. 1000'),
                      ),
                      const Gap(18),
                      Row(
                        children: [
                          const Text(
                            'Variants',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.textStrong),
                          ),
                          const Spacer(),
                          if (isNew)
                            GhostButton(
                              size: ButtonSize.small,
                              leading: const Icon(LucideIcons.plus, size: 14),
                              onPressed: _addVariant,
                              child: const Text('Add Variant'),
                            ),
                        ],
                      ),
                      const Gap(8),
                      for (int i = 0; i < _variants.length; i++) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Tokens.panel,
                                  borderRadius: BorderRadius.circular(Tokens.radius),
                                  border: Border.all(color: Tokens.border),
                                ),
                                child: Text(
                                  _variants[i].key,
                                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Tokens.textStrong),
                                ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Tokens.panel,
                                  borderRadius: BorderRadius.circular(Tokens.radius),
                                  border: Border.all(color: Tokens.border),
                                ),
                                child: Text(
                                  _variants[i].name,
                                  style: const TextStyle(fontSize: 13, color: Tokens.textStrong),
                                ),
                              ),
                            ),
                            if (isNew && _variants.length > 2) ...[
                              const Gap(6),
                              GhostButton(
                                size: ButtonSize.small,
                                onPressed: () => _removeVariant(i),
                                child: const Icon(LucideIcons.trash2, size: 14, color: Tokens.danger),
                              ),
                            ],
                          ],
                        ),
                        const Gap(6),
                      ],
                    ],
                  ),
                ),
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GhostButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Gap(10),
                  PrimaryButton(
                    onPressed: _saving ? null : _save,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_saving) ...[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const Gap(8),
                        ],
                        Text(isNew ? 'Create Experiment' : 'Save Changes'),
                      ],
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
