import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/privacy_provider.dart';

class PrivacySensitiveText extends ConsumerWidget {

  const PrivacySensitiveText(
    this.text, {
    super.key,
    this.style,
    this.mask = '••••••',
  });
  final String text;
  final TextStyle? style;
  final String mask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyModeProvider);
    
    return Text(
      isPrivate ? mask : text,
      style: style,
    );
  }
}
