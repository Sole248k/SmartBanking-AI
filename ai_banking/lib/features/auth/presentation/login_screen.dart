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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.xl),
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
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.xxl),
                AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationUtils.validateEmail,
                ),
                const SizedBox(height: AppConstants.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'password',
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
                ),
                const SizedBox(height: AppConstants.xl),
                authState.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  orElse: () => Column(
                    children: [
                      AppButton(text: 'Login', onPressed: _handleLogin),
                      const SizedBox(height: AppConstants.md),
                      AppButton(
                        text: 'Continue with Google',
                        variant: AppButtonVariant.outline,
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signInWithGoogle();
                        },
                      ),
                    ],
                  ),
                ),
                if (authState.hasError) ...[
                  const SizedBox(height: AppConstants.md),
                  Center(
                    child: Text(
                      authState.error.toString(),
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.xl),
                Center(
                  child: TextButton(
                    onPressed: () => context.pushReplacement('/register'),
                    child: const Text("Don't have an account? Create one"),
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
