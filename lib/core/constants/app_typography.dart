// core/constants/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayMedium = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle amountLarge = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle amountMedium = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle amountSmall = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
