import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/theme/bank_card_theme.dart';
import '../../../core/utils/card_utils.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _billingAddressController = TextEditingController();

  CardNetwork _detectedNetwork = CardNetwork.visa;
  AccountType _selectedType = AccountType.savings;
  String _selectedBank = 'EastWest Bank';
  bool _isLoading = false;

  static const List<String> _bankOptions = [
    'EastWest Bank',
    'BDO Unibank',
    'BPI',
    'Metrobank',
    'LandBank',
    'PNB',
    'UnionBank',
    'Security Bank',
    'RCBC',
    'Chinabank',
    'Maya Bank',
    'GoTyme Bank',
    'CIMB Bank',
    'Tonik Bank',
    'UNO Digital Bank',
    'SmartBank AI',
    'Other Bank',
  ];

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_onCardNumberChanged);
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nicknameController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final text = _cardNumberController.text;
    final network = CardUtils.detectCardNetwork(text);
    if (network != _detectedNetwork) {
      setState(() => _detectedNetwork = network);
    }
  }

  Future<void> _submitCard() async {
    if (!_formKey.currentState!.validate()) return;

    final rawNumber = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');

    // Luhn check
    if (!CardUtils.validateLuhn(rawNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid card number. Please check for typos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bankStyle = BankCardTheme.getBankStyle(_selectedBank);
    final hexColors = bankStyle.gradientColors.map((c) {
      return '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
    }).toList();
    final nickname = _nicknameController.text.trim();
    final label = nickname.isNotEmpty ? nickname : '$_selectedBank Card';

    final newCard = Account(
      id: '',
      userId: '',
      accountNumber: '****${rawNumber.substring(rawNumber.length - 4)}',
      cardNumber: CardUtils.formatCardNumber(rawNumber, _detectedNetwork),
      cvv: _cvvController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      holderName: _holderNameController.text.trim().toUpperCase(),
      balance: 0.0,
      availableBalance: 0.0,
      currency: 'PHP',
      type: _selectedType,
      label: label,
      status: AccountStatus.active,
      cardNetwork: _detectedNetwork,
      cardGradientColors: hexColors,
      bankName: _selectedBank,
      nickname: nickname.isEmpty ? null : nickname,
      billingAddress: _billingAddressController.text.trim().isEmpty
          ? null
          : _billingAddressController.text.trim(),
      isExternal: true,
    );

    final result = await ref.read(transactionRepositoryProvider).addExternalCard(newCard);

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (createdAccount) {
        ref.invalidate(dashboardAccountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bankStyle = BankCardTheme.getBankStyle(_selectedBank);
    final gradients = bankStyle.gradientColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Card'),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dynamic Live Card Preview ────────────────────────────
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradients,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: gradients.first.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedBank,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            CardUtils.getNetworkName(_detectedNetwork),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _cardNumberController.text.isEmpty
                          ? '•••• •••• •••• ••••'
                          : CardUtils.formatCardNumber(
                              _cardNumberController.text, _detectedNetwork),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppConstants.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _holderNameController.text.isEmpty
                              ? 'CARDHOLDER NAME'
                              : _holderNameController.text.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _expiryController.text.isEmpty
                              ? 'MM/YY'
                              : _expiryController.text,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.xl),

              // ── Form Inputs ──────────────────────────────────────────
              Text(
                'Card Information',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.md),

              // Issuing Bank Selector
              DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: InputDecoration(
                  labelText: 'Issuing Bank / Provider',
                  prefixIcon: const Icon(Icons.account_balance_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                items: _bankOptions.map((bank) {
                  return DropdownMenuItem(value: bank, child: Text(bank));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
              const SizedBox(height: AppConstants.md),

              // Card Number Input
              AppTextField(
                controller: _cardNumberController,
                label: 'Card Number',
                hint: '0000 0000 0000 0000',
                prefixIcon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(_detectedNetwork),
                ],
                validator: (v) {
                  if (v == null || v.replaceAll(' ', '').isEmpty) {
                    return 'Card number is required';
                  }
                  final clean = v.replaceAll(' ', '');
                  if (clean.length < 13) return 'Card number is too short';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.md),

              // Cardholder Name
              AppTextField(
                controller: _holderNameController,
                label: 'Cardholder Name',
                hint: 'e.g. JOHN DOE',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppConstants.md),

              // Expiry & CVV Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _expiryController,
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      prefixIcon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Expiry required';
                        if (!CardUtils.validateExpiry(v)) {
                          return 'Invalid/Expired';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppConstants.md),
                  Expanded(
                    child: AppTextField(
                      controller: _cvvController,
                      label: 'CVV / CVC',
                      hint: _detectedNetwork == CardNetwork.amex ? '1234' : '123',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          _detectedNetwork == CardNetwork.amex ? 4 : 3,
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'CVV required';
                        if (!CardUtils.validateCVV(v, _detectedNetwork)) {
                          return _detectedNetwork == CardNetwork.amex
                              ? '4 digits'
                              : '3 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.md),

              // Card Type Selector
              DropdownButtonFormField<AccountType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Card Type',
                  prefixIcon: const Icon(Icons.style_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: AccountType.savings, child: Text('Debit / Savings Card')),
                  DropdownMenuItem(
                      value: AccountType.checking, child: Text('Checking Card')),
                  DropdownMenuItem(
                      value: AccountType.credit, child: Text('Credit Card')),
                  DropdownMenuItem(
                      value: AccountType.prepaid, child: Text('Prepaid Card')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: AppConstants.md),

              // Card Nickname (Optional)
              AppTextField(
                controller: _nicknameController,
                label: 'Card Nickname (Optional)',
                hint: 'e.g. Shopping Card',
                prefixIcon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: AppConstants.md),

              // Billing Address (Optional)
              AppTextField(
                controller: _billingAddressController,
                label: 'Billing Address (Optional)',
                hint: 'Street, City, Postal Code',
                prefixIcon: Icons.location_on_outlined,
              ),

              const SizedBox(height: AppConstants.xl),

              // Submit Button
              AppButton(
                text: 'Link Card',
                isLoading: _isLoading,
                onPressed: _submitCard,
              ),
              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formatter for Card Number input spaces
class _CardNumberFormatter extends TextInputFormatter {
  _CardNumberFormatter(this.network);
  final CardNetwork network;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = CardUtils.formatCardNumber(newValue.text, network);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Expiry Date (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) return newValue;

    String formatted = text;
    if (text.length >= 2) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
