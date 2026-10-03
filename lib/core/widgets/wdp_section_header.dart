import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Standard Section Header with title and optional action button.
class WdpSectionHeader extends StatelessWidget {
  final String title;
  final String? actionTitle;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const WdpSectionHeader({
    super.key,
    required this.title,
    this.actionTitle,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          if (actionTitle != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  actionTitle!,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.brandOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
