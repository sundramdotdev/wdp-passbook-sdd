// core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand - WDP Orange (From Logo)
  static const Color primary         = Color(0xFFF97316); 
  static const Color primaryDark     = Color(0xFFEA6B0E); 

  // --- Light Mode ---
  static const Color lightBg         = Color(0xFFF0F3F8);
  static const Color lightCard       = Color(0xFFE0E5EC);
  static const Color lightButton     = Color(0xFFE0E5EC);
  static const Color lightText       = Color(0xFF1E1E1E);
  static const Color lightTextMuted  = Color(0xFF757575);
  
  // Shadows (Light)
  static const Color lightShadowOuter = Color(0x26A3B1C6); 
  static const Color lightShadowInnerLight = Color(0x99FFFFFF);
  static const Color lightShadowInnerDark = Color(0x1A000000);

  // --- Dark Mode (Navy Blue based on logo) ---
  static const Color darkBg          = Color(0xFF0F1724); // #0F1724 Deep Navy
  static const Color darkCard        = Color(0xFF1A2435); // #1A2435 Elevated Navy
  static const Color darkButton      = Color(0xFF1A2435);
  static const Color darkText        = Color(0xFFFFFFFF); // Pure white
  static const Color darkTextMuted   = Color(0xFFA3ADC2); // Blueish muted gray
  
  // Shadows (Dark)
  static const Color darkShadowOuter = Color(0x80080C14); // #080C14 Deep dark blue shadow
  static const Color darkShadowInnerLight = Color(0x0DFFFFFF); // 5% white inset
  static const Color darkShadowInnerDark = Color(0x33000000); // 20% black inset

  // Semantic
  static const Color income          = Color(0xFF10B981); // Emerald
  static const Color expense         = Color(0xFFEF4444); // Red
  static const Color udhar           = Color(0xFFF59E0B); // Amber

  // Legacy/Fallback Colors (To fix compile errors on older screens)
  static const Color surface         = Color(0xFF1A2435); 
  static const Color surfaceElevated = Color(0xFF223047); 
  static const Color info            = Color(0xFF3B82F6);
  static const Color textPrimary     = Color(0xFFFFFFFF);
  static const Color textSecondary   = Color(0xFFA3ADC2); 
  static const Color divider         = Color(0x1FFFFFFF);
  static const Color border          = Color(0x1FFFFFFF);
}
