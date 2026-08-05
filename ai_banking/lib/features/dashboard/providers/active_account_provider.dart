import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/account.dart';
import 'dashboard_providers.dart';

part 'active_account_provider.g.dart';

@riverpod
class ActiveAccount extends _$ActiveAccount {
  @override
  Account? build() {
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    return accountsAsync.maybeWhen(
      data: (accounts) => accounts.isNotEmpty ? accounts.first : null,
      orElse: () => null,
    );
  }

  void select(Account account) {
    state = account;
  }
}
