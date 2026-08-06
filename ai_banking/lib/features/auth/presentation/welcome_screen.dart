import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: AppConstants.screenPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo / Icon
            Container(
              padding: const EdgeInsets.all(AppConstants.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 64,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
            
            const SizedBox(height: AppConstants.xl),
            
            Text(
              'SmartBank AI',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ).animate().fadeIn().slideY(begin: 0.3, duration: 500.ms),
            
            const SizedBox(height: AppConstants.md),
            
            Text(
              'The future of intelligent banking is here. Manage, save, and grow your wealth with AI.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ).animate(delay: 200.ms).fadeIn(),
            
            const Spacer(flex: 3),
            
            AppButton(
              text: 'Get Started',
              onPressed: () => context.push('/register'),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: AppConstants.md),
            
            AppButton(
              text: 'Log In',
              variant: AppButtonVariant.outline,
              onPressed: () => context.push('/login'),
            ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
            
            const SizedBox(height: AppConstants.sm),

            TextButton.icon(
              onPressed: () => context.push('/admin/login'),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('Admin Portal'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ).animate(delay: 600.ms).fadeIn(),

            const SizedBox(height: AppConstants.md),
          ],
        ),
      ),
    );
  }
}
