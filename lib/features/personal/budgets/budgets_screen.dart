import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/commands/budget_commands.dart';
import '../../../application/providers/controller_providers.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/enums/personal_enums.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final limitController = TextEditingController();
    String? selectedCategoryId;
    String? selectedCategoryName;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categoriesAsync = ref.watch(expenseCategoriesStreamProvider);

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Create Monthly Budget', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),

                    // Expense Category Selector
                    categoriesAsync.when(
                      data: (cats) => DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Expense Category',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                        ),
                        items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCategoryId = val;
                              selectedCategoryName = cats.firstWhere((c) => c.id == val).name;
                            });
                          }
                        },
                      ),
                      loading: () => const SizedBox(),
                      error: (e, st) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    // Limit input
                    TextField(
                      controller: limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Monthly Limit (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.brandOrange),
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: AppTypography.caption.copyWith(color: AppColors.semanticError),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                        ),
                        onPressed: () async {
                          final limitVal = double.tryParse(limitController.text.trim());
                          if (selectedCategoryId == null) {
                            setModalState(() => errorMessage = 'Please select an expense category.');
                            return;
                          }
                          if (limitVal == null || limitVal <= 0) {
                            setModalState(() => errorMessage = 'Limit amount must be greater than zero.');
                            return;
                          }

                          final command = CreateBudgetCommand(
                            categoryId: selectedCategoryId!,
                            categoryName: selectedCategoryName ?? 'Category',
                            limitAmount: Money.fromMajor(limitVal),
                            period: BudgetPeriod.monthly,
                          );

                          final success = await ref
                              .read(budgetControllerProvider.notifier)
                              .createBudget(command);

                          if (context.mounted && success) {
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            final state = ref.read(budgetControllerProvider);
                            state.whenOrNull(
                              error: (msg, _) => setModalState(() => errorMessage = msg),
                            );
                          }
                        },
                        child: const Text('Save Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBudget(BuildContext context, WidgetRef ref, CalculatedBudget b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the monthly budget for "${b.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.semanticError),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(budgetControllerProvider.notifier).deleteBudget(b.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetsAsync = ref.watch(calculatedBudgetsStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Monthly Budgets',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddBudgetSheet(context, ref),
      ),
      body: SafeArea(
        child: budgetsAsync.when(
          data: (budgets) {
            if (budgets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    const SizedBox(height: 12),
                    Text('No monthly budgets set.', style: AppTypography.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Create Budget', style: TextStyle(color: Colors.white)),
                      onPressed: () => _showAddBudgetSheet(context, ref),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: budgets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = budgets[index];
                final progress = b.progress; // 0.0 to 1.0 clamped
                final isExceeded = b.isExceeded;
                final isNearLimit = b.isNearLimit;

                Color statusColor = AppColors.income;
                String statusLabel = 'On Track';

                if (isExceeded) {
                  statusColor = AppColors.semanticError;
                  statusLabel = 'Exceeded';
                } else if (isNearLimit) {
                  statusColor = AppColors.semanticWarning;
                  statusLabel = 'Near Limit';
                }

                return ClayContainer(
                  borderRadius: AppRadii.card,
                  padding: AppSpacing.cardPadding,
                  customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                b.categoryName,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: AppRadii.pillRadius,
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.semanticError),
                            tooltip: 'Delete Budget',
                            onPressed: () => _confirmDeleteBudget(context, ref, b),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent: ${b.spentAmount.format()}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isExceeded ? AppColors.semanticError : (isDark ? AppColors.darkText : AppColors.lightText),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Limit: ${b.limitAmount.format()}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isExceeded
                                ? 'Over limit by ${(b.spentAmount - b.limitAmount).format()}'
                                : 'Remaining: ${b.remainingAmount.format()}',
                            style: AppTypography.caption.copyWith(
                              color: isExceeded ? AppColors.semanticError : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                            ),
                          ),
                          Text(
                            '${b.usagePercentage.toInt()}%',
                            style: AppTypography.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: AppRadii.pillRadius,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark ? AppColors.navyBorder : AppColors.lightSurfaceSoft,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading budgets: $e')),
        ),
      ),
    );
  }
}
