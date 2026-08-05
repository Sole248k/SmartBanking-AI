import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_list_tile.dart';
import '../../shared/widgets/app_shimmer.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Buttons',
              children: [
                AppButton(text: 'Primary Button', onPressed: () {}),
                const SizedBox(height: AppConstants.md),
                AppButton(
                  text: 'Secondary Button',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: AppConstants.md),
                AppButton(
                  text: 'Outline Button',
                  variant: AppButtonVariant.outline,
                  onPressed: () {},
                ),
                const SizedBox(height: AppConstants.md),
                AppButton(
                  text: 'Loading Button',
                  isLoading: true,
                  onPressed: () {},
                ),
              ],
            ),
            const _Section(
              title: 'Text Fields',
              children: [
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                ),
                SizedBox(height: AppConstants.md),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
              ],
            ),
            _Section(
              title: 'Cards',
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Standard Card', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppConstants.sm),
                      Text('This is a standard card with elevation and shadow.',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.md),
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      ),
                    ),
                    const Positioned.fill(
                      child: GlassCard(
                        child: Center(
                          child: Text(
                            'Glassmorphic Card',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const _Section(
              title: 'Badges & Avatars',
              children: [
                Row(
                  children: [
                    AppBadge(label: 'Success', variant: AppBadgeVariant.success),
                    SizedBox(width: AppConstants.sm),
                    AppBadge(label: 'Error', variant: AppBadgeVariant.error),
                    SizedBox(width: AppConstants.sm),
                    AppBadge(label: 'Warning', variant: AppBadgeVariant.warning),
                  ],
                ),
                SizedBox(height: AppConstants.md),
                Row(
                  children: [
                    AppAvatar(name: 'John Doe'),
                    SizedBox(width: AppConstants.sm),
                    AppAvatar(name: 'Alice Smith', size: 50),
                    SizedBox(width: AppConstants.sm),
                    AppAvatar(imageUrl: 'https://i.pravatar.cc/150?u=1'),
                  ],
                ),
              ],
            ),
            _Section(
              title: 'List Tiles',
              children: [
                AppListTile(
                  title: const Text('Netflix Subscription'),
                  subtitle: const Text('Today, 10:00 AM'),
                  leading: const Icon(Icons.movie_outlined, color: Colors.red),
                  trailing: const Text('-₱15.99', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {},
                ),
                AppListTile(
                  title: const Text('Salary Deposit'),
                  subtitle: const Text('Yesterday, 04:00 PM'),
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                  trailing: const Text('+₱4,500.00',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  onTap: () {},
                ),
              ],
            ),
            _Section(
              title: 'Shimmers',
              children: [
                const AppShimmer(width: double.infinity, height: 60),
                const SizedBox(height: AppConstants.md),
                Row(
                  children: [
                    const AppShimmer.circle(size: 50),
                    const SizedBox(width: AppConstants.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppShimmer(width: double.infinity, height: 15),
                          const SizedBox(height: AppConstants.sm),
                          AppShimmer(width: MediaQuery.of(context).size.width * 0.4, height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.md),
        ...children,
        const SizedBox(height: AppConstants.xl),
      ],
    );
  }
}
