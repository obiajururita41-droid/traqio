import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/invoices/domain/entities/invoice_enums.dart';

class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const InvoiceStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case InvoiceStatus.draft: return Colors.grey;
      case InvoiceStatus.sent: return Colors.blue;
      case InvoiceStatus.partiallyPaid: return Colors.orange;
      case InvoiceStatus.paid: return Colors.green;
      case InvoiceStatus.overdue: return Colors.red;
      case InvoiceStatus.cancelled: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(status.label, style: theme.textTheme.labelSmall?.copyWith(color: _color)),
    );
  }
}
