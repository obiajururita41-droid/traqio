import 'package:equatable/equatable.dart';

class SalesOrderItemInput {
  final String productId;
  final double quantityOrdered;
  final double unitPrice;
  final double taxRate;

  const SalesOrderItemInput({
    required this.productId,
    required this.quantityOrdered,
    required this.unitPrice,
    this.taxRate = 0,
  });
}

class FulfillmentInput {
  final String itemId;
  final double quantityToFulfill;

  const FulfillmentInput({required this.itemId, required this.quantityToFulfill});
}

class SalesOrderMetrics extends Equatable {
  final int openOrdersCount;
  final int overdueCount;
  final double pendingValue;

  const SalesOrderMetrics({
    required this.openOrdersCount,
    required this.overdueCount,
    required this.pendingValue,
  });

  @override
  List<Object?> get props => [openOrdersCount, overdueCount, pendingValue];
}
