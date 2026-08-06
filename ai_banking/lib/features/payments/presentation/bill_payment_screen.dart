// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/profile/providers/profile_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/bill_biller.dart';
import '../providers/bill_payment_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root screen — delegates to the correct step widget
// ─────────────────────────────────────────────────────────────────────────────

class BillPaymentScreen extends ConsumerWidget {
  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billPaymentNotifierProvider);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);

    return PopScope(
      canPop: state.step == BillPaymentStep.selectBiller ||
          state.step == BillPaymentStep.success ||
          state.step == BillPaymentStep.failure,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          notifier.reset();
          return;
        }
        switch (state.step) {
          case BillPaymentStep.enterDetails:
            notifier.backToSelectBiller();
          case BillPaymentStep.review:
            notifier.backToEnterDetails();
          default:
            break;
        }
      },
      child: AnimatedSwitcher(
        duration: AppConstants.medium,
        child: _buildStep(context, state, notifier),
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, BillPaymentState s, BillPaymentNotifier n) {
    switch (s.step) {
      case BillPaymentStep.selectBiller:
        return _BillerSelectScreen(key: const ValueKey('select'));
      case BillPaymentStep.enterDetails:
        return _BillFormScreen(key: const ValueKey('form'));
      case BillPaymentStep.review:
        return _BillReviewScreen(key: const ValueKey('review'));
      case BillPaymentStep.processing:
        return _ProcessingOverlay(key: const ValueKey('processing'));
      case BillPaymentStep.success:
        return _BillSuccessScreen(key: const ValueKey('success'));
      case BillPaymentStep.failure:
        return _BillFailureScreen(key: const ValueKey('failure'));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Biller selection (categories + grid)
// ─────────────────────────────────────────────────────────────────────────────

class _BillerSelectScreen extends ConsumerStatefulWidget {
  const _BillerSelectScreen({super.key});

  @override
  ConsumerState<_BillerSelectScreen> createState() =>
      _BillerSelectScreenState();
}

class _BillerSelectScreenState extends ConsumerState<_BillerSelectScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);
    final state = ref.watch(billPaymentNotifierProvider);
    final billers = notifier.filteredBillers;
    final featured = notifier.featuredBillers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bills'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _SearchField(
                    controller: _searchCtrl,
                    onChanged: notifier.setSearchQuery,
                    hint: 'Search biller…',
                  ),
                  const SizedBox(height: AppConstants.xl),

                  // Category chips
                  Text('Categories',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.md),
                ],
              ),
            ),
          ),
          // Category grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppConstants.md,
                crossAxisSpacing: AppConstants.md,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate(
                BillCategory.values.map((cat) {
                  final selected = state.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      if (selected) {
                        notifier.clearCategory();
                      } else {
                        notifier.selectCategory(cat);
                      }
                    },
                    child: _CategoryTile(
                        category: cat, isSelected: selected),
                  );
                }).toList(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.lg, AppConstants.xl, AppConstants.lg, 0),
              child: Text(
                state.selectedCategory != null
                    ? state.selectedCategory!.label
                    : state.searchQuery.isNotEmpty
                        ? 'Search Results'
                        : 'Featured Billers',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Biller list
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                (state.searchQuery.isNotEmpty ||
                        state.selectedCategory != null
                    ? billers
                    : featured)
                    .map((b) => _BillerTile(
                          biller: b,
                          onTap: () => notifier.selectBiller(b),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppConstants.xxl)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Enter bill details
// ─────────────────────────────────────────────────────────────────────────────

class _BillFormScreen extends ConsumerStatefulWidget {
  const _BillFormScreen({super.key});

  @override
  ConsumerState<_BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<_BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final s = ref.read(billPaymentNotifierProvider);
    _accountCtrl.text = s.accountNumber;
    if (s.amount > 0) _amountCtrl.text = s.amount.toStringAsFixed(2);
    _noteCtrl.text = s.note;
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    final notifier = ref.read(billPaymentNotifierProvider.notifier);
    if (_selectedAccountId != null) {
      notifier.setFromAccount(_selectedAccountId!);
    }
    notifier.setAccountNumber(_accountCtrl.text);
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    notifier.setAmount(amt);
    notifier.setNote(_noteCtrl.text.trim());

    if (!_formKey.currentState!.validate()) return;
    final err = notifier.validateAndReview();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(billPaymentNotifierProvider);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);
    final biller = state.selectedBiller!;
    final amountFixed = biller.fixedAmount != null;
    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final accounts = accountsAsync.value ?? [];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => notifier.setFromAccount(_selectedAccountId!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(biller.name),
        leading: BackButton(onPressed: notifier.backToSelectBiller),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biller identity card
              _BillerHeaderCard(biller: biller),
              const SizedBox(height: AppConstants.xl),

              // Source account
              Text('Pay From',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: AppConstants.sm),
              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, e) => Text('Failed to load accounts.',
                    style: TextStyle(color: theme.colorScheme.error)),
                data: (accs) {
                  if (accs.isEmpty) {
                    return Text('No accounts available.',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5)));
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    items: accs.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text(
                          '${acc.label}  ·  ₱${acc.balance.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedAccountId = v);
                        notifier.setFromAccount(v);
                      }
                    },
                    validator: (_) => _selectedAccountId == null
                        ? 'Please select a source account'
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppConstants.lg),

              // Account / Reference number field
              Text(biller.accountLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: AppConstants.sm),
              TextFormField(
                controller: _accountCtrl,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: biller.accountHint,
                  prefixIcon: const Icon(Icons.tag_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.md, vertical: AppConstants.md),
                ),
                onChanged: notifier.setAccountNumber,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '${biller.accountLabel} is required';
                  }
                  if (!RegExp(biller.accountPattern).hasMatch(v.trim())) {
                    return 'Invalid ${biller.accountLabel} format (e.g. ${biller.accountHint})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.lg),

              // Amount field
              Text('Amount',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: AppConstants.sm),
              if (amountFixed)
                _ReadOnlyAmountCard(amount: biller.fixedAmount!)
              else
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '₱ ',
                    prefixStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    helperText:
                        'Min ₱${biller.minAmount.toStringAsFixed(0)}  –  Max ₱${biller.maxAmount.toStringAsFixed(0)}',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.md, vertical: AppConstants.md),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount is required';
                    final amt = double.tryParse(v.trim());
                    if (amt == null || amt <= 0) return 'Enter a valid amount';
                    if (amt < biller.minAmount) {
                      return 'Minimum is ₱${biller.minAmount.toStringAsFixed(0)}';
                    }
                    if (amt > biller.maxAmount) {
                      return 'Maximum is ₱${biller.maxAmount.toStringAsFixed(0)}';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: AppConstants.lg),

              // Processing fee notice
              if (biller.processingFee > 0)
                Container(
                  padding: const EdgeInsets.all(AppConstants.sm),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.amber, size: 16),
                      const SizedBox(width: AppConstants.sm),
                      Expanded(
                        child: Text(
                          'A convenience fee of ₱${biller.processingFee.toStringAsFixed(2)} applies to this payment.',
                          style: const TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              if (biller.processingFee > 0) const SizedBox(height: AppConstants.lg),

              // Optional note
              Text('Remarks (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: AppConstants.sm),
              TextFormField(
                controller: _noteCtrl,
                maxLength: 80,
                decoration: InputDecoration(
                  hintText: 'e.g. Payment for November',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.md, vertical: AppConstants.md),
                ),
                onChanged: notifier.setNote,
              ),
              const SizedBox(height: AppConstants.xxl),

              AppButton(text: 'Continue to Review', onPressed: _proceed),
              const SizedBox(height: AppConstants.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Review
// ─────────────────────────────────────────────────────────────────────────────

class _BillReviewScreen extends ConsumerWidget {
  const _BillReviewScreen({super.key});

  void _showPinModal(BuildContext context, WidgetRef ref) {
    String enteredPin = '';
    String? pinError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final profile = ref.read(profileControllerProvider).value;

          void onKey(String digit) {
            if (enteredPin.length >= 6) return;
            setModal(() {
              pinError = null;
              enteredPin += digit;
            });
            if (enteredPin.length == 6) {
              if (profile != null &&
                  PinUtils.verifyPin(enteredPin, profile.pinHash)) {
                Navigator.pop(ctx);
                ref.read(billPaymentNotifierProvider.notifier).confirmPayment();
              } else {
                setModal(() {
                  enteredPin = '';
                  pinError = 'Incorrect PIN. Please try again.';
                });
              }
            }
          }

          void onBack() {
            if (enteredPin.isNotEmpty) {
              setModal(() {
                pinError = null;
                enteredPin = enteredPin.substring(0, enteredPin.length - 1);
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security_rounded,
                    color: AppTheme.primaryColor, size: 36),
                const SizedBox(height: 12),
                const Text('Confirm Security PIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Enter your 6-digit PIN to authorise this payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < enteredPin.length
                            ? AppTheme.primaryColor
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 12),
                  Text(pinError!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                for (final row in [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row.map((d) => _PinKey(d, () => onKey(d))).toList(),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60, height: 60),
                    _PinKey('0', () => onKey('0')),
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(30),
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.backspace_outlined, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(billPaymentNotifierProvider);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);
    final biller = state.selectedBiller!;
    final profile = ref.watch(profileControllerProvider).value;
    final hasPin = profile?.pinHash?.isNotEmpty == true;

    final accountsAsync = ref.watch(dashboardAccountsProvider);
    final fromLabel = accountsAsync.when(
      data: (accs) {
        final match = accs.where((a) => a.id == state.fromAccountId).toList();
        if (match.isEmpty && accs.isNotEmpty) return accs.first.label;
        return match.isNotEmpty ? match.first.label : 'Unknown';
      },
      loading: () => '...',
      error: (_, e) => 'Error',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Payment'),
        leading: BackButton(onPressed: notifier.backToEnterDetails),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please confirm the payment details below.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: AppConstants.lg),

            // Summary card
            AppCard(
              child: Column(
                children: [
                  _ReviewRow(
                    icon: biller.icon,
                    iconColor: biller.color,
                    label: 'Biller',
                    value: biller.name,
                  ),
                  _Divider(),
                  _ReviewRow(
                    icon: Icons.tag_rounded,
                    iconColor: theme.colorScheme.primary,
                    label: biller.accountLabel,
                    value: state.accountNumber.trim(),
                  ),
                  _Divider(),
                  _ReviewRow(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: theme.colorScheme.primary,
                    label: 'Pay From',
                    value: fromLabel,
                  ),
                  _Divider(),
                  _ReviewRow(
                    icon: Icons.payments_outlined,
                    iconColor: Colors.green,
                    label: 'Amount',
                    value: CurrencyFormatter.format(state.amount),
                    valueStyle: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  if (biller.processingFee > 0) ...[
                    _Divider(),
                    _ReviewRow(
                      icon: Icons.receipt_outlined,
                      iconColor: Colors.amber,
                      label: 'Convenience Fee',
                      value: CurrencyFormatter.format(biller.processingFee),
                    ),
                  ],
                  _Divider(),
                  _ReviewRow(
                    icon: Icons.price_check_rounded,
                    iconColor: theme.colorScheme.primary,
                    label: 'Total Charged',
                    value: CurrencyFormatter.format(state.totalCharge),
                    valueStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
                  if (state.note.isNotEmpty) ...[
                    _Divider(),
                    _ReviewRow(
                      icon: Icons.notes_outlined,
                      iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      label: 'Remarks',
                      value: state.note,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.xxl),

            AppButton(
              text: 'Confirm Payment',
              onPressed: () {
                if (hasPin) {
                  _showPinModal(context, ref);
                } else {
                  notifier.confirmPayment();
                }
              },
            ),
            const SizedBox(height: AppConstants.md),
            AppButton(
              text: 'Go Back',
              variant: AppButtonVariant.outline,
              onPressed: notifier.backToEnterDetails,
            ),
            const SizedBox(height: AppConstants.xl),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Processing overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppConstants.lg),
            Text('Processing Payment…',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppConstants.sm),
            Text('Please do not close this screen.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 5 — Success receipt
// ─────────────────────────────────────────────────────────────────────────────

class _BillSuccessScreen extends ConsumerWidget {
  const _BillSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(billPaymentNotifierProvider);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);
    final biller = state.selectedBiller!;
    final paidAt = state.paidAt ?? DateTime.now();
    final fmt = DateFormat('MMM d, yyyy  hh:mm a');

    return Scaffold(
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppConstants.xxl),

            // Success icon
            Container(
              padding: const EdgeInsets.all(AppConstants.xl),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 80),
            ),
            const SizedBox(height: AppConstants.xl),

            Text('Payment Successful!',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.sm),
            Text(
              'Your bill payment has been processed.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.xxl),

            // Receipt card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.sm),
                        decoration: BoxDecoration(
                          color: biller.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(biller.icon, color: biller.color, size: 24),
                      ),
                      const SizedBox(width: AppConstants.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(biller.name,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(biller.category.label,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Chip(
                        label: const Text('PAID',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.green),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const Divider(height: AppConstants.xl),
                  _ReceiptRow(label: biller.accountLabel, value: state.accountNumber),
                  _ReceiptRow(
                      label: 'Amount Paid',
                      value: CurrencyFormatter.format(state.amount),
                      highlight: true),
                  if (biller.processingFee > 0)
                    _ReceiptRow(
                        label: 'Convenience Fee',
                        value: CurrencyFormatter.format(biller.processingFee)),
                  _ReceiptRow(
                      label: 'Total Deducted',
                      value: CurrencyFormatter.format(state.totalCharge),
                      bold: true),
                  if (state.note.isNotEmpty)
                    _ReceiptRow(label: 'Remarks', value: state.note),
                  _ReceiptRow(
                      label: 'Reference No.',
                      value: state.referenceNumber ?? '—',
                      mono: true),
                  _ReceiptRow(
                      label: 'Date & Time', value: fmt.format(paidAt)),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.xxl),

            AppButton(
              text: 'Pay Another Bill',
              onPressed: notifier.reset,
            ),
            const SizedBox(height: AppConstants.md),
            AppButton(
              text: 'Back to Dashboard',
              variant: AppButtonVariant.outline,
              onPressed: () {
                notifier.reset();
                context.go('/');
              },
            ),
            const SizedBox(height: AppConstants.xl),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 6 — Failure screen
// ─────────────────────────────────────────────────────────────────────────────

class _BillFailureScreen extends ConsumerWidget {
  const _BillFailureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(billPaymentNotifierProvider);
    final notifier = ref.read(billPaymentNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_rounded,
                  color: theme.colorScheme.error, size: 80),
            ),
            const SizedBox(height: AppConstants.xl),
            Text('Payment Failed',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.md),
            Text(
              state.errorMessage ?? 'Something went wrong. Please try again.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.xxl),
            AppButton(
                text: 'Try Again', onPressed: notifier.backToEnterDetails),
            const SizedBox(height: AppConstants.md),
            AppButton(
              text: 'Cancel',
              variant: AppButtonVariant.outline,
              onPressed: () {
                notifier.reset();
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Search bar used on the biller selection screen
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.hint,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMax),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

/// Category icon tile with selection highlight
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.isSelected});

  final BillCategory category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return AnimatedContainer(
      duration: AppConstants.fast,
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.18)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? color : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Single biller list tile
class _BillerTile extends StatelessWidget {
  const _BillerTile({required this.biller, required this.onTap});

  final BillBiller biller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sm),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: biller.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(biller.icon, color: biller.color, size: 22),
                ),
                const SizedBox(width: AppConstants.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(biller.name,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(biller.description,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Biller identity banner at the top of the form screen
class _BillerHeaderCard extends StatelessWidget {
  const _BillerHeaderCard({required this.biller});

  final BillBiller biller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.md),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: biller.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(biller.icon, color: biller.color, size: 26),
          ),
          const SizedBox(width: AppConstants.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(biller.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(biller.description,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: biller.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                  ),
                  child: Text(biller.category.label,
                      style: TextStyle(
                          fontSize: 10,
                          color: biller.color,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only amount display for fixed-amount billers
class _ReadOnlyAmountCard extends StatelessWidget {
  const _ReadOnlyAmountCard({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.md, vertical: AppConstants.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Fixed Amount', style: TextStyle(color: Colors.grey)),
          Text(
            CurrencyFormatter.format(amount),
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

/// Review screen — labelled row
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.xs),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: AppConstants.sm),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          Flexible(
            child: Text(
              value,
              style: valueStyle ??
                  theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin divider used in the review card
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.xs),
        child: Divider(height: 1),
      );
}

/// Receipt row used in the success screen
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.bold = false,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool bold;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = highlight ? Colors.green : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: bold || highlight ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
                fontFamily: mono ? 'monospace' : null,
                fontSize: theme.textTheme.bodyMedium?.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PIN keypad button
class _PinKey extends StatelessWidget {
  const _PinKey(this.digit, this.onTap);
  final String digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(digit,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
