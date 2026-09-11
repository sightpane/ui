// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';

class SurveyDialog extends ConsumerStatefulWidget {
  const SurveyDialog({
    super.key,
    required this.projectId,
    this.survey,
  });

  final int projectId;
  final Survey? survey;

  @override
  ConsumerState<SurveyDialog> createState() => _SurveyDialogState();
}

class _SurveyDialogState extends ConsumerState<SurveyDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _questionCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _urlPatternCtrl;
  late final TextEditingController _eventTriggerCtrl;

  late String _type;
  late List<TextEditingController> _choiceCtrls;
  late bool _active;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.survey;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _questionCtrl = TextEditingController(text: s?.question ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _urlPatternCtrl = TextEditingController(text: s?.targeting.urlPattern ?? '');
    _eventTriggerCtrl = TextEditingController(text: s?.targeting.eventTrigger ?? '');

    _type = s?.type ?? 'nps';
    _active = s?.active ?? true;

    if (s != null && s.choices.isNotEmpty) {
      _choiceCtrls = s.choices.map((c) => TextEditingController(text: c)).toList();
    } else {
      _choiceCtrls = [
        TextEditingController(text: 'Option 1'),
        TextEditingController(text: 'Option 2'),
      ];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _questionCtrl.dispose();
    _descCtrl.dispose();
    _urlPatternCtrl.dispose();
    _eventTriggerCtrl.dispose();
    for (final c in _choiceCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addChoice() {
    setState(() {
      _choiceCtrls.add(TextEditingController(text: 'Option ${_choiceCtrls.length + 1}'));
    });
  }

  void _removeChoice(int idx) {
    if (_choiceCtrls.length <= 2) {
      setState(() => _error = 'Single choice survey must have at least 2 options.');
      return;
    }
    setState(() {
      final ctrl = _choiceCtrls.removeAt(idx);
      ctrl.dispose();
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final question = _questionCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    if (question.isEmpty) {
      setState(() => _error = 'Question is required.');
      return;
    }

    final choices = <String>[];
    if (_type == 'single_choice') {
      for (final c in _choiceCtrls) {
        final txt = c.text.trim();
        if (txt.isNotEmpty) {
          choices.add(txt);
        }
      }
      if (choices.length < 2) {
        setState(() => _error = 'Please provide at least 2 choices.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ref.read(apiProvider);
      final targeting = SurveyTargeting(
        urlPattern: _urlPatternCtrl.text.trim(),
        eventTrigger: _eventTriggerCtrl.text.trim(),
        sampleRate: 1.0,
      );

      if (widget.survey == null) {
        await api.createSurvey(
          widget.projectId,
          name: name,
          type: _type,
          question: question,
          description: _descCtrl.text.trim(),
          choices: choices,
          targeting: targeting,
          active: _active,
        );
      } else {
        await api.updateSurvey(
          widget.projectId,
          widget.survey!.id,
          name: name,
          type: _type,
          question: question,
          description: _descCtrl.text.trim(),
          choices: choices,
          targeting: targeting,
          active: _active,
        );
      }

      ref.invalidate(surveysProvider(widget.projectId));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.survey != null;

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
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Survey' : 'Create New Survey',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Tokens.textStrong,
                      ),
                    ),
                  ),
                  GhostButton(
                    density: ButtonDensity.compact,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Icon(LucideIcons.x, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Tokens.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Tokens.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Tokens.danger, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Survey Name
              const Text(
                'Survey Name',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                placeholder: const Text('e.g. Quarterly NPS or Checkout Satisfaction'),
              ),
              const SizedBox(height: 14),

              // Survey Type Selection
              const Text(
                'Survey Type',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in [
                    ('nps', 'NPS (0-10)'),
                    ('csat', 'CSAT (1-5)'),
                    ('rating', 'Rating (1-5)'),
                    ('single_choice', 'Single Choice'),
                    ('open_text', 'Open Text'),
                  ])
                    OutlineButton(
                      density: ButtonDensity.compact,
                      onPressed: isEdit ? null : () => setState(() => _type = t.$1),
                      child: Text(
                        t.$2,
                        style: TextStyle(
                          color: _type == t.$1 ? Tokens.brand : null,
                          fontWeight: _type == t.$1 ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Question
              const Text(
                'Question Text',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _questionCtrl,
                placeholder: const Text('e.g. How likely are you to recommend Sightpane?'),
              ),
              const SizedBox(height: 14),

              // Description / Subtitle
              const Text(
                'Description / Subtitle (Optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                placeholder: const Text('Brief extra context shown under the question'),
              ),
              const SizedBox(height: 14),

              // Single Choice Options
              if (_type == 'single_choice') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choices',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    GhostButton(
                      density: ButtonDensity.compact,
                      onPressed: _addChoice,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.plus, size: 14),
                          SizedBox(width: 4),
                          Text('Add Choice', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (int i = 0; i < _choiceCtrls.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _choiceCtrls[i],
                          placeholder: Text('Option ${i + 1}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GhostButton(
                        density: ButtonDensity.compact,
                        onPressed: () => _removeChoice(i),
                        child: const Icon(LucideIcons.trash2, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 8),
              ],

              // Targeting URL Pattern
              const Text(
                'Targeting: URL Pattern (Optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _urlPatternCtrl,
                placeholder: const Text('e.g. /checkout/* or /pricing'),
              ),
              const SizedBox(height: 14),

              // Targeting Event Trigger
              const Text(
                'Targeting: Event Trigger (Optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _eventTriggerCtrl,
                placeholder: const Text('e.g. purchase_success or signup_completed'),
              ),
              const SizedBox(height: 16),

              // Active Switch
              Row(
                children: [
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(width: 10),
                  const Text('Active (Collecting responses)', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GhostButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  PrimaryButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Save Changes' : 'Create Survey'),
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
