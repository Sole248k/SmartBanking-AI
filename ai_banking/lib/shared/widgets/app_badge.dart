import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';

enum AppBadgeVariant { success, error, warning, info, neutral }

class AppBadge extends StatelessWidget {

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
  });
  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AppBadgeVariant.success:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case AppBadgeVariant.error:
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      case AppBadgeVariant.warning:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        break;
      case AppBadgeVariant.info:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case AppBadgeVariant.neutral:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.sm,
        vertical: AppConstants.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
