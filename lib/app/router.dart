import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/wdp_shell.dart';
import '../features/personal/accounts/accounts_screen.dart';
import '../features/personal/analytics/analytics_screen.dart';
import '../features/personal/budgets/budgets_screen.dart';
import '../features/personal/goals/savings_goals_screen.dart';
import '../features/personal/home/home_screen.dart';
import '../features/personal/ledger/ledger_screen.dart';
import '../features/personal/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Central GoRouter provider for WDP Passbook with /personal namespace.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/personal',
    routes: [
      // Legacy redirects
      GoRoute(
        path: '/',
        redirect: (_, __) => '/personal',
      ),
      GoRoute(
        path: '/passbook',
        redirect: (_, __) => '/personal',
      ),
      GoRoute(
        path: '/budget',
        redirect: (_, __) => '/personal/budgets',
      ),

      // Personal Module Shell Route
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return WdpShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/personal',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/personal/ledger',
            builder: (context, state) => const LedgerScreen(),
          ),
          GoRoute(
            path: '/personal/budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/personal/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/personal/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/personal/goals',
            builder: (context, state) => const SavingsGoalsScreen(),
          ),
        ],
      ),

      // Standalone Full-Screen Routes
      GoRoute(
        path: '/personal/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings',
        redirect: (_, __) => '/personal/settings',
      ),
    ],
  );
});
