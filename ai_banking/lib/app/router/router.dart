import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/loading_screen.dart';
import '../../features/auth/presentation/setup_pin_screen.dart';
import '../../features/auth/presentation/pin_lock_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/presentation/account_details_screen.dart';
import '../../features/transfer/presentation/add_beneficiary_screen.dart';
import '../../features/payments/presentation/bill_payment_screen.dart';
import '../../features/dashboard/design_system_screen.dart';
import '../../features/transfer/presentation/transfer_screen.dart';
import '../../features/qr/presentation/qr_hub_screen.dart';
import '../../features/qr/presentation/qr_scanner_screen.dart';
import '../../features/qr/presentation/my_qr_screen.dart';
import '../../features/qr/presentation/request_money_screen.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/wallet/presentation/top_up_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/budget/presentation/budget_list_screen.dart';
import '../../features/budget/presentation/create_budget_screen.dart';
import '../../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../features/kyc/presentation/screens/kyc_main_flow.dart';
import '../../features/savings/presentation/screens/savings_screen.dart';
import '../../features/savings/presentation/screens/savings_create_screen.dart';
import '../../features/card_management/presentation/add_card_screen.dart';
import '../../features/card_management/presentation/card_details_screen.dart';
import '../../features/transactions/presentation/transaction_history_screen.dart';
import '../../features/transactions/presentation/transaction_details_screen.dart';
import '../../features/dashboard/models/transaction.dart';
import '../../shared/models/account.dart';

import '../../shared/providers/session_lock_provider.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final isSessionLocked = ref.watch(sessionLockControllerProvider);
  final profileAsync = ref.watch(profileControllerProvider);

  return GoRouter(
    initialLocation: '/welcome',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      // Don't redirect while loading or if there's an error (let the UI handle errors)
      if (authState.isLoading) return null;

      final user = authState.value;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/welcome';

      final isLoadingRoute = state.matchedLocation == '/loading';
      final isPinRoute = state.matchedLocation == '/setup-pin' ||
          state.matchedLocation == '/pin-lock';

      if (user == null) {
        // Not logged in → only allow auth routes; redirect everything else to welcome
        return isAuthRoute ? null : '/welcome';
      }

      // Logged in & session locked → enforce PIN lock screen for accounts with a PIN
      if (isSessionLocked && !isPinRoute) {
        final profile = profileAsync.value;
        final hasPin = profile != null &&
            profile.pinHash != null &&
            profile.pinHash!.isNotEmpty;
        if (hasPin) {
          return '/pin-lock';
        }
      }

      // Logged in → don't allow auth routes; route through loading screen
      // so Firestore data has time to load before the dashboard appears.
      if (isAuthRoute) return '/loading';
      if (isLoadingRoute || isPinRoute) return null;

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/setup-pin',
        builder: (context, state) => const SetupPinScreen(),
      ),
      GoRoute(
        path: '/pin-lock',
        builder: (context, state) => const PinLockScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycMainFlow(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _ShellScaffold(
          state: state,
          child: child,
        ),
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
              GoRoute(
                path: 'card-management/add',
                builder: (context, state) => const AddCardScreen(),
              ),
              GoRoute(
                path: 'card-management/details',
                builder: (context, state) {
                  final account = state.extra as Account;
                  return CardDetailsScreen(account: account);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/qr',
            builder: (context, state) => const QrHubScreen(),
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
          GoRoute(
            path: '/savings',
            builder: (context, state) => const SavingsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const SavingsCreateScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionHistoryScreen(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final transaction = state.extra as Transaction;
                  return TransactionDetailsScreen(transaction: transaction);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

int _calculateSelectedIndex(String location) {
  if (location == '/') return 0;
  if (location.startsWith('/wallet')) return 1;
  if (_isQrRoute(location)) return 2;
  if (location.startsWith('/analytics')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}

bool _isQrRoute(String location) {
  return location.startsWith('/qr') ||
      location.startsWith('/qr-scanner') ||
      location.startsWith('/my-qr') ||
      location.startsWith('/request-money');
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
      context.go('/qr');
      break;
    case 3:
      context.go('/analytics');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}

/// Shell scaffold with an intelligent, draggable, edge-snapping AI Assistant FAB.
///
/// Features:
///   - Automatically HIDES on sensitive/form routes (PIN, card details, transfer, QR, etc.) or when keyboard is open.
///   - Slides out of view when scrolling DOWN, reappears when scrolling UP.
///   - Supports drag-and-drop repositioning with smooth edge-snapping.
class _ShellScaffold extends StatefulWidget {
  const _ShellScaffold({required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  bool _scrollFabVisible = true;
  double _fabRight = 16.0;
  double _fabBottom = 80.0;
  bool _isDragging = false;

  bool _shouldHideFab(String path, BuildContext context) {
    // Hide if soft keyboard is open
    if (MediaQuery.of(context).viewInsets.bottom > 0) return true;

    // Hide during sensitive, form, or full-screen routes
    final lower = path.toLowerCase();
    return lower.contains('ai-assistant') ||
        lower.contains('setup-pin') ||
        lower.contains('pin-lock') ||
        lower.contains('card-management') ||
        lower.contains('transfer') ||
        lower.contains('add-') ||
        lower.contains('details') ||
        lower.contains('qr') ||
        lower.contains('request-money') ||
        lower.contains('pay-bills') ||
        lower.contains('kyc') ||
        lower.contains('top-up') ||
        lower.contains('topup') ||
        lower.contains('deposit') ||
        lower.contains('add-card') ||
        lower.contains('welcome') ||
        lower.contains('login') ||
        lower.contains('register');
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = widget.state.fullPath ?? '/';
    final isRouteHide = _shouldHideFab(currentPath, context);
    final isFabVisible = _scrollFabVisible && !isRouteHide;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: const ValueKey('shell_scaffold'),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final delta = notification.scrollDelta ?? 0.0;
                if (delta > 2.0 && _scrollFabVisible) {
                  setState(() => _scrollFabVisible = false);
                } else if (delta < -2.0 && !_scrollFabVisible) {
                  setState(() => _scrollFabVisible = true);
                }
              } else if (notification is UserScrollNotification) {
                if (notification.direction == ScrollDirection.reverse &&
                    _scrollFabVisible) {
                  setState(() => _scrollFabVisible = false);
                } else if (notification.direction == ScrollDirection.forward &&
                    !_scrollFabVisible) {
                  setState(() => _scrollFabVisible = true);
                }
              }
              return false;
            },
            child: widget.child,
          ),

          // Draggable & Edge-Snapping Chatbot FAB
          if (isFabVisible)
            Positioned(
              right: _fabRight,
              bottom: _fabBottom,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _isDragging = true;
                    _fabRight = (_fabRight - details.delta.dx)
                        .clamp(16.0, size.width - 72.0);
                    _fabBottom = (_fabBottom - details.delta.dy)
                        .clamp(80.0, size.height - 120.0);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    // Edge snapping logic (snap to nearest left or right edge)
                    final midX = size.width / 2;
                    if (_fabRight > midX - 36) {
                      _fabRight = size.width - 72.0; // Snap to left edge
                    } else {
                      _fabRight = 16.0; // Snap to right edge
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: FloatingActionButton(
                    heroTag: 'ai_assistant_fab_draggable',
                    onPressed: () => context.push('/ai-assistant'),
                    tooltip: 'AI Assistant (Drag to move)',
                    child: const Icon(Icons.auto_awesome_rounded),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _calculateSelectedIndex(currentPath),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
