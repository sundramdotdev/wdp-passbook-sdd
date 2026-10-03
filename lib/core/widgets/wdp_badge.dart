import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

enum WdpBadgeVariant {
  income,
  expense,
  warning,
  info,
  neutral,
  brand,
}

/// Token-based status badge / pill component.
class WdpBadge extends StatelessWidget {
  final String text;
  final WdpBadgeVariant variant;
  final Widget? icon;

  const WdpBadge({
    super.key,
    required this.text,
    this.variant = WdpBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bgColor, Color textColor) = switch (variant) {
      WdpBadgeVariant.income => (
          isDark ? const Color(0x2616A34A) : AppColors.incomeSoft,
          AppColors.income,
        ),
      WdpBadgeVariant.expense => (
          isDark ? const Color(0x26EF4444) : AppColors.expenseSoft,
          AppColors.expense,
        ),
      WdpBadgeVariant.warning => (
          isDark ? const Color(0x26F59E0B) : AppColors.warningSoft,
          AppColors.warning,
        ),
      WdpBadgeVariant.info => (
          isDark ? const Color(0x263B82F6) : AppColors.infoSoft,
          AppColors.info,
        ),
      WdpBadgeVariant.brand => (
          isDark ? const Color(0x26F97316) : AppColors.orangeSoft,
          AppColors.brandOrange,
        ),
      WdpBadgeVariant.neutral => (
          isDark ? AppColors.navyElevated : AppColors.lightSurfaceSoft,
          isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: 12),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
