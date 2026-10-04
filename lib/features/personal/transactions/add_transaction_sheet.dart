import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/controllers/add_transaction_controller.dart';
import '../../../application/providers/reactive_providers.dart';
import '../../../core/calculator/calculator_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/wdp_calculator_keyboard.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/enums/personal_enums.dart';
import '../categories/add_category_sheet.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const AddTransactionSheet({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(initialTabIndex: initialTabIndex),
    );
  }

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final CalculatorController _calcController;

  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedAccountId;
  String? _selectedAccountName;
  String? _selectedTargetAccountId;
  String? _selectedTargetAccountName;
  final PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  final DateTime _selectedDate = DateTime.now();

  bool _showCalculator = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _tabController.addListener(_onTabChanged);
    _calcController = CalculatorController();
    _calcController.addListener(_onCalculatorChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
  }

  void _onCalculatorChanged() {
    final state = _calcController.state;
    if (state.displayValue.isNotEmpty && state.displayValue != _amountController.text) {
      _amountController.text = state.displayValue;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _calcController.removeListener(_onCalculatorChanged);
    _calcController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _openAddCategory(CategoryType type) async {
    final createdCategory = await AddCategorySheet.show(context, initialType: type);
    if (createdCategory != null && mounted) {
      setState(() {
        _selectedCategoryId = createdCategory.id;
        _selectedCategoryName = createdCategory.name;
      });
    }
  }

  void _handleSubmit() async {
    final amountText = _amountController.text.trim();
    // In case user hasn't evaluated their formula, evaluate it first
    _calcController.evaluate();
    final evaluatedText = _calcController.state.displayValue.trim();
    final amountVal = double.tryParse(evaluatedText.isNotEmpty ? evaluatedText : amountText);

    if (amountVal == null || amountVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    final money = Money.fromMajor(amountVal);
    final controller = ref.read(addTransactionControllerProvider.notifier);

    bool success = false;
    final tabIndex = _tabController.index;

    if (tabIndex == 0) {
      // Expense
      if (_selectedCategoryId == null || _selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Category and Account.')),
        );
        return;
      }
      success = await controller.submitExpense(
        amount: money,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName ?? 'Expense',
        accountId: _selectedAccountId!,
        accountName: _selectedAccountName ?? 'Account',
        remark: _remarkController.text,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
      );
    } else if (tabIndex == 1) {
      // Income
      if (_selectedCategoryId == null || _selectedAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Category and Account.')),
        );
        return;
      }
      success = await controller.submitIncome(
        amount: money,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName ?? 'Income',
        accountId: _selectedAccountId!,
        accountName: _selectedAccountName ?? 'Account',
        remark: _remarkController.text,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
      );
    } else {
      // Transfer
      if (_selectedAccountId == null || _selectedTargetAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Source and Target Accounts.')),
        );
        return;
      }
      success = await controller.submitTransfer(
        amount: money,
        sourceAccountId: _selectedAccountId!,
        sourceAccountName: _selectedAccountName ?? 'Source',
        targetAccountId: _selectedTargetAccountId!,
        targetAccountName: _selectedTargetAccountName ?? 'Target',
        remark: _remarkController.text,
        date: _selectedDate,
      );
    }

    if (mounted && success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final submissionState = ref.watch(addTransactionControllerProvider);
    final tabIndex = _tabController.index;

    // Use separate category streams for Expense vs Income
    final AsyncValue<List<Category>> categoriesAsync = tabIndex == 0
        ? ref.watch(expenseCategoriesStreamProvider)
        : (tabIndex == 1
            ? ref.watch(incomeCategoriesStreamProvider)
            : const AsyncValue.data([]));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.hero)),
        ),
        child: SingleChildScrollView(
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
                'Record Transaction',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.navyElevated : AppColors.lightSurfaceSoft,
                  borderRadius: AppRadii.controlRadius,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.brandOrange,
                  labelColor: AppColors.brandOrange,
                  unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  tabs: const [
                    Tab(text: 'Expense'),
                    Tab(text: 'Income'),
                    Tab(text: 'Transfer'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount Input with In-App Calculator Toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      readOnly: _showCalculator,
                      onTap: () {
                        setState(() => _showCalculator = true);
                      },
                      style: AppTypography.amountLarge.copyWith(color: AppColors.brandOrange),
                      decoration: InputDecoration(
                        labelText: 'Amount (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.brandOrange),
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _showCalculator ? Icons.keyboard_hide : Icons.calculate_outlined,
                      color: _showCalculator ? AppColors.brandOrange : AppColors.lightTextMuted,
                    ),
                    tooltip: 'Toggle Financial Calculator',
                    onPressed: () {
                      setState(() => _showCalculator = !_showCalculator);
                    },
                  ),
                ],
              ),

              // Embedded WdpCalculatorKeyboard
              if (_showCalculator) ...[
                const SizedBox(height: 12),
                WdpCalculatorKeyboard(
                  controller: _calcController,
                  onSubmitted: () {
                    setState(() => _showCalculator = false);
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Category Selector (Only for Expense & Income)
              if (tabIndex != 2) ...[
                categoriesAsync.when(
                  data: (categories) {
                    final isExistingSelected =
                        categories.any((c) => c.id == _selectedCategoryId);
                    final currentValue = isExistingSelected ? _selectedCategoryId : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${tabIndex == 0 ? "Expense" : "Income"} Category',
                              style: AppTypography.labelMedium,
                            ),
                            TextButton.icon(
                              onPressed: () => _openAddCategory(
                                tabIndex == 0 ? CategoryType.expense : CategoryType.income,
                              ),
                              icon: const Icon(Icons.add, size: 16, color: AppColors.brandOrange),
                              label: const Text(
                                'New Category',
                                style: TextStyle(color: AppColors.brandOrange, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          value: currentValue,
                          decoration: InputDecoration(
                            labelText: 'Select Category',
                            prefixIcon: const Icon(Icons.label_outline),
                            border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                          ),
                          items: categories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategoryId = val;
                                _selectedCategoryName =
                                    categories.firstWhere((c) => c.id == val).name;
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (e, st) => const SizedBox(),
                ),
                const SizedBox(height: 16),
              ],

              // Source Account Selector
              accountsAsync.when(
                data: (accounts) {
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: tabIndex == 2 ? 'Source Account' : 'From Account',
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                      border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                    ),
                    items: accounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.name} (${a.balance.format()})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedAccountId = val;
                          _selectedAccountName = accounts.firstWhere((a) => a.id == val).name;
                        });
                      }
                    },
                  );
                },
                loading: () => const SizedBox(),
                error: (e, st) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Target Account Selector (Transfer only)
              if (tabIndex == 2) ...[
                accountsAsync.when(
                  data: (accounts) {
                    final targetAccounts =
                        accounts.where((a) => a.id != _selectedAccountId).toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedTargetAccountId,
                      decoration: InputDecoration(
                        labelText: 'Destination Account',
                        prefixIcon: const Icon(Icons.move_to_inbox_outlined),
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                      items: targetAccounts.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.name} (${a.balance.format()})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTargetAccountId = val;
                            _selectedTargetAccountName =
                                targetAccounts.firstWhere((a) => a.id == val).name;
                          });
                        }
                      },
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (e, st) => const SizedBox(),
                ),
                const SizedBox(height: 16),
              ],

              // Remark Input
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: 'Note / Remark (e.g. Chai, Groceries)',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                  ),
                  onPressed: submissionState is TransactionLoadingState ? null : _handleSubmit,
                  child: submissionState is TransactionLoadingState
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Transaction',
                          style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
