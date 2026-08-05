import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../models/qr_data.dart';
import '../providers/qr_providers.dart';

class MyQrScreen extends ConsumerWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileControllerProvider);
    final accountsAsync = ref.watch(dashboardAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile.id.isEmpty) {
            return const Center(child: Text('Please log in to view your QR code.'));
          }
          return accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return const Center(child: Text('No accounts found to generate QR'));
              }
              
              final primaryAccount = accounts.first;
              final qrData = QrData(
                recipientId: profile.id,
                recipientName: profile.fullName,
                accountNumber: primaryAccount.accountNumber,
              );
              
              final payload = ref.read(qrRepositoryProvider).generateQrPayload(qrData);

              return Padding(
                padding: AppConstants.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(AppConstants.xl),
                      child: Column(
                        children: [
                          AppAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, size: 64),
                          const SizedBox(height: AppConstants.md),
                          Text(
                            profile.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Scan to pay me',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: AppConstants.xl),
                          QrImageView(
                            data: payload,
                            version: QrVersions.auto,
                            size: 200.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.xxl),
                    const Text(
                      'Your unique QR code for receiving payments directly into your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
