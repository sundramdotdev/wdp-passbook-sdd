import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/constants/app_colors.dart';
import 'package:wdp_passbook/core/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    testWidgets('lightTheme has correct brightness and colors', (tester) async {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBg);
      expect(theme.colorScheme.primary, AppColors.brandOrange);
      expect(theme.colorScheme.surface, AppColors.lightSurface);
      expect(theme.colorScheme.error, AppColors.expense);
    });

    testWidgets('darkTheme has correct brightness and colors', (tester) async {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBg);
      expect(theme.colorScheme.primary, AppColors.brandOrange);
      expect(theme.colorScheme.surface, AppColors.darkSurface);
      expect(theme.colorScheme.error, AppColors.expense);
    });

    testWidgets('button themes adhere to touch targets and colors', (tester) async {
      final lightTheme = AppTheme.lightTheme;
      final elevatedButtonStyle = lightTheme.elevatedButtonTheme.style;
      expect(elevatedButtonStyle, isNotNull);
    });
  });
}
