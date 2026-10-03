import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/commands/goal_commands.dart';
import '../../../application/providers/controller_providers.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/entities/savings_goal.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text('Create Savings Goal', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Goal Title (e.g. Emergency Fund, Laptop)',
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Target Amount (₹)',
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final targetVal = double.tryParse(targetController.text.trim());

                          if (title.isEmpty) {
                            setModalState(() => errorMessage = 'Goal name cannot be empty.');
                            return;
                          }
                          if (targetVal == null || targetVal <= 0) {
                            setModalState(() => errorMessage = 'Target amount must be greater than zero.');
                            return;
                          }

                          final command = CreateGoalCommand(
                            title: title,
                            targetAmount: Money.fromMajor(targetVal),
                          );

                          final success = await ref
                              .read(goalControllerProvider.notifier)
                              .createGoal(command);

                          if (context.mounted && success) {
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            final state = ref.read(goalControllerProvider);
                            state.whenOrNull(
                              error: (msg, _) => setModalState(() => errorMessage = msg),
                            );
                          }
                        },
                        child: const Text('Save Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAddMoneySheet(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    _showMoneyOperationSheet(
      context: context,
      ref: ref,
      goal: goal,
      isDeposit: true,
    );
  }

  void _showRemoveMoneySheet(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    _showMoneyOperationSheet(
      context: context,
      ref: ref,
      goal: goal,
      isDeposit: false,
    );
  }

  void _showMoneyOperationSheet({
    required BuildContext context,
    required WidgetRef ref,
    required SavingsGoal goal,
    required bool isDeposit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController = TextEditingController();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(
                      isDeposit ? 'Deposit to ${goal.title}' : 'Withdraw from ${goal.title}',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current saved: ${goal.savedAmount.format()} | Target: ${goal.targetAmount.format()}',
                      style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: isDeposit ? 'Deposit Amount (₹)' : 'Withdrawal Amount (₹)',
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDeposit ? AppColors.income : AppColors.brandOrange,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                        ),
                        onPressed: () async {
                          final val = double.tryParse(amountController.text.trim());
                          if (val == null || val <= 0) {
                            setModalState(() => errorMessage = 'Please enter a valid positive amount.');
                            return;
                          }

                          final money = Money.fromMajor(val);
                          bool success = false;

                          if (isDeposit) {
                            final cmd = AddGoalMoneyCommand(
                              goalId: goal.id,
                              amount: money,
                              note: 'Deposit',
                            );
                            success = await ref.read(goalControllerProvider.notifier).addMoney(cmd);
                          } else {
                            final cmd = RemoveGoalMoneyCommand(
                              goalId: goal.id,
                              amount: money,
                              note: 'Withdrawal',
                            );
                            success = await ref.read(goalControllerProvider.notifier).removeMoney(cmd);
                          }

                          if (context.mounted && success) {
                            Navigator.pop(context);
                          } else if (context.mounted) {
                            final state = ref.read(goalControllerProvider);
                            state.whenOrNull(
                              error: (msg, _) => setModalState(() => errorMessage = msg),
                            );
                          }
                        },
                        child: Text(
                          isDeposit ? 'Confirm Deposit' : 'Confirm Withdrawal',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Savings Goals',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddGoalSheet(context, ref),
      ),
      body: SafeArea(
        child: goalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.savings_outlined, size: 48, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    const SizedBox(height: 12),
                    Text('No active savings goals.', style: AppTypography.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Goal', style: TextStyle(color: Colors.white)),
                      onPressed: () => _showAddGoalSheet(context, ref),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final g = goals[index];
                final progress = g.progressPercentage; // 0.0 to 1.0 clamped
                final isCompleted = g.isCompleted;

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
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  g.title,
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.income.withValues(alpha: 0.15),
                                      borderRadius: AppRadii.pillRadius,
                                    ),
                                    child: const Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: AppColors.income,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.brandOrange),
                                tooltip: 'Withdraw Money',
                                onPressed: () => _showRemoveMoneySheet(context, ref, g),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.income),
                                tooltip: 'Deposit Money',
                                onPressed: () => _showAddMoneySheet(context, ref, g),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saved: ${g.savedAmount.format()}', style: AppTypography.bodySmall.copyWith(color: AppColors.income, fontWeight: FontWeight.bold)),
                          Text('Target: ${g.targetAmount.format()}', style: AppTypography.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining: ${g.remainingAmount.format()}',
                            style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? AppColors.income : AppColors.brandOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading goals: $e')),
        ),
      ),
    );
  }
}
