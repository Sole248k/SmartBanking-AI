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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.accounts.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              ref.read(activeAccountProvider.notifier).select(widget.accounts[index]);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.hasClients && _pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 220,
                      width: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.sm),
                  child: BalanceCard(
                    account: widget.accounts[index],
                    onTap: () => context.push('/account-details', extra: widget.accounts[index]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.accounts.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
