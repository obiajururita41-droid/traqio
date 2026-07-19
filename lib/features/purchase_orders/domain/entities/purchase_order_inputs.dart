import 'package:equatable/equatable.dart';

/// Plain input used when creating/editing a PO — no id yet, no
/// receiving info, just what the user is ordering.
class PurchaseOrderItemInput {
  final String productId;
  final double quantityOrdered;
  final double unitCost;
  final double taxRate;

  const PurchaseOrderItemInput({
    required this.productId,
    required this.quantityOrdered,
    required this.unitCost,
    this.taxRate = 0,
  });
}

/// One line of a receiving action: how much of a specific PO item
/// is being received right now (supports partial receiving).
class ReceiptInput {
  final String itemId;
  final double quantityToReceive;

  const ReceiptInput({required this.itemId, required this.quantityToReceive});
}

class PurchaseOrderMetrics extends Equatable {
  final int openOrdersCount;
  final int overdueCount;
  final double pendingValue;

  const PurchaseOrderMetrics({
    required this.openOrdersCount,
    required this.overdueCount,
    required this.pendingValue,
  });

  @override
  List<Object?> get props => [openOrdersCount, overdueCount, pendingValue];
}
