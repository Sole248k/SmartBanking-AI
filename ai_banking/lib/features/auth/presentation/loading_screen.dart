import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../profile/providers/profile_providers.dart';

/// Splash/loading screen shown after successful login or account creation.
///
/// The screen subscribes to the key dashboard providers while it is visible,
/// which kicks off Firestore fetches in the background. Navigation to the
/// dashboard happens only when ALL of the following are satisfied:
///
///   1. [_minDisplayMs] has elapsed (minimum brand exposure).
///   2. [dashboardAccountsProvider] emits a NON-EMPTY list (account card ready).
///   3. [profileControllerProvider] has resolved (user name is available).
///
/// A [_maxWaitMs] safety timeout ensures we never wait forever on a slow
/// connection — after that threshold we navigate regardless.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  /// Minimum time the splash must be visible regardless of data state.
  static const int _minDisplayMs = 2500;

  /// Maximum time we will wait for Firestore before navigating anyway.
  /// Profile retry logic can take up to ~2.4 s, add network slack on top.
  static const int _maxWaitMs = 12000;

  late final AnimationController _pulseController;

  bool _minTimerDone = false;
  bool _accountsReady = false; // true when ≥1 account received from Firestore
  bool _profileReady = false;  // true when user profile/name has loaded
  bool _navigated = false;     // guard against calling context.go twice

  bool get _allReady => _accountsReady && _profileReady;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // ── Minimum display timer ────────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: _minDisplayMs), () {
      if (!mounted) return;
      setState(() => _minTimerDone = true);
      _tryNavigate();
    });

    // ── Safety timeout ───────────────────────────────────────────────────
    // Navigate regardless if Firestore is unreachable or very slow.
    Future.delayed(const Duration(milliseconds: _maxWaitMs), () {
      if (mounted && !_navigated) {
        debugPrint('[LoadingScreen] Safety timeout reached — navigating anyway.');
        _navigate();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (_minTimerDone && _allReady && !_navigated) {
      _navigate();
    }
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    _navigated = true;

    final profile = ref.read(profileControllerProvider).value;
    if (profile != null && (profile.pinHash == null || profile.pinHash!.isEmpty)) {
      context.go('/setup-pin');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Watch providers to kick off background fetches ─────────────────
    // Subscribing here means Riverpod starts the Firestore streams/futures
    // immediately while the user sees the splash, so data arrives faster.

    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    // Accounts: we need at least ONE account — empty list means Firestore
    // hasn't propagated the newly-provisioned account document yet.
    accountsAsync.whenData((accounts) {
      if (accounts.isNotEmpty && !_accountsReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _accountsReady = true);
            _tryNavigate();
          }
        });
      }
    });

    // Profile: any resolved value (including the auth-based fallback) is fine.
    profileAsync.whenData((_) {
      if (!_profileReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _profileReady = true);
            _tryNavigate();
          }
        });
      }
    });

    // ── Progress label ──────────────────────────────────────────────────
    final String statusText;
    if (_accountsReady && _profileReady) {
      statusText = 'Ready!';
    } else if (_profileReady && !_accountsReady) {
      statusText = 'Creating your account...';
    } else if (_accountsReady && !_profileReady) {
      statusText = 'Loading your profile...';
    } else {
      statusText = 'Setting up your experience...';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF05071A),
      body: Stack(
        children: [
          // ── Background ambient glows ────────────────────────────────
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryColor.withOpacity(0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Centre content ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing logo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = 20.0 + (_pulseController.value * 18.0);
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(
                                0.35 + _pulseController.value * 0.3),
                            blurRadius: glow,
                            spreadRadius: glow * 0.3,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                )
                    .animate()
                    .scale(duration: 700.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                const Text(
                  'SmartBank AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.25,
                      end: 0,
                      delay: 350.ms,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 10),

                const Text(
                  'Your intelligent banking partner',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ).animate().fadeIn(delay: 550.ms, duration: 500.ms),
              ],
            ),
          ),

          // ── Bottom progress section ─────────────────────────────────
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Stepped mini-checklist so users see what's happening
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      _StatusRow(
                        label: 'Account card',
                        done: _accountsReady,
                      ),
                      const SizedBox(height: 6),
                      _StatusRow(
                        label: 'User profile',
                        done: _profileReady,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                const SizedBox(height: 16),

                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      value: _allReady ? 1.0 : null,
                      color: AppTheme.primaryColor,
                      minHeight: 3,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                const SizedBox(height: 12),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    statusText,
                    key: ValueKey(statusText),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small row showing a label with a tick/spinner to indicate load status.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: done
              ? const Icon(Icons.check_circle_rounded,
                  color: AppTheme.accentColor, size: 14, key: ValueKey('done'))
              : const SizedBox(
                  width: 14,
                  height: 14,
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white38,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: done ? Colors.white54 : Colors.white30,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
