import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';
import '../providers/active_account_provider.dart';
import 'balance_card.dart';

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
    // Sort accounts so that Default card is always at index 0
    final sortedAccounts = List<Account>.from(widget.accounts)
      ..sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));

    final totalItems = sortedAccounts.length + 1;
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
                      final isAddCard = index == sortedAccounts.length;

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.hasClients &&
                              _pageController.position.haveDimensions) {
                            value = (_pageController.page ?? _currentPage.toDouble()) - index;
                            value = (1 - (value.abs() * 0.1)).clamp(0.85, 1.0);
                          }
                          return Center(
                            child: Transform.scale(
                              scale: value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.sm),
                          child: isAddCard
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
                    : theme.colorScheme.primary.withOpacity(0.2),
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
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
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
            color: theme.colorScheme.surface.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Icon(
            icon,
            size: 22,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}