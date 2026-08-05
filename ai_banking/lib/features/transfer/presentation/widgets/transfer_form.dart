import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/beneficiary.dart';
import '../../providers/transfer_providers.dart';
import '../../repositories/transfer_repository.dart';
import '../../../dashboard/providers/dashboard_providers.dart';

/// Transfer form where beneficiary selection is OPTIONAL.
/// Users can enter recipient details & amount directly or choose a saved beneficiary.
class TransferForm extends ConsumerStatefulWidget {
  const TransferForm({super.key});

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedBank = 'SmartBank AI';
  bool _saveAsBeneficiary = false;

  static const List<String> _popularBanks = [
    'SmartBank AI',
    'EastWest Bank',
    'BDO Unibank',
    'BPI',
    'GCash',
    'Maya',
    'UnionBank',
    'Metrobank',
    'LandBank',
    'RCBC',
    'Security Bank',
  ];

  RecipientDetails? _lookedUpRecipient;
  bool _isSearchingRecipient = false;
  String? _selectedSourceAccountId;

  @override
  void initState() {
    super.initState();
    final state = ref.read(transferControllerProvider);
    _nameController.text = state.recipientName;
    _accountController.text = state.recipientAccountNumber;
    if (state.amount > 0) {
      _amountController.text = state.amount.toStringAsFixed(2);
    }
    if (state.bankName.isNotEmpty) {
      _selectedBank = _popularBanks.contains(state.bankName)
          ? state.bankName
          : _popularBanks.first;
    }
    _saveAsBeneficiary = state.saveAsBeneficiary;

    _accountController.addListener(_onAccountNumChanged);
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountNumChanged);
    _nameController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAccountNumChanged() async {
    final text = _accountController.text.trim();
    if (text.length >= 6) {
      setState(() => _isSearchingRecipient = true);
      final res = await ref.read(transferRepositoryProvider).lookupRecipient(text);
      res.fold(
        (_) => setState(() {
          _isSearchingRecipient = false;
          _lookedUpRecipient = null;
        }),
        (details) {
          setState(() {
            _isSearchingRecipient = false;
            _lookedUpRecipient = details;
            if (details != null) {
              _nameController.text = details.recipientName;
              if (_popularBanks.contains(details.bankName)) {
                _selectedBank = details.bankName;
              }
            }
          });
        },
      );
    } else if (_lookedUpRecipient != null) {
      setState(() => _lookedUpRecipient = null);
    }
  }

  void _onSelectBeneficiary(Beneficiary beneficiary) {
    setState(() {
      _nameController.text = beneficiary.name;
      _accountController.text = beneficiary.accountNumber;
      if (_popularBanks.contains(beneficiary.bankName)) {
        _selectedBank = beneficiary.bankName;
      } else {
        _selectedBank = 'SmartBank AI';
      }
      _saveAsBeneficiary = false;
    });
    ref
        .read(transferControllerProvider.notifier)
        .selectBeneficiary(beneficiary);
  }

