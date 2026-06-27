import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/repositories_provider.dart';
import '../../data/models/transaction.dart';

class AddIncomeSheet extends ConsumerStatefulWidget {
  const AddIncomeSheet({super.key});

  @override
  ConsumerState<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<AddIncomeSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String _selectedSource = 'pocket_money';

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final repo = ref.read(transactionRepositoryProvider);
    if (repo != null) {
      final txn = Transaction()
        ..uuid = const Uuid().v4()
        ..amount = amount
        ..isCredit = true
        ..type = 'income'
        ..categoryId = 'income'
        ..merchantId = null
        ..remark = _remarkController.text.isNotEmpty ? _remarkController.text : 'Added Income'
        ..date = DateTime.now()
        ..incomeSource = _selectedSource
        ..isUpiVerified = false
        ..createdAt = DateTime.now();

      await repo.addTransaction(txn);

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppDimensions.screenPadding,
        right: AppDimensions.screenPadding,
        top: AppDimensions.baseSpacing * 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Add Income', style: AppTypography.titleLarge),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.amountLarge.copyWith(color: AppColors.income),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: AppTypography.amountLarge.copyWith(color: AppColors.textSecondary),
              hintText: '0.00',
              hintStyle: AppTypography.amountLarge.copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Source'),
          DropdownButtonFormField<String>(
            value: _selectedSource,
            decoration: const InputDecoration(border: UnderlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'pocket_money', child: Text('Pocket Money')),
              DropdownMenuItem(value: 'scholarship', child: Text('Scholarship')),
              DropdownMenuItem(value: 'salary', child: Text('Salary')),
              DropdownMenuItem(value: 'refund', child: Text('Refund')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedSource = val);
              }
            },
            hint: const Text('Select Source'),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Remark (Optional)'),
          TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              hintText: 'Type in any language...',
              hintStyle: AppTypography.bodySmall,
              border: const UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.income,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Income', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: AppTypography.bodySmall);
  }
}
