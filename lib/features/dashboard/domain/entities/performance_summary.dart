import 'package:equatable/equatable.dart';

class TopProduct extends Equatable {
  final String name;
  final int unitsSold;
  final double revenue;

  const TopProduct({
    required this.name,
    required this.unitsSold,
    required this.revenue,
  });

  @override
  List<Object?> get props => [name, unitsSold, revenue];
}

class TopCustomer extends Equatable {
  final String name;
  final double totalSpent;
  final int ordersCount;

  const TopCustomer({
    required this.name,
    required this.totalSpent,
    required this.ordersCount,
  });

  @override
  List<Object?> get props => [name, totalSpent, ordersCount];
}

class PerformanceSummary extends Equatable {
  final List<TopProduct> topProducts;
  final List<TopCustomer> topCustomers;
  final double monthlyProfit;
  final double monthlyExpenses;

  const PerformanceSummary({
    required this.topProducts,
    required this.topCustomers,
    required this.monthlyProfit,
    required this.monthlyExpenses,
  });

  @override
  List<Object?> get props =>
      [topProducts, topCustomers, monthlyProfit, monthlyExpenses];
}
