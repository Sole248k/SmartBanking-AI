import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _barHeight = 56.0;
  static const _qrButtonSize = 48.0;
  static const _qrProtrusion = 18.0;

  static const _items = [
    _NavItemData(icon: Icons.dashboard, label: 'Home'),
    _NavItemData(icon: Icons.account_balance_wallet, label: 'Wallet'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Analytics'),
    _NavItemData(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;

    return Material(
      color: navTheme.backgroundColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: _qrProtrusion),
          child: SizedBox(
            height: _barHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _NavItem(
                        data: _items[0],
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        data: _items[1],
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                    Expanded(
                      child: _QrLabel(
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        data: _items[2],
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        data: _items[3],
                        isSelected: currentIndex == 4,
                        onTap: () => onTap(4),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -_qrProtrusion,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _QrCircleButton(
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final color = isSelected
        ? navTheme.selectedItemColor
        : navTheme.unselectedItemColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: (isSelected
                      ? navTheme.selectedLabelStyle
                      : navTheme.unselectedLabelStyle)
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrLabel extends StatelessWidget {
  const _QrLabel({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final color = isSelected
        ? navTheme.selectedItemColor
        : navTheme.unselectedItemColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24, width: 24),
            const SizedBox(height: 4),
            Text(
              'QR',
              style: (isSelected
                      ? navTheme.selectedLabelStyle
                      : navTheme.unselectedLabelStyle)
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCircleButton extends StatelessWidget {
  const _QrCircleButton({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppBottomNavBar._qrButtonSize,
          height: AppBottomNavBar._qrButtonSize,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.surface,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
