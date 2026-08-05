import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';

class BalanceCard extends StatelessWidget {

  const BalanceCard({super.key, required this.account, this.onTap});
  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Color> gradientColors = account.cardGradientColors.map((hex) {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    }).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GlassCard(
          opacity: 0.1,
          blur: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        account.type.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  _getNetworkIcon(account.cardNetwork),
                ],
              ),
              const Spacer(),
              PrivacySensitiveText(
                '${account.currency} ${account.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrivacySensitiveText(
                    account.accountNumber,
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    account.expiryDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNetworkIcon(CardNetwork network) {
    IconData iconData;
    switch (network) {
      case CardNetwork.visa:
        iconData = Icons.credit_card;
        break;
      case CardNetwork.mastercard:
        iconData = Icons.payment;
        break;
      default:
        iconData = Icons.credit_card;
    }
    return Icon(iconData, color: Colors.white, size: 32);
  }
}
