import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/sales_orders/domain/entities/so_enums.dart';

class SoStatusBadge extends StatelessWidget {
  final SalesOrderStatus status;
  const SoStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case SalesOrderStatus.draft: return Colors.grey;
      case SalesOrderStatus.confirmed: return Colors.blue;
      case SalesOrderStatus.partiallyFulfilled: return Colors.orange;
      case SalesOrderStatus.fulfilled: return Colors.green;
      case SalesOrderStatus.cancelled: return Colors.red;
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
