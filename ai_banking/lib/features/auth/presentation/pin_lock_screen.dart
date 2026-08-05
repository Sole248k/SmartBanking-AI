import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/pin_utils.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_providers.dart';

import '../../../shared/providers/session_lock_provider.dart';

/// Screen requiring 6-digit PIN or Biometrics for daily app access.
class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String _enteredPin = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric authentication if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  Future<void> _tryBiometricUnlock() async {
    final profile = ref.read(profileControllerProvider).value;
    if (profile != null && profile.isBiometricEnabled) {
      final result = await ref
          .read(authRepositoryProvider)
          .authenticateWithBiometrics();

      result.fold(
        (_) => null,
        (success) {
          if (success && mounted) {
            ref.read(sessionLockControllerProvider.notifier).unlockSession();
            context.go('/loading');
          }
        },
      );
    }
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 6) {
      setState(() {
        _errorMessage = null;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final profile = ref.read(profileControllerProvider).value;
    if (profile == null) return;

    // Check if account is locked
    if (profile.pinLockedUntil != null) {
      final lockTime = DateTime.tryParse(profile.pinLockedUntil!);
      if (lockTime != null && DateTime.now().isBefore(lockTime)) {
        final remainingMin = lockTime.difference(DateTime.now()).inMinutes + 1;
        setState(() {
          _errorMessage =
              'Too many failed attempts. Try again in $remainingMin minute(s).';
          _enteredPin = '';
        });
        return;
      }
    }

    final isValid = PinUtils.verifyPin(_enteredPin, profile.pinHash);

    if (isValid) {
      setState(() => _isLoading = true);
      await ref.read(profileRepositoryProvider).resetPinAttempts();
      setState(() => _isLoading = false);

      if (mounted) {
        ref.read(sessionLockControllerProvider.notifier).unlockSession();
        context.go('/loading');
      }
    } else {
      final currentAttempts = profile.pinAttempts;
      await ref
          .read(profileRepositoryProvider)
          .recordFailedPinAttempt(currentAttempts);
      ref.invalidate(profileControllerProvider);

      setState(() {
        _enteredPin = '';
        final remaining = 5 - (currentAttempts + 1);
        if (remaining <= 0) {
          _errorMessage =
              'Account locked for 5 minutes due to repeated incorrect PINs.';
        } else {
          _errorMessage = 'Incorrect PIN. $remaining attempt(s) remaining.';
        }
      });
    }
  }

  void _showForgotPasswordDialog() {
    final passwordController = TextEditingController();
    bool isVerifying = false;
    String? dialogError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forgot PIN / Password Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your account password to verify identity and reset your PIN.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Account Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    dialogError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isVerifying
                        ? null
                        : () async {
                            final password = passwordController.text.trim();
                            if (password.isEmpty) return;

                            setModalState(() => isVerifying = true);

                            final authUser =
                                ref.read(authNotifierProvider).value;
                            if (authUser == null) return;

                            final result = await ref
                                .read(authRepositoryProvider)
                                .login(authUser.email, password);

                            setModalState(() => isVerifying = false);

                            result.fold(
                              (f) {
                                setModalState(
                                    () => dialogError = 'Incorrect password');
                              },
                              (_) async {
                                Navigator.pop(context); // Close sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Password verified. Please set your new Security PIN.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.go('/setup-pin');
                              },
                            );
                          },
                    child: isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verify & Reset PIN'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF05071A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.xl),

            // Header Avatar / Lock Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: AppConstants.lg),

            Text(
              'Welcome Back',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.sm),

            Text(
              profile?.fullName ?? 'SmartBank User',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: AppConstants.xxl),

            // PIN Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? AppTheme.primaryColor
                        : Colors.white24,
                    boxShadow: index < _enteredPin.length
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppConstants.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const Spacer(),

            if (_isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryColor)
            else
              _buildKeypad(profile?.isBiometricEnabled ?? false),

            const SizedBox(height: AppConstants.md),

            // Forgot PIN / Unlock with Password Link
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text(
                'Forgot PIN? Unlock with Password',
                style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
              ),
            ),

            const SizedBox(height: AppConstants.md),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(bool biometricEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '1', onTap: () => _onKeyPress('1')),
              _KeypadButton(digit: '2', onTap: () => _onKeyPress('2')),
              _KeypadButton(digit: '3', onTap: () => _onKeyPress('3')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '4', onTap: () => _onKeyPress('4')),
              _KeypadButton(digit: '5', onTap: () => _onKeyPress('5')),
              _KeypadButton(digit: '6', onTap: () => _onKeyPress('6')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '7', onTap: () => _onKeyPress('7')),
              _KeypadButton(digit: '8', onTap: () => _onKeyPress('8')),
              _KeypadButton(digit: '9', onTap: () => _onKeyPress('9')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (biometricEnabled)
                InkWell(
                  onTap: _tryBiometricUnlock,
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppTheme.accentColor,
                      size: 32,
                    ),
                  ),
                )
              else
                const SizedBox(width: 70, height: 70),
              _KeypadButton(digit: '0', onTap: () => _onKeyPress('0')),
              InkWell(
                onTap: _onBackspace,
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.digit, required this.onTap});
  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
