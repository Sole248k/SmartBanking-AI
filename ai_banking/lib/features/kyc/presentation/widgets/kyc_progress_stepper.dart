import 'package:flutter/material.dart';

class KycProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const KycProgressStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= currentStep;
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          } else {
            final isActive = (index ~/ 2) < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isActive ? colorScheme.primary : colorScheme.surfaceVariant,
              ),
            );
          }
        }),
      ),
    );
  }
}
