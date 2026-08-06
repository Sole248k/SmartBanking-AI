import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/constants/app_constants.dart';

// ─── Mock data models ────────────────────────────────────────────────────────

class _Stock {
  const _Stock({
    required this.ticker,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.color,
  });
  final String ticker;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final Color color;
}

const _stocks = [
  _Stock(
    ticker: 'AAPL',
    name: 'Apple Inc.',
    price: 213.45,
    change: 2.87,
    changePercent: 1.36,
    color: Color(0xFF0A84FF),
  ),
  _Stock(
    ticker: 'TSLA',
    name: 'Tesla Inc.',
    price: 248.12,
    change: -4.33,
    changePercent: -1.71,
    color: Color(0xFFFF453A),
  ),
  _Stock(
    ticker: 'GOOGL',
    name: 'Alphabet Inc.',
    price: 177.89,
    change: 1.54,
    changePercent: 0.87,
    color: Color(0xFF30D158),
  ),
  _Stock(
    ticker: 'NVDA',
    name: 'NVIDIA Corp.',
    price: 875.60,
    change: 18.40,
    changePercent: 2.15,
    color: Color(0xFFFF9F0A),
  ),
];

// Chart data sets keyed by filter label
const _chartDataSets = {
  '1D': [62, 65, 63, 70, 68, 74, 72, 78, 76, 80, 79, 83],
  '1W': [55, 60, 58, 65, 63, 70, 68, 72, 70, 76, 74, 80],
  '1M': [40, 48, 45, 55, 52, 62, 60, 68, 65, 74, 72, 80],
  '1Y': [20, 30, 28, 40, 38, 52, 50, 62, 60, 72, 70, 80],
  'ALL': [5, 15, 12, 28, 25, 42, 40, 55, 52, 68, 65, 80],
};

const _filters = ['1D', '1W', '1M', '1Y', 'ALL'];

// ─── Screen ──────────────────────────────────────────────────────────────────

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  String _activeFilter = '1M';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            title: const Text('Invest'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: AppConstants.sm),
            ],
          ),

          // ── Portfolio header + chart ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.md, 0, AppConstants.md, AppConstants.md),
              child: _PortfolioCard(
                activeFilter: _activeFilter,
                isDark: isDark,
                onFilterChanged: (f) => setState(() => _activeFilter = f),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          ),

          // ── Section title ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.md, AppConstants.sm, AppConstants.md, AppConstants.xs),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Watchlist',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ── Stock list ───────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.md, vertical: AppConstants.xs),
                child: _StockCard(stock: _stocks[index], isDark: isDark)
                    .animate(delay: (index * 80).ms)
                    .fadeIn(duration: 350.ms)
                    .slideX(begin: 0.05, end: 0),
              ),
              childCount: _stocks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Portfolio card with chart ────────────────────────────────────────────────

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.activeFilter,
    required this.isDark,
    required this.onFilterChanged,
  });

  final String activeFilter;
  final bool isDark;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = _chartDataSets[activeFilter]!;
    final isUp = points.last >= points.first;
    final chartColor = isUp ? const Color(0xFF30D158) : const Color(0xFFFF453A);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance row
          const Text(
            'Total Portfolio',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppConstants.xs),
          const Text(
            '\$48,320.75',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppConstants.xs),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: chartColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isUp ? '+\$1,240.30 (2.64%)' : '-\$480.20 (-0.98%)',
                style: TextStyle(
                  color: chartColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Today',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.lg),

          // Chart
          SizedBox(
            height: 110,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        Colors.white.withValues(alpha: 0.15),
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '\$${(s.y * 600 + 44000).toStringAsFixed(0)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      points.length,
                      (i) => FlSpot(i.toDouble(), points[i].toDouble()),
                    ),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.md),

          // Filter tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _filters
                .map((f) => _FilterChip(
                      label: f,
                      isActive: f == activeFilter,
                      onTap: () => onFilterChanged(f),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMax),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Stock card ───────────────────────────────────────────────────────────────

class _StockCard extends StatelessWidget {
  const _StockCard({required this.stock, required this.isDark});

  final _Stock stock;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = stock.change >= 0;
    final changeColor =
        isPositive ? const Color(0xFF30D158) : const Color(0xFFFF453A);

    return Container(
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.04 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ticker badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stock.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              stock.ticker[0],
              style: TextStyle(
                color: stock.color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.md),

          // Name & ticker
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.ticker,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          // Price & change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 12,
                    color: changeColor,
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppConstants.md),

          // Buy button
          TextButton(
            onPressed: () => _showBuySheet(context, stock),
            style: TextButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            child: const Text(
              'Buy',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Buy bottom sheet ─────────────────────────────────────────────────────────

void _showBuySheet(BuildContext context, _Stock stock) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BuySheet(stock: stock),
  );
}

class _BuySheet extends StatefulWidget {
  const _BuySheet({required this.stock});
  final _Stock stock;

  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  int _shares = 1;
  bool _ordered = false;

  double get _total => _shares * widget.stock.price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppConstants.lg, AppConstants.md, AppConstants.lg, AppConstants.xl),
        child: _ordered ? _buildSuccess(theme) : _buildForm(theme, isDark),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: AppConstants.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppConstants.radiusMax),
          ),
        ),

        Text(
          'Buy ${widget.stock.ticker}',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.xs),
        Text(
          widget.stock.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppConstants.xl),

        // Current price chip
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.md, vertical: AppConstants.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart_rounded,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Market price  \$${widget.stock.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.xl),

        // Share stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              onTap: () {
                if (_shares > 1) setState(() => _shares--);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.xl),
              child: Column(
                children: [
                  Text(
                    '$_shares',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _shares == 1 ? 'share' : 'shares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            _StepperButton(
              icon: Icons.add_rounded,
              onTap: () => setState(() => _shares++),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.xl),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Estimated Total',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
            Text(
              '\$${_total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.lg),

        // Confirm button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _ordered = true),
            child: Text('Confirm Purchase · \$${_total.toStringAsFixed(2)}'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppConstants.lg),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF30D158),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 36),
        ).animate().scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 600.ms,
            ),
        const SizedBox(height: AppConstants.lg),
        Text(
          'Order Placed!',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.sm),
        Text(
          'You bought $_shares ${_shares == 1 ? 'share' : 'shares'} of '
          '${widget.stock.ticker} for \$${_total.toStringAsFixed(2)}.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppConstants.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
        const SizedBox(height: AppConstants.sm),
      ],
    );
  }
}

// ─── Stepper button ───────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMax),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon, size: 22, color: theme.colorScheme.primary),
      ),
    );
  }
}
