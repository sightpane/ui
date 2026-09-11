// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';
import '../../../shared/widgets/panel_message.dart';

class SankeyDiagram extends StatefulWidget {
  const SankeyDiagram({
    super.key,
    required this.result,
    this.onLinkTap,
  });

  final PathResult result;
  final void Function(PathLink link)? onLinkTap;

  @override
  State<SankeyDiagram> createState() => _SankeyDiagramState();
}

class _SankeyDiagramState extends State<SankeyDiagram> {
  PathLink? _hoveredLink;

  @override
  Widget build(BuildContext context) {
    if (widget.result.nodes.isEmpty || widget.result.links.isEmpty) {
      return PanelMessage(context.l10n.pathsEmpty);
    }

    // Group nodes by step
    final stepMap = <int, List<PathNode>>{};
    int maxStep = 0;
    for (final node in widget.result.nodes) {
      stepMap.putIfAbsent(node.step, () => []).add(node);
      if (node.step > maxStep) maxStep = node.step;
    }

    // Layout geometry constants
    const double colWidth = 180.0;
    const double colGap = 120.0;
    const double nodeHeight = 52.0;
    const double nodeGap = 16.0;
    const double topOffset = 48.0;

    int maxNodesInStep = 0;
    for (final list in stepMap.values) {
      if (list.length > maxNodesInStep) maxNodesInStep = list.length;
    }

    final double totalWidth = math.max(800.0, (maxStep + 1) * colWidth + maxStep * colGap + 60.0);
    final double totalHeight = math.max(450.0, topOffset + maxNodesInStep * (nodeHeight + nodeGap) + 60.0);

    // Compute node bounding boxes
    final nodeRects = <String, Rect>{};
    for (var s = 0; s <= maxStep; s++) {
      final nodes = stepMap[s] ?? [];
      final x = 30.0 + s * (colWidth + colGap);
      for (var i = 0; i < nodes.length; i++) {
        final y = topOffset + i * (nodeHeight + nodeGap);
        nodeRects[nodes[i].id] = Rect.fromLTWH(x, y, colWidth, nodeHeight);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            children: [
              // Custom paint for bezier ribbon links
              CustomPaint(
                size: Size(totalWidth, totalHeight),
                painter: _SankeyPainter(
                  links: widget.result.links,
                  nodeRects: nodeRects,
                  hoveredLink: _hoveredLink,
                ),
              ),
              // Step header labels
              for (var s = 0; s <= maxStep; s++)
                Positioned(
                  left: 30.0 + s * (colWidth + colGap),
                  top: 12,
                  child: Container(
                    width: colWidth,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${context.l10n.retentionBucket} $s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Tokens.textMuted,
                      ),
                    ),
                  ),
                ),
              // Node widgets
              for (final node in widget.result.nodes) ...[
                if (nodeRects.containsKey(node.id))
                  _buildNodeWidget(context, node, nodeRects[node.id]!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, PathNode node, Rect rect) {
    final isExit = node.name == 'Exit' || node.name.startsWith('error');
    final displayName = node.name == 'Exit' ? context.l10n.pathsExit : node.name;
    final borderColor = isExit ? Tokens.danger.withValues(alpha: 0.5) : Tokens.border;
    final bgColor = isExit ? Tokens.danger.withValues(alpha: 0.08) : Tokens.surface;

    // Find upstream and downstream links for this node
    final outgoing = widget.result.links.where((l) => l.source == node.id).toList();
    final incoming = widget.result.links.where((l) => l.target == node.id).toList();

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Tooltip(
        tooltip: (_) => TooltipContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Tokens.textStrong),
              ),
              const Gap(4),
              Text(
                '${context.l10n.retentionUsers}: ${node.count}',
                style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
              ),
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (outgoing.isNotEmpty && widget.onLinkTap != null) {
              widget.onLinkTap!(outgoing.first);
            } else if (incoming.isNotEmpty && widget.onLinkTap != null) {
              widget.onLinkTap!(incoming.first);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(Tokens.radius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isExit ? Tokens.danger : Tokens.textStrong,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        '${node.count}',
                        style: const TextStyle(fontSize: 11, color: Tokens.textMuted),
                      ),
                    ],
                  ),
                ),
                if (outgoing.isNotEmpty && widget.onLinkTap != null)
                  IconButton.ghost(
                    size: ButtonSize.small,
                    icon: const Icon(LucideIcons.play, size: 12),
                    onPressed: () => widget.onLinkTap!(outgoing.first),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SankeyPainter extends CustomPainter {
  _SankeyPainter({
    required this.links,
    required this.nodeRects,
    this.hoveredLink,
  });

  final List<PathLink> links;
  final Map<String, Rect> nodeRects;
  final PathLink? hoveredLink;

  @override
  void paint(Canvas canvas, Size size) {
    if (links.isEmpty) return;

    int maxCount = 1;
    for (final l in links) {
      if (l.count > maxCount) maxCount = l.count.toInt();
    }

    for (final link in links) {
      final src = nodeRects[link.source];
      final tgt = nodeRects[link.target];
      if (src == null || tgt == null) continue;

      final startPoint = Offset(src.right, src.top + src.height / 2);
      final endPoint = Offset(tgt.left, tgt.top + tgt.height / 2);

      final thickness = (link.count.toDouble() / maxCount * 28.0).clamp(3.0, 32.0);
      final isExit = link.target.endsWith(':Exit') || link.target.contains(':error:');
      final baseColor = isExit ? Tokens.danger : Tokens.brand;
      final alpha = (link == hoveredLink) ? 0.65 : 0.28;

      final paint = Paint()
        ..color = baseColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);

      final dx = (endPoint.dx - startPoint.dx) / 2;
      path.cubicTo(
        startPoint.dx + dx,
        startPoint.dy,
        endPoint.dx - dx,
        endPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SankeyPainter oldDelegate) {
    return oldDelegate.links != links || oldDelegate.hoveredLink != hoveredLink;
  }
}
