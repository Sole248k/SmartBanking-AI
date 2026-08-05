import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

enum AccountType { checking, savings, investment, credit, virtual }
enum CardNetwork { visa, mastercard, amex, discovery }
enum AccountStatus { active, frozen, closed }

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String userId,
    required String accountNumber,
    @Default('0000 0000 0000 0000') String cardNumber,
    @Default('000') String cvv,
    @Default('01/25') String expiryDate,
    @Default('SmartBank User') String holderName,
    @Default(0.0) double balance,
    @Default(0.0) double availableBalance,
    @Default('PHP') String currency,
    required AccountType type,
    required String label,
    @Default(AccountStatus.active) AccountStatus status,
    @Default(CardNetwork.visa) CardNetwork cardNetwork,
    @Default(['#0A84FF', '#5E5CE6']) List<String> cardGradientColors,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}
