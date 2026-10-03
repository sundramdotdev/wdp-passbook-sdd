import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

enum WdpButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
}

enum WdpButtonSize {
  small,
  medium,
  large,
}

/// Accessible, token-based reusable button component for WDP Passbook.
/// Guarantees minimum 44x44 tap target size and proper semantic labeling.
class WdpButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final WdpButtonVariant variant;
  final WdpButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;
  final String? semanticLabel;

  const WdpButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = WdpButtonVariant.primary,
    this.size = WdpButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dimensions & Paddings
    final double height = switch (size) {
      WdpButtonSize.small => 44.0, // Minimum touch target 44px
      WdpButtonSize.medium => 48.0,
      WdpButtonSize.large => 54.0,
    };

    final EdgeInsets padding = switch (size) {
      WdpButtonSize.small => const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      WdpButtonSize.medium => const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      WdpButtonSize.large => const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    };

    final TextStyle textStyle = switch (size) {
      WdpButtonSize.small => AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
      WdpButtonSize.medium => AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
      WdpButtonSize.large => AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
    };

    // Color definitions per variant
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    final isDisabled = onPressed == null || isLoading;

    switch (variant) {
      case WdpButtonVariant.primary:
        backgroundColor = isDisabled
            ? (isDark ? AppColors.navyElevated : AppColors.lightSurfaceSoft)
            : AppColors.brandOrange;
        foregroundColor = isDisabled
            ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextTertiary)
            : Colors.white;
        break;

      case WdpButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.navyElevated : AppColors.lightSurface;
        foregroundColor = isDisabled
            ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextTertiary)
            : (isDark ? AppColors.darkText : AppColors.lightText);
        borderSide = BorderSide(
          color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
          width: 1,
        );
        break;

      case WdpButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled
            ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextTertiary)
            : (isDark ? AppColors.darkText : AppColors.lightText);
        break;

      case WdpButtonVariant.destructive:
        backgroundColor = isDisabled
            ? (isDark ? AppColors.navyElevated : AppColors.lightSurfaceSoft)
            : AppColors.expense;
        foregroundColor = Colors.white;
        break;
    }

    Widget content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: 20),
            child: icon!,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: textStyle.copyWith(color: foregroundColor),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? text,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height,
          minWidth: 44.0,
        ),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.controlRadius,
            side: borderSide,
          ),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: AppRadii.controlRadius,
            splashColor: foregroundColor.withValues(alpha: 0.12),
            highlightColor: foregroundColor.withValues(alpha: 0.08),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
