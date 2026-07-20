import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/invoices/domain/entities/invoice.dart';
import 'package:traqio/features/invoices/presentation/widgets/invoice_status_badge.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceCard({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y');
    final effectiveStatus = invoice.effectiveStatus;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: effectiveStatus.name == 'overdue' ? theme.colorScheme.error : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(invoice.invoiceNumber, style: theme.textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                InvoiceStatusBadge(status: effectiveStatus),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              invoice.customerName ?? 'Unknown customer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.dueDate != null ? 'Due ${dateFormat.format(invoice.dueDate!)}' : dateFormat.format(invoice.issueDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currency.format(invoice.totalAmount), style: theme.textTheme.titleMedium),
                    if (invoice.balanceDue > 0 && invoice.balanceDue < invoice.totalAmount)
                      Text(
                        '${currency.format(invoice.balanceDue)} due',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
