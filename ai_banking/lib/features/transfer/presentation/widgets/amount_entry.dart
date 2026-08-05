import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../providers/transfer_providers.dart';

class AmountEntry extends ConsumerStatefulWidget {
  const AmountEntry({super.key});

  @override
  ConsumerState<AmountEntry> createState() => _AmountEntryState();
}

class _AmountEntryState extends ConsumerState<AmountEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferControllerProvider);
    final beneficiary = transferState.selectedBeneficiary!;
    final theme = Theme.of(context);

    return Padding(
      padding: AppConstants.screenPadding,
      child: Column(
        children: [
          const Spacer(),
          AppAvatar(name: beneficiary.name, size: 80),
          const SizedBox(height: AppConstants.md),
          Text(
            'Transfer to ${beneficiary.name}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppConstants.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₱',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: AppConstants.xs),
              IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          AppButton(
            text: 'Continue',
            onPressed: () {
              final amount = double.tryParse(_controller.text) ?? 0.0;
              if (amount > 0) {
                ref.read(transferControllerProvider.notifier).setAmount(amount);
              }
            },
          ),
        ],
      ),
    );
  }
}
