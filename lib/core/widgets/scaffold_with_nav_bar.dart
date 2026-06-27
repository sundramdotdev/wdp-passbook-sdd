import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/add_transaction/add_expense_sheet.dart';
import '../../features/add_transaction/add_income_sheet.dart';
import '../../features/add_transaction/add_udhar_sheet.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int idx) => _onItemTapped(idx, context),
            items: [
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.account_balance_wallet_outlined, size: 24)),
                activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.account_balance_wallet, size: 24)),
                label: 'Passbook',
              ),
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.storefront_outlined, size: 24)),
                activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.storefront, size: 24)),
                label: 'Merchants',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.handshake_outlined, size: 24)),
                activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.handshake, size: 24)),
                label: 'Udhar',
              ),
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.more_horiz, size: 24)),
                activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.more_horiz, size: 24, color: AppColors.primary)),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.money_off, color: AppColors.expense),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddExpenseSheet(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money, color: AppColors.income),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddIncomeSheet(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: AppColors.udhar),
                title: const Text('Add Udhar Entry'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const AddUdharSheet(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: AppColors.info),
                title: const Text('Scan QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/qr_scanner').then((code) {
                    if (code != null) {
                      // Handle the scanned code
                      print('Scanned code: $code');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/passbook')) return 0;
    if (location.startsWith('/merchants')) return 1;
    if (location.startsWith('/udhar')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/passbook');
        break;
      case 1:
        context.go('/merchants');
        break;
      case 2:
        _showAddOptions(context);
        break;
      case 3:
        context.go('/udhar');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }
}
