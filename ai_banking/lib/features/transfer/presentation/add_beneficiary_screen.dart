import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/beneficiary.dart';
import '../providers/transfer_providers.dart';

class AddBeneficiaryScreen extends ConsumerStatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  ConsumerState<AddBeneficiaryScreen> createState() =>
      _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends ConsumerState<AddBeneficiaryScreen> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _bankController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Beneficiary')),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter recipient name',
                prefixIcon: Icons.person_outline,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _accountController,
                label: 'Account Number',
                hint: '010-XXXX-XXXX',
                prefixIcon: Icons.numbers_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _bankController,
                label: 'Bank Name',
                hint: 'e.g. SmartBank',
                prefixIcon: Icons.account_balance_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppConstants.xl),
              AppButton(
                text: 'Save Beneficiary',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final beneficiary = Beneficiary(
        id: const Uuid().v4(),
        userId: uid,
        name: _nameController.text.trim(),
        accountNumber: _accountController.text.trim(),
        bankName: _bankController.text.trim(),
      );

      final result =
          await ref.read(transferRepositoryProvider).addBeneficiary(beneficiary);

      if (mounted) {
        setState(() => _isLoading = false);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Beneficiary added successfully')),
            );
            context.pop();
          },
        );
      }
    }
  }
}
