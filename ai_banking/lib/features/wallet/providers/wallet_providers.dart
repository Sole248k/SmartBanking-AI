import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/failure.dart';
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

  Future<Either<Failure, Wallet>> topUp(double amount, String fromAccountId) async {
    return await ref.read(walletRepositoryProvider).topUp(amount, fromAccountId);
  }
}
