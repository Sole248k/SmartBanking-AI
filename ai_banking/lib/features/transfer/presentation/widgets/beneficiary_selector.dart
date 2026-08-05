import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../providers/transfer_providers.dart';

class BeneficiarySelector extends ConsumerWidget {
  const BeneficiarySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beneficiariesAsync = ref.watch(beneficiariesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: AppConstants.screenPadding,
          child: Row(
            children: [
              const Expanded(
                child: AppTextField(
                  hint: 'Search beneficiary',
                  prefixIcon: Icons.search,
                ),
              ),
              const SizedBox(width: AppConstants.md),
              IconButton.filled(
                onPressed: () => context.push('/transfer/add-beneficiary'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: beneficiariesAsync.when(
            data: (list) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final beneficiary = list[index];
                return AppListTile(
                  title: Text(beneficiary.name),
                  subtitle: Text('${beneficiary.bankName} • ${beneficiary.accountNumber}'),
                  leading: AppAvatar(name: beneficiary.name),
                  onTap: () {
                    ref.read(transferControllerProvider.notifier).selectBeneficiary(beneficiary);
                  },
                );
              },
            ),
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: AppConstants.sm),
                child: AppShimmer(width: double.infinity, height: 72, borderRadius: AppConstants.radiusLg),
              ),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
