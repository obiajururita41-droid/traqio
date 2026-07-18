import 'package:equatable/equatable.dart';

/// Business-wide inventory snapshot for Dashboard integration.
/// Computed from Products directly (current_stock * cost_price),
/// with a documented upgrade path to true FIFO layer valuation once
/// the movement history has enough volume to support it.
class StockValuation extends Equatable {
  final double totalStockValue;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalProductCount;

  const StockValuation({
    required this.totalStockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalProductCount,
  });

  @override
  List<Object?> get props =>
      [totalStockValue, lowStockCount, outOfStockCount, totalProductCount];
}
