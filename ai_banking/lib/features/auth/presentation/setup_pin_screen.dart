import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/pin_utils.dart';
import '../../profile/providers/profile_providers.dart';

/// Mandatory onboarding screen to set up a 6-digit Security PIN.
class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  String? _errorMessage;

  void _onKeyPress(String digit) {
    setState(() => _errorMessage = null);

    if (!_isConfirming) {
      if (_firstPin.length < 6) {
        setState(() => _firstPin += digit);
        if (_firstPin.length == 6) {
          // Transition to confirmation stage after brief delay
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      }
    } else {
      if (_confirmPin.length < 6) {
        setState(() => _confirmPin += digit);
        if (_confirmPin.length == 6) {
          _verifyAndSavePin();
        }
      }
    }
  }

  void _onBackspace() {
    setState(() => _errorMessage = null);
    if (!_isConfirming) {
      if (_firstPin.isNotEmpty) {
        setState(() => _firstPin = _firstPin.substring(0, _firstPin.length - 1));
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(
            () => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      }
    }
  }

  Future<void> _verifyAndSavePin() async {
    if (_firstPin != _confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _firstPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final hashedPin = PinUtils.hashPin(_firstPin);
    final result = await ref
        .read(profileRepositoryProvider)
        .setSecurityPin(hashedPin);

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _firstPin = '';
          _confirmPin = '';
          _isConfirming = false;
        });
      },
      (_) {
        ref.invalidate(profileControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security PIN created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/loading');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPin = _isConfirming ? _confirmPin : _firstPin;

    return PopScope(
      canPop: false, // Mandatory setup: cannot pop or go back
      child: Scaffold(
        backgroundColor: const Color(0xFF05071A),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.xl),

              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: AppConstants.lg),

              Text(
                _isConfirming
                    ? 'Confirm Security PIN'
                    : 'Set Up Security PIN',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppConstants.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _isConfirming
                      ? 'Re-enter your 6-digit PIN to confirm'
                      : 'Create a 6-digit PIN to secure your daily access',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
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
                      color: index < currentPin.length
                          ? AppTheme.primaryColor
                          : Colors.white24,
                      boxShadow: index < currentPin.length
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
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(),

              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.primaryColor)
              else
                // Numeric Keypad
                _buildKeypad(),

              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
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
              const SizedBox(width: 70, height: 70), // Empty space placeholder
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
