import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ClayContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;
  final Color? customBackgroundColor;

  const ClayContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.isPressed = false,
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final bg = customBackgroundColor ?? defaultBg;

    // Claymorphism soft gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.5),
        isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02),
      ],
    );

    final List<BoxShadow>? shadows = isPressed 
      ? [
          BoxShadow(
            color: isDark ? AppColors.darkShadowOuter.withOpacity(0.4) : AppColors.lightShadowOuter,
            blurRadius: 4,
            offset: const Offset(2, 2), 
          )
        ] 
      : [
          // Strong outer shadow
          BoxShadow(
            color: isDark ? AppColors.darkShadowOuter : AppColors.lightShadowOuter,
            blurRadius: 24,
            offset: const Offset(12, 12),
          ),
          // Soft top highlight shadow
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
            blurRadius: 20,
            offset: const Offset(-8, -8),
          ),
        ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}
