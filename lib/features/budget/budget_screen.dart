import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/budget_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/clay_container.dart';
import 'add_budget_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Budget Tracking', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => const AddBudgetSheet(),
              );
            },
          )
        ],
      ),
      body: budgets.isEmpty
          ? Center(
              child: Text(
                'No Budgets Set',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final progress = budgets[index];
                final isExceeded = progress.spent >= progress.budget.limitAmount;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClayContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(progress.budget.name, style: AppTypography.titleMedium),
                            ClayContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              borderRadius: 12,
                              customBackgroundColor: isExceeded ? AppColors.expense.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                              isPressed: true,
                              child: Text(
                                isExceeded ? 'Exceeded' : '${(progress.progressPercent * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: isExceeded ? AppColors.expense : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.progressPercent,
                            backgroundColor: AppColors.surface,
                            color: isExceeded ? AppColors.expense : AppColors.primary,
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${CurrencyFormatter.format(progress.spent)}',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              'Limit: ${CurrencyFormatter.format(progress.budget.limitAmount)}',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
