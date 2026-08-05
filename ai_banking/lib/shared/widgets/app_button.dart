import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../app/constants/app_constants.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? backgroundColor;
    Color? foregroundColor;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        border = BorderSide(color: colorScheme.primary, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
    }

    if (isDisabled || onPressed == null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
      border = border?.copyWith(color: border.color.withValues(alpha: 0.5));
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: MaterialButton(
        onPressed: (isLoading || isDisabled)
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        color: backgroundColor,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: border ?? BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg),
        child: isLoading
            ? SpinKitThreeBounce(
                color: foregroundColor,
                size: 20,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: foregroundColor),
                    const SizedBox(width: AppConstants.sm),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
