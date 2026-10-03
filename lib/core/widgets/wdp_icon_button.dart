import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';

/// Semantic icon button with a guaranteed minimum 44x44 tap target size.
class WdpIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final bool hasBorder;

  const WdpIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 20,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultIconColor = color ?? (isDark ? AppColors.darkText : AppColors.lightText);
    final defaultBg = backgroundColor ?? Colors.transparent;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Material(
            color: defaultBg,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.controlRadius,
              side: hasBorder
                  ? BorderSide(
                      color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
                      width: 1,
                    )
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: AppRadii.controlRadius,
              child: Center(
                child: Icon(
                  icon,
                  size: size,
                  color: onPressed != null
                      ? defaultIconColor
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextTertiary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
