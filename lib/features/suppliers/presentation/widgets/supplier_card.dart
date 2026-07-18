import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier.dart';
import 'package:traqio/features/suppliers/domain/entities/supplier_enums.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;

  const SupplierCard({super.key, required this.supplier, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final typeColor = supplier.supplierType == SupplierType.international
        ? Colors.purple
        : theme.colorScheme.primary;

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
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
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
                        child: Text(supplier.name, style: theme.textTheme.titleMedium,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(supplier.supplierType.label,
                            style: theme.textTheme.labelSmall?.copyWith(color: typeColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    supplier.contactPerson ?? supplier.phone ?? 'No contact info',
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
                  currency.format(supplier.outstandingBalance),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: supplier.outstandingBalance > 0 ? theme.colorScheme.error : Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text('you owe', style: theme.textTheme.labelSmall?.copyWith(
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
