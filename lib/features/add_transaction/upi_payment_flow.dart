import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:modern_upi_plugin/modern_upi_plugin.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/clay_container.dart';
import '../../data/providers/repositories_provider.dart';
import '../../data/models/transaction.dart';

class UpiPaymentFlow extends ConsumerStatefulWidget {
  final String upiId;
  final String merchantName;

  const UpiPaymentFlow({
    super.key,
    required this.upiId,
    required this.merchantName,
  });

  @override
  ConsumerState<UpiPaymentFlow> createState() => _UpiPaymentFlowState();
}

class _UpiPaymentFlowState extends ConsumerState<UpiPaymentFlow> {
  int _currentStep = 0;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _processPayment() async {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final remark = _remarkController.text.isNotEmpty ? _remarkController.text : 'Payment';
    
    try {
      final plugin = ModernUpiPlugin();
      final response = await plugin.startTransaction(
        receiverUpiId: widget.upiId,
        receiverName: widget.merchantName,
        transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        transactionNote: remark,
        amount: amount,
      );

      if (response.status == UpiPaymentStatus.SUCCESS) {
        // Save Transaction
        final repo = ref.read(transactionRepositoryProvider);
        if (repo != null) {
          final txn = Transaction()
            ..uuid = const Uuid().v4()
            ..amount = amount
            ..isCredit = false
            ..type = 'expense'
            ..categoryId = 'transfer'
            ..merchantId = widget.merchantName
            ..remark = remark
            ..date = DateTime.now()
            ..incomeSource = ''
            ..isUpiVerified = true
            ..createdAt = DateTime.now();

          await repo.addTransaction(txn);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
          context.go('/passbook');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Not Successful: ${response.status.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching UPI: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  ClayContainer(
                    width: 80,
                    height: 80,
                    borderRadius: 40,
                    child: Center(
                      child: Text(
                        widget.merchantName.isNotEmpty ? widget.merchantName[0].toUpperCase() : '?',
                        style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.merchantName.isNotEmpty ? widget.merchantName : 'Unknown Merchant',
                    style: AppTypography.titleLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.upiId,
                    style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Step Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0 ? _buildAmountStep() : _buildRemarkStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountStep() {
    return Column(
      key: const ValueKey(0),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Enter Amount', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 18)),
        const SizedBox(height: 24),
        ClayContainer(
          borderRadius: 32,
          isPressed: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              hintText: '0',
              hintStyle: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _nextStep,
          child: ClayContainer(
            height: 64,
            borderRadius: 32,
            customBackgroundColor: AppColors.primary,
            child: const Center(
              child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRemarkStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Why this payment?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 18)),
        const SizedBox(height: 24),
        ClayContainer(
          borderRadius: 24,
          isPressed: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            controller: _remarkController,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'e.g. Chai and snacks',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _processPayment,
          child: ClayContainer(
            height: 64,
            borderRadius: 32,
            customBackgroundColor: AppColors.primary,
            child: const Center(
              child: Text('Proceed to Pay', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
