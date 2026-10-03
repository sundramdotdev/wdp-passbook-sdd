import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/personal/accounts/accounts_screen.dart';
import '../../features/personal/analytics/analytics_screen.dart';
import '../../features/personal/budgets/budgets_screen.dart';
import '../../features/personal/goals/savings_goals_screen.dart';
import '../../features/personal/home/home_screen.dart';
import '../../features/personal/ledger/ledger_screen.dart';
import '../../features/personal/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/passbook',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/passbook',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/ledger',
            builder: (context, state) => const LedgerScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const SavingsGoalsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
