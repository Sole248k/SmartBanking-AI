import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../dashboard/models/transaction.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../dashboard/providers/active_account_provider.dart';

enum TransactionSortOption { newest, oldest, highestAmount, lowestAmount }

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategoryFilter = 'All';
  String _selectedTypeFilter = 'All';
  TransactionSortOption _sortOption = TransactionSortOption.newest;

  static const List<String> _categoryFilters = [
    'All',
    'Transfer',
    'Deposit',
    'Card Management',
    'Wallet',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterAndSortTransactions(List<Transaction> transactions) {
    final query = _searchController.text.trim().toLowerCase();

    return transactions.where((t) {
      // 1. Search Query
      if (query.isNotEmpty) {
        final matchesRef = (t.referenceNumber ?? '').toLowerCase().contains(query);
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesDesc = t.description.toLowerCase().contains(query);
        final matchesRecipient = (t.recipientName ?? '').toLowerCase().contains(query);
        final matchesSender = (t.senderName ?? '').toLowerCase().contains(query);
        final matchesBank = (t.targetBank ?? '').toLowerCase().contains(query);
        final matchesNote = (t.note ?? '').toLowerCase().contains(query);

        if (!matchesRef &&
            !matchesTitle &&
            !matchesDesc &&
            !matchesRecipient &&
            !matchesSender &&
            !matchesBank &&
            !matchesNote) {
          return false;
        }
      }

      // 2. Category Filter
      if (_selectedCategoryFilter != 'All') {
        if (t.category.toLowerCase() != _selectedCategoryFilter.toLowerCase()) {
          return false;
        }
      }

      // 3. Type Filter
      if (_selectedTypeFilter == 'Credit (+)' && t.type != TransactionType.credit) {
        return false;
      }
      if (_selectedTypeFilter == 'Debit (-)' && t.type != TransactionType.debit) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortOption) {
          case TransactionSortOption.newest:
            return b.date.compareTo(a.date);
          case TransactionSortOption.oldest:
            return a.date.compareTo(b.date);
          case TransactionSortOption.highestAmount:
            return b.amount.compareTo(a.amount);
          case TransactionSortOption.lowestAmount:
            return a.amount.compareTo(b.amount);
        }
      });
  }

  bool _filterByActiveAccount = true;

  @override
  Widget build(BuildContext context) {
    final transactionsStream = ref.watch(transactionRepositoryProvider).watchRecentTransactions();
    final activeAccount = ref.watch(activeAccountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          PopupMenuButton<TransactionSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort By',
            onSelected: (opt) => setState(() => _sortOption = opt),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TransactionSortOption.newest,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: TransactionSortOption.oldest,
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: TransactionSortOption.highestAmount,
                child: Text('Highest Amount'),
              ),
              const PopupMenuItem(
                value: TransactionSortOption.lowestAmount,
                child: Text('Lowest Amount'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Active Card Filter Banner (If applicable) ────────────
          if (activeAccount != null && _filterByActiveAccount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.md, vertical: 8),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered by ${activeAccount.label} (${activeAccount.cardNumber.length >= 4 ? "**** ${activeAccount.cardNumber.substring(activeAccount.cardNumber.length - 4)}" : activeAccount.accountNumber})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _filterByActiveAccount = false),
                    child: const Text('Show All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // ── Search & Filter Bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.md,
              AppConstants.sm,
              AppConstants.md,
              AppConstants.xs,
            ),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  hint: 'Search ref #, recipient, bank, note...',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppConstants.xs),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoryFilters.map((cat) {
                      final isSelected = _selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategoryFilter = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Transaction List Stream ────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Transaction>>(
              stream: transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var rawList = snapshot.data!;
                if (activeAccount != null && _filterByActiveAccount) {
                  final accId = activeAccount.id;
                  final accNum = activeAccount.accountNumber;
                  final cardNum = activeAccount.cardNumber;

                  rawList = rawList.where((t) {
                    if (t.accountId == accId) return true;
                    if (accNum.isNotEmpty && t.targetAccount == accNum) return true;
                    if (cardNum.isNotEmpty && t.targetAccount == cardNum) return true;
                    if (accNum.isNotEmpty && t.senderAccount == accNum) return true;
                    if (cardNum.isNotEmpty && t.senderAccount == cardNum) return true;
                    return false;
                  }).toList();
                }
                final filtered = _filterAndSortTransactions(rawList);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: AppConstants.md),
                        const Text(
                          'No transactions found',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try adjusting your search or filters.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: AppConstants.screenPadding,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppConstants.sm),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isCredit = item.type == TransactionType.credit;

                    return AppCard(
                      onTap: () => context.push(
                        '/transactions/details',
                        extra: item,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.sm),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isCredit ? Colors.green : Colors.blue)
                                    .withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isCredit ? Colors.green : Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppConstants.md),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.date.day}/${item.date.month}/${item.date.year} • ${item.category}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Amount & Status Badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isCredit ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCredit ? Colors.green : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.green.shade400,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
