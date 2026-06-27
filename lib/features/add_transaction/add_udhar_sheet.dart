import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/repositories_provider.dart';
import '../../data/models/transaction.dart';
import '../../data/models/udhar_entry.dart';

class AddUdharSheet extends ConsumerStatefulWidget {
  const AddUdharSheet({super.key});

  @override
  ConsumerState<AddUdharSheet> createState() => _AddUdharSheetState();
}

class _AddUdharSheetState extends ConsumerState<AddUdharSheet> {
  bool _isIGave = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _personController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveUdhar() async {
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

    final personName = _personController.text.trim();
    if (personName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a person name')));
      return;
    }

    final txnRepo = ref.read(transactionRepositoryProvider);
    final udharRepo = ref.read(udharRepositoryProvider);
    
    if (txnRepo != null && udharRepo != null) {
      final txnType = _isIGave ? 'udhar_given' : 'udhar_received';
      
      final txn = Transaction()
        ..uuid = const Uuid().v4()
        ..amount = amount
        ..isCredit = !_isIGave
        ..type = txnType
        ..categoryId = 'udhar'
        ..merchantId = personName
        ..remark = _reasonController.text.isNotEmpty ? _reasonController.text : 'Udhar to $personName'
        ..date = DateTime.now()
        ..incomeSource = ''
        ..isUpiVerified = false
        ..createdAt = DateTime.now();

      final udhar = UdharEntry()
        ..uuid = const Uuid().v4()
        ..personName = personName
        ..amount = amount
        ..iGave = _isIGave
        ..reason = txn.remark
        ..date = DateTime.now()
        ..isSettled = false
        ..createdAt = DateTime.now();

      await txnRepo.addTransaction(txn);
      await udharRepo.addUdhar(udhar);

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
          Text('Add Udhar', style: AppTypography.titleLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('I Gave'),
                  value: true,
                  groupValue: _isIGave,
                  onChanged: (val) => setState(() => _isIGave = val!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('They Gave Me'),
                  value: false,
                  groupValue: _isIGave,
                  onChanged: (val) => setState(() => _isIGave = val!),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.amountLarge.copyWith(color: AppColors.udhar),
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
          _buildFieldLabel('Person Name'),
          TextField(
            controller: _personController,
            decoration: InputDecoration(
              hintText: 'Who?',
              hintStyle: AppTypography.bodySmall,
              border: const UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Reason'),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Why?',
              hintStyle: AppTypography.bodySmall,
              border: const UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveUdhar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.udhar,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Udhar', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
