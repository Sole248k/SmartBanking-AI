import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/account.dart';
import 'dashboard_providers.dart';

part 'active_account_provider.g.dart';

@riverpod
class ActiveAccount extends _$ActiveAccount {
  String? _selectedAccountId;

  @override
  Account? build() {
    final accounts = ref.watch(dashboardAccountsProvider).value ?? [];
    if (accounts.isEmpty) return null;

    if (_selectedAccountId != null) {
      final existing = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
      if (existing != null) return existing;
    }

    final defaultAccount = accounts.where((a) => a.isDefault).firstOrNull ?? accounts.first;
    _selectedAccountId = defaultAccount.id;
    return defaultAccount;
  }

  void select(Account account) {
    _selectedAccountId = account.id;
    state = account;
  }
}
