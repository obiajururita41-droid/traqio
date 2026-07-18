import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/customers/domain/entities/customer.dart';
import 'package:traqio/features/customers/domain/entities/customer_enums.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCard({super.key, required this.customer, this.onTap});

  Color _typeColor(BuildContext context) {
    switch (customer.customerType) {
      case CustomerType.vip: return Colors.purple;
      case CustomerType.wholesale: return Colors.blue;
      case CustomerType.retail: return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final typeColor = _typeColor(context);

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
            CircleAvatar(
              radius: 22,
              backgroundColor: typeColor.withValues(alpha: 0.12),
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(color: typeColor),
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
                        child: Text(customer.name, style: theme.textTheme.titleMedium,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(customer.customerType.label,
                            style: theme.textTheme.labelSmall?.copyWith(color: typeColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.phone ?? customer.email ?? 'No contact info',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(customer.outstandingBalance),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: customer.outstandingBalance > 0 ? theme.colorScheme.error : Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text('owed', style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
