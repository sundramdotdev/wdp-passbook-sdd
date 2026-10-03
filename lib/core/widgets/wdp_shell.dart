import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Navigation item model for WdpShell
class WdpNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const WdpNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

/// Responsive App Shell supporting Mobile, Tablet, and Desktop layouts.
class WdpShell extends StatelessWidget {
  final Widget child;

  const WdpShell({
    super.key,
    required this.child,
  });

  static const List<WdpNavItem> navItems = [
    WdpNavItem(
      label: 'Home',
      icon: AppIcons.homeOutlined,
      selectedIcon: AppIcons.home,
      path: '/personal',
    ),
    WdpNavItem(
      label: 'Ledger',
      icon: AppIcons.ledgerOutlined,
      selectedIcon: AppIcons.ledger,
      path: '/personal/ledger',
    ),
    WdpNavItem(
      label: 'Budgets',
      icon: AppIcons.budgetsOutlined,
      selectedIcon: AppIcons.budgets,
      path: '/personal/budgets',
    ),
    WdpNavItem(
      label: 'Analytics',
      icon: AppIcons.analyticsOutlined,
      selectedIcon: AppIcons.analytics,
      path: '/personal/analytics',
    ),
    WdpNavItem(
      label: 'Accounts',
      icon: AppIcons.accountsOutlined,
      selectedIcon: AppIcons.accounts,
      path: '/personal/accounts',
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/personal') return 0;
    if (location.startsWith('/personal/ledger')) return 1;
    if (location.startsWith('/personal/budgets')) return 2;
    if (location.startsWith('/personal/analytics')) return 3;
    if (location.startsWith('/personal/accounts')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index >= 0 && index < navItems.length) {
      context.go(navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (AppBreakpoints.isDesktop(width)) {
      // Desktop Layout: Expanded Sidebar + Content
      return Scaffold(
        body: Row(
          children: [
            _buildDesktopSidebar(context, selectedIndex, isDark),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else if (AppBreakpoints.isTablet(width)) {
      // Tablet Layout: Navigation Rail + Content
      return Scaffold(
        body: Row(
          children: [
            _buildTabletRail(context, selectedIndex, isDark),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      // Mobile Layout: Content + Bottom Navigation Bar
      return Scaffold(
        body: child,
        bottomNavigationBar: _buildMobileBottomBar(context, selectedIndex, isDark),
      );
    }
  }

  Widget _buildMobileBottomBar(BuildContext context, int selectedIndex, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.navyBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = index == selectedIndex;
              final color = isSelected
                  ? AppColors.brandOrange
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => _onItemTapped(index, context),
                    borderRadius: AppRadii.controlRadius,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletRail(BuildContext context, int selectedIndex, bool isDark) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (idx) => _onItemTapped(idx, context),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
      selectedIconTheme: const IconThemeData(color: AppColors.brandOrange),
      unselectedIconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
      selectedLabelTextStyle: AppTypography.caption.copyWith(
        color: AppColors.brandOrange,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: AppTypography.caption.copyWith(
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        fontWeight: FontWeight.w500,
      ),
      labelType: NavigationRailLabelType.all,
      destinations: navItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, int selectedIndex, bool isDark) {
    return Container(
      width: 240,
      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange,
                    borderRadius: AppRadii.compactRadius,
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'WDP Passbook',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = index == selectedIndex;
                final color = isSelected
                    ? AppColors.brandOrange
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
                  tileColor: isSelected
                      ? (isDark ? AppColors.navyElevated : AppColors.orangeSoft)
                      : Colors.transparent,
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: color,
                  ),
                  title: Text(
                    item.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: color,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  onTap: () => _onItemTapped(index, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
