import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionStatus { completed, pending, failed }
enum TransactionType { debit, credit }

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @Default('') String userId,
    @Default('') String accountId,
    required String title,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    required TransactionStatus status,
    required TransactionType type,
    String? merchantLogoUrl,
    String? location,
    String? iconUrl,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
