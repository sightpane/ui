// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/format.dart';
import '../../../core/models.dart';

/// A rendered block representing a call frame invocation over time.
class FlameBlock {
  const FlameBlock({
    required this.frameIndex,
    required this.frame,
    required this.depth,
    required this.startMs,
    required this.durationMs,
    required this.selfTimeMs,
    required this.totalTimeMs,
  });

  final int frameIndex;
  final ProfileFrame frame;
  final int depth;
  final double startMs;
  final double durationMs;
  final double selfTimeMs;
  final double totalTimeMs;
}

class FlameChart extends StatefulWidget {
  const FlameChart({
    super.key,
    required this.callTree,
    required this.totalDurationMs,
    this.searchQuery = '',
    this.inverted = false,
    this.zoomLevel = 1.0,
    this.selectedBlock,
    this.onBlockSelected,
  });

  final ProfileCallTree callTree;
  final double totalDurationMs;
  final String searchQuery;
  final bool inverted;
  final double zoomLevel;
  final FlameBlock? selectedBlock;
  final ValueChanged<FlameBlock?>? onBlockSelected;

  @override
  State<FlameChart> createState() => _FlameChartState();
}

class _FlameChartState extends State<FlameChart> {
  List<FlameBlock> _blocks = [];
  int _maxDepth = 0;
  FlameBlock? _hoveredBlock;

  @override
  void initState() {
    super.initState();
    _computeBlocks();
  }

