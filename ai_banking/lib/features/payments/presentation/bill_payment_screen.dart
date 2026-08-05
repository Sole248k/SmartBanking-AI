import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_list_tile.dart';

class BillPaymentScreen extends StatelessWidget {
  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bills'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: AppConstants.md,
              crossAxisSpacing: AppConstants.md,
              children: [
                const _CategoryIcon(icon: Icons.electric_bolt_rounded, label: 'Electric', color: Colors.amber),
                const _CategoryIcon(icon: Icons.water_drop_rounded, label: 'Water', color: Colors.blue),
                const _CategoryIcon(icon: Icons.wifi_rounded, label: 'Internet', color: Colors.purple),
                const _CategoryIcon(icon: Icons.phone_android_rounded, label: 'Mobile', color: Colors.green),
                const _CategoryIcon(icon: Icons.credit_card_rounded, label: 'Credit Card', color: Colors.red),
                const _CategoryIcon(icon: Icons.school_rounded, label: 'Tuition', color: Colors.orange),
                const _CategoryIcon(icon: Icons.home_work_rounded, label: 'Govt', color: Colors.teal),
                const _CategoryIcon(icon: Icons.more_horiz_rounded, label: 'Others', color: Colors.grey),
              ],
            ),
            const SizedBox(height: AppConstants.xl),
            Text(
              'Recent Billers',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),
            AppCard(
              child: Column(
                children: [
                  AppListTile(
                    title: const Text('Meralco'),
                    subtitle: const Text('Customer ID: 1234567890'),
                    leading: const Icon(Icons.electric_bolt_rounded, color: Colors.amber),
                    onTap: () {},
                  ),
                  AppListTile(
                    title: const Text('Manila Water'),
                    subtitle: const Text('Account: 0987654321'),
                    leading: const Icon(Icons.water_drop_rounded, color: Colors.blue),
                    onTap: () {},
                  ),
                  AppListTile(
                    title: const Text('PLDT Home'),
                    subtitle: const Text('Account: 5566778899'),
                    leading: const Icon(Icons.wifi_rounded, color: Colors.purple),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {

  const _CategoryIcon({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
