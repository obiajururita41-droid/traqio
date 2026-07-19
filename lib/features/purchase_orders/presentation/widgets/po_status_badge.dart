import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/purchase_orders/domain/entities/po_enums.dart';

class PoStatusBadge extends StatelessWidget {
  final PurchaseOrderStatus status;
  const PoStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case PurchaseOrderStatus.draft: return Colors.grey;
      case PurchaseOrderStatus.sent: return Colors.blue;
      case PurchaseOrderStatus.partiallyReceived: return Colors.orange;
      case PurchaseOrderStatus.received: return Colors.green;
      case PurchaseOrderStatus.cancelled: return Colors.red;
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
