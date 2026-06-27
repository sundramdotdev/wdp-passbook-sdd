import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/clay_container.dart';
import '../../data/models/budget.dart';
import '../../data/providers/db_provider.dart';

class AddBudgetSheet extends ConsumerStatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();

  Future<void> _saveBudget() async {
    final name = _nameController.text.trim();
    final limitStr = _limitController.text.trim();
    
    if (name.isEmpty || limitStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and limit')));
      return;
    }
    
    final limit = double.tryParse(limitStr);
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid limit amount')));
      return;
    }

    final isar = await ref.read(isarProvider.future);
    
    final budget = Budget()
      ..uuid = const Uuid().v4()
      ..name = name
      ..limitAmount = limit
      ..period = 'monthly'
      ..startDate = DateTime.now()
      ..isActive = true
      ..alertAt50 = true
      ..alertAt80 = true
      ..alertAt100 = true
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.budgets.put(budget);
    });

    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
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
          Text('Add Monthly Budget', style: AppTypography.titleLarge),
          const SizedBox(height: 24),
          ClayContainer(
            borderRadius: 16,
            isPressed: true,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Budget Name (e.g. Food)',
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
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Limit Amount',
                prefixText: '₹ ',
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
              onPressed: _saveBudget,
              child: Text('Save Budget', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
