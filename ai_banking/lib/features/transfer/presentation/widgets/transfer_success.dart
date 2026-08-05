import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../providers/transfer_providers.dart';

class TransferSuccess extends ConsumerWidget {
  const TransferSuccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppConstants.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppConstants.xl),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 100,
            ),
          ),
          const SizedBox(height: AppConstants.xl),
          Text(
            'Transfer Successful!',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.md),
          const Text(
            'Your money has been sent successfully. It will reflect in the recipient\'s account shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          AppButton(
            text: 'Back to Dashboard',
            onPressed: () {
              ref.read(transferControllerProvider.notifier).reset();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
