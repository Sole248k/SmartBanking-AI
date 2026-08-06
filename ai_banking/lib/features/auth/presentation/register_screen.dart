import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Local auth error — shown in the inline banner and used to tint fields red.
  // Cleared as soon as the user edits any field.
  String? _authError;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.addListener(_clearError);
    }
  }

  void _clearError() {
    if (_authError != null) setState(() => _authError = null);
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.removeListener(_clearError);
      c.dispose();
    }
    super.dispose();
  }

  // ── Friendly Firebase error messages ───────────────────────────────────

  String _friendlyError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('email-already-in-use') ||
        raw.contains('already in use')) {
      return 'An account with this email address already exists. '
          'Try logging in instead.';
    }
    if (raw.contains('invalid-email') || raw.contains('invalid email')) {
      return 'The email address is not valid. Please check and try again.';
    }
    if (raw.contains('weak-password') || raw.contains('weak password')) {
      return 'Password is too weak. Use at least 8 characters with an '
          'uppercase letter and a number.';
    }
    if (raw.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled. Please contact support.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'Network error. Please check your connection and try again.';
    }
    debugPrint('[RegisterScreen] Auth error: $error');
    return 'Something went wrong. Please try again.';
  }

  // ── Register handler ────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (_authError != null) setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
  }

  // ── Google sign-up handler ──────────────────────────────────────────────

  Future<void> _handleGoogle() async {
    if (_authError != null) setState(() => _authError = null);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  // ── Error dialog ────────────────────────────────────────────────────────

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded,
            color: Colors.redAccent, size: 36),
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Success dialog ──────────────────────────────────────────────────────

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Account created successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Only react to the outcome of an explicit register/Google action
    // (previous state must be loading).
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous == null || !previous.isLoading) return;

      next.when(
        data: (user) {
          if (user != null && mounted) {
            _showSuccessSnackBar();
            context.go('/loading');
          }
        },
        loading: () {},
        error: (error, _) {
          if (!mounted) return;
          final msg = _friendlyError(error);
          setState(() => _authError = msg);
          _showErrorDialog(msg);
        },
      );
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Heading ───────────────────────────────────────────
              Text(
                'Create Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.sm),
              Text(
                'Start your journey to smarter banking today.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppConstants.xl),

              // ── Error banner ──────────────────────────────────────
              if (_authError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.25),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                        color:
                            theme.colorScheme.error.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: AppConstants.sm),
                      Expanded(
                        child: Text(
                          _authError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.md),
              ],

              // ── Full Name ─────────────────────────────────────────
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: ValidationUtils.validateFullName,
              ),
              const SizedBox(height: AppConstants.md),

              // ── Email ─────────────────────────────────────────────
              AppTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: ValidationUtils.validateEmail,
                // Tint field red when auth fails (e.g. email already in use)
                errorText: _authError != null ? '' : null,
              ),
              const SizedBox(height: AppConstants.md),

              // ── Password ──────────────────────────────────────────
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 8 chars, 1 uppercase, 1 number',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: ValidationUtils.validatePassword,
              ),
              const SizedBox(height: AppConstants.md),

              // ── Confirm Password ──────────────────────────────────
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.xl),

              // ── Action buttons ────────────────────────────────────
              AppButton(
                text: 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleRegister,
              ),
              const SizedBox(height: AppConstants.md),
              AppButton(
                text: 'Continue with Google',
                variant: AppButtonVariant.outline,
                icon: Icons.g_mobiledata_rounded,
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleGoogle,
              ),

              const SizedBox(height: AppConstants.xl),

              // ── Switch to login ───────────────────────────────────
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.pushReplacement('/login'),
                  child: const Text('Already have an account? Log In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
