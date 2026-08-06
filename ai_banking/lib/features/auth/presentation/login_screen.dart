import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Local error string used to highlight fields and show an error banner.
  // This is set when auth fails and cleared when the user starts typing.
  String? _authError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (_authError != null) setState(() => _authError = null);
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Friendly Firebase error messages ───────────────────────────────────

  String _friendlyError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('user-not-found') || raw.contains('no user record')) {
      return 'No account found with that email address.';
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-credential') ||
        raw.contains('invalid credential')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a moment and try again.';
    }
    if (raw.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (raw.contains('email') && raw.contains('format')) {
      return 'Invalid email format. Please enter a valid email.';
    }
    debugPrint('[LoginScreen] Auth error: $error');
    return 'Something went wrong. Please try again.';
  }

  // ── Login handler ───────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    // Clear any previous auth error
    if (_authError != null) setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  // ── Google sign-in handler ──────────────────────────────────────────────

  Future<void> _handleGoogle() async {
    if (_authError != null) setState(() => _authError = null);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  // ── Error dialog (modal) ────────────────────────────────────────────────

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded,
            color: Colors.redAccent, size: 36),
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen for state changes.
    // • Success (loading → data(user != null)): navigate to /loading.
    // • Failure (loading → error): show dialog, keep user on screen.
    ref.listen(authNotifierProvider, (previous, next) {
      // Only react when the previous state was loading — this ensures we only
      // respond to an explicit login/Google action, not to the initial provider
      // build which may also emit data(user).
      if (previous == null || !previous.isLoading) return;

      next.when(
        data: (user) {
          if (user != null && mounted) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.xl),

                // ── Heading ───────────────────────────────────────────
                Text(
                  'Welcome to\nSmartBank AI',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.sm),
                Text(
                  'Sign in to continue.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.xxl),

                // ── Error banner (shown in-form after a failed attempt) ──
                if (_authError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer
                          .withValues(alpha: 0.25),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.5)),
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

                // ── Email field ───────────────────────────────────────
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationUtils.validateEmail,
                  // Highlight field red when there is an auth error
                  errorText: _authError != null ? '' : null,
                ),
                const SizedBox(height: AppConstants.md),

                // ── Password field ────────────────────────────────────
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                  errorText: _authError != null ? '' : null,
                ),
                const SizedBox(height: AppConstants.xl),

                // ── Action buttons ────────────────────────────────────
                AppButton(
                  text: 'Login',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
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

                // ── Switch to register ────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.pushReplacement('/register'),
                    child: const Text("Don't have an account? Create one"),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push('/admin/login'),
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                    label: const Text('Admin Portal Sign In'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
