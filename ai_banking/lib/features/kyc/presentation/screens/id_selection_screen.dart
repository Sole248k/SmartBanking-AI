import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/kyc_record.dart';
import '../../providers/kyc_provider.dart';
import '../widgets/kyc_progress_stepper.dart';

class IdSelectionScreen extends ConsumerStatefulWidget {
  const IdSelectionScreen({super.key});

  @override
  ConsumerState<IdSelectionScreen> createState() => _IdSelectionScreenState();
}

class _IdSelectionScreenState extends ConsumerState<IdSelectionScreen> {
  IdType? _selectedType;

  final _idTypes = [
    {'type': IdType.passport, 'label': 'Passport', 'icon': LucideIcons.globe},
    {'type': IdType.driversLicense, 'label': 'Driver\'s License', 'icon': LucideIcons.car},
    {'type': IdType.philsys, 'label': 'PhilSys ID', 'icon': LucideIcons.contact},
    {'type': IdType.umid, 'label': 'UMID', 'icon': LucideIcons.contact},
    {'type': IdType.nationalId, 'label': 'National ID', 'icon': LucideIcons.contact},
    {'type': IdType.votersId, 'label': 'Voter\'s ID', 'icon': LucideIcons.vote},
    {'type': IdType.postalId, 'label': 'Postal ID', 'icon': LucideIcons.mail},
    {'type': IdType.prcId, 'label': 'PRC ID', 'icon': LucideIcons.badgeCheck},
  ];

  void _next() {
    if (_selectedType == null) return;
    
    final current = ref.read(kycControllerProvider).record;
    ref.read(kycControllerProvider.notifier).updateRecord(current.copyWith(idType: _selectedType));
    ref.read(kycControllerProvider.notifier).setStep(KycStep.idCaptureFront);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select ID Type'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => ref.read(kycControllerProvider.notifier).setStep(KycStep.personalInfo),
        ),
      ),
      body: Column(
        children: [
          const KycProgressStepper(currentStep: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'What document are you using?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select one of the following government-issued IDs.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                ..._idTypes.map((item) {
                  final type = item['type'] as IdType;
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withOpacity(0.1)
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item['label'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? colorScheme.primary : null,
                                  ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(LucideIcons.circleCheck, color: colorScheme.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _selectedType == null ? null : _next,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
