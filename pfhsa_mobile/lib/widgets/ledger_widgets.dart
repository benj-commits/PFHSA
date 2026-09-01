import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paperDim,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(), style: AppTextStyles.eyebrow(AppColors.mutedInk)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A single ledger-register row: label left, amount right in mono type,
/// with a hairline divider — evokes a checkbook register rather than
/// a generic Material ListTile.
class LedgerRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double amount;
  final bool isPositive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LedgerRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    this.isPositive = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final color = isPositive ? AppColors.pine : AppColors.ink;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body(15, weight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.body(12, color: AppColors.mutedInk)),
                  ],
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : '-'} ${formatter.format(amount)}',
              style: AppTextStyles.mono(15, color: color, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerDivider extends StatelessWidget {
  const LedgerDivider({super.key});
  @override
  Widget build(BuildContext context) => const Divider(height: 1);
}
