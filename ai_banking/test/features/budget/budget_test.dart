import 'package:flutter_test/flutter_test.dart';
import 'package:ai_banking/features/budget/models/budget.dart';

void main() {
  group('Budget Model', () {
    test('should calculate progress correctly', () {
      const budget = Budget(
        id: '1',
        category: 'Food',
        limitAmount: 1000,
        spentAmount: 500, userId: '',
      );

      final progress = budget.spentAmount / budget.limitAmount;
      expect(progress, 0.5);
    });

    test('should identify over budget correctly', () {
      const budget = Budget(
        id: '1',
        category: 'Food',
        limitAmount: 1000,
        spentAmount: 1200, userId: '',
      );

      expect(budget.spentAmount > budget.limitAmount, true);
    });
  });
}
