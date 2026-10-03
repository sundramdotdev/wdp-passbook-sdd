import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_elevation.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';

enum WdpCardVariant {
  elevated,
  surface,
  outlined,
}

/// Token-based reusable Card component for WDP Passbook.
class WdpCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final WdpCardVariant variant;
  final Color? color;
  final BorderRadius? borderRadius;

  const WdpCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.variant = WdpCardVariant.elevated,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadii.cardRadius;

    Color cardColor = color ??
        (isDark ? AppColors.darkCard : AppColors.lightSurface);

    List<BoxShadow> shadows = switch (variant) {
      WdpCardVariant.elevated => isDark ? AppElevation.darkCard : AppElevation.card,
      WdpCardVariant.surface => isDark ? AppElevation.none : AppElevation.subtle,
      WdpCardVariant.outlined => AppElevation.none,
    };

    Border? border;
    if (variant == WdpCardVariant.outlined || !isDark) {
      border = Border.all(
        color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
        width: 1,
      );
    }

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: shadows,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              )
            : content,
      ),
    );
  }
}
