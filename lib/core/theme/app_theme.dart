// core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.lightCard,
        error: AppColors.expense,
        onSurface: AppColors.lightText,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightText),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightText),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightText),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightText),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightText),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightShadowOuter,
        thickness: 1,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.darkCard,
        error: AppColors.expense,
        onSurface: AppColors.darkText,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkText),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkText),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkText),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkText),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkText),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(color: AppColors.darkText, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkShadowOuter,
        thickness: 1,
      ),
      useMaterial3: true,
    );
  }
}
