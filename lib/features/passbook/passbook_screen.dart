import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/passbook_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/clay_container.dart';
import 'package:intl/intl.dart';

class PassbookScreen extends ConsumerWidget {
  const PassbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(incomeProvider);
    final spent = ref.watch(spentProvider);
    final txnsAsync = ref.watch(filteredTransactionsProvider);
    final dateFilter = ref.watch(passbookDateFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Passbook', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => context.go('/budget'),
          ),
          TextButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateFilter ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                ref.read(passbookDateFilterProvider.notifier).state = date;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filtered to ${DateFormat('MMMM yyyy').format(date)}')));
                }
              }
            },
            icon: Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurface),
            label: Text(
              dateFilter != null ? DateFormat('MMMM yyyy').format(dateFilter) : DateFormat('MMMM yyyy').format(DateTime.now()), 
              style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface)
            ),
          ),
          if (dateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () => ref.read(passbookDateFilterProvider.notifier).state = null,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: AppDimensions.baseSpacing),
              child: _buildBalanceCard(context, balance, income, spent),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: AppDimensions.baseSpacing),
              child: _buildFilterChips(context, ref),
            ),
          ),
          txnsAsync.when(
            data: (txns) {
              if (txns.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No transactions yet')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final txn = txns[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding, vertical: 8),
                      child: ClayContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClayContainer(
                              width: 48,
                              height: 48,
                              borderRadius: 16,
                              child: Center(
                                child: Icon(
                                  txn.isCredit ? Icons.arrow_downward_rounded : Icons.shopping_bag_outlined,
                                  color: txn.isCredit ? AppColors.income : AppColors.expense,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(txn.merchantId ?? 'Category', style: AppTypography.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(txn.remark, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${txn.isCredit ? '+' : '-'} ${CurrencyFormatter.format(txn.amount)}',
                                  style: AppTypography.amountMedium.copyWith(color: txn.isCredit ? AppColors.income : AppColors.expense),
                                ),
                                const SizedBox(height: 4),
                                Text(DateFormat('h:mm a').format(txn.date), style: AppTypography.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: txns.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, double income, double spent) {
    return ClayContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(CurrencyFormatter.format(balance), style: AppTypography.amountLarge.copyWith(fontSize: 36)),
          const SizedBox(height: 4),
          Text('Current Balance', style: AppTypography.bodySmall),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('↑ ${CurrencyFormatter.format(income)}', 'Income', AppColors.income),
              _buildStatItem('↓ ${CurrencyFormatter.format(spent)}', 'Spent', AppColors.expense),
              _buildStatItem('⏳ 0', 'Pending Confirm', AppColors.udhar),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.amountSmall.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final filters = ['All', 'Income', 'Expense', 'Udhar', 'UPI', 'SMS', 'Pending'];
    final currentFilter = ref.watch(passbookTypeFilterProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => ref.read(passbookTypeFilterProvider.notifier).state = f,
              child: ClayContainer(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                isPressed: !isSelected,
                child: Text(
                  f,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
