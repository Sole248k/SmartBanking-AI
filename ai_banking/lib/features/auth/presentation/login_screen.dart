import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to\nSmartBank AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
           TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            authState.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              orElse: () => AppButton(
                text: 'Login',
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).login(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
              ),
            ),
            const SizedBox(height: 16),
            authState.maybeWhen(
              loading: () => const SizedBox.shrink(),
              orElse: () => AppButton(
                text: 'Continue with Google',
                variant: AppButtonVariant.outline,
                icon: Icons.g_mobiledata_rounded,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pushReplacement('/register'),
                child: const Text('Don\'t have an account? Create one'),
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
          ],
        ),
      ),
    );
  }
}
