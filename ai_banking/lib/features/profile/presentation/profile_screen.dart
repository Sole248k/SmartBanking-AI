import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_list_tile.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../shared/providers/privacy_provider.dart';
import '../../../core/services/firebase_service/database_seeder.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(profileControllerProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile.id.isEmpty) {
            return _buildErrorState(context, ref, 'Please log in to view your profile.');
          }
          return _buildProfileContent(context, ref, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(context, ref, err.toString()),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, dynamic profile) {
    final theme = Theme.of(context);
    final kycColor = _kycColor(profile.kycStatus);
    final kycIcon = _kycIcon(profile.kycStatus);

    return SingleChildScrollView(
      padding: AppConstants.screenPadding,
      child: Column(
        children: [
          AppAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, size: 100),
          const SizedBox(height: AppConstants.md),
          Text(
            profile.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppConstants.xl),

          _Section(
            title: 'Account Settings',
            children: [
              AppListTile(
                title: const Text('Personal Information'),
                leading: const Icon(Icons.person_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              AppListTile(
                title: const Text('KYC Verification'),
                subtitle: Text(profile.kycStatus),
                leading: const Icon(Icons.verified_user_outlined),
                trailing: Icon(kycIcon, color: kycColor),
                onTap: () => context.push('/kyc'),
              ),
            ],
          ),

          _Section(
            title: 'Security',
            children: [
              AppListTile(
                title: const Text('Biometric Login'),
                leading: const Icon(Icons.fingerprint),
                trailing: Switch.adaptive(
                  value: profile.isBiometricEnabled,
                  onChanged: (val) =>
                      ref.read(profileControllerProvider.notifier).toggleBiometrics(val),
                ),
              ),
              AppListTile(
                title: const Text('Change Transaction PIN'),
                leading: const Icon(Icons.lock_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          _Section(
            title: 'Preferences',
            children: [
              AppListTile(
                title: const Text('Push Notifications'),
                leading: const Icon(Icons.notifications_none),
                trailing: Switch.adaptive(
                  value: profile.pushNotificationsEnabled,
                  onChanged: (val) =>
                      ref.read(profileControllerProvider.notifier).toggleNotifications(val),
                ),
              ),
              AppListTile(
                title: const Text('Dark Mode'),
                leading: const Icon(Icons.dark_mode_outlined),
                trailing: Switch.adaptive(
                  value: ref.watch(appThemeModeProvider) == ThemeMode.dark,
                  onChanged: (_) => ref.read(appThemeModeProvider.notifier).toggleTheme(),
                ),
              ),
              AppListTile(
                title: const Text('Privacy Mode'),
                leading: const Icon(Icons.security_rounded),
                trailing: Switch.adaptive(
                  value: ref.watch(privacyModeProvider),
                  onChanged: (_) => ref.read(privacyModeProvider.notifier).toggle(),
                ),
              ),
            ],
          ),

          _buildDevTools(context, ref),

          const SizedBox(height: AppConstants.xl),
          Text(
            'App Version 1.0.0 (Build 12)',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _kycColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending Review':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _kycIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Pending Review':
        return Icons.hourglass_top_rounded;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.chevron_right;
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Padding(
      padding: AppConstants.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppConstants.md),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.md),
          AppButton(
            text: 'Retry',
            onPressed: () => ref.read(profileControllerProvider.notifier).refresh(),
          ),
          const SizedBox(height: AppConstants.md),
          if (error.contains('logged in'))
            AppButton(
              text: 'Go to Login',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/login'),
            ),
          const SizedBox(height: AppConstants.xxl),
          _buildDevTools(context, ref),
        ],
      ),
    );
  }

  Widget _buildDevTools(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    return _Section(
      title: 'Developer Tools',
      children: [
        AppListTile(
          title: const Text('Seed Database'),
          subtitle: const Text('Populate Firestore with mock data'),
          leading: const Icon(Icons.data_array),
          onTap: () async {
            await DatabaseSeeder.seedData();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database seeded successfully!')),
              );
            }
          },
        ),
        AppListTile(
          title: const Text('Create Demo Users'),
          subtitle: const Text('Register user1, user2, and bot accounts'),
          leading: const Icon(Icons.people_outline_rounded),
          onTap: () async {
            await DatabaseSeeder.createDemoUsers();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo users creation triggered!')),
              );
            }
          },
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.md),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}