  void _onClearSelection() {
    setState(() {
      _nameController.clear();
      _accountController.clear();
      _selectedBank = 'SmartBank AI';
      _lookedUpRecipient = null;
    });
    ref.read(transferControllerProvider.notifier).clearBeneficiary();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      ref.read(transferControllerProvider.notifier).setRecipientDetails(
            fromAccountId: _selectedSourceAccountId,
            recipientName: _nameController.text.trim(),
            recipientAccountNumber: _accountController.text.trim(),
            bankName: _selectedBank,
            amount: amount,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            saveAsBeneficiary: _saveAsBeneficiary,
          );
    }
  }

  void _showBeneficiaryPicker(List<Beneficiary> beneficiariesList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = beneficiariesList.where((b) {
              final q = searchQuery.toLowerCase();
              return b.name.toLowerCase().contains(q) ||
                  b.accountNumber.toLowerCase().contains(q) ||
                  b.bankName.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Saved Beneficiary',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.md),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, bank or account',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: AppConstants.md),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No matching beneficiaries found'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final b = filtered[index];
                              return ListTile(
                                leading: AppAvatar(name: b.name),
                                title: Text(b.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${b.bankName} • ${b.accountNumber}'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _onSelectBeneficiary(b);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final beneficiariesAsync = ref.watch(beneficiariesProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final transferState = ref.watch(transferControllerProvider);
    final theme = Theme.of(context);

    final savedList = beneficiariesAsync.value ?? [];
    final accountsList = accountsAsync.value ?? [];

    if (_selectedSourceAccountId == null && accountsList.isNotEmpty) {
      _selectedSourceAccountId = accountsList.first.id;
    }

    return SingleChildScrollView(
      padding: AppConstants.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Source Account Selector ──────────────────────────────
            Text(
              'Source Account / Card',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),
            if (accountsList.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedSourceAccountId,
                decoration: InputDecoration(
                  labelText: 'Transfer From',
                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                items: accountsList.map((acc) {
                  final balStr = '₱${acc.balance.toStringAsFixed(2)}';
                  return DropdownMenuItem(
                    value: acc.id,
                    child: Text(
                      '${acc.label} ($balStr)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSourceAccountId = val);
                  }
                },
              ),
            const SizedBox(height: AppConstants.xl),

            // ── Saved Beneficiaries Carousel (Optional) ───────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Beneficiaries',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (savedList.isNotEmpty)
                      TextButton(
                        onPressed: () => _showBeneficiaryPicker(savedList),
                        child: const Text('View All'),
                      ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/transfer/add-beneficiary'),
                      icon: const Icon(Icons.person_add_alt_1_rounded,
                          size: 18),
                      label: const Text('Add New'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.xs),

            beneficiariesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: AppConstants.sm),
                        const Expanded(
                          child: Text(
                            'No saved beneficiaries. You can enter recipient info directly below.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppConstants.sm),
                    itemBuilder: (context, index) {
                      final b = list[index];
                      final isSelected =
                          transferState.selectedBeneficiary?.id == b.id;

                      return GestureDetector(
                        onTap: () => _onSelectBeneficiary(b),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(AppConstants.sm),
                          width: 85,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.15)
                                : theme.colorScheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusLg),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppAvatar(name: b.name, size: 38),
                              const SizedBox(height: 4),
                              Text(
                                b.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 90),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppConstants.xl),

            // ── Recipient Details Section Header ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recipient Information',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (transferState.selectedBeneficiary != null ||
                    _lookedUpRecipient != null)
                  TextButton(
                    onPressed: _onClearSelection,
                    child: const Text('Clear Selection'),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.sm),

            // Bank Selector Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBank,
              decoration: InputDecoration(
                labelText: 'Select Bank / Network',
                prefixIcon: const Icon(Icons.account_balance_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
              ),
              items: _popularBanks.map((bank) {
                return DropdownMenuItem(
                  value: bank,
                  child: Text(bank),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedBank = val);
                }
              },
            ),
            const SizedBox(height: AppConstants.md),

            // Account / Mobile / Card Number
            AppTextField(
              controller: _accountController,
              label: 'Account / Card Number',
              hint: 'e.g. 1001234567 or 4000 1234 ...',
              prefixIcon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Account or Card number is required'
                  : null,
            ),
            const SizedBox(height: AppConstants.md),

            // Live Recipient Lookup Preview Card
            if (_isSearchingRecipient) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppConstants.md),
            ] else if (_lookedUpRecipient != null) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: Colors.green, size: 28),
                    const SizedBox(width: AppConstants.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lookedUpRecipient!.recipientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${_lookedUpRecipient!.bankName} • ${_lookedUpRecipient!.maskedCardNumber}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Chip(
                      label: Text('Verified',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.md),
            ],

            // Recipient Name
            AppTextField(
              controller: _nameController,
              label: 'Recipient Name',
              hint: 'Enter full name',
              prefixIcon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppConstants.xl),

            // ── Transfer Amount Section ──────────────────────────────
            Text(
              'Transfer Amount',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.sm),

            AppTextField(
              controller: _amountController,
              label: 'Amount (₱)',
              hint: '0.00',
              prefixIcon: Icons.payments_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final val = double.tryParse(v);
                if (val == null || val <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.md),

            // Note (Optional)
            AppTextField(
              controller: _noteController,
              label: 'Note / Purpose (Optional)',
              hint: 'e.g. Payment for dinner',
              prefixIcon: Icons.notes_outlined,
            ),
            const SizedBox(height: AppConstants.md),

            // Save as Beneficiary Checkbox (if not picked from saved)
            if (transferState.selectedBeneficiary == null)
              SwitchListTile(
                value: _saveAsBeneficiary,
                contentPadding: EdgeInsets.zero,
                activeColor: theme.colorScheme.primary,
                title: const Text('Save to my beneficiaries'),
                subtitle: const Text(
                  'Quick access for future transfers',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onChanged: (val) => setState(() => _saveAsBeneficiary = val),
              ),

            const SizedBox(height: AppConstants.xl),

            // Continue Button
            AppButton(
              text: 'Continue to Review',
              onPressed: _submit,
            ),
            const SizedBox(height: AppConstants.xl),
          ],
        ),
      ),
    );
  }
}
