import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/sales_orders/domain/entities/sales_order.dart';
import 'package:traqio/features/sales_orders/presentation/widgets/so_status_badge.dart';

class SoCard extends StatelessWidget {
  final SalesOrder so;
  final VoidCallback? onTap;

  const SoCard({super.key, required this.so, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: so.isOverdue ? theme.colorScheme.error : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(so.soNumber, style: theme.textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SoStatusBadge(status: so.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              so.customerName ?? 'Unknown customer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dateFormat.format(so.orderDate)}${so.isOverdue ? ' · Overdue' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: so.isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(currency.format(so.totalAmount), style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
