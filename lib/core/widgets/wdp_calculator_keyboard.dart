import 'package:flutter/material.dart';
import '../calculator/calculator_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// In-app financial calculator keyboard widget styled with WDP design tokens.
/// Does not depend on OS numeric keyboards.
/// Operates entirely via [CalculatorController] (no internal arithmetic).
class WdpCalculatorKeyboard extends StatelessWidget {
  final CalculatorController controller;
  final VoidCallback? onSubmitted;

  const WdpCalculatorKeyboard({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final state = controller.state;

            return Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: AppRadii.cardRadius,
                border: Border.all(
                  color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calculation Expression & Error Banner
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        state.error!.message,
                        style: AppTypography.caption.copyWith(color: AppColors.semanticError),
                      ),
                    ),

                  // Button Matrix: 5 rows
                  // Row 1: Clear, Backspace, ÷, ×
                  _buildRow([
                    _CalcKey(
                      label: 'C',
                      isAction: true,
                      onTap: controller.clear,
                    ),
                    _CalcKey(
                      icon: Icons.backspace_outlined,
                      isAction: true,
                      onTap: controller.backspace,
                    ),
                    _CalcKey(
                      label: '÷',
                      isOperator: true,
                      onTap: () => controller.inputOperator('÷'),
                    ),
                    _CalcKey(
                      label: '×',
                      isOperator: true,
                      onTap: () => controller.inputOperator('×'),
                    ),
                  ], isDark),
                  const SizedBox(height: 8),

                  // Row 2: 7, 8, 9, -
                  _buildRow([
                    _CalcKey(label: '7', onTap: () => controller.inputDigit('7')),
                    _CalcKey(label: '8', onTap: () => controller.inputDigit('8')),
                    _CalcKey(label: '9', onTap: () => controller.inputDigit('9')),
                    _CalcKey(
                      label: '-',
                      isOperator: true,
                      onTap: () => controller.inputOperator('-'),
                    ),
                  ], isDark),
                  const SizedBox(height: 8),

                  // Row 3: 4, 5, 6, +
                  _buildRow([
                    _CalcKey(label: '4', onTap: () => controller.inputDigit('4')),
                    _CalcKey(label: '5', onTap: () => controller.inputDigit('5')),
                    _CalcKey(label: '6', onTap: () => controller.inputDigit('6')),
                    _CalcKey(
                      label: '+',
                      isOperator: true,
                      onTap: () => controller.inputOperator('+'),
                    ),
                  ], isDark),
                  const SizedBox(height: 8),

                  // Row 4: 1, 2, 3, =
                  _buildRow([
                    _CalcKey(label: '1', onTap: () => controller.inputDigit('1')),
                    _CalcKey(label: '2', onTap: () => controller.inputDigit('2')),
                    _CalcKey(label: '3', onTap: () => controller.inputDigit('3')),
                    _CalcKey(
                      label: '=',
                      isEqual: true,
                      onTap: () {
                        controller.evaluate();
                        if (onSubmitted != null) onSubmitted!();
                      },
                    ),
                  ], isDark),
                  const SizedBox(height: 8),

                  // Row 5: 0 (span 2), .
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildKeyWidget(
                          _CalcKey(label: '0', onTap: () => controller.inputDigit('0')),
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildKeyWidget(
                          _CalcKey(label: '.', onTap: controller.inputDecimal),
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildKeyWidget(
                          _CalcKey(
                            label: 'Done',
                            isDone: true,
                            onTap: () {
                              controller.evaluate();
                              if (onSubmitted != null) onSubmitted!();
                            },
                          ),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(List<_CalcKey> keys, bool isDark) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyWidget(key, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyWidget(_CalcKey key, bool isDark) {
    Color bg;
    Color fg;

    if (key.isEqual) {
      bg = AppColors.brandOrange;
      fg = Colors.white;
    } else if (key.isDone) {
      bg = AppColors.brandGreen;
      fg = Colors.white;
    } else if (key.isOperator) {
      bg = isDark ? AppColors.navyElevated : AppColors.brandOrangeSurface;
      fg = AppColors.brandOrange;
    } else if (key.isAction) {
      bg = isDark ? AppColors.navySurface : AppColors.lightSurfaceSoft;
      fg = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    } else {
      bg = isDark ? AppColors.navySurface : AppColors.lightBg;
      fg = isDark ? AppColors.darkText : AppColors.lightText;
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        borderRadius: AppRadii.controlRadius,
        child: InkWell(
          borderRadius: AppRadii.controlRadius,
          onTap: key.onTap,
          child: Center(
            child: key.icon != null
                ? Icon(key.icon, size: 20, color: fg)
                : Text(
                    key.label ?? '',
                    style: AppTypography.titleMedium.copyWith(
                      color: fg,
                      fontWeight: (key.isEqual || key.isOperator || key.isDone)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CalcKey {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isAction;
  final bool isEqual;
  final bool isDone;

  const _CalcKey({
    this.label,
    this.icon,
    required this.onTap,
    this.isOperator = false,
    this.isAction = false,
    this.isEqual = false,
    this.isDone = false,
  });
}