  @override
  void didUpdateWidget(FlameChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callTree != widget.callTree ||
        oldWidget.totalDurationMs != widget.totalDurationMs) {
      _computeBlocks();
    }
  }

  void _computeBlocks() {
    final frames = widget.callTree.frames;
    final samples = widget.callTree.samples;

    if (frames.isEmpty || samples.isEmpty) {
      setState(() {
        _blocks = [];
        _maxDepth = 0;
      });
      return;
    }

    final computedBlocks = <FlameBlock>[];
    int maxD = 0;

    // Track active blocks per depth: depth -> current block start
    // Estimate interval per sample
    final sampleCount = samples.length;

    // Calculate self-time and total-time per frame index
    final frameSelfTimes = <int, double>{};
    final frameTotalTimes = <int, double>{};

    for (var i = 0; i < sampleCount; i++) {
      final s = samples[i];
      final nextElapsed = (i + 1 < sampleCount)
          ? samples[i + 1].elapsedMs
          : widget.totalDurationMs;
      final dt = math.max(0.1, nextElapsed - s.elapsedMs);

      for (var d = 0; d < s.stackId.length; d++) {
        final fIdx = s.stackId[d];
        frameTotalTimes[fIdx] = (frameTotalTimes[fIdx] ?? 0.0) + dt;
      }
      if (s.stackId.isNotEmpty) {
        final topIdx = s.stackId.last;
        frameSelfTimes[topIdx] = (frameSelfTimes[topIdx] ?? 0.0) + dt;
      }
    }

    // Build hierarchical blocks by collapsing contiguous samples with identical frame at depth
    final activeByDepth = <int, _ActiveBlock>{};

    for (var i = 0; i < sampleCount; i++) {
      final s = samples[i];
      final currentElapsed = s.elapsedMs;
      final nextElapsed = (i + 1 < sampleCount)
          ? samples[i + 1].elapsedMs
          : widget.totalDurationMs;
      final dt = math.max(0.1, nextElapsed - currentElapsed);

      final stack = s.stackId;
      if (stack.length > maxD) maxD = stack.length;

      // Close blocks that no longer match
      final depthsToClose = <int>[];
      for (final entry in activeByDepth.entries) {
        final d = entry.key;
        if (d >= stack.length || stack[d] != entry.value.frameIndex) {
          depthsToClose.add(d);
        }
      }
      depthsToClose.sort((a, b) => b.compareTo(a));
      for (final d in depthsToClose) {
        final ab = activeByDepth.remove(d)!;
        computedBlocks.add(
          FlameBlock(
            frameIndex: ab.frameIndex,
            frame: frames[ab.frameIndex],
            depth: d,
            startMs: ab.startMs,
            durationMs: ab.durationMs,
            selfTimeMs: frameSelfTimes[ab.frameIndex] ?? 0.0,
            totalTimeMs: frameTotalTimes[ab.frameIndex] ?? 0.0,
          ),
        );
      }

      // Extend or create blocks for current stack
      for (var d = 0; d < stack.length; d++) {
        final fIdx = stack[d];
        final existing = activeByDepth[d];
        if (existing == null) {
          activeByDepth[d] = _ActiveBlock(
            frameIndex: fIdx,
            startMs: currentElapsed,
            durationMs: dt,
          );
        } else if (existing.frameIndex == fIdx) {
          existing.durationMs += dt;
        }
      }
    }

    // Flush any remaining active blocks
    for (final entry in activeByDepth.entries) {
      final d = entry.key;
      final ab = entry.value;
      computedBlocks.add(
        FlameBlock(
          frameIndex: ab.frameIndex,
          frame: frames[ab.frameIndex],
          depth: d,
          startMs: ab.startMs,
          durationMs: ab.durationMs,
          selfTimeMs: frameSelfTimes[ab.frameIndex] ?? 0.0,
          totalTimeMs: frameTotalTimes[ab.frameIndex] ?? 0.0,
        ),
      );
    }

    setState(() {
      _blocks = computedBlocks;
      _maxDepth = maxD;
    });
  }

  FlameBlock? _findBlockAt(Offset localOffset, Size size) {
    if (_blocks.isEmpty || size.width <= 0 || size.height <= 0) return null;

    const rowHeight = 24.0;
    const rowSpacing = 2.0;
    final totalH = (_maxDepth + 1) * (rowHeight + rowSpacing);
    final totalW = size.width * widget.zoomLevel;
    final totalDur = math.max(1.0, widget.totalDurationMs);

    for (final b in _blocks) {
      final x = (b.startMs / totalDur) * totalW;
      final w = math.max(4.0, (b.durationMs / totalDur) * totalW);

      final y = widget.inverted
          ? b.depth * (rowHeight + rowSpacing)
          : (totalH - ((b.depth + 1) * (rowHeight + rowSpacing)));

      final rect = Rect.fromLTWH(x, y, w, rowHeight);
      if (rect.contains(localOffset)) {
        return b;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_blocks.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Tokens.panel,
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: Border.all(color: Tokens.border),
        ),
        child: Text(
          context.l10n.profilingEmpty,
          style: const TextStyle(color: Tokens.textMuted),
        ),
      );
    }

    const rowHeight = 24.0;
    const rowSpacing = 2.0;
    final chartHeight = math.max(260.0, (_maxDepth + 1) * (rowHeight + rowSpacing) + 30.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = constraints.maxWidth;
        final chartWidth = math.max(baseWidth, baseWidth * widget.zoomLevel);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                final b = _findBlockAt(event.localPosition, Size(baseWidth, chartHeight));
                if (b != _hoveredBlock) {
                  setState(() => _hoveredBlock = b);
                }
              },
              onExit: (_) {
                if (_hoveredBlock != null) {
                  setState(() => _hoveredBlock = null);
                }
              },
              child: GestureDetector(
                onTapUp: (details) {
                  final b = _findBlockAt(details.localPosition, Size(baseWidth, chartHeight));
                  widget.onBlockSelected?.call(b);
                },
                child: CustomPaint(
                  size: Size(chartWidth, chartHeight),
                  painter: _FlameChartPainter(
                    blocks: _blocks,
                    totalDurationMs: math.max(1.0, widget.totalDurationMs),
                    maxDepth: _maxDepth,
                    zoomLevel: widget.zoomLevel,
                    searchQuery: widget.searchQuery.trim().toLowerCase(),
                    inverted: widget.inverted,
                    hoveredBlock: _hoveredBlock,
                    selectedBlock: widget.selectedBlock,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveBlock {
  _ActiveBlock({
    required this.frameIndex,
    required this.startMs,
    required this.durationMs,
  });

  final int frameIndex;
  final double startMs;
  double durationMs;
}

class _FlameChartPainter extends CustomPainter {
  _FlameChartPainter({
    required this.blocks,
    required this.totalDurationMs,
    required this.maxDepth,
    required this.zoomLevel,
    required this.searchQuery,
    required this.inverted,
    this.hoveredBlock,
    this.selectedBlock,
  });

  final List<FlameBlock> blocks;
  final double totalDurationMs;
  final int maxDepth;
  final double zoomLevel;
  final String searchQuery;
  final bool inverted;
  final FlameBlock? hoveredBlock;
  final FlameBlock? selectedBlock;

  static const _palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF84CC16), // Lime
  ];

  Color _colorForFrame(String name, String file) {
    final key = file.isNotEmpty ? file : name;
    final hash = key.codeUnits.fold(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    const rowHeight = 24.0;
    const rowSpacing = 2.0;
    final totalH = (maxDepth + 1) * (rowHeight + rowSpacing);
    final totalW = size.width;

    // Draw background grid lines
    final gridPaint = Paint()
      ..color = Tokens.border.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    final stepCount = 10;
    for (var i = 0; i <= stepCount; i++) {
      final x = (i / stepCount) * totalW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final blockPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final b in blocks) {
      final x = (b.startMs / totalDurationMs) * totalW;
      final w = math.max(2.0, (b.durationMs / totalDurationMs) * totalW);

      final y = inverted
          ? b.depth * (rowHeight + rowSpacing)
          : (totalH - ((b.depth + 1) * (rowHeight + rowSpacing)));

      final rect = Rect.fromLTWH(x, y, w, rowHeight);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

      var color = _colorForFrame(b.frame.name, b.frame.file);

      final matchesSearch = searchQuery.isNotEmpty &&
          (b.frame.name.toLowerCase().contains(searchQuery) ||
              b.frame.file.toLowerCase().contains(searchQuery));

      final isHovered = hoveredBlock != null &&
          hoveredBlock!.frameIndex == b.frameIndex &&
          hoveredBlock!.depth == b.depth &&
          hoveredBlock!.startMs == b.startMs;

      final isSelected = selectedBlock != null &&
          selectedBlock!.frameIndex == b.frameIndex &&
          selectedBlock!.depth == b.depth &&
          selectedBlock!.startMs == b.startMs;

      if (searchQuery.isNotEmpty && !matchesSearch) {
        // Dim non-matching blocks
        color = color.withValues(alpha: 0.25);
      }

      blockPaint.color = color;
      canvas.drawRRect(rrect, blockPaint);

      if (isSelected) {
        borderPaint.color = const Color(0xFFFFFFFF);
        borderPaint.strokeWidth = 2.0;
        canvas.drawRRect(rrect, borderPaint);
      } else if (isHovered) {
        borderPaint.color = const Color(0xFFE2E8F0);
        borderPaint.strokeWidth = 1.5;
        canvas.drawRRect(rrect, borderPaint);
      } else if (matchesSearch) {
        borderPaint.color = const Color(0xFFFBBF24); // Amber highlight border
        borderPaint.strokeWidth = 1.5;
        canvas.drawRRect(rrect, borderPaint);
      }

      // Draw text if block has sufficient width
      if (w > 28) {
        final textSpan = TextSpan(
          text: b.frame.name,
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: 11,
            fontWeight: isSelected || matchesSearch ? FontWeight.w600 : FontWeight.w500,
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '...',
        )..layout(maxWidth: w - 8);

        final textY = y + (rowHeight - tp.height) / 2;
        tp.paint(canvas, Offset(x + 4, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlameChartPainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.totalDurationMs != totalDurationMs ||
        oldDelegate.maxDepth != maxDepth ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.inverted != inverted ||
        oldDelegate.hoveredBlock != hoveredBlock ||
        oldDelegate.selectedBlock != selectedBlock;
  }
}
