import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic Elevation and Shadow Tokens for WDP Passbook.
/// Kept subtle and refined to maintain a clean, premium visual language.
class AppElevation {
  // Shadow definitions
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: AppColors.lightShadowLevel1,
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.lightShadowLevel2,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.lightShadowLevel3,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x330F1724), // 20% opacity deep navy
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Dark Mode Shadows
  static const List<BoxShadow> darkCard = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkFloating = [
    BoxShadow(
      color: Color(0x66000000), // 40% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
