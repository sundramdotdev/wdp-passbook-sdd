import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdp_passbook/core/constants/app_breakpoints.dart';
import 'package:wdp_passbook/core/constants/app_colors.dart';
import 'package:wdp_passbook/core/constants/app_elevation.dart';
import 'package:wdp_passbook/core/constants/app_icons.dart';
import 'package:wdp_passbook/core/constants/app_motion.dart';
import 'package:wdp_passbook/core/constants/app_radii.dart';
import 'package:wdp_passbook/core/constants/app_spacing.dart';
import 'package:wdp_passbook/core/constants/app_typography.dart';

void main() {
  group('Design Tokens - AppColors', () {
    test('brand colors match Stitch palette', () {
      expect(AppColors.brandOrange, const Color(0xFFF97316));
      expect(AppColors.orangePressed, const Color(0xFFEA580C));
      expect(AppColors.orangeSoft, const Color(0xFFFFF7ED));
      expect(AppColors.deepNavy, const Color(0xFF0F1724));
    });

    test('semantic financial colors are distinct and defined', () {
      expect(AppColors.income, const Color(0xFF16A34A));
      expect(AppColors.expense, const Color(0xFFEF4444));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.info, const Color(0xFF3B82F6));
    });
  });

  group('Design Tokens - AppSpacing', () {
    test('adheres to 4px spatial rhythm', () {
      expect(AppSpacing.xs % 4, 0);
      expect(AppSpacing.sm % 4, 0);
      expect(AppSpacing.md % 4, 0);
      expect(AppSpacing.lg % 4, 0);
      expect(AppSpacing.xl % 4, 0);
    });
  });

  group('Design Tokens - AppRadii', () {
    test('radii tokens maintain correct geometric hierarchy', () {
      expect(AppRadii.compact < AppRadii.control, isTrue);
      expect(AppRadii.control < AppRadii.card, isTrue);
      expect(AppRadii.card < AppRadii.hero, isTrue);
      expect(AppRadii.hero < AppRadii.pill, isTrue);
    });
  });

  group('Design Tokens - AppElevation', () {
    test('box shadow tokens provide subtle and clean elevation', () {
      expect(AppElevation.none, isEmpty);
      expect(AppElevation.subtle, isNotEmpty);
      expect(AppElevation.card, isNotEmpty);
      expect(AppElevation.floating, isNotEmpty);
      expect(AppElevation.card.first.blurRadius, 8.0);
    });
  });

  group('Design Tokens - AppMotion', () {
    test('durations align with UI hierarchy', () {
      expect(AppMotion.fast.inMilliseconds, 150);
      expect(AppMotion.standard.inMilliseconds, 250);
      expect(AppMotion.sheet.inMilliseconds, 300);
      expect(AppMotion.screen.inMilliseconds, 350);
    });
  });

  group('Design Tokens - AppBreakpoints', () {
    test('correctly categorizes screen sizes', () {
      // Mobile
      expect(AppBreakpoints.isMobile(375), isTrue);
      expect(AppBreakpoints.isMobile(599), isTrue);
      expect(AppBreakpoints.isMobile(600), isFalse);

      // Tablet
      expect(AppBreakpoints.isTablet(600), isTrue);
      expect(AppBreakpoints.isTablet(820), isTrue);
      expect(AppBreakpoints.isTablet(1023), isTrue);
      expect(AppBreakpoints.isTablet(1024), isFalse);

      // Desktop
      expect(AppBreakpoints.isDesktop(1024), isTrue);
      expect(AppBreakpoints.isDesktop(1440), isTrue);
    });
  });

  group('Design Tokens - AppIcons', () {
    test('semantic icons are defined and valid', () {
      expect(AppIcons.home, Icons.home_rounded);
      expect(AppIcons.ledger, Icons.receipt_long_rounded);
      expect(AppIcons.budgets, Icons.pie_chart_rounded);
      expect(AppIcons.analytics, Icons.insights_rounded);
      expect(AppIcons.accounts, Icons.account_balance_wallet_rounded);
    });
  });

  group('Design Tokens - AppTypography', () {
    testWidgets('tabular amounts provide bold legible figures', (tester) async {
      expect(AppTypography.amountLarge.fontWeight, FontWeight.w700);
      expect(AppTypography.amountLarge.fontSize, 32.0);
    });
  });
}
