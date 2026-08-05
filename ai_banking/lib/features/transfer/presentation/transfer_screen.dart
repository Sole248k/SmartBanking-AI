import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../models/transfer_state.dart';
import '../providers/transfer_providers.dart';
import 'widgets/beneficiary_selector.dart';
import 'widgets/amount_entry.dart';
import 'widgets/transfer_confirmation.dart';
import 'widgets/transfer_success.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferControllerProvider);
    final controller = ref.read(transferControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        leading: transferState.step == TransferStep.success
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (transferState.step == TransferStep.selectBeneficiary) {
                    context.pop();
                  } else {
                    controller.back();
                  }
                },
              ),
      ),
      body: AnimatedSwitcher(
        duration: AppConstants.fast,
        child: _buildStep(transferState.step),
      ),
    );
  }

  Widget _buildStep(TransferStep step) {
    switch (step) {
      case TransferStep.selectBeneficiary:
        return const BeneficiarySelector();
      case TransferStep.enterAmount:
        return const AmountEntry();
      case TransferStep.confirm:
        return const TransferConfirmation();
      case TransferStep.success:
        return const TransferSuccess();
    }
  }
}
