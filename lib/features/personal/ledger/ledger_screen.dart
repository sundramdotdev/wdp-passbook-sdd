import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../domain/entities/transaction.dart';
import '../transactions/add_transaction_sheet.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetails(Transaction tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
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
                'Transaction Details',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  tx.amount.format(),
                  style: AppTypography.amountLarge.copyWith(
                    color: tx.isExpense ? AppColors.expense : AppColors.income,
                    fontSize: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _DetailRow(label: 'Remark', value: tx.remark),
              _DetailRow(label: 'Category', value: tx.categoryName),
              _DetailRow(label: 'Account', value: tx.accountName),
              _DetailRow(label: 'Type', value: tx.type.name.toUpperCase()),
              _DetailRow(label: 'Date', value: DateFormat('MMM dd, yyyy • hh:mm a').format(tx.date)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        side: const BorderSide(color: AppColors.expense),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: bottomSheetContext,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Transaction?'),
                            content: const Text('This will permanently delete the transaction and adjust account balances.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.expense))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final repo = ref.read(transactionRepositoryProvider);
                          await repo.deleteTransaction(tx.id);
                          if (bottomSheetContext.mounted) Navigator.pop(bottomSheetContext);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsStreamProvider);

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
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTransactionSheet(),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search remarks, categories, accounts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
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

            // Feed
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  var list = transactions;
                  if (_searchQuery.isNotEmpty) {
                    list = list.where((t) {
                      return t.remark.toLowerCase().contains(_searchQuery) ||
                          t.categoryName.toLowerCase().contains(_searchQuery) ||
                          t.accountName.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 48, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(height: 12),
                          Text('No ledger entries found.', style: AppTypography.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      final isExpense = tx.isExpense;

                      return InkWell(
                        onTap: () => _showTransactionDetails(tx),
                        borderRadius: AppRadii.cardRadius,
                        child: ClayContainer(
                          borderRadius: AppRadii.card,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
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
                                    const SizedBox(height: 2),
                                    Text(
                                      '${tx.categoryName} • ${DateFormat("MMM dd").format(tx.date)}',
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
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error loading ledger: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted)),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
