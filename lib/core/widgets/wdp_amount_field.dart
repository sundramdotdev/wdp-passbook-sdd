import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Specialized amount entry field with large tabular typography matching Stitch design.
class WdpAmountField extends StatelessWidget {
  final TextEditingController? controller;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool autofocus;

  const WdpAmountField({
    super.key,
    this.controller,
    this.currencySymbol = '₹',
    this.onChanged,
    this.errorText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              currencySymbol,
              style: AppTypography.displayMedium.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 260),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  autofocus: autofocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textAlign: TextAlign.start,
                  style: AppTypography.amountLarge.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.amountLarge.copyWith(
                      color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.expense),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
