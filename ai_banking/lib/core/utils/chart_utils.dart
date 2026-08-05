import 'package:flutter/material.dart';

class ChartUtils {
  static Color getCategoryColor(int index, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.inversePrimary,
    ];
    return colors[index % colors.length];
  }
}
