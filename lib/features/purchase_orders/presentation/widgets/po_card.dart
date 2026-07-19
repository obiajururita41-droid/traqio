import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/purchase_orders/domain/entities/purchase_order.dart';
import 'package:traqio/features/purchase_orders/presentation/widgets/po_status_badge.dart';

class PoCard extends StatelessWidget {
  final PurchaseOrder po;
  final VoidCallback? onTap;

  const PoCard({super.key, required this.po, this.onTap});

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
            color: po.isOverdue ? theme.colorScheme.error : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(po.poNumber, style: theme.textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                PoStatusBadge(status: po.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              po.supplierName ?? 'Unknown supplier',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dateFormat.format(po.orderDate)}${po.isOverdue ? ' · Overdue' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: po.isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(currency.format(po.totalAmount), style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
