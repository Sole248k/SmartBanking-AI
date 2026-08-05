import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/constants/app_constants.dart';

class AppShimmer extends StatelessWidget {

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppConstants.radiusMd,
  });

  const AppShimmer.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
