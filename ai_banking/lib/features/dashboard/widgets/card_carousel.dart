import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../providers/active_account_provider.dart';
import 'balance_card.dart';

/// Horizontal swipeable card carousel on dashboard.
///
/// Features:
///   - Mouse drag, trackpad, and touch drag support.
///   - Previous / Next arrow navigation buttons for desktop users.
///   - Mouse wheel horizontal scroll listener.
///   - Smooth active page scaling effect.
///   - Displays all linked cards (SmartBank accounts + linked external cards).
///   - Includes a dedicated Wallet Card and an "+ Add Card" item at the end.
class CardCarousel extends ConsumerStatefulWidget {
  const CardCarousel({super.key, required this.accounts});
  final List<Account> accounts;

  @override
  ConsumerState<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends ConsumerState<CardCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int totalItems) {
    if (_currentPage < totalItems - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAccount = ref.watch(activeAccountProvider);

    // Sort accounts so that Default card is always at index 0

    final sortedAccounts = List<Account>.from(widget.accounts)
      ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));

    int targetIdx = 0;
    if (activeAccount != null) {
      final idx = sortedAccounts.indexWhere((a) => a.id == activeAccount.id);
      if (idx != -1) targetIdx = idx;
    } else if (sortedAccounts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeAccountProvider.notifier).select(sortedAccounts.first);
      });
    }

    // Sync PageController position ONLY if viewing a bank account index and out of sync
    if (_pageController.hasClients &&
        _currentPage < sortedAccounts.length &&
        _pageController.page?.round() != targetIdx &&
        _currentPage != targetIdx) {
      _currentPage = targetIdx;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(targetIdx);
        }
      });
    }

    final walletCardIdx = sortedAccounts.length;
    final addCardIdx = sortedAccounts.length + 1;
    final totalItems = sortedAccounts.length + 2;
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 210,
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    if (pointerSignal.scrollDelta.dx > 0 ||
                        pointerSignal.scrollDelta.dy > 0) {
                      _nextPage(totalItems);
                    } else if (pointerSignal.scrollDelta.dx < 0 ||
                        pointerSignal.scrollDelta.dy < 0) {
                      _previousPage();
                    }
                  }
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalItems,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      if (index < sortedAccounts.length) {
                        ref
                            .read(activeAccountProvider.notifier)
                            .select(sortedAccounts[index]);
                      }
                    },
                    itemBuilder: (context, index) {
                      final isWalletCard = index == walletCardIdx;
                      final isAddCard = index == addCardIdx;

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.hasClients &&
                              _pageController.position.haveDimensions) {
                            value =
                                (_pageController.page ??
                                    _currentPage.toDouble()) -
                                index;
                            value = (1 - (value.abs() * 0.1)).clamp(0.85, 1.0);
                          }
                          return Center(
                            child: Transform.scale(scale: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.sm,
                          ),
                          child: isWalletCard
                              ? const _WalletCard()
                              : isAddCard
                              ? _buildAddCardItem(context, theme)
                              : BalanceCard(
                                  account: sortedAccounts[index],
                                  onTap: () => context.push(
                                    '/card-management/details',
                                    extra: sortedAccounts[index],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Left Navigation Arrow Button
            if (_currentPage > 0)
              Positioned(
                left: 4,
                child: _ArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: _previousPage,
                ),
              ),

            // Right Navigation Arrow Button
            if (_currentPage < totalItems - 1)
              Positioned(
                right: 4,
                child: _ArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => _nextPage(totalItems),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.md),

        // Carousel Page Indicators (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalItems,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardItem(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => context.push('/card-management/add'),
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.md),
            Text(
              'Link New Card',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add debit or credit cards from other banks',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  const _WalletCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletControllerProvider);

    return InkWell(
      onTap: () => context.push('/wallet'),
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A00E0).withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: GlassCard(
            opacity: 0.15,
            blur: 15,
            child: walletAsync.when(
              data: (wallet) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SmartBank Wallet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'DIGITAL WALLET',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.amberAccent,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          PrivacySensitiveText(
                            CurrencyFormatter.format(wallet.balance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Available',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          PrivacySensitiveText(
                            CurrencyFormatter.format(wallet.balance),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WAL-${wallet.id.length >= 8 ? wallet.id.substring(0, 8).toUpperCase() : '88219041'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push('/wallet'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Wallet Details',
                                style: TextStyle(
                                  color: Color(0xFF4A00E0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: Color(0xFF4A00E0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error loading wallet: $err',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
