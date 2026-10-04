import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/commands/transaction_commands.dart';
import '../../../application/providers/controller_providers.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../core/widgets/wdp_badge.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/personal_enums.dart';

/// Detailed view for inspecting, editing, or deleting an existing transaction.
class TransactionDetailsScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends ConsumerState<TransactionDetailsScreen> {
  void _confirmDelete(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'This will permanently delete the transaction and adjust the account balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(transactionControllerProvider.notifier)
          .deleteTransaction(tx.id);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully.')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _openEditSheet(Transaction tx) {
    final remarkCtrl = TextEditingController(text: tx.remark);
    String selectedCatId = tx.categoryId;
    DateTime selectedDate = tx.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final categoriesAsync = tx.isExpense
                ? ref.watch(expenseCategoriesStreamProvider)
                : ref.watch(incomeCategoriesStreamProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
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
                    Text('Edit Transaction', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(
                      controller: remarkCtrl,
                      decoration: InputDecoration(
                        labelText: 'Description / Remark',
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (tx.type != TransactionType.transfer)
                      categoriesAsync.when(
                        data: (cats) => DropdownButtonFormField<String>(
                          initialValue: selectedCatId,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                          ),
                          items: cats
                              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() {
                                selectedCatId = val;
                              });
                            }
                          },
                        ),
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),
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
                          final command = UpdateTransactionCommand(
                            id: tx.id,
                            amount: tx.amount,
                            accountId: tx.accountId,
                            targetAccountId: tx.targetAccountId,
                            categoryId: selectedCatId,
                            type: tx.type,
                            remark: remarkCtrl.text.trim(),
                            paymentMethod: tx.paymentMethod,
                            date: selectedDate,
                          );

                          final success = await ref
                              .read(transactionControllerProvider.notifier)
                              .updateTransaction(command);

                          if (!mounted) return;
                          if (success) {
                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction updated.')),
                            );
                          }
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tx = ref.watch(transactionByIdProvider(widget.transactionId));

    if (tx == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              const SizedBox(height: 16),
              Text('Transaction not found', style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandOrange),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Ledger', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final isExpense = tx.isExpense;
    final isIncome = tx.isIncome;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Transaction Details',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Transaction',
            onPressed: () => _openEditSheet(tx),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.expense),
            tooltip: 'Delete Transaction',
            onPressed: () => _confirmDelete(tx),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Amount Card
              ClayContainer(
                borderRadius: AppRadii.hero,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    WdpBadge(
                      text: tx.type.displayName.toUpperCase(),
                      variant: isExpense
                          ? WdpBadgeVariant.expense
                          : (isIncome ? WdpBadgeVariant.income : WdpBadgeVariant.neutral),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${isExpense ? "-" : (isIncome ? "+" : "")}${tx.amount.format()}',
                      style: AppTypography.amountLarge.copyWith(
                        fontSize: 38,
                        color: isExpense
                            ? AppColors.expense
                            : (isIncome ? AppColors.income : (isDark ? AppColors.darkText : AppColors.lightText)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tx.remark.isNotEmpty ? tx.remark : 'No description provided',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Metadata Details Card
              Text('Transaction Information', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),

              ClayContainer(
                borderRadius: AppRadii.card,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: tx.categoryName.isNotEmpty ? tx.categoryName : 'Transfer',
                      isDark: isDark,
                    ),
                    Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: tx.type == TransactionType.transfer ? 'From Account' : 'Account',
                      value: tx.accountName,
                      isDark: isDark,
                    ),
                    if (tx.type == TransactionType.transfer && tx.targetAccountName != null) ...[
                      Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                      _DetailRow(
                        icon: Icons.move_to_inbox_outlined,
                        label: 'To Account',
                        value: tx.targetAccountName!,
                        isDark: isDark,
                      ),
                    ],
                    Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date & Time',
                      value: DateFormat('MMM dd, yyyy • hh:mm a').format(tx.date),
                      isDark: isDark,
                    ),
                    Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                    _DetailRow(
                      icon: Icons.payment_outlined,
                      label: 'Payment Method',
                      value: tx.paymentMethod.displayName,
                      isDark: isDark,
                    ),
                    Divider(color: isDark ? AppColors.navyDivider : AppColors.lightDivider),
                    _DetailRow(
                      icon: Icons.fingerprint,
                      label: 'Record ID',
                      value: tx.id.length > 12 ? '${tx.id.substring(0, 12)}...' : tx.id,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        side: const BorderSide(color: AppColors.expense),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () => _confirmDelete(tx),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      label: const Text('Edit Details', style: TextStyle(color: Colors.white)),
                      onPressed: () => _openEditSheet(tx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.brandOrange),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
