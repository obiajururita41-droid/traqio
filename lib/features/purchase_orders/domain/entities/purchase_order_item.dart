import 'package:equatable/equatable.dart';

class PurchaseOrderItem extends Equatable {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final String? productName;
  final double quantityOrdered;
  final double quantityReceived;
  final double unitCost;
  final double taxRate;
  final double lineTotal;

  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    this.productName,
    required this.quantityOrdered,
    this.quantityReceived = 0,
    required this.unitCost,
    this.taxRate = 0,
    this.lineTotal = 0,
  });

  double get remainingQuantity => quantityOrdered - quantityReceived;
  bool get isFullyReceived => quantityReceived >= quantityOrdered;
  bool get isPartiallyReceived => quantityReceived > 0 && !isFullyReceived;

  @override
  List<Object?> get props => [
        id, purchaseOrderId, productId, productName, quantityOrdered,
        quantityReceived, unitCost, taxRate, lineTotal,
      ];
}
