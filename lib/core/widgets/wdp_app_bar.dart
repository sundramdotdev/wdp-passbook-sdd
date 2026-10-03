import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_typography.dart';
import 'wdp_icon_button.dart';

/// Reusable top app bar matching Stitch design.
class WdpAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const WdpAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = WdpIconButton(
        icon: AppIcons.chevronLeft,
        tooltip: 'Back',
        onPressed: onBackPressed ?? () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      title: Text(
        title,
        style: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      leading: leadingWidget,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
