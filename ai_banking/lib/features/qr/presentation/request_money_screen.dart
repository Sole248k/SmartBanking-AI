import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/qr_data.dart';
import '../providers/qr_providers.dart';

class RequestMoneyScreen extends ConsumerStatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  ConsumerState<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends ConsumerState<RequestMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  QrData? _generatedData;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).value;
    final accounts = ref.watch(dashboardAccountsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Money'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            if (_generatedData == null) ...[
              const Text(
                'Enter the amount you would like to receive. We will generate a QR code for others to scan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppConstants.xl),
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money_rounded,
              ),
              const SizedBox(height: AppConstants.md),
              AppTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'e.g. Lunch split',
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: AppConstants.xl),
              AppButton(
                text: 'Generate QR Code',
                onPressed: () {
                  if (profile != null && profile.id.isNotEmpty && accounts != null && accounts.isNotEmpty) {
                    setState(() {
                      _generatedData = QrData(
                        recipientId: profile.id,
                        recipientName: profile.fullName,
                        accountNumber: accounts.first.accountNumber,
                        amount: double.tryParse(_amountController.text),
                        note: _noteController.text.trim(),
                      );
                    });
                  }
                },
              ),
            ] else ...[
              AppCard(
                padding: const EdgeInsets.all(AppConstants.xl),
                child: Column(
                  children: [
                    Text(
                      'Requesting ${CurrencyFormatter.format(_generatedData!.amount ?? 0.0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_generatedData!.note != null && _generatedData!.note!.isNotEmpty)
                      Text('"${_generatedData!.note}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: AppConstants.xl),
                    QrImageView(
                      data: ref.read(qrRepositoryProvider).generateQrPayload(_generatedData!),
                      version: QrVersions.auto,
                      size: 240.0,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.xl),
                    const Text('Show this QR to the sender', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.xl),
              AppButton(
                text: 'Create New Request',
                variant: AppButtonVariant.outline,
                onPressed: () => setState(() => _generatedData = null),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
