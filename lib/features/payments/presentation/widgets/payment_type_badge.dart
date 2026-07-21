import 'package:flutter/material.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/features/payments/domain/entities/payment_enums.dart';

class PaymentTypeBadge extends StatelessWidget {
  final PaymentType type;
  const PaymentTypeBadge({super.key, required this.type});

  Color get _color {
    switch (type) {
      case PaymentType.customerReceipt: return Colors.green;
      case PaymentType.supplierPayment: return Colors.blue;
      case PaymentType.refund: return Colors.orange;
      case PaymentType.adjustment: return Colors.grey;
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
      child: Text(type.label, style: theme.textTheme.labelSmall?.copyWith(color: _color)),
    );
  }
}
