import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';

/// Centralized Theme System for WDP Passbook consuming WDP Design Tokens.
class AppTheme {
  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandOrange,
      onPrimary: Colors.white,
      primaryContainer: AppColors.orangeSoft,
      onPrimaryContainer: AppColors.orangePressed,
      secondary: AppColors.deepNavy,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSurfaceSoft,
      onSecondaryContainer: AppColors.deepNavy,
      error: AppColors.expense,
      onError: Colors.white,
      errorContainer: AppColors.expenseSoft,
      onErrorContainer: AppColors.expense,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightSurfaceSoft,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      shadow: AppColors.lightShadowLevel2,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AppColors.lightText, AppColors.lightTextMuted),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightText, size: 24),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.lightText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          elevation: 0,
          textStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightText,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          textStyle: AppTypography.labelMedium.copyWith(color: AppColors.lightText, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          textStyle: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.expense, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextTertiary),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextMuted),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.expense),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.brandOrange,
      onPrimary: Colors.white,
      primaryContainer: AppColors.navyElevated,
      onPrimaryContainer: AppColors.brandOrange,
      secondary: Colors.white,
      onSecondary: AppColors.deepNavy,
      secondaryContainer: AppColors.navyElevated,
      onSecondaryContainer: Colors.white,
      error: AppColors.expense,
      onError: Colors.white,
      errorContainer: AppColors.expenseSoft,
      onErrorContainer: AppColors.expense,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.navyElevated,
      outline: AppColors.navyBorder,
      outlineVariant: AppColors.navyDivider,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextMuted),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.navyBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText, size: 24),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.darkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          elevation: 0,
          textStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          side: const BorderSide(color: AppColors.navyBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          textStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkText, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandOrange,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          textStyle: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.navyBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.navyBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.expense, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextMuted),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextMuted),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.expense),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.navyDivider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT THEME BUILDER
  // ---------------------------------------------------------------------------
  static TextTheme _buildTextTheme(Color primaryTextColor, Color mutedTextColor) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: primaryTextColor),
      displayMedium: AppTypography.displayMedium.copyWith(color: primaryTextColor),
      displaySmall: AppTypography.displaySmall.copyWith(color: primaryTextColor),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: primaryTextColor),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: primaryTextColor),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: primaryTextColor),
      titleLarge: AppTypography.titleLarge.copyWith(color: primaryTextColor),
      titleMedium: AppTypography.titleMedium.copyWith(color: primaryTextColor),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primaryTextColor),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: primaryTextColor),
      bodySmall: AppTypography.bodySmall.copyWith(color: mutedTextColor),
      labelMedium: AppTypography.labelMedium.copyWith(color: primaryTextColor),
      labelSmall: AppTypography.labelSmall.copyWith(color: mutedTextColor),
    );
  }
}
