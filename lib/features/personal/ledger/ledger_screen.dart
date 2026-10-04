
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/personal_enums.dart';
import '../transactions/add_transaction_sheet.dart';

/// Passbook Ledger displaying chronologically grouped, filterable, and searchable transactions.
class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    final current = ref.read(transactionFilterProvider);
    ref.read(transactionFilterProvider.notifier).state = current.copyWith(
      searchQuery: val.trim(),
    );
  }

  void _onTypeFilterChanged(TransactionType? type) {
    final current = ref.read(transactionFilterProvider);
    ref.read(transactionFilterProvider.notifier).state = current.copyWith(
      type: type,
    );
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate.isAtSameMomentAs(today)) return 'Today';
    if (txDate.isAtSameMomentAs(yesterday)) return 'Yesterday';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in transactions) {
      final header = _formatDateGroup(tx.date);
      grouped.putIfAbsent(header, () => []).add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAsync = ref.watch(filteredTransactionsProvider);
    final activeFilter = ref.watch(transactionFilterProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Digital Passbook Ledger',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandOrange,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionSheet(),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search remarks, categories, accounts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.controlRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: activeFilter.type == null,
                    onTap: () => _onTypeFilterChanged(null),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expenses',
                    isSelected: activeFilter.type == TransactionType.expense,
                    onTap: () => _onTypeFilterChanged(TransactionType.expense),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    isSelected: activeFilter.type == TransactionType.income,
                    onTap: () => _onTypeFilterChanged(TransactionType.income),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Transfers',
                    isSelected: activeFilter.type == TransactionType.transfer,
                    onTap: () => _onTypeFilterChanged(TransactionType.transfer),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Transactions Feed
            Expanded(
              child: filteredAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 56,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              activeFilter.isActive
                                  ? 'No matching transactions'
                                  : 'No transactions yet',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activeFilter.isActive
                                  ? 'Try adjusting your search query or filter chips.'
                                  : 'Tap below to record your first income or expense.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (!activeFilter.isActive)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandOrange,
                                  shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const AddTransactionSheet(initialTabIndex: 0),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  final grouped = _groupTransactions(transactions);
                  final groupKeys = grouped.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.xs,
                      bottom: 80,
                    ),
                    itemCount: groupKeys.length,
                    itemBuilder: (context, groupIndex) {
                      final groupHeader = groupKeys[groupIndex];
                      final groupItems = grouped[groupHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
                            child: Text(
                              groupHeader,
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, itemIndex) {
                              final tx = groupItems[itemIndex];
                              return _TransactionListTile(
                                tx: tx,
                                isDark: isDark,
                                onTap: () => context.push('/transactions/${tx.id}'),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error loading ledger: $e', style: AppTypography.bodyMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.controlRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandOrange
              : (isDark ? AppColors.navyElevated : AppColors.lightSurface),
          borderRadius: AppRadii.controlRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.brandOrange
                : (isDark ? AppColors.navyBorder : AppColors.lightBorder),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkText : AppColors.lightText),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TransactionListTile extends StatelessWidget {
  final Transaction tx;
  final bool isDark;
  final VoidCallback onTap;

  const _TransactionListTile({
    required this.tx,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.isExpense;
    final isIncome = tx.isIncome;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.controlRadius,
      child: ClayContainer(
        borderRadius: AppRadii.card,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseSoft
                    : (isIncome ? AppColors.incomeSoft : AppColors.orangeSoft),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense
                    ? Icons.arrow_upward
                    : (isIncome ? Icons.arrow_downward : Icons.swap_horiz),
                color: isExpense
                    ? AppColors.expense
                    : (isIncome ? AppColors.income : AppColors.brandOrange),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.remark.isNotEmpty ? tx.remark : (tx.isTransfer ? 'Transfer' : tx.categoryName),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${tx.categoryName} • ${tx.accountName}',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? "-" : (isIncome ? "+" : "")}${tx.amount.format()}',
              style: AppTypography.amountSmall.copyWith(
                color: isExpense
                    ? AppColors.expense
                    : (isIncome ? AppColors.income : (isDark ? AppColors.darkText : AppColors.lightText)),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
