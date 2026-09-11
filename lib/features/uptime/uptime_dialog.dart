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

class UptimeDialog extends ConsumerStatefulWidget {
  const UptimeDialog({
    super.key,
    required this.projectId,
    this.monitor,
  });

  final int projectId;
  final UptimeMonitor? monitor;

  @override
  ConsumerState<UptimeDialog> createState() => _UptimeDialogState();
}

class _UptimeDialogState extends ConsumerState<UptimeDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _statusCtrl;
  late final TextEditingController _timeoutCtrl;

  String _method = 'GET';
  int _intervalSeconds = 60;
  bool _sslCheckEnabled = true;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.monitor;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _urlCtrl = TextEditingController(text: m?.url ?? 'https://');
    _statusCtrl = TextEditingController(text: (m?.expectedStatusCode ?? 200).toString());
    _timeoutCtrl = TextEditingController(text: (m?.timeoutSeconds ?? 10).toString());
    _method = m?.method ?? 'GET';
    _intervalSeconds = m?.intervalSeconds ?? 60;
    _sslCheckEnabled = m?.sslCheckEnabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _statusCtrl.dispose();
    _timeoutCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    final expectedStatus = int.tryParse(_statusCtrl.text.trim()) ?? 200;
    final timeout = int.tryParse(_timeoutCtrl.text.trim()) ?? 10;

    if (name.isEmpty) {
      setState(() => _error = 'Monitor name is required.');
      return;
    }
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      setState(() => _error = 'Valid HTTP or HTTPS URL is required.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (widget.monitor != null) {
        await ref.read(apiProvider).updateUptimeMonitor(
          widget.projectId,
          widget.monitor!.id,
          name: name,
          url: url,
          method: _method,
          expectedStatusCode: expectedStatus,
          intervalSeconds: _intervalSeconds,
          timeoutSeconds: timeout,
          sslCheckEnabled: _sslCheckEnabled,
        );
      } else {
        await ref.read(apiProvider).createUptimeMonitor(
          widget.projectId,
          name: name,
          url: url,
          method: _method,
          expectedStatusCode: expectedStatus,
          intervalSeconds: _intervalSeconds,
          timeoutSeconds: timeout,
          sslCheckEnabled: _sslCheckEnabled,
        );
      }

      ref.invalidate(uptimeMonitorsProvider(widget.projectId));
      ref.invalidate(uptimeStatsProvider(widget.projectId));
      if (widget.monitor != null) {
        ref.invalidate(uptimeMonitorProvider((
          projectId: widget.projectId,
          monitorId: widget.monitor!.id,
        )));
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
        constraints: const BoxConstraints(maxWidth: 540),
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
                        isEdit ? l.uptimeEdit : l.uptimeNew,
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
                      style: const TextStyle(color: Tokens.danger, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Name
                Text(
                  l.uptimeName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  placeholder: const Text('Production API Gateway'),
                ),
                const SizedBox(height: 14),

                // URL
                Text(
                  l.uptimeURL,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _urlCtrl,
                  placeholder: const Text('https://api.example.com/healthz'),
                ),
                const SizedBox(height: 14),

                // Method & Interval
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.uptimeMethod,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              for (final m in ['GET', 'HEAD', 'POST'])
                                OutlineButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () => setState(() => _method = m),
                                  child: Text(
                                    m,
                                    style: TextStyle(
                                      color: _method == m ? Tokens.brand : null,
                                      fontWeight: _method == m ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
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
                            l.uptimeInterval,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              for (final (sec, lbl) in [(30, '30s'), (60, '60s'), (300, '5m'), (600, '10m')])
                                OutlineButton(
                                  density: ButtonDensity.compact,
                                  onPressed: () => setState(() => _intervalSeconds = sec),
                                  child: Text(
                                    lbl,
                                    style: TextStyle(
                                      color: _intervalSeconds == sec ? Tokens.brand : null,
                                      fontWeight: _intervalSeconds == sec ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Expected Status Code & Timeout
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.uptimeExpectedStatus,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _statusCtrl,
                            placeholder: const Text('200'),
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
                            '${l.uptimeTimeout} (s)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textMuted),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _timeoutCtrl,
                            placeholder: const Text('10'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // SSL Check Checkbox
                Row(
                  children: [
                    Checkbox(
                      state: _sslCheckEnabled ? CheckboxState.checked : CheckboxState.unchecked,
                      onChanged: (val) {
                        setState(() => _sslCheckEnabled = val == CheckboxState.checked);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.uptimeSSLCheck,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Tokens.textStrong),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      onPressed: () => Navigator.of(context).pop(false),
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
