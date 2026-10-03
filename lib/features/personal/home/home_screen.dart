import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../transactions/add_transaction_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final monthlyInsightAsync = ref.watch(monthlyInsightProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'WDP Passbook',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(transactionsStreamProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Balance Card
                ClayContainer(
                  borderRadius: AppRadii.hero,
                  padding: AppSpacing.heroCardPadding,
                  customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Net Balance',
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.orangeSoft,
                              borderRadius: AppRadii.pillRadius,
                            ),
                            child: Text(
                              'Personal',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      totalBalanceAsync.when(
                        data: (balance) => Text(
                          balance.format(),
                          style: AppTypography.amountLarge.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        loading: () => Text('₹ --', style: AppTypography.amountLarge),
                        error: (_, _) => Text('₹ 0.00', style: AppTypography.amountLarge),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                      const SizedBox(height: 12),
                      monthlyInsightAsync.when(
                        data: (insight) => Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.incomeSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_downward, color: AppColors.income, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Income', style: AppTypography.caption),
                                      Text(insight.income.format(), style: AppTypography.amountSmall.copyWith(color: AppColors.income)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.expenseSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_upward, color: AppColors.expense, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Expense', style: AppTypography.caption),
                                      Text(insight.expense.format(), style: AppTypography.amountSmall.copyWith(color: AppColors.expense)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick Navigation Shortcuts
                Row(
                  children: [
                    Expanded(
                      child: _ShortcutButton(
                        icon: Icons.pie_chart_outline,
                        label: 'Analytics',
                        onTap: () => context.push('/analytics'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShortcutButton(
                        icon: Icons.track_changes,
                        label: 'Budgets',
                        onTap: () => context.push('/budget'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShortcutButton(
                        icon: Icons.savings_outlined,
                        label: 'Goals',
                        onTap: () => context.push('/goals'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Recent Ledger Activity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/ledger'),
                      child: Text(
                        'View All',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.brandOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                transactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                              const SizedBox(height: 12),
                              Text('No transactions recorded yet.', style: AppTypography.bodyMedium),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandOrange,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                                ),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => const AddTransactionSheet(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final recent = transactions.take(5).toList();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tx = recent[index];
                        final isExpense = tx.isExpense;

                        return ClayContainer(
                          borderRadius: AppRadii.card,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isExpense ? AppColors.expenseSoft : AppColors.incomeSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isExpense ? AppColors.expense : AppColors.income,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.remark,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                    Text(
                                      '${tx.categoryName} • ${tx.accountName}',
                                      style: AppTypography.caption.copyWith(
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? "-" : "+"}${tx.amount.format()}',
                                style: AppTypography.amountSmall.copyWith(
                                  color: isExpense ? AppColors.expense : AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.controlRadius,
      child: ClayContainer(
        borderRadius: AppRadii.control,
        padding: const EdgeInsets.symmetric(vertical: 16),
        customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
        child: Column(
          children: [
            Icon(icon, color: AppColors.brandOrange, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

