import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/payments/domain/entities/payment.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';
import 'package:traqio/features/payments/presentation/widgets/payment_type_badge.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;

  const PaymentCard({super.key, required this.payment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');
    final isInflow = payment.paymentType == PaymentType.customerReceipt;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (isInflow ? Colors.green : Colors.blue).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInflow ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isInflow ? Colors.green : Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(payment.counterpartyName, style: theme.textTheme.titleMedium,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      PaymentTypeBadge(type: payment.paymentType),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.paymentNumber} · ${dateFormat.format(payment.paymentDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${isInflow ? '+' : '-'}${currency.format(payment.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isInflow ? Colors.green : Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
