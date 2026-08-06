import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../profile/providers/profile_providers.dart';

class NewAccountScreen extends ConsumerStatefulWidget {
  const NewAccountScreen({super.key, this.initialAccountType});

  final AccountType? initialAccountType;

  @override
  ConsumerState<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends ConsumerState<NewAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _depositController;
  late AccountType _selectedAccountType;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).value;
    _fullNameController = TextEditingController(text: profile?.fullName ?? '');
    _addressController = TextEditingController();
    _occupationController = TextEditingController();
    _depositController = TextEditingController(text: '1000');
    _selectedAccountType = widget.initialAccountType ?? AccountType.savings;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final depositAmount = double.tryParse(_depositController.text.trim()) ?? 0.0;
    if (depositAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Initial deposit amount must be greater than zero.')),
      );
      return;
    }

    final applicationData = {
      'fullName': _fullNameController.text.trim(),
      'address': _addressController.text.trim(),
      'occupation': _occupationController.text.trim(),
      'accountType': _selectedAccountType,
      'initialDeposit': depositAmount,
    };

    context.push('/products/review', extra: applicationData);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);

    final kycStatus = profileAsync.value?.kycStatus ?? 'Not Started';
    final isKycApproved = kycStatus == 'Approved';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open New Account'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KYC Warning Banner if not approved
              if (!isKycApproved) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.md),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: AppConstants.sm),
                          Expanded(
                            child: Text(
                              'KYC Approval Required',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.xs),
                      Text(
                        'KYC approval is required before creating a new account. Current status: $kycStatus.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.orange[900]),
                      ),
                      const SizedBox(height: AppConstants.md),
                      AppButton(
                        text: 'Complete KYC Verification',
                        icon: Icons.verified_user_rounded,
                        onPressed: () => context.push('/kyc'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.xl),
              ],

              // Section: Personal Information
              Text(
                'Personal Information',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full legal name',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Full name is required';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _addressController,
                label: 'Residential Address',
                hint: 'Enter complete home address',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Residential address is required';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _occupationController,
                label: 'Occupation / Work',
                hint: 'e.g. Software Engineer, Business Owner',
                prefixIcon: Icons.work_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Occupation is required';
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.xxl),

              // Section: Account Details
              Text(
                'Account Details',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.md),
              Text(
                'Select Account Type',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppConstants.xs),
              Row(
                children: [
                  Expanded(
                    child: _AccountTypeOption(
                      title: 'Savings',
                      subtitle: 'Interest Bearing',
                      icon: Icons.savings_rounded,
                      isSelected: _selectedAccountType == AccountType.savings,
                      onTap: () => setState(() => _selectedAccountType = AccountType.savings),
                    ),
                  ),
                  const SizedBox(width: AppConstants.md),
                  Expanded(
                    child: _AccountTypeOption(
                      title: 'Current',
                      subtitle: 'Checking Account',
                      icon: Icons.account_balance_rounded,
                      isSelected: _selectedAccountType == AccountType.checking,
                      onTap: () => setState(() => _selectedAccountType = AccountType.checking),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.lg),
              AppTextField(
                controller: _depositController,
                label: 'Initial Deposit Amount (PHP)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                prefixIcon: Icons.payments_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Initial deposit is required';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'Deposit must be greater than 0';
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.xxl),
              AppButton(
                text: 'Review Application',
                icon: Icons.arrow_forward_rounded,
                onPressed: isKycApproved ? _submitForm : null,
              ),
              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.md),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.xs),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
