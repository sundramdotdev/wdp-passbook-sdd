import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/clay_container.dart';
import '../../data/models/merchant.dart';
import '../../data/providers/db_provider.dart';
import 'merchants_screen.dart';

class AddMerchantSheet extends ConsumerStatefulWidget {
  const AddMerchantSheet({super.key});

  @override
  ConsumerState<AddMerchantSheet> createState() => _AddMerchantSheetState();
}

class _AddMerchantSheetState extends ConsumerState<AddMerchantSheet> {
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();
  
  Future<void> _saveMerchant() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter merchant name')));
      return;
    }
    
    final isar = await ref.read(isarProvider.future);
    
    final merchant = Merchant()
      ..uuid = const Uuid().v4()
      ..name = name
      ..upiId = _upiController.text.trim().isNotEmpty ? _upiController.text.trim() : null
      ..categoryId = 'general'
      ..totalSpent = 0.0
      ..visitCount = 0
      ..lastVisited = DateTime.now()
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.merchants.put(merchant);
    });

    ref.invalidate(merchantsProvider);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Merchant', style: AppTypography.titleLarge),
          const SizedBox(height: 24),
          ClayContainer(
            borderRadius: 16,
            isPressed: true,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Merchant Name',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClayContainer(
            borderRadius: 16,
            isPressed: true,
            child: TextField(
              controller: _upiController,
              decoration: const InputDecoration(
                hintText: 'UPI ID (Optional)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _saveMerchant,
              child: Text('Save Merchant', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
