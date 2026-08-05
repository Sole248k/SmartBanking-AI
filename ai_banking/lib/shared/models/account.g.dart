// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountNumber: json['accountNumber'] as String,
      cardNumber: json['cardNumber'] as String? ?? '0000 0000 0000 0000',
      cvv: json['cvv'] as String? ?? '000',
      expiryDate: json['expiryDate'] as String? ?? '01/25',
      holderName: json['holderName'] as String? ?? 'SmartBank User',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PHP',
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      label: json['label'] as String,
      status: $enumDecodeNullable(_$AccountStatusEnumMap, json['status']) ??
          AccountStatus.active,
      cardNetwork:
          $enumDecodeNullable(_$CardNetworkEnumMap, json['cardNetwork']) ??
              CardNetwork.visa,
      cardGradientColors: (json['cardGradientColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['#0A84FF', '#5E5CE6'],
      isDefault: json['isDefault'] as bool? ?? false,
      nickname: json['nickname'] as String?,
      bankName: json['bankName'] as String? ?? 'SmartBank',
      linkedAt: json['linkedAt'] as String?,
      billingAddress: json['billingAddress'] as String?,
      isExternal: json['isExternal'] as bool? ?? false,
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'accountNumber': instance.accountNumber,
      'cardNumber': instance.cardNumber,
      'cvv': instance.cvv,
      'expiryDate': instance.expiryDate,
      'holderName': instance.holderName,
      'balance': instance.balance,
      'availableBalance': instance.availableBalance,
      'currency': instance.currency,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'label': instance.label,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'cardNetwork': _$CardNetworkEnumMap[instance.cardNetwork]!,
      'cardGradientColors': instance.cardGradientColors,
      'isDefault': instance.isDefault,
      'nickname': instance.nickname,
      'bankName': instance.bankName,
      'linkedAt': instance.linkedAt,
      'billingAddress': instance.billingAddress,
      'isExternal': instance.isExternal,
    };

const _$AccountTypeEnumMap = {
  AccountType.checking: 'checking',
  AccountType.savings: 'savings',
  AccountType.investment: 'investment',
  AccountType.credit: 'credit',
  AccountType.virtual: 'virtual',
  AccountType.prepaid: 'prepaid',
};

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.frozen: 'frozen',
  AccountStatus.closed: 'closed',
};

const _$CardNetworkEnumMap = {
  CardNetwork.visa: 'visa',
  CardNetwork.mastercard: 'mastercard',
  CardNetwork.amex: 'amex',
  CardNetwork.discover: 'discover',
  CardNetwork.discovery: 'discovery',
  CardNetwork.jcb: 'jcb',
  CardNetwork.unionpay: 'unionpay',
};
