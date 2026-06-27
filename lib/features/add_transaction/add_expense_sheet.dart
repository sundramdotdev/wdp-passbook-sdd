import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:modern_upi_plugin/modern_upi_plugin.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/ai_assistant/groq_consent_dialog.dart';
import '../../data/providers/groq_provider.dart';
import '../../data/providers/repositories_provider.dart';
import '../../data/models/transaction.dart';
import '../merchants/add_merchant_sheet.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleAIPress() async {
    final apiKey = ref.read(groqApiKeyProvider);
    if (apiKey == null || apiKey.isEmpty) {
      final consented = await showDialog<bool>(
        context: context,
        builder: (_) => const GroqConsentDialog(),
      );
      if (consented != true) return;
    }

    // Now ask for input
    final aiInputController = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('🤖 AI Assistant'),
          content: TextField(
            controller: aiInputController,
            decoration: const InputDecoration(
              hintText: 'e.g. "chai aur momos 80 mein"',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, aiInputController.text),
              child: const Text('Parse'),
            ),
          ],
        );
      },
    );

    if (input != null && input.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final groqService = ref.read(groqServiceProvider);
        if (groqService != null) {
          final result = await groqService.parseTransaction(input);
          if (result != null) {
            setState(() {
              _amountController.text = result['amount'].toString();
              _remarkController.text = result['remark'] ?? '';
              // Additional fields can be mapped here later
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveTransaction(bool viaUpi, String upiUrl) async {
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

    if (viaUpi) {
      try {
        final uri = Uri.parse(upiUrl);
        final upiId = uri.queryParameters['pa'] ?? '';
        final merchantName = uri.queryParameters['pn'] ?? 'Unknown Merchant';
        
        final plugin = ModernUpiPlugin();
        final response = await plugin.startTransaction(
          receiverUpiId: upiId.isNotEmpty ? upiId : 'test@upi',
          receiverName: merchantName,
          transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          transactionNote: _remarkController.text,
          amount: amount,
        );

        if (response.status != UpiPaymentStatus.SUCCESS) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Not Successful: ${response.status.name}')),
            );
          }
          return; // Do not save on failure
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('UPI Error: $e')));
        return;
      }
    }

    final repo = ref.read(transactionRepositoryProvider);
    if (repo != null) {
      final txn = Transaction()
        ..uuid = const Uuid().v4()
        ..amount = amount
        ..isCredit = false
        ..type = 'expense'
        ..categoryId = 'food'
        ..merchantId = null
        ..remark = _remarkController.text.isNotEmpty ? _remarkController.text : 'Cash Expense'
        ..date = DateTime.now()
        ..incomeSource = ''
        ..isUpiVerified = viaUpi
        ..createdAt = DateTime.now();

      await repo.addTransaction(txn);

      if (mounted) context.pop();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Expense', style: AppTypography.titleLarge),
              if (_isLoading) const CircularProgressIndicator(strokeWidth: 2)
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.amountLarge,
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
          // AI Try Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleAIPress,
            icon: const Text('🤖'),
            label: const Text('Parse via AI (Try: "chai 20")'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.info,
              side: const BorderSide(color: AppColors.info),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Merchant'),
          ListTile(
            title: const Text('Select Merchant ▾'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                      builder: (_) => const AddMerchantSheet(),
                    );
                  }, 
                  child: const Text('+ New'),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final code = await context.push('/qr_scanner');
                    if (code != null && code is String && context.mounted) {
                      setState(() {
                        _remarkController.text = 'QR Code: $code';
                      });
                    }
                  },
                ),
              ],
            ),
            contentPadding: EdgeInsets.zero,
          ),
          _buildFieldLabel('Remark'),
          TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              hintText: 'Type in any language...',
              hintStyle: AppTypography.bodySmall,
              border: const UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFieldLabel('Category'),
              const Spacer(),
              Chip(label: const Text('🍔 Food'), backgroundColor: AppColors.surface, side: const BorderSide(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _saveTransaction(false, ''),
                  child: const Text('💵 Save as Cash'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    String upiUrl = '';
                    if (_remarkController.text.startsWith('upi://')) {
                      final amount = _amountController.text;
                      upiUrl = _remarkController.text;
                      if (amount.isNotEmpty && !upiUrl.contains('&am=')) {
                        upiUrl += '&am=$amount';
                      }
                    } else {
                      final amount = _amountController.text.isEmpty ? '1' : _amountController.text;
                      upiUrl = 'upi://pay?pa=test@upi&pn=Test&am=$amount&cu=INR';
                    }
                    _saveTransaction(true, upiUrl);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('💸 Pay via UPI', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
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
