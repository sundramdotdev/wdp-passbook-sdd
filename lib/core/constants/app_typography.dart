import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Manrope-based Typographic hierarchy matching Stitch design tokens.
class AppTypography {
  static TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.96,
  );

  static TextStyle displayMedium = GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.8,
  );

  static TextStyle displaySmall = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.32,
  );

  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.28,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.24,
  );

  static TextStyle headlineSmall = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
  );

  static TextStyle titleLarge = GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 30 / 22,
  );

  static TextStyle titleMedium = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
  );

  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
  );

  static TextStyle labelMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  static TextStyle labelSmall = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.24,
  );

  static TextStyle caption = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.33,
  );

  // Numerical Tabular Figures for Currency
  static TextStyle amountLarge = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle amountMedium = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle amountSmall = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
