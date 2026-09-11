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
import '../../l10n/gen/app_localizations.dart';

class CronDialog extends ConsumerStatefulWidget {
  const CronDialog({
    super.key,
    required this.projectId,
    this.monitor,
  });

  final int projectId;
  final CronMonitor? monitor;

  @override
  ConsumerState<CronDialog> createState() => _CronDialogState();
}

class _CronDialogState extends ConsumerState<CronDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _scheduleCtrl;
  late final TextEditingController _timezoneCtrl;
  late final TextEditingController _gracePeriodCtrl;
  late final TextEditingController _maxRuntimeCtrl;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.monitor;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _slugCtrl = TextEditingController(text: m?.slug ?? '');
    _scheduleCtrl = TextEditingController(text: m?.schedule ?? '0 * * * *');
    _timezoneCtrl = TextEditingController(text: m?.timezone ?? 'UTC');
    _gracePeriodCtrl = TextEditingController(text: (m?.gracePeriodMinutes ?? 15).toString());
    _maxRuntimeCtrl = TextEditingController(text: (m?.maxRuntimeMinutes ?? 60).toString());

    if (m == null) {
      _nameCtrl.addListener(_onNameChanged);
    }
  }

  void _onNameChanged() {
    if (widget.monitor == null) {
      final slug = _nameCtrl.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugCtrl.text = slug;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _scheduleCtrl.dispose();
    _timezoneCtrl.dispose();
    _gracePeriodCtrl.dispose();
    _maxRuntimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final slug = _slugCtrl.text.trim();
    final schedule = _scheduleCtrl.text.trim();
    final timezone = _timezoneCtrl.text.trim().isEmpty ? 'UTC' : _timezoneCtrl.text.trim();
    final gracePeriod = int.tryParse(_gracePeriodCtrl.text.trim()) ?? 15;
    final maxRuntime = int.tryParse(_maxRuntimeCtrl.text.trim()) ?? 60;

    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    if (widget.monitor == null && slug.isEmpty) {
      setState(() => _error = 'Slug is required.');
      return;
    }
    if (schedule.isEmpty) {
      setState(() => _error = 'Schedule expression is required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (widget.monitor != null) {
        await ref.read(apiProvider).updateCronMonitor(
          widget.projectId,
          widget.monitor!.id,
          name: name,
          schedule: schedule,
          timezone: timezone,
          gracePeriodMinutes: gracePeriod,
          maxRuntimeMinutes: maxRuntime,
        );
      } else {
        await ref.read(apiProvider).createCronMonitor(
          widget.projectId,
          name: name,
          slug: slug,
          schedule: schedule,
          timezone: timezone,
          gracePeriodMinutes: gracePeriod,
          maxRuntimeMinutes: maxRuntime,
        );
      }

      ref.invalidate(cronMonitorsProvider(widget.projectId));
      ref.invalidate(cronStatsProvider(widget.projectId));
      if (widget.monitor != null) {
        ref.invalidate(cronMonitorProvider((projectId: widget.projectId, monitorId: widget.monitor!.id)));
      }

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
    final l = L.of(context);
    final isEdit = widget.monitor != null;

    return Card(
      filled: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Cron Monitor' : l.cronsNew,
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

                // Name
                Text(
                  l.cronsName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  placeholder: const Text('e.g. Daily Database Backup'),
                ),
                const SizedBox(height: 14),

                // Slug
                Text(
                  l.cronsSlug,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _slugCtrl,
                  enabled: !isEdit,
                  placeholder: const Text('daily-db-backup'),
                ),
                const SizedBox(height: 14),

                // Schedule
                Text(
                  l.cronsSchedule,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _scheduleCtrl,
                  placeholder: const Text('0 * * * * (Crontab format)'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    OutlineButton(
                      density: ButtonDensity.compact,
                      onPressed: () => setState(() => _scheduleCtrl.text = '*/5 * * * *'),
                      child: const Text('Every 5m', style: TextStyle(fontSize: 11)),
                    ),
                    OutlineButton(
                      density: ButtonDensity.compact,
                      onPressed: () => setState(() => _scheduleCtrl.text = '0 * * * *'),
                      child: const Text('Hourly', style: TextStyle(fontSize: 11)),
                    ),
                    OutlineButton(
                      density: ButtonDensity.compact,
                      onPressed: () => setState(() => _scheduleCtrl.text = '0 0 * * *'),
                      child: const Text('Daily', style: TextStyle(fontSize: 11)),
                    ),
                    OutlineButton(
                      density: ButtonDensity.compact,
                      onPressed: () => setState(() => _scheduleCtrl.text = '0 0 * * 0'),
                      child: const Text('Weekly', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Timezone
                Text(
                  l.cronsTimezone,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _timezoneCtrl,
                  placeholder: const Text('UTC'),
                ),
                const SizedBox(height: 14),

                // Grace Period & Max Runtime Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.cronsGracePeriod,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _gracePeriodCtrl,
                            placeholder: const Text('15'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.cronsMaxRuntime,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _maxRuntimeCtrl,
                            placeholder: const Text('60'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                      child: Text(l.commonCancel),
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
                          : Text(l.commonSave),
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
}
