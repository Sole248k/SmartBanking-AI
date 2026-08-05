import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/qr_repository_impl.dart';
import '../repositories/qr_repository.dart';

part 'qr_providers.g.dart';

@riverpod
QrRepository qrRepository(QrRepositoryRef ref) {
  return QrRepositoryImpl();
}
