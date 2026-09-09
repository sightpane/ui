import 'package:flutter/painting.dart';

/// Dashboard color and sizing constants (a pared-down Control Room palette).
abstract final class Tokens {
  static const brand = Color(0xFFF8A818);
  static const bg = Color(0xFF0E0D0B);
  static const surface = Color(0xFF121110);
  static const panel = Color(0xFF171512);
  static const raised = Color(0xFF201D18);
  static const chip = Color(0xFF2A2621);
  static const border = Color(0xFF262219);
  static const hairline = Color(0xFF1F1C17);
  static const textStrong = Color(0xFFFAF8F3);
  static const text = Color(0xFFE7E3DA);
  static const textMuted = Color(0xFFA39E92);
  static const textDim = Color(0xFF75706A);
  static const textFaint = Color(0xFF565149);
  static const accent = brand;
  static const accentSoft = Color(0xFFFFC24D);
  static const accentInk = Color(0xFF2A1B00);
  static const info = Color(0xFF38BDF8);
  static const ok = Color(0xFF4ADE80);
  static const danger = Color(0xFFF87171);
  static const radius = 6.0;
  static const sidebarWidth = 220.0;
  static const mobileBreakpoint = 900.0;
}
