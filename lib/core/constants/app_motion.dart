import 'package:flutter/material.dart';

/// Semantic Motion Tokens for WDP Passbook.
/// Defines centralized animation durations and curves.
class AppMotion {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration sheet = Duration(milliseconds: 300);
  static const Duration screen = Duration(milliseconds: 350);
  static const Duration emphasis = Duration(milliseconds: 500);

  // Curves
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveAccelerate = Curves.easeInCubic;
  static const Curve curveEmphasized = Curves.fastOutSlowIn;
}
