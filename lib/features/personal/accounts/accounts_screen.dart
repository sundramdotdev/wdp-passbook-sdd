import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../application/providers/repository_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radii.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/clay_container.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/money.dart';
import '../../../domain/enums/personal_enums.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    AccountType selectedType = AccountType.bank;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    Text('Add Financial Account', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Account Name (e.g. HDFC Bank, PayTM)',
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AccountType>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
                      items: AccountType.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Initial Balance (₹)',
                        border: OutlineInputBorder(borderRadius: AppRadii.controlRadius),
                      ),
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
                          final name = nameController.text.trim();
                          final balVal = double.tryParse(balanceController.text.trim()) ?? 0.0;
                          if (name.isNotEmpty) {
                            final acc = Account(
                              id: const Uuid().v4(),
                              name: name,
                              type: selectedType,
                              balance: Money.fromMajor(balVal),
                              iconName: selectedType == AccountType.cash ? 'coins' : 'landmark',
                              colorHex: '#F97316',
                              createdAt: DateTime.now(),
                            );
                            await ref.read(accountRepositoryProvider).createAccount(acc);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text('Save Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Financial Accounts',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandOrange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddAccountSheet(context, ref),
      ),
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return Center(
                child: Text('No accounts registered.', style: AppTypography.bodyMedium),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final acc = accounts[index];
                IconData iconData = Icons.account_balance;
                if (acc.type == AccountType.cash) iconData = Icons.payments_outlined;
                if (acc.type == AccountType.wallet) iconData = Icons.account_balance_wallet_outlined;

                return ClayContainer(
                  borderRadius: AppRadii.card,
                  padding: AppSpacing.cardPadding,
                  customBackgroundColor: isDark ? AppColors.navyElevated : AppColors.lightSurface,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.orangeSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, color: AppColors.brandOrange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(acc.type.displayName, style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                          ],
                        ),
                      ),
                      Text(
                        acc.balance.format(),
                        style: AppTypography.amountMedium.copyWith(
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error loading accounts: $e'),
        ),
      ),
    );
  }
}

