// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../app/theme/tokens.dart';
import '../../core/format.dart';
import 'field_error.dart';

/// A confirmation dialog; if [onConfirm] throws, the dialog stays open.
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.destructive = false,
  });

  final String title, message, confirmLabel;
  final Future<void> Function() onConfirm;
  final bool destructive;

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) closeOverlay(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message, style: const TextStyle(color: Tokens.textMuted)),
          if (_error != null) FieldError(_error!),
        ],
      ),
    ),
    actions: [
      OutlineButton(
        onPressed: _busy ? null : () => closeOverlay(context, false),
        child: Text(context.l10n.commonCancel),
      ),
      widget.destructive
          ? DestructiveButton(
              onPressed: _busy ? null : _confirm,
              child: Text(widget.confirmLabel),
            )
          : PrimaryButton(
              onPressed: _busy ? null : _confirm,
              child: Text(widget.confirmLabel),
            ),
    ],
  );
}
