import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/theme/bank_card_theme.dart';
import '../../../core/utils/card_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pin_utils.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../dashboard/widgets/transaction_item.dart';
import '../../profile/providers/profile_providers.dart';
import '../../../shared/providers/session_lock_provider.dart';

class CardDetailsScreen extends ConsumerStatefulWidget {
  const CardDetailsScreen({super.key, required this.account});
  final Account account;

  @override
  ConsumerState<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isFront = true;
  bool _isAuthenticated = false;
  Timer? _securityTimer;
  late Account _currentAccount;

  @override
  void initState() {
    super.initState();
    _currentAccount = widget.account;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _securityTimer?.cancel();
    _flipController.dispose();
    // Clear card session when leaving card details screen
    ref.read(cardAuthSessionControllerProvider.notifier).clearSession();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _onToggleDetails() {
    final session = ref.read(cardAuthSessionControllerProvider);
    final isAuthed = session.isCardAuthenticated(_currentAccount.id);

    if (_isAuthenticated) {
      _securityTimer?.cancel();
      setState(() => _isAuthenticated = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sensitive details hidden.')),
      );
    } else if (isAuthed) {
      // Authenticated within 60s grace period for THIS SPECIFIC card!
      _grantAuthentication('Authenticated via Active Card Session!');
    } else {
      _authenticateUser();
    }
  }

  Future<void> _authenticateUser() async {
    // 1. Try Biometrics on supported mobile devices
    final result = await ref
        .read(authRepositoryProvider)
        .authenticateWithBiometrics();

    final bool bioSuccess = result.match((_) => false, (success) => success);

    if (bioSuccess) {
      _grantAuthentication('Authenticated via Biometrics!');
    } else {
      // 2. Fallback cleanly to Security PIN verification modal
      if (mounted) {
        _showPinModal();
      }
    }
  }

  void _grantAuthentication(String message) {
    // Grant 60s grace period for this specific card
    ref
        .read(cardAuthSessionControllerProvider.notifier)
        .authenticateCard(_currentAccount.id, gracePeriodSeconds: 60);

    setState(() => _isAuthenticated = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    // Auto-remask after 60 seconds
    _securityTimer?.cancel();
    _securityTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() => _isAuthenticated = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card grace period expired. Details re-masked.'),
          ),
        );
      }
    });
  }

  void _showPinModal() {
    String enteredPin = '';
    String? pinError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final profile = ref.read(profileControllerProvider).value;

          void onKeyPress(String digit) {
            if (enteredPin.length < 6) {
              setModalState(() {
                pinError = null;
                enteredPin += digit;
              });

              if (enteredPin.length == 6) {
                if (profile != null && PinUtils.verifyPin(enteredPin, profile.pinHash)) {
                  Navigator.pop(context);
                  _grantAuthentication('Authenticated with Security PIN!');
                } else {
                  setModalState(() {
                    enteredPin = '';
                    pinError = 'Incorrect Security PIN. Please try again.';
                  });
                }
              }
            }
          }

          void onBackspace() {
            if (enteredPin.isNotEmpty) {
              setModalState(() {
                pinError = null;
                enteredPin = enteredPin.substring(0, enteredPin.length - 1);
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security_rounded, color: AppTheme.primaryColor, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Enter Security PIN',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your 6-digit PIN to unmask sensitive card details',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
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
                        color: i < enteredPin.length ? AppTheme.primaryColor : Colors.white24,
                      ),
                    ),
                  ),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 12),
                  Text(pinError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinModalBtn(digit: '1', onTap: () => onKeyPress('1')),
                        _PinModalBtn(digit: '2', onTap: () => onKeyPress('2')),
                        _PinModalBtn(digit: '3', onTap: () => onKeyPress('3')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinModalBtn(digit: '4', onTap: () => onKeyPress('4')),
                        _PinModalBtn(digit: '5', onTap: () => onKeyPress('5')),
                        _PinModalBtn(digit: '6', onTap: () => onKeyPress('6')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PinModalBtn(digit: '7', onTap: () => onKeyPress('7')),
                        _PinModalBtn(digit: '8', onTap: () => onKeyPress('8')),
                        _PinModalBtn(digit: '9', onTap: () => onKeyPress('9')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 60, height: 60),
                        _PinModalBtn(digit: '0', onTap: () => onKeyPress('0')),
                        InkWell(
                          onTap: onBackspace,
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
              ],
            ),
          );
        },
      ),
    );
  }

  void _copyCardNumber() {
    if (!_isAuthenticated) {
      _authenticateUser();
      return;
    }
    Clipboard.setData(ClipboardData(text: _currentAccount.cardNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card number copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _toggleFreezeCard() async {
    final newStatus = _currentAccount.status == AccountStatus.active
        ? AccountStatus.frozen
        : AccountStatus.active;

    final result = await ref
        .read(transactionRepositoryProvider)
        .updateCardStatus(_currentAccount.id, newStatus);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      ),
      (_) {
        setState(() {
          _currentAccount = _currentAccount.copyWith(status: newStatus);
        });
        ref.invalidate(dashboardAccountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == AccountStatus.frozen
                  ? 'Card frozen successfully'
                  : 'Card unfrozen successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _setDefaultCard() async {
    final result = await ref
        .read(transactionRepositoryProvider)
        .setDefaultCard(_currentAccount.id);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      ),
      (_) {
        setState(() {
          _currentAccount = _currentAccount.copyWith(isDefault: true);
        });
        ref.invalidate(dashboardAccountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set as default payment card!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog() async {
    final controller =
        TextEditingController(text: _currentAccount.nickname ?? _currentAccount.label);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Card'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Card Nickname',
            hintText: 'e.g. Personal Shopping Card',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              Navigator.pop(context);

              final result = await ref
                  .read(transactionRepositoryProvider)
                  .updateCardNickname(_currentAccount.id, newName);

              result.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(f.message), backgroundColor: Colors.red),
                ),
                (_) {
                  setState(() {
                    _currentAccount = _currentAccount.copyWith(
                      nickname: newName.isEmpty ? null : newName,
                      label: newName.isEmpty ? _currentAccount.bankName : newName,
                    );
                  });
                  ref.invalidate(dashboardAccountsProvider);
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveCard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: Text(
          'Are you sure you want to unlink ${_currentAccount.label}? You can re-add it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ref
          .read(transactionRepositoryProvider)
          .removeCard(_currentAccount.id);

      result.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message), backgroundColor: Colors.red),
        ),
        (_) {
          ref.invalidate(dashboardAccountsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card unlinked successfully.')),
          );
          context.pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    final gradients = CardUtils.getCardGradient(
      _currentAccount.cardNetwork,
      _currentAccount.bankName,
    ).map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAccount.label),
        actions: [
          IconButton(
            icon: Icon(
              _isAuthenticated
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: _isAuthenticated ? theme.colorScheme.primary : null,
            ),
            onPressed: _onToggleDetails,
            tooltip: _isAuthenticated ? 'Hide Details' : 'Show Details (Auth)',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showRenameDialog,
            tooltip: 'Rename Card',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 3D FLIP CARD CONTAINER ────────────────────────────────
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isUnder = (angle > math.pi / 2);

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isUnder
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildCardBack(gradients),
                          )
                        : _buildCardFront(gradients),
                  );
                },
              ),
            ),

            const SizedBox(height: AppConstants.sm),

            Center(
              child: TextButton.icon(
                onPressed: _flipCard,
                icon: const Icon(Icons.flip_rounded, size: 16),
                label: Text(
                  _isFront ? 'Tap card to flip to back' : 'Tap card to flip to front',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.lg),

            // ── QUICK ACTIONS ROW ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: _isAuthenticated
                        ? Icons.content_copy_rounded
                        : Icons.lock_outline_rounded,
                    label: _isAuthenticated ? 'Copy Number' : 'Authenticate',
                    color: theme.colorScheme.primary,
                    onTap: _isAuthenticated ? _copyCardNumber : _authenticateUser,
                  ),
                ),
                const SizedBox(width: AppConstants.sm),
                Expanded(
                  child: _QuickActionButton(
                    icon: _currentAccount.status == AccountStatus.frozen
                        ? Icons.lock_open_rounded
                        : Icons.ac_unit_rounded,
                    label: _currentAccount.status == AccountStatus.frozen
                        ? 'Unfreeze'
                        : 'Freeze Card',
                    color: _currentAccount.status == AccountStatus.frozen
                        ? Colors.green
                        : Colors.orange,
                    onTap: _toggleFreezeCard,
                  ),
                ),
                const SizedBox(width: AppConstants.sm),
                Expanded(
                  child: _QuickActionButton(
                    icon: _currentAccount.isDefault
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    label: _currentAccount.isDefault ? 'Default Card' : 'Set Default',
                    color: _currentAccount.isDefault ? Colors.amber : Colors.grey,
                    onTap: _currentAccount.isDefault ? null : _setDefaultCard,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.xl),

            // ── CARD DETAILS SECTION ──────────────────────────────────
            Text(
              'Card Details & Status',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),

            AppCard(
              child: Column(
                children: [
                  _DetailRow(
                      label: 'Issuing Bank', value: _currentAccount.bankName),
                  const Divider(),
                  _DetailRow(
                    label: 'Card Type',
                    value:
                        '${_currentAccount.type.name.toUpperCase()} Card (${_currentAccount.isExternal ? 'Linked' : 'Primary'})',
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Network',
                    value: CardUtils.getNetworkName(_currentAccount.cardNetwork),
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Card Status',
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _currentAccount.status == AccountStatus.frozen
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentAccount.status == AccountStatus.frozen
                            ? 'FROZEN'
                            : 'ACTIVE',
                        style: TextStyle(
                          color: _currentAccount.status == AccountStatus.frozen
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (_currentAccount.linkedAt != null) ...[
                    const Divider(),
                    _DetailRow(
                      label: 'Linked On',
                      value: _currentAccount.linkedAt!.split('T').first,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppConstants.xl),

            // ── RECENT CARD TRANSACTIONS ─────────────────────────────
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.md),

            transactionsAsync.when(
              data: (list) {
                final cardTx = list
                    .where((t) => t.accountId == _currentAccount.id)
                    .take(5)
                    .toList();
                if (cardTx.isEmpty) {
                  return const AppCard(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.xl),
                      child: Center(
                        child: Text(
                          'No recent transactions for this card',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: cardTx
                      .map((t) => TransactionItem(transaction: t))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: AppConstants.xxl),

            // ── REMOVE CARD BUTTON ──────────────────────────────────
            if (_currentAccount.isExternal)
              AppButton(
                text: 'Unlink / Remove Card',
                variant: AppButtonVariant.outline,
                onPressed: _confirmRemoveCard,
              ),
            const SizedBox(height: AppConstants.xl),
          ],
        ),
      ),
    );
  }

  // ── FRONT OF CARD ──────────────────────────────────────────────────
  Widget _buildCardFront(List<Color> gradients) {
    return Container(
      height: 210,
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
            color: gradients.first.withOpacity(0.35),
            blurRadius: 18,
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
              Expanded(
                child: Text(
                  _currentAccount.bankName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  if (_currentAccount.status == AccountStatus.frozen)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FROZEN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  InkWell(
                    onTap: _onToggleDetails,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isAuthenticated
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      CardUtils.getNetworkName(_currentAccount.cardNetwork),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: PrivacySensitiveText(
              _isAuthenticated
                  ? _currentAccount.cardNumber
                  : CardUtils.maskCardNumber(_currentAccount.cardNumber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _currentAccount.holderName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentAccount.expiryDate,
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
    );
  }

  // ── BACK OF CARD ───────────────────────────────────────────────────
  Widget _buildCardBack(List<Color> gradients) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: gradients.first.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          // Magnetic Stripe
          Container(
            height: 38,
            width: double.infinity,
            color: const Color(0xFF111111),
          ),
          const SizedBox(height: 16),
          // Signature strip & CVV
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.xl),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 34,
                    color: Colors.white.withOpacity(0.87),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 12),
                    child: const Text(
                      'AUTHORIZED SIGNATURE',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                Container(
                  height: 34,
                  width: 56,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    _isAuthenticated ? _currentAccount.cvv : '•••',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Full number info
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.xl, 0, AppConstants.xl, AppConstants.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isAuthenticated
                          ? _currentAccount.cardNumber
                          : CardUtils.maskCardNumber(_currentAccount.cardNumber),
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _onToggleDetails,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _isAuthenticated
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, this.value, this.valueWidget});
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PinModalBtn extends StatelessWidget {
  const _PinModalBtn({required this.digit, required this.onTap});
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
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
