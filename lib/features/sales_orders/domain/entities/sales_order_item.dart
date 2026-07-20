import 'package:equatable/equatable.dart';

class SalesOrderItem extends Equatable {
  final String id;
  final String salesOrderId;
  final String productId;
  final String? productName;
  final double quantityOrdered;
  final double quantityFulfilled;
  final double unitPrice;
  final double taxRate;
  final double lineTotal;

  const SalesOrderItem({
    required this.id,
    required this.salesOrderId,
    required this.productId,
    this.productName,
    required this.quantityOrdered,
    this.quantityFulfilled = 0,
    required this.unitPrice,
    this.taxRate = 0,
    this.lineTotal = 0,
  });

  double get remainingQuantity => quantityOrdered - quantityFulfilled;
  bool get isFullyFulfilled => quantityFulfilled >= quantityOrdered;
  bool get isPartiallyFulfilled => quantityFulfilled > 0 && !isFullyFulfilled;

  @override
  List<Object?> get props => [
        id, salesOrderId, productId, productName, quantityOrdered,
        quantityFulfilled, unitPrice, taxRate, lineTotal,
      ];
}
