import 'package:flutter/material.dart';

/// Stitch Design System Color Palette for WDP Passbook Personal Module.
class AppColors {
  // Brand
  static const Color brandOrange      = Color(0xFFF97316); // Vibrant Orange 500
  static const Color orangePressed    = Color(0xFFEA580C); // Orange 600
  static const Color orangeSoft       = Color(0xFFFFF7ED); // Orange 50
  static const Color primary          = brandOrange;
  static const Color primaryDark      = orangePressed;

  // Navy Neutrals
  static const Color deepNavy         = Color(0xFF0F1724); // Primary dark bedrock
  static const Color navyElevated     = Color(0xFF182131); // Dark elevated surface
  static const Color navySurface      = Color(0xFF111827); // Standard dark surface
  static const Color navyBorder       = Color(0xFF263244); // Dark border
  static const Color navyDivider      = Color(0xFF1E293B); // Dark divider

  // Light Mode Canvas & Surfaces
  static const Color lightBg          = Color(0xFFF7F8FA);
  static const Color lightSurface     = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFF1F3F5);
  static const Color lightBorder      = Color(0xFFE5E7EB);
  static const Color lightDivider     = Color(0xFFEAECF0);
  static const Color lightText        = Color(0xFF111827); // Gray 900
  static const Color lightTextMuted   = Color(0xFF667085); // Gray 500
  static const Color lightTextTertiary= Color(0xFF98A2B3); // Gray 400

  // Dark Mode Canvas & Surfaces
  static const Color darkBg           = Color(0xFF0B1018);
  static const Color darkSurface      = navySurface;
  static const Color darkCard         = navyElevated;
  static const Color darkText         = Color(0xFFFFFFFF);
  static const Color darkTextMuted    = Color(0xFFA3ADC2);

  // Financial Semantic
  static const Color income           = Color(0xFF16A34A); // Income Green
  static const Color incomeSoft       = Color(0xFFF0FDF4);
  static const Color expense          = Color(0xFFEF4444); // Expense Red
  static const Color expenseSoft      = Color(0xFFFEF2F2);
  static const Color warning          = Color(0xFFF59E0B); // Amber Warning
  static const Color warningSoft      = Color(0xFFFFFBEB);
  static const Color info             = Color(0xFF3B82F6); // Info Blue
  static const Color infoSoft         = Color(0xFFEFF6FF); // Blue 50
  static const Color udhar            = Color(0xFFF59E0B);
  static const Color semanticError    = expense;
  static const Color semanticWarning  = warning;
  static const Color brandGreen       = income;
  static const Color brandOrangeSurface = orangeSoft;

  // Deprecated/Compatibility aliases for older screens
  static const Color lightCard        = lightSurface;
  static const Color lightButton      = lightSurfaceSoft;
  static const Color darkButton       = navyElevated;
  static const Color surface          = lightSurface;
  static const Color surfaceElevated  = navyElevated;
  static const Color textPrimary      = lightText;
  static const Color textSecondary    = lightTextMuted;
  static const Color divider          = lightDivider;
  static const Color border           = lightBorder;

  // Claymorphic & Elevation Shadows
  static const Color lightShadowLevel1 = Color(0x0D0F1724); // 5% opacity
  static const Color lightShadowLevel2 = Color(0x140F1724); // 8% opacity
  static const Color lightShadowLevel3 = Color(0x1F0F1724); // 12% opacity
  static const Color lightShadowOuter  = Color(0x26A3B1C6);
  static const Color darkShadowOuter   = Color(0x80080C14);
  static const Color lightShadowInner  = Color(0xCCFFFFFF); // 80% white highlight
  static const Color darkShadowInner   = Color(0x0FFFFFFF); // 6% white highlight
}
