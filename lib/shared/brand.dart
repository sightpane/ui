// sightpane — error tracking, product analytics and session replay you host yourself.
// Copyright (C) 2026 Can Us
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';

/// The sightpane mark: a window sash, divided off-centre, with one pane lit.
///
/// Three panes rather than four on purpose — a symmetrical cross reads as a
/// generic window *icon*, while the off-centre mullion makes it a particular
/// window. The lit column is the half that carries the brand colour and the
/// only part that survives at sixteen pixels, which is what [simplified] is
/// about.
///
/// Drawn rather than shipped as an asset: it is four shapes on a 64-unit grid,
/// it has to take its stroke colour from whatever it sits on, and an SVG would
/// mean a dependency for that.
class SightpaneMark extends StatelessWidget {
  const SightpaneMark({
    super.key,
    this.size = 20,
    this.color,
    this.simplified,
  });

  final double size;

  /// The frame and mullions; the lit pane is always [Tokens.accent]. Defaults
  /// to [Tokens.text].
  final Color? color;

  /// Drops the horizontal mullion. Null decides by [size]: below 20 logical
  /// pixels the 4-unit stroke lands on a single pixel and the horizontal
  /// mullion collides with the corner radius, so it goes.
  final bool? simplified;

  /// What [simplified] resolves to for this [size].
  bool get isSimplified => simplified ?? size < 20;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _MarkPainter(
        frame: color ?? Tokens.text,
        simplified: isSimplified,
      ),
      isComplex: false,
    ),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.frame, required this.simplified});

  final Color frame;
  final bool simplified;

  // Everything below is in grid units and scaled once, so the numbers match the
  // identity study one for one and stay whole at any size.
  static const _grid = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _grid;
    Offset p(double x, double y) => Offset(x * k, y * k);

    // The lit pane, clipped to the inner opening so it cannot bleed over the
    // frame's rounded corner.
    canvas.save();
    canvas.clipRRect(
      RRect.fromLTRBR(6 * k, 6 * k, 58 * k, 58 * k, Radius.circular(12 * k)),
    );
    canvas.drawRect(
      Rect.fromLTRB(40 * k, 6 * k, 58 * k, 58 * k),
      Paint()..color = Tokens.accent,
    );
    canvas.restore();

    final stroke = Paint()
      ..color = frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * k;

    canvas.drawRRect(
      RRect.fromLTRBR(4 * k, 4 * k, 60 * k, 60 * k, Radius.circular(14 * k)),
      stroke,
    );
    canvas.drawLine(p(40, 4), p(40, 60), stroke);
    // The horizontal stops at the mullion; carrying it across would close the
    // tall pane into a quadrant and lose the asymmetry the mark reads by.
    if (!simplified) canvas.drawLine(p(4, 38), p(40, 38), stroke);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.frame != frame || old.simplified != simplified;
}

/// `sightpane`, with the weight break doing the work a colour break would — so
/// it still reads in one colour, on a sticker or in a terminal.
class SightpaneWordmark extends StatelessWidget {
  const SightpaneWordmark({super.key, this.fontSize = 15, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: const [
        TextSpan(text: 'sight', style: TextStyle(fontWeight: FontWeight.w500)),
        TextSpan(text: 'pane', style: TextStyle(fontWeight: FontWeight.w700)),
      ],
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? Tokens.textStrong,
        // −0.035 em, from the identity study.
        letterSpacing: fontSize * -0.035,
        height: 1,
      ),
    ),
  );
}

/// Mark and wordmark side by side, at the proportions the study sets: the mark
/// is cap height plus two units, and the gap is a quarter of the mark.
class SightpaneLockup extends StatelessWidget {
  const SightpaneLockup({super.key, this.markSize = 18, this.fontSize = 15});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SightpaneMark(size: markSize),
      SizedBox(width: markSize / 4),
      SightpaneWordmark(fontSize: fontSize),
    ],
  );
}
