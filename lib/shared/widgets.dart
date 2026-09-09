import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../app/theme/app_theme.dart';
import '../app/theme/tokens.dart';
import '../core/format.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Tokens.textStrong,
        ),
      ),
      if (subtitle != null) ...[
        const Gap(10),
        Flexible(
          child: Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: Tokens.textDim),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      const Spacer(),
      for (final a in actions) ...[a, const Gap(8)],
    ],
  );
}

class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    padding: EdgeInsets.zero,
    filled: true,
    fillColor: Tokens.panel,
    borderColor: Tokens.border,
    borderRadius: BorderRadius.circular(Tokens.radius),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tokens.border)),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Tokens.textStrong,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(10),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 11, color: Tokens.textDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              ?action,
            ],
          ),
        ),
        Flexible(child: child),
      ],
    ),
  );
}

class PanelMessage extends StatelessWidget {
  const PanelMessage(this.text, {super.key, this.color = Tokens.textDim});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: Text(text, style: TextStyle(fontSize: 12, color: color)),
  );
}

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.valueColor = Tokens.textStrong,
  });
  final String label, value;
  final String? note;
  final Color valueColor;
  @override
  Widget build(BuildContext context) => Card(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
    filled: true,
    fillColor: Tokens.panel,
    borderColor: Tokens.border,
    borderRadius: BorderRadius.circular(Tokens.radius),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Tokens.textDim),
        ),
        const Gap(4),
        Text(
          value,
          style: AppTheme.mono(
            size: 22,
            weight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (note != null)
          Text(
            note!,
            style: const TextStyle(fontSize: 11, color: Tokens.textDim),
          ),
      ],
    ),
  );
}

/// KPIs side by side; stacked on a narrow screen.
class KpiRow extends StatelessWidget {
  const KpiRow(this.tiles, {super.key});
  final List<Widget> tiles;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < Tokens.mobileBreakpoint
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in tiles) ...[t, const Gap(8)],
            ],
          )
        : Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                Expanded(child: tiles[i]),
                if (i < tiles.length - 1) const Gap(10),
              ],
            ],
          ),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = Tokens.textMuted});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
    decoration: BoxDecoration(
      border: Border.all(color: color.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Tokens.textMuted,
      ),
    ),
  );
}

class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Tokens.danger),
    ),
  );
}

/// A single copyable line (API key, address).
class CopyField extends StatelessWidget {
  const CopyField({super.key, required this.value, this.label});
  final String value;
  final String? label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (label != null) ...[
        SizedBox(
          width: 90,
          child: Text(
            label!,
            style: const TextStyle(fontSize: 12, color: Tokens.textDim),
          ),
        ),
        const Gap(8),
      ],
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Tokens.surface,
            border: Border.all(color: Tokens.border),
            borderRadius: BorderRadius.circular(Tokens.radius),
          ),
          child: SelectableText(value, style: AppTheme.mono(size: 12)),
        ),
      ),
      const Gap(6),
      IconButton.ghost(
        size: ButtonSize.small,
        icon: const Icon(LucideIcons.copy, size: 14),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          toast(context, context.l10n.commonCopied);
        },
      ),
    ],
  );
}

void toast(BuildContext context, String title, {String? subtitle}) => showToast(
  context: context,
  builder: (context, overlay) => SurfaceCard(
    child: Basic(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    ),
  ),
);

Future<T?> showAppDialog<T>(BuildContext context, Widget dialog) =>
    showOverlay<T>(
      context,
      const DialogConfiguration(),
      builder: (_) => dialog,
    ).future;

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

/// A simple bar chart: [values] in day order; the highest value is full height.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = Tokens.accent,
    this.height = 120,
    this.secondary,
    this.secondaryColor = Tokens.danger,
  });
  final List<int> values;
  final List<String> labels;
  final List<int>? secondary;
  final Color color, secondaryColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final max = [
      ...values,
      ...?secondary,
    ].fold<int>(1, (m, v) => v > m ? v : m);
    return SizedBox(
      height: height + 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      tooltip: (_) => TooltipContainer(
                        child: Text(
                          '${labels[i]}: ${values[i]}${secondary == null ? '' : ' / ${secondary![i]}'}',
                        ),
                      ),
                      child: SizedBox(
                        height: height,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                height: height * values[i] / max,
                                decoration: BoxDecoration(
                                  color: values[i] == 0 ? Tokens.chip : color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            if (secondary != null) ...[
                              const Gap(1),
                              Expanded(
                                child: Container(
                                  height: height * secondary![i] / max,
                                  decoration: BoxDecoration(
                                    color: secondary![i] == 0
                                        ? Tokens.chip
                                        : secondaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      i % (values.length > 14 ? 7 : 2) == 0 ? labels[i] : '',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Tokens.textFaint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A plain table: headers + rows; a row can be tapped.
class DataTable<T> extends StatelessWidget {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.cells,
    this.onTap,
    this.emptyText,
  });
  final List<(String, int, bool)> columns; // header, flex, right-aligned
  final List<T> rows;
  final List<Widget> Function(T row) cells;
  final void Function(T)? onTap;

  /// The text shown when there are no rows; left out, "Kayıt yok." comes from
  /// the translations (the default cannot be a `const` string, it depends on the
  /// language).
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return PanelMessage(emptyText ?? context.l10n.commonNoRecords);
    }
    Widget line(List<Widget> cells, {bool header = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].$2,
              child: Align(
                alignment: columns[i].$3
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cells[i],
              ),
            ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tokens.hairline)),
          ),
          child: line([
            for (final c in columns)
              Text(
                context.fmt.upper(c.$1),
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: Tokens.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ]),
        ),
        for (final r in rows)
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Tokens.hairline)),
            ),
            child: onTap == null
                ? line(cells(r))
                : GhostButton(
                    density: ButtonDensity.compact,
                    alignment: Alignment.centerLeft,
                    onPressed: () => onTap!(r),
                    child: line(cells(r)),
                  ),
          ),
      ],
    );
  }
}
