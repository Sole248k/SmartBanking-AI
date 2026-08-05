import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/firestore_wallet_repository_impl.dart';
import '../models/wallet.dart';
import '../repositories/wallet_repository.dart';

part 'wallet_providers.g.dart';

@riverpod
WalletRepository walletRepository(WalletRepositoryRef ref) {
  return FirestoreWalletRepositoryImpl();
}

@riverpod
class WalletController extends _$WalletController {
  @override
  Stream<Wallet> build() {
    return ref.watch(walletRepositoryProvider).watchWallet();
  }

  Future<void> topUp(double amount, String fromAccountId) async {
    // Top up logic remains the same as it uses the repository
    await ref.read(walletRepositoryProvider).topUp(amount, fromAccountId);
  }
}
