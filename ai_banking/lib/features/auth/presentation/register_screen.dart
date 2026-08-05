import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../domain/auth_user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // Navigate to loading screen on successful registration
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        context.go('/loading');
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                validator: ValidationUtils.validateFullName,
              ),
              const SizedBox(height: AppConstants.md),

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
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: ValidationUtils.validatePassword,
              ),
              const SizedBox(height: AppConstants.md),

              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'confirm password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (val) {
                  if (val != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.xl),

              authState.maybeWhen(
                loading: () => const Center(child: CircularProgressIndicator()),
                orElse: () => Column(
                  children: [
                    AppButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 16),
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

              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authState.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: AppConstants.xl),
              Center(
                child: TextButton(
                  onPressed: () => context.pushReplacement('/login'),
                  child: const Text('Already have an account? Log In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
    }
  }
}
