import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/presentation/account_details_screen.dart';
import '../../features/transfer/presentation/add_beneficiary_screen.dart';
import '../../features/payments/presentation/bill_payment_screen.dart';
import '../../features/dashboard/design_system_screen.dart';
import '../../features/transfer/presentation/transfer_screen.dart';
import '../../features/qr/presentation/qr_scanner_screen.dart';
import '../../features/qr/presentation/my_qr_screen.dart';
import '../../features/qr/presentation/request_money_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/wallet/presentation/top_up_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/budget/presentation/budget_list_screen.dart';
import '../../features/budget/presentation/create_budget_screen.dart';
import '../../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/models/account.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/welcome',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      // Don't redirect while loading or if there's an error (let the UI handle errors)
      if (authState.isLoading) return null;

      final user = authState.value;
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' || 
                          state.matchedLocation == '/welcome';

      if (user == null) {
        // Not logged in -> only allow auth routes
        return isAuthRoute ? null : '/welcome';
      }

      // Logged in -> don't allow auth routes
      if (isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            key: const ValueKey('shell_scaffold'),
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(state.fullPath ?? '/'),
              onTap: (index) => _onItemTapped(index, context),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'design-system',
                builder: (context, state) => const DesignSystemScreen(),
              ),
              GoRoute(
                path: 'transfer',
                builder: (context, state) => const TransferScreen(),
                routes: [
                  GoRoute(
                    path: 'add-beneficiary',
                    builder: (context, state) => const AddBeneficiaryScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'qr-scanner',
                builder: (context, state) => const QrScannerScreen(),
              ),
              GoRoute(
                path: 'my-qr',
                builder: (context, state) => const MyQrScreen(),
              ),
              GoRoute(
                path: 'request-money',
                builder: (context, state) => const RequestMoneyScreen(),
              ),
              GoRoute(
                path: 'ai-assistant',
                builder: (context, state) => const AiAssistantScreen(),
              ),
              GoRoute(
                path: 'account-details',
                builder: (context, state) {
                  final account = state.extra as Account;
                  return AccountDetailsScreen(account: account);
                },
              ),
              GoRoute(
                path: 'pay-bills',
                builder: (context, state) => const BillPaymentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
            routes: [
              GoRoute(
                path: 'top-up',
                builder: (context, state) => const TopUpScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateBudgetScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // Add other shell routes here
        ],
      ),
    ],
  );
}

int _calculateSelectedIndex(String location) {
  if (location == '/') return 0;
  if (location.startsWith('/wallet')) return 1;
  if (location.startsWith('/analytics')) return 2;
  if (location.startsWith('/profile')) return 3;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/wallet');
      break;
    case 2:
      context.go('/analytics');
      break;
    case 3:
      context.go('/profile');
      break;
  }
}
